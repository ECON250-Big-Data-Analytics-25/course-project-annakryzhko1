{{ config(materialized="ephemeral")}}

SELECT 
*,

date_diff(updated_date, published_date, day) days_until_updated,
if(published_date != updated_date, 1,0) as is_updated,
if (
  summary LIKE '%GPT%' OR
  summary LIKE '%LLM%', 1,0
) is_llm_related
 FROM {{ ref('stg_week4_arxiv') }} 
 order by id, published_date