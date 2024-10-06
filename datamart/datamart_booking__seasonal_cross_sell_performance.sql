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
ORDER BY fct.crosssell_transaction_id