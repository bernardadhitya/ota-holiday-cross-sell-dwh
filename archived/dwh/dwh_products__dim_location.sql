SELECT
    lm.location_id,
    lm.city,
    lm.country,
    lm.region
FROM
    ota_data_prod.raw_products__raw_location_mapping lm