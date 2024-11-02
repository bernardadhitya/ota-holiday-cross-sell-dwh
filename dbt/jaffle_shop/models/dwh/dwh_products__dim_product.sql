{{
    config(
        tags=['ota_daily']
    ) 
}}

SELECT
    rpc.product_id,
    rpc.product_name,
    rpc.service_type_id,
    rpc.product_category
FROM
    {{ ref('raw_products__raw_product_catalog') }} rpc