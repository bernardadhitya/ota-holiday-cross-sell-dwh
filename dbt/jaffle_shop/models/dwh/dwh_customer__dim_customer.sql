{{
    config(
        tags=['ota_daily']
    ) 
}}

SELECT
    cp.customer_id,
    cp.customer_name,
    cp.gender,
    cp.age_group,
    ls.membership_tier,
    cp.preferred_location
FROM
    {{ ref('raw_customer__raw_customer_profile') }} cp
LEFT JOIN {{ ref('raw_customer__raw_customer_loyalty_status') }} ls ON cp.customer_id = ls.customer_id