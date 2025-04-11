{{
  config(
    materialized = "table",
    cluster_by = "order_id",
  )
}}

select 
order_id, 
payment_sequential,
payment_type,
if(payment_type = "credit_card" and payment_installments = 0, 1, payment_installments) as payment_installments, 
cast(payment_value as numeric) as payment_value
from {{ source('fp', 'fp_order_payments')}}
