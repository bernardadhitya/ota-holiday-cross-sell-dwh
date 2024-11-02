{{
    config(
        tags=['ota_daily']
    ) 
}}

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
ORDER BY fmu.multiservice_user_id