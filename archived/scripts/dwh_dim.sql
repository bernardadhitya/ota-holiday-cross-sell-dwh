-- Insert data into ota_data_prod.dwh_products__dim_service_type
TRUNCATE ota_data_prod.dwh_products__dim_service_type CASCADE;
TRUNCATE ota_data_prod.dwh_products__dim_location CASCADE;
TRUNCATE ota_data_prod.dwh_customer__dim_date CASCADE;
TRUNCATE ota_data_prod.dwh_products__dim_product CASCADE;
TRUNCATE ota_data_prod.dwh_marketing__dim_seasonal_event CASCADE;
TRUNCATE ota_data_prod.dwh_customer__dim_customer CASCADE;
TRUNCATE ota_data_prod.dwh_marketing__dim_campaign CASCADE;
TRUNCATE ota_data_prod.dwh_products__dim_bundle_offer CASCADE;

INSERT INTO ota_data_prod.dwh_products__dim_service_type (service_type_id, service_type_name)
SELECT
    stm.service_type_id,
    stm.service_type_name
FROM
    ota_data_prod.raw_products__raw_service_type_mapping stm;

-- Insert data into ota_data_prod.dwh_products__dim_location
INSERT INTO ota_data_prod.dwh_products__dim_location (location_id, city, country, region)
SELECT
    lm.location_id,
    lm.city,
    lm.country,
    lm.region
FROM
    ota_data_prod.raw_products__raw_location_mapping lm;


WITH date_range AS (
  SELECT DATE(generate_series) AS date FROM generate_series(
    '2024-01-01 00:00:00'::timestamp,
    '2024-12-31 00:00:00'::timestamp,
    '1 day'::interval
  )
)
INSERT INTO ota_data_prod.dwh_customer__dim_date (
    date_id,
    date,
    year,
    quarter,
    month,
    day,
    week,
    is_holiday_flag,
    holiday_name,
    season
)
SELECT
    date AS date_id,
    date,
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(QUARTER FROM date) AS quarter,
    EXTRACT(MONTH FROM date) AS month,
    EXTRACT(DAY FROM date) AS day,
    EXTRACT(WEEK FROM date) AS week,
    CASE
        WHEN sem.event_date IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS is_holiday_flag,
    sem.event_name AS holiday_name,
    CASE
        WHEN EXTRACT(MONTH FROM date) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM date) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Autumn'
    END AS season
FROM
    date_range dr
LEFT JOIN (
    SELECT DISTINCT
        generate_series(sem.start_date, sem.end_date, INTERVAL '1 day') AS event_date,
        sem.event_name
    FROM
        ota_data_prod.raw_marketing__raw_seasonal_event_mapping sem
) sem ON dr.date = sem.event_date;

-- Insert data into ota_data_prod.dwh_products__dim_product
INSERT INTO ota_data_prod.dwh_products__dim_product (product_id, product_name, service_type_id, product_category)
SELECT
    rpc.product_id,
    rpc.product_name,
    rpc.service_type_id,
    rpc.product_category
FROM
    ota_data_prod.raw_products__raw_product_catalog rpc;

-- Insert data into ota_data_prod.dwh_customer__dim_customer
INSERT INTO ota_data_prod.dwh_customer__dim_customer (
    customer_id,
    customer_name,
    gender,
    age_group,
    membership_level,
    preferred_location
)
SELECT
    cp.customer_id,
    cp.customer_name,
    cp.gender,
    cp.age_group,
    ls.membership_tier,
    cp.preferred_location
FROM
    ota_data_prod.raw_customer__raw_customer_profile cp
LEFT JOIN ota_data_prod.raw_customer__raw_customer_loyalty_status ls ON cp.customer_id = ls.customer_id;

-- Insert data into ota_data_prod.dwh_marketing__dim_seasonal_event
INSERT INTO ota_data_prod.dwh_marketing__dim_seasonal_event (
    event_id,
    event_name,
    event_type,
    start_date,
    end_date
)
SELECT
    sem.event_id,
    sem.event_name,
    sem.event_type,
    sem.start_date,
    sem.end_date
FROM
    ota_data_prod.raw_marketing__raw_seasonal_event_mapping sem;

-- Insert data into ota_data_prod.dwh_marketing__dim_campaign
INSERT INTO ota_data_prod.dwh_marketing__dim_campaign (
    campaign_id,
    campaign_name,
    campaign_type,
    start_date,
    end_date
)
SELECT
    cp.campaign_id,
    cp.campaign_name,
    COALESCE(sem.event_type, 'General Campaign') AS campaign_type,
    cp.start_date,
    cp.end_date
FROM
    ota_data_prod.raw_marketing__raw_campaign_performance cp
LEFT JOIN ota_data_prod.raw_marketing__raw_seasonal_event_mapping sem ON cp.campaign_name = sem.event_name;

-- Insert data into ota_data_prod.dwh_products__dim_bundle_offer
INSERT INTO ota_data_prod.dwh_products__dim_bundle_offer (
    bundle_offer_id,
    bundle_offer_name,
    primary_service_type_id,
    secondary_service_type_id,
    discount_amount
)
SELECT DISTINCT
    rbb.bundle_booking_id AS bundle_offer_id,
    CONCAT('Bundle Offer ', rbb.bundle_booking_id) AS bundle_offer_name,
    ppc1.service_type_id AS primary_service_type_id,
    ppc2.service_type_id AS secondary_service_type_id,
    rbb.discount_applied AS discount_amount
FROM
    ota_data_prod.raw_booking__raw_bundle_booking rbb
JOIN ota_data_prod.raw_products__raw_product_catalog ppc1 ON rbb.primary_product_id = ppc1.product_id
JOIN ota_data_prod.raw_products__raw_product_catalog ppc2 ON rbb.secondary_product_id = ppc2.product_id;

