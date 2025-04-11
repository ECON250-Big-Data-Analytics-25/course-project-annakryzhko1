with stat as (
select 
    EXTRACT(year FROM order_purchase_timestamp) AS order_year,
    EXTRACT(month FROM order_purchase_timestamp) AS order_month,
    count(*) as orders_count,
    round(sum(order_total_amount),2) as ordered_total,
    round(sum(order_payment_total),2) as paid_total,
    round(avg(order_total_amount),2) as ordered_mean,
    round(avg(order_payment_total), 2) as paid_mean,
    APPROX_QUANTILES(order_total_amount, 2)[1] as ordered_median,
    APPROX_QUANTILES(order_payment_total,2)[1] as paid_median,
    min(order_total_amount) as ordered_min,
    min(order_payment_total) as paid_min,
    max(order_total_amount) as ordered_max,
    max(order_payment_total) as paid_max,
    
   from {{ ref("fp_sales_full") }}
   group by order_year, order_month
   order by order_year, order_month
)

select 
order_year,
format_date('%B', date(order_year, order_month, 1)) as order_month1,
orders_count,
concat(round((orders_count/lag(orders_count, 12) over (ORDER BY order_year, order_month) - 1)*100, 2), "%" )  as yoy_count,
ordered_total,
concat(round((ordered_total/lag(ordered_total, 12) over (ORDER BY order_year, order_month) - 1)*100, 2), "%" )  as yoy_ordered_total,
paid_total,
concat(round((paid_total/lag(paid_total, 12) over (ORDER BY order_year, order_month) - 1)*100, 2), "%" ) as yoy_paid_total,
ordered_median,
paid_median,
ordered_mean,
paid_mean,
ordered_min,
paid_min,
ordered_max,
paid_max,
from stat 
order by order_year, order_month