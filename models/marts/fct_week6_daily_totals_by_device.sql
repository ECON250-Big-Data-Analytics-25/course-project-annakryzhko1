{{
  config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by = {
      "field": "date",
      "data_type": "date"
    },
    cluster_by=['deviceCategory']
  )
}}

SELECT  
date_add(date, interval 9 year) as date,
deviceCategory,
count(*) total_hits,
sum(1) total_hits_alt,
sum(if(eventInfo.eventCategory is not null, 1, 0)) as event_count,
sum(if(eventInfo.eventCategory is null, 1, 0)) as page_view_count
FROM {{ source('test_dataset', 'week5_hits') }}
left join {{ source('test_dataset', 'week5_web_visits') }}
using(date, visitId)
{% if is_incremental() %}
where date >= (select coalesce(max(date) - 7, "2000-01-01") from {{ this}} )
{% endif %}
group by date, deviceCategory


