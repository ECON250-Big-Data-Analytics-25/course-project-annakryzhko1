select *
from {{ source('fp', 'fp_customers')}}