{{
    config(
        tags=['ota_daily'],
        materialization='table',
    ) 
}}

SELECT
    cp.campaign_id,
    cp.campaign_name,
    COALESCE(sem.event_type, 'General Campaign') AS campaign_type,
    cp.start_date,
    cp.end_date
FROM
    {{ source('raw.ota_data_prod', 'raw_marketing__raw_campaign_performance') }} cp
LEFT JOIN {{ source('raw.ota_data_prod', 'raw_marketing__raw_seasonal_event_mapping') }} sem ON cp.campaign_name = sem.event_name