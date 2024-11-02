SELECT
    sem.event_id,
    sem.event_name,
    sem.event_type,
    sem.start_date,
    sem.end_date
FROM
    {{ source('raw.ota_data_prod', 'raw_marketing__raw_seasonal_event_mapping') }} sem