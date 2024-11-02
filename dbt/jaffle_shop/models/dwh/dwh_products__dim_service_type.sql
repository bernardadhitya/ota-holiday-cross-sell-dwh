{{
    config(
        tags=['ota_daily']
    ) 
}}

SELECT
    stm.service_type_id,
    stm.service_type_name
FROM
    {{ ref('raw_products__raw_service_type_mapping') }} stm