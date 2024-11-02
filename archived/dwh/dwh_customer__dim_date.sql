WITH date_range AS (
  SELECT DATE(generate_series) AS date FROM generate_series(
    '2024-01-01 00:00:00'::timestamp,
    '2024-12-31 00:00:00'::timestamp,
    '1 day'::interval
  )
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
) sem ON dr.date = sem.event_date