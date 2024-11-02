{{
    config(
        tags=['ota_daily']
    ) 
}}

SELECT
    cp.campaign_id,
    cp.campaign_name,
    COALESCE(sem.event_type, 'General Campaign') AS campaign_type,
    cp.start_date,
    cp.end_date
FROM
    {{ ref('raw_marketing__raw_campaign_performance') }} cp
LEFT JOIN {{ ref('raw_marketing__raw_seasonal_event_mapping') }} sem ON cp.campaign_name = sem.event_name