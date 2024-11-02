SELECT
    rpc.product_id,
    rpc.product_name,
    rpc.service_type_id,
    rpc.product_category
FROM
    {{ source('raw.ota_data_prod', 'raw_products__raw_product_catalog') }} rpc