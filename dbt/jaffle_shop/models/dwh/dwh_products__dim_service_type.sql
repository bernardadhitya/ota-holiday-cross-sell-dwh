{{
    config(
        tags=['ota_daily'],
        materialization='table',
    ) 
}}

SELECT
    stm.service_type_id,
    stm.service_type_name
FROM
    {{ source('raw.ota_data_prod', 'raw_products__raw_service_type_mapping') }} stm