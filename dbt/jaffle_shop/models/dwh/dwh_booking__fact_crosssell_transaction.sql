WITH product_location AS (
    SELECT
        pc.product_id,
        MIN(dl.location_id) AS location_id
    FROM
        {{ source('raw.ota_data_prod', 'raw_products__raw_product_catalog') }} pc
    JOIN {{ ref('dwh_products__dim_location') }} dl
        ON pc.product_name LIKE CONCAT('%', dl.city, '%')
    GROUP BY pc.product_id
)
SELECT
    rbb.bundle_booking_id AS crosssell_transaction_id,
    rbb.customer_id,
    ppc1.service_type_id AS primary_service_type_id,
    ppc2.service_type_id AS secondary_service_type_id,
    rbb.primary_product_id,
    rbb.secondary_product_id,
    rbb.booking_date AS transaction_date,
    pl1.location_id,
    dbo.bundle_offer_id,
    rbb.bundle_price AS transaction_amount,
    rbb.discount_applied AS bundle_discount_amount
FROM
    {{ source('raw.ota_data_prod', 'raw_booking__raw_bundle_booking') }} rbb
JOIN {{ source('raw.ota_data_prod', 'raw_products__raw_product_catalog') }} ppc1 ON rbb.primary_product_id = ppc1.product_id
JOIN {{ source('raw.ota_data_prod', 'raw_products__raw_product_catalog') }} ppc2 ON rbb.secondary_product_id = ppc2.product_id
LEFT JOIN product_location pl1 ON ppc1.product_id = pl1.product_id
LEFT JOIN {{ ref('dwh_products__dim_bundle_offer') }} dbo ON rbb.bundle_booking_id = dbo.bundle_offer_id