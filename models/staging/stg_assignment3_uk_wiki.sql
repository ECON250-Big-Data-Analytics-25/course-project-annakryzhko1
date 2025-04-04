{{ config(materialized='view')}}

WITH source_data AS (
    SELECT 
        *, 
        "desktop" as src 
    FROM {{ source("test_dataset", "assignment3_input_uk") }}
    UNION ALL
    SELECT *,
        "mobile" as src 
     FROM {{ source("test_dataset", "assignment3_input_uk_m") }}
)

SELECT 
  *, 
  DATE(datehour) as date,
  EXTRACT(DAYOFWEEK FROM datehour) as day_of_week,
  EXTRACT(HOUR FROM datehour) as hour_of_day
FROM source_data