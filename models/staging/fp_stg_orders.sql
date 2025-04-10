 {{
  config(
    materialized='table'
  )
}}

select 
order_id, customer_id, order_status,
order_status='canceled' as is_canceled,
order_delivered_carrier_date is not null as is_shipped,
order_delivered_customer_date is not null as is_delivered,
TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, day) > 0 as is_delivered_after_estimated,
TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, day) as diff_delivered_purchased_d,
TIMESTAMP_DIFF(order_delivered_carrier_date, order_purchase_timestamp, day) as diff_shipped_purchased_d,
TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, day) as diff_approved_purchased_d,
TIMESTAMP_DIFF(order_delivered_customer_date, order_delivered_carrier_date, day) as diff_delivered_by_carrier_d,
TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, day) as diff_delivered_to_estimated_d,
 order_purchase_timestamp,
 order_approved_at,
 order_delivered_carrier_date,
 order_delivered_customer_date,
 order_estimated_delivery_date
from {{ source('fp', 'fp_orders')}}