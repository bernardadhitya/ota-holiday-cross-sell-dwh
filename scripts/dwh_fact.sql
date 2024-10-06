TRUNCATE ota_data_prod.dwh_booking__fact_crosssell_transaction CASCADE;
TRUNCATE ota_data_prod.dwh_booking__fact_holiday_sales CASCADE;
TRUNCATE ota_data_prod.dwh_customer__fact_multiservice_user CASCADE;
TRUNCATE ota_data_prod.dwh_engagement__fact_customer_journey CASCADE;
TRUNCATE ota_data_prod.dwh_marketing__fact_campaign_performance CASCADE;
TRUNCATE ota_data_prod.dwh_feedback__fact_product_rating_and_feedback CASCADE;

-- Create a mapping of product_id to a single location_id
WITH product_location AS (
    SELECT
        pc.product_id,
        MIN(dl.location_id) AS location_id
    FROM
        ota_data_prod.raw_products__raw_product_catalog pc
    JOIN ota_data_prod.dwh_products__dim_location dl
        ON pc.product_name LIKE CONCAT('%', dl.city, '%')
    GROUP BY pc.product_id
)
-- Insert data into fact_crosssell_transaction using the mapping
INSERT INTO ota_data_prod.dwh_booking__fact_crosssell_transaction (
    crosssell_transaction_id,
    customer_id,
    primary_service_type_id,
    secondary_service_type_id,
    primary_product_id,
    secondary_product_id,
    transaction_date,
    location_id,
    bundle_offer_id,
    transaction_amount,
    bundle_discount_amount
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
    ota_data_prod.raw_booking__raw_bundle_booking rbb
JOIN ota_data_prod.raw_products__raw_product_catalog ppc1 ON rbb.primary_product_id = ppc1.product_id
JOIN ota_data_prod.raw_products__raw_product_catalog ppc2 ON rbb.secondary_product_id = ppc2.product_id
LEFT JOIN product_location pl1 ON ppc1.product_id = pl1.product_id
LEFT JOIN ota_data_prod.dwh_products__dim_bundle_offer dbo ON rbb.bundle_booking_id = dbo.bundle_offer_id;

select * from ota_data_prod.dwh_customer__dim_customer;

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
INSERT INTO ota_data_prod.dwh_booking__fact_holiday_sales (
    holiday_sales_id,
    customer_id,
    service_type_id,
    product_id,
    location_id,
    transaction_date,
    campaign_id,
    seasonal_event_id,
    sales_amount,
    holiday_sales_discount,
    is_bundled_flag
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
WHERE pt.transaction_date BETWEEN '2024-01-01' AND '2024-12-31';

WITH all_booking_transaction AS (
    -- Union of all booking transactions
    SELECT
        fb.customer_id,
        fb.booking_date AS transaction_date,
        pc.service_type_id,
        fb.price AS amount,
        'Flight' AS booking_type
    FROM ota_data_prod.raw_booking__raw_flight_booking fb
    JOIN ota_data_prod.raw_products__raw_product_catalog pc ON fb.product_id = pc.product_id
    UNION ALL
    SELECT
        hb.customer_id,
        hb.booking_date AS transaction_date,
        pc.service_type_id,
        hb.price AS amount,
        'Hotel' AS booking_type
    FROM ota_data_prod.raw_booking__raw_hotel_booking hb
    JOIN ota_data_prod.raw_products__raw_product_catalog pc ON hb.product_id = pc.product_id
    UNION ALL
    SELECT
        crb.customer_id,
        crb.booking_date AS transaction_date,
        pc.service_type_id,
        crb.price AS amount,
        'Car Rental' AS booking_type
    FROM ota_data_prod.raw_booking__raw_car_rental_booking crb
    JOIN ota_data_prod.raw_products__raw_product_catalog pc ON crb.product_id = pc.product_id
    UNION ALL
    SELECT
        ab.customer_id,
        ab.booking_date AS transaction_date,
        pc.service_type_id,
        ab.price AS amount,
        'Attraction' AS booking_type
    FROM ota_data_prod.raw_booking__raw_attraction_booking ab
    JOIN ota_data_prod.raw_products__raw_product_catalog pc ON ab.product_id = pc.product_id
    UNION ALL
    SELECT
        bb.customer_id,
        bb.booking_date AS transaction_date,
        pc.service_type_id,
        bb.bundle_price AS amount,
        'Bundle' AS booking_type
    FROM ota_data_prod.raw_booking__raw_bundle_booking bb
    JOIN ota_data_prod.raw_products__raw_product_catalog pc ON bb.primary_product_id = pc.product_id
)
INSERT INTO ota_data_prod.dwh_customer__fact_multiservice_user (
    multiservice_user_id,
    customer_id,
    primary_service_type_id,
    secondary_service_type_id,
    first_transaction_date,
    last_transaction_date,
    total_spend,
    total_transactions,
    total_bundles_purchased
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
HAVING COUNT(DISTINCT t.service_type_id) > 1;

INSERT INTO ota_data_prod.dwh_engagement__fact_customer_journey (
    customer_journey_id,
    customer_id,
    session_id,
    page_view_id,
    funnel_event_id,
    campaign_id,
    journey_start,
    journey_end,
    total_duration
)
SELECT
    ROW_NUMBER() OVER (ORDER BY cs.session_id) AS customer_journey_id,
    cs.customer_id,
    cs.session_id,
    pv.page_view_id,
    fe.funnel_event_id,
    oc.campaign_id,
    cs.session_start AS journey_start,
    cs.session_end AS journey_end,
    cs.total_duration
FROM
    ota_data_prod.raw_engagement__raw_customer_sessions cs
LEFT JOIN ota_data_prod.raw_engagement__raw_page_views pv ON cs.session_id = pv.session_id
LEFT JOIN ota_data_prod.raw_engagement__raw_funnel_events fe ON cs.session_id = fe.session_id
LEFT JOIN ota_data_prod.raw_engagement__raw_offer_clicks oc ON cs.customer_id = oc.customer_id AND cs.session_start::date = oc.click_date::date;

INSERT INTO ota_data_prod.dwh_marketing__fact_campaign_performance (
    campaign_performance_id,
    campaign_id,
    impressions,
    clicks,
    conversions,
    start_date,
    end_date
)
SELECT
    cp.campaign_id AS campaign_performance_id,
    cp.campaign_id,
    cp.impressions,
    cp.clicks,
    cp.conversions,
    cp.start_date,
    cp.end_date
FROM
    ota_data_prod.raw_marketing__raw_campaign_performance cp;

INSERT INTO ota_data_prod.dwh_feedback__fact_product_rating_and_feedback (
    feedback_id,
    customer_id,
    product_id,
    rating,
    review_text,
    review_date
)
SELECT
    pr.review_id AS feedback_id,
    pr.customer_id,
    pr.product_id,
    pr.rating,
    pr.review_text,
    pr.review_date
FROM
    ota_data_prod.raw_feedback__raw_product_reviews pr;
