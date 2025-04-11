
{{
  config(
    materialized = 'table',
    partition_by = {
      "field": "order_purchase_timestamp",
      "data_type": "timestamp",
      "granularity": "month"   
    },
    cluster_by = "order_status",
    partition_expiration_days = 366 * 20
    )
}}

with cte_products_extended as (
    select 
    product_id,
    product_description,
    product_measurements,
    struct(
        product_category_name,
        en,
        pt
    ) as product_category 
    from {{ ref('fp_stg_products')}} 
    left join {{ ref('fp_stg_product_category_name_translation')}}
    using(product_category_name)
),

cte_orders_items as(
    select 
    order_id,
    order_item_id,
    struct(
        product_id,
        product_description,
        product_measurements,
        product_category
        ) as product,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    total_amount
    from {{ ref('fp_stg_order_items')}} 
    left join cte_products_extended
    using(product_id)
),
cte_order_items_by_order as (
    select order_id,
    array_agg(struct(
        order_item_id,
        product,
        struct(
            seller_id,
            seller_city,
            seller_state,
            seller_zip_code_prefix
        ) as seller,
        shipping_limit_date,
        price,
        freight_value,
        total_amount
    ) order by order_item_id) as order_items,
    round(sum(total_amount),2) as order_total_amount
    from cte_orders_items
    left join {{ ref('fp_stg_sellers')}} using(seller_id)
    group by order_id
),
cte_order_payments_by_order as (
    select order_id,
    array_agg(
        struct(
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value
        ) order by payment_sequential) as order_payments,
    round(sum(payment_value),2) as order_payment_total
    from {{ ref('fp_stg_order_payments')}} 
    group by order_id
)
select 
order_id, 
struct(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
) as customer, 
order_status,
is_canceled,
is_shipped,
is_delivered,
is_delivered_after_estimated,
diff_delivered_purchased_d,
diff_shipped_purchased_d,
diff_approved_purchased_d,
diff_delivered_by_carrier_d,
diff_delivered_to_estimated_d,
order_purchase_timestamp,
order_approved_at,
order_delivered_carrier_date,
order_delivered_customer_date,
order_estimated_delivery_date,
order_items,
order_total_amount,
order_payments,
order_payment_total
from  {{ ref('fp_stg_orders')}}
left join cte_order_items_by_order using (order_id)
left join {{ ref('fp_stg_customers')}} using (customer_id)
left join cte_order_payments_by_order using(order_id)
