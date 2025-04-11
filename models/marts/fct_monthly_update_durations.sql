{{ config(materialized='table')}}

SELECT 
EXTRACT(month from published_date) as published_month,
round(avg(days_until_updated)) avg_update_period_total,
round(avg(if(is_updated =1, days_until_updated, null))) avg_update_period
FROM {{ref('int_arxiv_duration_llm')}} 
--where is_updated = 1
group by 1