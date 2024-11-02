TRUNCATE ota_data_prod.datamart_booking__seasonal_cross_sell_performance CASCADE;
TRUNCATE ota_data_prod.datamart_marketing__holiday_service_bundle_analysis CASCADE;
TRUNCATE ota_data_prod.datamart_customer__multi_service_customer_behavior CASCADE;


INSERT INTO ota_data_prod.datamart_booking__seasonal_cross_sell_performance (
    crosssell_performance_id,
    transaction_date,
    customer_id,
    primary_service_type_name,
    secondary_service_type_name,
    primary_product_name,
    secondary_product_name,
    location_city,
    location_country,
    bundle_offer_name,
    transaction_amount,
    bundle_discount_amount,
    is_holiday_flag,
    holiday_name
)
SELECT
    fct.crosssell_transaction_id AS crosssell_performance_id,
    dd.date AS transaction_date,
    fct.customer_id,
    dst1.service_type_name AS primary_service_type_name,
    dst2.service_type_name AS secondary_service_type_name,
    dp1.product_name AS primary_product_name,
    dp2.product_name AS secondary_product_name,
    dl.city AS location_city,
    dl.country AS location_country,
    dbo.bundle_offer_name,
    fct.transaction_amount,
    fct.bundle_discount_amount,
    dd.is_holiday_flag,
    dd.holiday_name
FROM
    ota_data_prod.dwh_booking__fact_crosssell_transaction fct
JOIN ota_data_prod.dwh_products__dim_service_type dst1 ON fct.primary_service_type_id = dst1.service_type_id
JOIN ota_data_prod.dwh_products__dim_service_type dst2 ON fct.secondary_service_type_id = dst2.service_type_id
JOIN ota_data_prod.dwh_products__dim_product dp1 ON fct.primary_product_id = dp1.product_id
JOIN ota_data_prod.dwh_products__dim_product dp2 ON fct.secondary_product_id = dp2.product_id
LEFT JOIN ota_data_prod.dwh_products__dim_location dl ON fct.location_id = dl.location_id
LEFT JOIN ota_data_prod.dwh_products__dim_bundle_offer dbo ON fct.bundle_offer_id = dbo.bundle_offer_id
JOIN ota_data_prod.dwh_customer__dim_date dd ON fct.transaction_date = dd.date
ORDER BY fct.crosssell_transaction_id;

INSERT INTO ota_data_prod.datamart_marketing__holiday_service_bundle_analysis (
    bundle_analysis_id,
    transaction_date,
    customer_id,
    campaign_name,
    service_type_name,
    product_name,
    location_city,
    location_country,
    seasonal_event_name,
    sales_amount,
    holiday_sales_discount,
    is_bundled_flag,
    bundle_offer_name
)
SELECT
    fhs.holiday_sales_id AS bundle_analysis_id,
    dd.date AS transaction_date,
    fhs.customer_id,
    dc.campaign_name,
    dst.service_type_name,
    dp.product_name,
    dl.city AS location_city,
    dl.country AS location_country,
    dse.event_name AS seasonal_event_name,
    fhs.sales_amount,
    fhs.holiday_sales_discount,
    fhs.is_bundled_flag,
    dbo.bundle_offer_name
FROM
    ota_data_prod.dwh_booking__fact_holiday_sales fhs
LEFT JOIN ota_data_prod.dwh_marketing__dim_campaign dc ON fhs.campaign_id = dc.campaign_id
JOIN ota_data_prod.dwh_products__dim_service_type dst ON fhs.service_type_id = dst.service_type_id
JOIN ota_data_prod.dwh_products__dim_product dp ON fhs.product_id = dp.product_id
LEFT JOIN ota_data_prod.dwh_products__dim_location dl ON fhs.location_id = dl.location_id
LEFT JOIN ota_data_prod.dwh_marketing__dim_seasonal_event dse ON fhs.seasonal_event_id = dse.event_id
LEFT JOIN ota_data_prod.dwh_products__dim_bundle_offer dbo ON fhs.is_bundled_flag = TRUE AND fhs.product_id = dbo.bundle_offer_id
JOIN ota_data_prod.dwh_customer__dim_date dd ON fhs.transaction_date = dd.date
ORDER BY fhs.holiday_sales_id;

INSERT INTO ota_data_prod.datamart_customer__multi_service_customer_behavior (
    multi_service_behavior_id,
    customer_id,
    first_transaction_date,
    last_transaction_date,
    total_spend,
    total_transactions,
    total_bundles_purchased,
    primary_service_type_name,
    secondary_service_type_name,
    preferred_location_city,
    preferred_location_country,
    preferred_membership_level,
    loyalty_points_accrued
)
SELECT
    fmu.multiservice_user_id AS multi_service_behavior_id,
    fmu.customer_id,
    dd1.date AS first_transaction_date,
    dd2.date AS last_transaction_date,
    fmu.total_spend,
    fmu.total_transactions,
    fmu.total_bundles_purchased,
    dst1.service_type_name AS primary_service_type_name,
    dst2.service_type_name AS secondary_service_type_name,
    dl.city AS preferred_location_city,
    dl.country AS preferred_location_country,
    dc.membership_level AS preferred_membership_level,
    cls.points_accrued AS loyalty_points_accrued
FROM
    ota_data_prod.dwh_customer__fact_multiservice_user fmu
JOIN ota_data_prod.dwh_customer__dim_customer dc ON fmu.customer_id = dc.customer_id
LEFT JOIN ota_data_prod.dwh_products__dim_service_type dst1 ON fmu.primary_service_type_id = dst1.service_type_id
LEFT JOIN ota_data_prod.dwh_products__dim_service_type dst2 ON fmu.secondary_service_type_id = dst2.service_type_id
LEFT JOIN ota_data_prod.dwh_products__dim_location dl ON dc.preferred_location = dl.location_id
LEFT JOIN ota_data_prod.dwh_customer__dim_date dd1 ON fmu.first_transaction_date = dd1.date
LEFT JOIN ota_data_prod.dwh_customer__dim_date dd2 ON fmu.last_transaction_date = dd2.date
LEFT JOIN ota_data_prod.raw_customer__raw_customer_loyalty_status cls ON fmu.customer_id = cls.customer_id
ORDER BY fmu.multiservice_user_id;

-- Verify datamart_booking__seasonal_cross_sell_performance
SELECT * FROM ota_data_prod.datamart_booking__seasonal_cross_sell_performance;

-- Verify datamart_marketing__holiday_service_bundle_analysis
SELECT * FROM ota_data_prod.datamart_marketing__holiday_service_bundle_analysis;

-- Verify datamart_customer__multi_service_customer_behavior
SELECT * FROM ota_data_prod.datamart_customer__multi_service_customer_behavior;
