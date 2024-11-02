{{
    config(
        tags=['ota_daily']
    ) 
}}

SELECT
    lm.location_id,
    lm.city,
    lm.country,
    lm.region
FROM
    {{ ref('raw_products__raw_location_mapping') }} lm