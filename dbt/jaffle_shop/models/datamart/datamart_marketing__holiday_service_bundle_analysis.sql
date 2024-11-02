{{
    config(
        tags=['ota_daily'],
        materialization='table',
    ) 
}}

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
    {{ ref('dwh_booking__fact_holiday_sales') }} fhs
LEFT JOIN {{ ref('dwh_marketing__dim_campaign') }} dc ON fhs.campaign_id = dc.campaign_id
JOIN {{ ref('dwh_products__dim_service_type') }} dst ON fhs.service_type_id = dst.service_type_id
JOIN {{ ref('dwh_products__dim_product') }} dp ON fhs.product_id = dp.product_id
LEFT JOIN {{ ref('dwh_products__dim_location') }} dl ON fhs.location_id = dl.location_id
LEFT JOIN {{ ref('dwh_marketing__dim_seasonal_event') }} dse ON fhs.seasonal_event_id = dse.event_id
LEFT JOIN {{ ref('dwh_products__dim_bundle_offer') }} dbo ON fhs.is_bundled_flag = TRUE AND fhs.product_id = dbo.bundle_offer_id
JOIN {{ ref('dwh_customer__dim_date') }} dd ON fhs.transaction_date = dd.date
ORDER BY fhs.holiday_sales_id