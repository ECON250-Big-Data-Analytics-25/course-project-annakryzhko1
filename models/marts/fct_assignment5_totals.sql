{{
    config(
        materialized ='incremental',
        incremental_strategy ="insert_overwrite",
        partition_by = {
            "field": "date",
            "data_type": "timestamp"
        }
    )
}}

select 
date_trunc(datehour, day) as date, 
title, 
sum(views) as views,
current_timestamp() as insert_time
from {{ source('test_dataset', 'assignment5_input') }}
{% if is_incremental() %}
    where datehour >= TIMESTAMP_SUB(_dbt_max_partition, INTERVAL 1 DAY)
{% endif %}
group by date, title