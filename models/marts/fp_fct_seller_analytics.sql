with orders_with_one_seller as (
  SELECT 
  order_items[0].seller.seller_id as seller_id,
  order_items[0].seller.seller_city as seller_city,
  order_items[0].seller.seller_state as seller_state,
    *
FROM {{ ref('fp_sales_full') }}
WHERE (
  SELECT COUNT(DISTINCT  element.seller.seller_id)
  FROM UNNEST(order_items) AS element
) = 1
)
SELECT 
seller_id,
count(*) as orders_count,
sum(order_total_amount) as total_sold_amount,
APPROX_QUANTILES(order_total_amount, 2)[1] as median_order_total,
concat(round(countif(is_canceled)/count(*)*100,2), "%") as canceled_orders,
concat(round(countif(is_shipped)/count(*)*100,2), "%")  as shipped_orders,
concat(round(countif(is_delivered_after_estimated)/count(*)*100,2), "%")  as orders_delivered_with_delay,
APPROX_QUANTILES(diff_approved_purchased_d, 2)[1] as median_approval_time_in_days,
APPROX_QUANTILES(diff_shipped_purchased_d, 2)[1] as median_shipping_time_in_days,
APPROX_QUANTILES(diff_delivered_to_estimated_d, 2)[1] as median_delay_in_delivery_days
FROM orders_with_one_seller
group by seller_id
order by orders_count desc