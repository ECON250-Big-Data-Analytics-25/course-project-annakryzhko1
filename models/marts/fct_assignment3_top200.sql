{{ config(materialized='table')}}

WITH
  views_data AS (
  SELECT
    title,
    COUNT(views) AS total_views,
    COUNTIF(src="mobile") AS total_mobile_views,
    ROW_NUMBER() OVER (ORDER BY COUNT(views) DESC) AS rating
  FROM
    {{ ref("int_assignment3_uk_wiki") }}
  WHERE
    is_meta_page = FALSE
  GROUP BY
    title )

SELECT
  title,
  total_views,
  total_mobile_views,
  FORMAT('%s%%', CAST(ROUND((views_data.total_mobile_views/views_data.total_views) * 100, 2) AS STRING)) as mobile_percentage
FROM
  views_data
WHERE
  rating <= 200
ORDER BY mobile_percentage ASC