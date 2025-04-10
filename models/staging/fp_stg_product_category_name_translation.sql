select product_category_name, 
initcap(regexp_replace(product_category_name_english, "_", " ")) as en,
initcap(regexp_replace(product_category_name, "_", " ")) as pt 
from {{ source('fp', 'fp_product_category_name_translation')}} 
UNION ALL  
select 
"(nenhum)" as product_category_name,
"None" as en,
"Nenhum" as pt