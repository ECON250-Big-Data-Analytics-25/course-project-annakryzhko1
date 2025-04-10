{% set city_map = {
    "sao paluo": "sao paulo",
    "sao pauo": "sao paulo",
    "sao paulop": "sao paulo",
    "sp": "sao paulo",
    "tabao da serra": "taboao da serra",
    "ribeirao pretp": "ribeirao preto",
    "riberao preto": "ribeirao preto",
    "sao bernardo do capo": "sao bernardo do campo",
    "mogi das cruses": "mogi das cruzes",
    "sao jose dos pinhas": "sao jose dos pinhais",
    "santa barbara d'oeste": "santa barbara d oeste",
    "santa barbara d\´oeste": "santa barbara d oeste",
    "sao miguel d'oeste": "sao miguel do oeste",
    "guara": "guaira",
    "cascavael": "cascavel",
    "s jose do rio preto": "san jose do rio preto",
    "balneario camboriu": "balenario camboriu",
    "floranopolis": "florianopolis"
}
%}

with normalizing_city_name as (
    select
        seller_id,
        REGEXP_REPLACE(seller_city, r'\s+', ' ') as seller_city,
        seller_state,
        seller_zip_code_prefix
    from {{ source('fp', 'fp_sellers')}}
),
city_extracted as (
    select 
seller_id,
case when contains_substr(seller_city, '/') 
        then trim(split(seller_city, '/')[0])
    when contains_substr(seller_city, '\\') 
        then trim(split(seller_city, '\\')[0])
    when contains_substr(seller_city, '-') 
        then trim(split(seller_city, '-')[0])
    when ends_with(seller_city, concat(" ", lower(seller_state))) 
        then trim(split(seller_city, lower(seller_state))[0])
    when contains_substr(seller_city, ',') 
        then trim(split(seller_city, ',')[0])
    when regexp_contains(seller_city, '[@1-9]') 
        then '(incorrect city)'
     else seller_city -- this else is optional
end as seller_city,
seller_state,
seller_zip_code_prefix
from normalizing_city_name
)
select 
    seller_id,
    case
    {% for typo, correct in city_map.items() %}
     when seller_city = "{{ typo }}" then "{{ correct }}"
    {% endfor %}
        else seller_city
    end as seller_city,
    seller_state,
    seller_zip_code_prefix
from city_extracted