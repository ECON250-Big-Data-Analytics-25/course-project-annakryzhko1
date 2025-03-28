{{
    config(
        materialized="incremental",
        unique_key="visitId",
        incremental_strategy="merge"
    )
}}

SELECT 
date, 
visitId, 
page.pagePath 
FROM {{ source("test_dataset", "week5_hits") }}

where hitNumber = 1

{% if is_incremental() %}
AND date >= (select coalesce(max(date) - 7, "2000-01-01") from {{ this}} )
{% endif %}

qualify row_number() over(partition by visitId order by hitNumber) = 1