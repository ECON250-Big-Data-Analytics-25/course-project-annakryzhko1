{{
    config(
        materialized = 'incremental',
        unique_key = 'title'
    )
}}

SELECT  
title,
date_trunc(min(datehour), day) as min_date,
date_trunc(max(datehour), day) as max_date,
sum(views) as total_views
FROM {{ source('test_dataset', 'assignment5_input') }}
{% if is_incremental() %}
    where datehour >= TIMESTAMP_SUB((select max(max_date) from {{ this
}}), INTERVAL 1 DAY)
{% endif %}
group by title