WITH all_booking_transaction AS (
    -- Union of all booking transactions
    SELECT
        fb.customer_id,
        fb.booking_date AS transaction_date,
        pc.service_type_id,
        fb.price AS amount,
        'Flight' AS booking_type
    FROM {{ source('raw.ota_data_prod', 'raw_booking__raw_flight_booking') }} fb
    JOIN {{ source('raw.ota_data_prod', 'raw_products__raw_product_catalog') }} pc ON fb.product_id = pc.product_id
    UNION ALL
    SELECT
        hb.customer_id,
        hb.booking_date AS transaction_date,
        pc.service_type_id,
        hb.price AS amount,
        'Hotel' AS booking_type
    FROM {{ source('raw.ota_data_prod', 'raw_booking__raw_hotel_booking') }} hb
    JOIN {{ source('raw.ota_data_prod', 'raw_products__raw_product_catalog') }} pc ON hb.product_id = pc.product_id
    UNION ALL
    SELECT
        crb.customer_id,
        crb.booking_date AS transaction_date,
        pc.service_type_id,
        crb.price AS amount,
        'Car Rental' AS booking_type
    FROM {{ source('raw.ota_data_prod', 'raw_booking__raw_car_rental_booking') }} crb
    JOIN {{ source('raw.ota_data_prod', 'raw_products__raw_product_catalog') }} pc ON crb.product_id = pc.product_id
    UNION ALL
    SELECT
        ab.customer_id,
        ab.booking_date AS transaction_date,
        pc.service_type_id,
        ab.price AS amount,
        'Attraction' AS booking_type
    FROM {{ source('raw.ota_data_prod', 'raw_booking__raw_attraction_booking') }} ab
    JOIN {{ source('raw.ota_data_prod', 'raw_products__raw_product_catalog') }} pc ON ab.product_id = pc.product_id
    UNION ALL
    SELECT
        bb.customer_id,
        bb.booking_date AS transaction_date,
        pc.service_type_id,
        bb.bundle_price AS amount,
        'Bundle' AS booking_type
    FROM {{ source('raw.ota_data_prod', 'raw_booking__raw_bundle_booking') }} bb
    JOIN {{ source('raw.ota_data_prod', 'raw_products__raw_product_catalog') }} pc ON bb.primary_product_id = pc.product_id
)
SELECT
    ROW_NUMBER() OVER (ORDER BY t.customer_id) AS multiservice_user_id,
    t.customer_id,
    MIN(t.service_type_id) AS primary_service_type_id,
    MAX(t.service_type_id) AS secondary_service_type_id,
    MIN(t.transaction_date) AS first_transaction_date,
    MAX(t.transaction_date) AS last_transaction_date,
    SUM(t.amount) AS total_spend,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN t.booking_type = 'Bundle' THEN 1 ELSE 0 END) AS total_bundles_purchased
FROM all_booking_transaction t
GROUP BY t.customer_id
HAVING COUNT(DISTINCT t.service_type_id) > 1