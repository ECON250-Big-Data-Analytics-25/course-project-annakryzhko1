{{ config(materialized='view')}}

with ext_view AS (
  SELECT
  *,
  REGEXP_CONTAINS(title, r':[^_]') as is_meta_page
FROM
    {{ ref('stg_assignment3_uk_wiki') }} 

  )

SELECT
  *,
  IF(is_meta_page, SPLIT(title, ":")[OFFSET(0)], NULL) as meta_page_type
FROM
  ext_view