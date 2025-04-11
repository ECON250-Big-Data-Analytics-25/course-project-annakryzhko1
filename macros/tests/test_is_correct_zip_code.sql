{% test is_correct_zip_code(model, column_name) %}

with validation as (

    select
        {{ column_name }} as zip_code_field

    from {{ model }}

),

validation_errors as (

    select
        zip_code_field

    from validation
    -- zip code should contain 5 digits
    where not regexp_contains(cast(zip_code_field as string), r'^\d{5}$') 

)

select *
from validation_errors

{% endtest %}