{{
    config(
        materialized="incremental",
        unique_key="visitId",
        incremental_strategy="merge"
    )
}}

SELECT 
*
FROM {{ ref("fct_week7_landing_page_ephemeral") }}

{% if is_incremental() %}
WHERE date > (select coalesce(max(date) - 7, "2023-01-01") from {{ this }} )
{% endif %}

