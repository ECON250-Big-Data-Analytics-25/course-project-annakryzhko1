select product_id, 
coalesce(product_category_name, "(nenhum)") as product_category_name,
struct(
  product_name_lenght as product_name_length,
  product_description_lenght as product_description_length,
  coalesce(product_photos_qty, 0) as product_photos_qty
) as product_description,
struct(
  product_weight_g,
  product_length_cm,
  product_height_cm,
  product_width_cm
) as product_measurements
from {{ source('fp', 'fp_products')}}