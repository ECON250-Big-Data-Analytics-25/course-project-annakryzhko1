{{
    config(
        materialized="ephemeral"
    )
}}

SELECT 
date, 
visitId, 
page.pagePath as pagePath
FROM {{ source("test_dataset", "week5_hits") }}
where hitNumber = 1
qualify row_number() over(partition by visitId order by hitNumber) = 1