SELECT DISTINCT
    rbb.bundle_booking_id AS bundle_offer_id,
    CONCAT('Bundle Offer ', rbb.bundle_booking_id) AS bundle_offer_name,
    ppc1.service_type_id AS primary_service_type_id,
    ppc2.service_type_id AS secondary_service_type_id,
    rbb.discount_applied AS discount_amount
FROM
    ota_data_prod.raw_booking__raw_bundle_booking rbb
JOIN ota_data_prod.raw_products__raw_product_catalog ppc1 ON rbb.primary_product_id = ppc1.product_id
JOIN ota_data_prod.raw_products__raw_product_catalog ppc2 ON rbb.secondary_product_id = ppc2.product_id