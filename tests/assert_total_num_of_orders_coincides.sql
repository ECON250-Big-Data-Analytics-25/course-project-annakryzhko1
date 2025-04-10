-- Checks that total orders count 
-- in fp_fct_sales_stats_all and fp_sales_full are the same

with sales_mart_total as (
    select
        sum(orders_count) as mart_orders_count
    from {{ ref("fp_fct_sales_stats_all") }}
), sales_full_total as (
    select
       count(*) as full_orders_count
    from {{ ref("fp_sales_full") }}
)

select *
from sales_mart_total cross join sales_full_total
where full_orders_count != mart_orders_count

