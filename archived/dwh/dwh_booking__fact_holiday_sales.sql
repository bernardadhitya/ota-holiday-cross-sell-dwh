WITH all_booking_transaction AS (
    -- Union of all booking transactions
    SELECT
        fb.customer_id,
        fb.product_id,
        fb.booking_date AS transaction_date,
        'Flight' AS booking_type,
        fb.price AS amount
    FROM ota_data_prod.dwh_customer__dim_customer dc
    JOIN ota_data_prod.raw_booking__raw_flight_booking fb ON dc.customer_id = fb.customer_id
    UNION ALL
    SELECT
        hb.customer_id,
        hb.product_id,
        hb.booking_date AS transaction_date,
        'Hotel' AS booking_type,
        hb.price AS amount
    FROM ota_data_prod.dwh_customer__dim_customer dc
    JOIN ota_data_prod.raw_booking__raw_hotel_booking hb  ON dc.customer_id = hb.customer_id
    UNION ALL
    SELECT
        crb.customer_id,
        crb.product_id,
        crb.booking_date AS transaction_date,
        'Car Rental' AS booking_type,
        crb.price AS amount
    FROM ota_data_prod.dwh_customer__dim_customer dc
    JOIN ota_data_prod.raw_booking__raw_car_rental_booking crb ON dc.customer_id = crb.customer_id
    UNION ALL
    SELECT
        ab.customer_id,
        ab.product_id,
        ab.booking_date AS transaction_date,
        'Attraction' AS booking_type,
        ab.price AS amount
    FROM ota_data_prod.dwh_customer__dim_customer dc
    JOIN ota_data_prod.raw_booking__raw_attraction_booking ab ON dc.customer_id = ab.customer_id
    UNION ALL
    SELECT
        bb.customer_id,
        bb.primary_product_id AS product_id,
        bb.booking_date AS transaction_date,
        'Bundle' AS booking_type,
        bb.bundle_price AS amount
    FROM ota_data_prod.dwh_customer__dim_customer dc
    JOIN ota_data_prod.raw_booking__raw_bundle_booking bb ON dc.customer_id = bb.customer_id
)
SELECT
    ROW_NUMBER() OVER (ORDER BY pt.transaction_date) AS holiday_sales_id,
    pt.customer_id,
    pc.service_type_id,
    pt.product_id,
    dl.location_id,
    pt.transaction_date,
    cs.campaign_id,
    sem.event_id,
    pt.amount AS sales_amount,
    da.discount_amount AS holiday_sales_discount,
    CASE WHEN pt.booking_type = 'Bundle' THEN TRUE ELSE FALSE END AS is_bundled_flag
FROM all_booking_transaction as pt
JOIN ota_data_prod.raw_products__raw_product_catalog pc ON pt.product_id = pc.product_id
LEFT JOIN ota_data_prod.dwh_products__dim_location dl ON pc.product_name LIKE CONCAT('%', dl.city, '%')
LEFT JOIN ota_data_prod.raw_marketing__raw_campaign_sales cs ON pt.product_id = cs.product_id AND pt.transaction_date = cs.transaction_date
LEFT JOIN ota_data_prod.raw_marketing__raw_seasonal_event_mapping sem ON cs.campaign_id = sem.event_id
LEFT JOIN ota_data_prod.raw_finserv__raw_discount_applications da ON da.payment_id = pt.product_id
WHERE pt.transaction_date BETWEEN '2024-01-01' AND '2024-12-31'