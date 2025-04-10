{{
  config(
    materialized = "table",
    cluster_by = "order_id",
  )
}}

select 
order_id,
order_item_id,
product_id,
seller_id,
shipping_limit_date,
price,
freight_value,
round(price  + freight_value, 2) as total_amount
from {{ source('fp', 'fp_order_items')}}
