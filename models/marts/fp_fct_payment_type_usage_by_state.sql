with payments_data_by_state as (
  SELECT 
    EXTRACT(year FROM order_purchase_timestamp) AS order_year,
    payments.payment_installments as installments,
    payments.payment_type as payment_type,
    payments.payment_sequential as payment_sequential,
    customer.customer_state as state
  FROM {{ ref('fp_sales_full') }}, unnest(order_payments) as payments
  where order_purchase_timestamp >=  TIMESTAMP("2017-01-01")
),
payments_type as (
  select distinct payment_type  
  from {{ ref('fp_stg_order_payments') }}
  where payment_type!="not_defined"
),
calculated_data as (
  select
p.payment_type as payment_type,
order_year,
state, 
round(countif(s.payment_type = p.payment_type)/count(*)*100,2) as used_in_orders
FROM payments_data_by_state as s
cross join payments_type as p 
group by  payment_type, order_year, state
order by  payment_type,  state desc, order_year asc
)

select * 
from calculated_data
pivot(sum(used_in_orders) FOR state IN ("AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG", "MS", "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC", "SE", "SP", "TO"))
order by payment_type, order_year asc