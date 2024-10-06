-- Create a ota_data_prod schema (if not exists) for all raw tables
CREATE SCHEMA IF NOT EXISTS ota_data_prod;

-- Create tables with the new naming convention

-- Schema: raw_booking
CREATE TABLE ota_data_prod.raw_booking__raw_flight_booking (
    flight_booking_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    booking_date DATE,
    flight_number VARCHAR(50),
    departure_city VARCHAR(100),
    arrival_city VARCHAR(100),
    price DECIMAL(12, 2)
);

CREATE TABLE ota_data_prod.raw_booking__raw_hotel_booking (
    hotel_booking_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    booking_date DATE,
    hotel_name VARCHAR(100),
    city VARCHAR(100),
    price DECIMAL(12, 2),
    nights_stayed INT
);

CREATE TABLE ota_data_prod.raw_booking__raw_car_rental_booking (
    car_rental_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    booking_date DATE,
    pick_up_location VARCHAR(100),
    drop_off_location VARCHAR(100),
    vehicle_type VARCHAR(50),
    price DECIMAL(12, 2)
);

CREATE TABLE ota_data_prod.raw_booking__raw_attraction_booking (
    attraction_booking_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    booking_date DATE,
    attraction_name VARCHAR(100),
    city VARCHAR(100),
    price DECIMAL(12, 2)
);

CREATE TABLE ota_data_prod.raw_booking__raw_bundle_booking (
    bundle_booking_id SERIAL PRIMARY KEY,
    customer_id INT,
    primary_product_id INT,
    secondary_product_id INT,
    booking_date DATE,
    bundle_price DECIMAL(12, 2),
    discount_applied DECIMAL(12, 2)
);

-- Schema: raw_engagement
CREATE TABLE ota_data_prod.raw_engagement__raw_customer_sessions (
    session_id SERIAL PRIMARY KEY,
    customer_id INT,
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    total_duration INTERVAL
);

CREATE TABLE ota_data_prod.raw_engagement__raw_offer_clicks (
    offer_click_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    campaign_id INT,
    click_date TIMESTAMP
);

CREATE TABLE ota_data_prod.raw_engagement__raw_page_views (
    page_view_id SERIAL PRIMARY KEY,
    customer_id INT,
    page_url VARCHAR(255),
    view_date TIMESTAMP,
    session_id INT
);

CREATE TABLE ota_data_prod.raw_engagement__raw_funnel_events (
    funnel_event_id SERIAL PRIMARY KEY,
    customer_id INT,
    event_type VARCHAR(50),
    event_date TIMESTAMP,
    session_id INT
);

-- Schema: raw_marketing
CREATE TABLE ota_data_prod.raw_marketing__raw_campaign_performance (
    campaign_id SERIAL PRIMARY KEY,
    campaign_name VARCHAR(100),
    impressions INT,
    clicks INT,
    conversions INT,
    start_date DATE,
    end_date DATE
);

CREATE TABLE ota_data_prod.raw_marketing__raw_campaign_sales (
    campaign_sales_id SERIAL PRIMARY KEY,
    campaign_id INT,
    product_id INT,
    sales_amount DECIMAL(12, 2),
    transaction_date DATE
);

CREATE TABLE ota_data_prod.raw_marketing__raw_seasonal_event_mapping (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(100),
    event_type VARCHAR(50),
    start_date DATE,
    end_date DATE
);

-- Schema: raw_feedback
CREATE TABLE ota_data_prod.raw_feedback__raw_product_reviews (
    review_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    rating INT,
    review_text TEXT,
    review_date DATE
);

CREATE TABLE ota_data_prod.raw_feedback__raw_complaints_and_resolutions (
    complaint_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    complaint_description TEXT,
    resolution_description TEXT,
    complaint_date DATE,
    resolution_date DATE
);

CREATE TABLE ota_data_prod.raw_feedback__raw_post_purchase_feedback (
    feedback_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    feedback_text TEXT,
    feedback_date DATE
);

-- Schema: raw_products
CREATE TABLE ota_data_prod.raw_products__raw_product_catalog (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    service_type_id INT,
    product_category VARCHAR(50)
);

CREATE TABLE ota_data_prod.raw_products__raw_product_pricing (
    pricing_id SERIAL PRIMARY KEY,
    product_id INT,
    price DECIMAL(12, 2),
    effective_date DATE
);

CREATE TABLE ota_data_prod.raw_products__raw_service_type_mapping (
    service_type_id SERIAL PRIMARY KEY,
    service_type_name VARCHAR(50)
);

CREATE TABLE ota_data_prod.raw_products__raw_location_mapping (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(100),
    country VARCHAR(100),
    region VARCHAR(100)
);

-- Schema: raw_customer
CREATE TABLE ota_data_prod.raw_customer__raw_customer_profile (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age_group VARCHAR(20),
    membership_level VARCHAR(50),
    preferred_location INT
);

CREATE TABLE ota_data_prod.raw_customer__raw_customer_loyalty_status (
    loyalty_id SERIAL PRIMARY KEY,
    customer_id INT,
    points_accrued INT,
    membership_tier VARCHAR(50)
);

CREATE TABLE ota_data_prod.raw_customer__raw_customer_preference (
    preference_id SERIAL PRIMARY KEY,
    customer_id INT,
    preferred_service_type INT
);

-- Schema: raw_finserv
CREATE TABLE ota_data_prod.raw_finserv__raw_payment_transactions (
    payment_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    transaction_date DATE,
    amount DECIMAL(12, 2),
    payment_method VARCHAR(50),
    status VARCHAR(20)
);

CREATE TABLE ota_data_prod.raw_finserv__raw_discount_applications (
    discount_id SERIAL PRIMARY KEY,
    payment_id INT,
    discount_amount DECIMAL(12, 2),
    discount_type VARCHAR(50)
);

CREATE TABLE ota_data_prod.raw_finserv__raw_refund_transactions (
    refund_id SERIAL PRIMARY KEY,
    payment_id INT,
    refund_amount DECIMAL(12, 2),
    refund_reason VARCHAR(100)
);

-- Foreign key constraints for `ota_data_prod.raw_engagement__raw_page_views`
ALTER TABLE ota_data_prod.raw_engagement__raw_page_views
    ADD CONSTRAINT fk_raw_page_views_session_id
    FOREIGN KEY (session_id) REFERENCES ota_data_prod.raw_engagement__raw_customer_sessions(session_id);

-- Foreign key constraints for `ota_data_prod.raw_engagement__raw_funnel_events`
ALTER TABLE ota_data_prod.raw_engagement__raw_funnel_events
    ADD CONSTRAINT fk_raw_funnel_events_session_id
    FOREIGN KEY (session_id) REFERENCES ota_data_prod.raw_engagement__raw_customer_sessions(session_id);

-- Foreign key constraints for `ota_data_prod.raw_marketing__raw_campaign_sales`
ALTER TABLE ota_data_prod.raw_marketing__raw_campaign_sales
    ADD CONSTRAINT fk_raw_campaign_sales_campaign_id
    FOREIGN KEY (campaign_id) REFERENCES ota_data_prod.raw_marketing__raw_campaign_performance(campaign_id);

-- Foreign key constraints for `ota_data_prod.raw_products__raw_product_pricing`
ALTER TABLE ota_data_prod.raw_products__raw_product_pricing
    ADD CONSTRAINT fk_raw_product_pricing_product_id
    FOREIGN KEY (product_id) REFERENCES ota_data_prod.raw_products__raw_product_catalog(product_id);

-- Foreign key constraints for `ota_data_prod.raw_customer__raw_customer_profile`
ALTER TABLE ota_data_prod.raw_customer__raw_customer_profile
    ADD CONSTRAINT fk_raw_customer_profile_preferred_location
    FOREIGN KEY (preferred_location) REFERENCES ota_data_prod.raw_products__raw_location_mapping(location_id);

-- Foreign key constraints for `ota_data_prod.raw_customer__raw_customer_loyalty_status`
ALTER TABLE ota_data_prod.raw_customer__raw_customer_loyalty_status
    ADD CONSTRAINT fk_raw_loyalty_status_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.raw_customer__raw_customer_profile(customer_id);

-- Foreign key constraints for `ota_data_prod.raw_customer__raw_customer_preference`
ALTER TABLE ota_data_prod.raw_customer__raw_customer_preference
    ADD CONSTRAINT fk_raw_customer_preference_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.raw_customer__raw_customer_profile(customer_id);

ALTER TABLE ota_data_prod.raw_customer__raw_customer_preference
    ADD CONSTRAINT fk_raw_customer_preference_service_type
    FOREIGN KEY (preferred_service_type) REFERENCES ota_data_prod.raw_products__raw_service_type_mapping(service_type_id);

-- Foreign key constraints for `ota_data_prod.raw_finserv__raw_discount_applications`
ALTER TABLE ota_data_prod.raw_finserv__raw_discount_applications
    ADD CONSTRAINT fk_raw_discount_applications_payment_id
    FOREIGN KEY (payment_id) REFERENCES ota_data_prod.raw_finserv__raw_payment_transactions(payment_id);

-- Foreign key constraints for `ota_data_prod.raw_finserv__raw_refund_transactions`
ALTER TABLE ota_data_prod.raw_finserv__raw_refund_transactions
    ADD CONSTRAINT fk_raw_refund_transactions_payment_id
    FOREIGN KEY (payment_id) REFERENCES ota_data_prod.raw_finserv__raw_payment_transactions(payment_id);

-- Create tables with the new naming convention

-- Fact Tables

-- Schema: dwh_booking
CREATE TABLE ota_data_prod.dwh_booking__fact_crosssell_transaction (
    crosssell_transaction_id SERIAL PRIMARY KEY,
    customer_id INT,
    primary_service_type_id INT,
    secondary_service_type_id INT,
    primary_product_id INT,
    secondary_product_id INT,
    transaction_date DATE,
    location_id INT,
    bundle_offer_id INT,
    transaction_amount DECIMAL(12, 2),
    bundle_discount_amount DECIMAL(12, 2)
);

CREATE TABLE ota_data_prod.dwh_booking__fact_holiday_sales (
    holiday_sales_id SERIAL PRIMARY KEY,
    customer_id INT,
    service_type_id INT,
    product_id INT,
    location_id INT,
    transaction_date DATE,
    campaign_id INT,
    seasonal_event_id INT,
    sales_amount DECIMAL(12, 2),
    holiday_sales_discount DECIMAL(12, 2),
    is_bundled_flag BOOLEAN
);

-- Schema: dwh_customer
CREATE TABLE ota_data_prod.dwh_customer__fact_multiservice_user (
    multiservice_user_id SERIAL PRIMARY KEY,
    customer_id INT,
    primary_service_type_id INT,
    secondary_service_type_id INT,
    first_transaction_date DATE,
    last_transaction_date DATE,
    total_spend DECIMAL(12, 2),
    total_transactions INT,
    total_bundles_purchased INT
);

-- Schema: dwh_engagement
CREATE TABLE ota_data_prod.dwh_engagement__fact_customer_journey (
    customer_journey_id SERIAL PRIMARY KEY,
    customer_id INT,
    session_id INT,
    page_view_id INT,
    funnel_event_id INT,
    campaign_id INT,
    journey_start TIMESTAMP,
    journey_end TIMESTAMP,
    total_duration INTERVAL
);

-- Schema: dwh_marketing
CREATE TABLE ota_data_prod.dwh_marketing__fact_campaign_performance (
    campaign_performance_id SERIAL PRIMARY KEY,
    campaign_id INT,
    impressions INT,
    clicks INT,
    conversions INT,
    start_date DATE,
    end_date DATE
);

-- Schema: dwh_feedback
CREATE TABLE ota_data_prod.dwh_feedback__fact_product_rating_and_feedback (
    feedback_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    rating INT,
    review_text TEXT,
    review_date DATE
);

-- Dimension Tables

-- Schema: dwh_products
CREATE TABLE ota_data_prod.dwh_products__dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    service_type_id INT,
    product_category VARCHAR(50)
);

CREATE TABLE ota_data_prod.dwh_products__dim_service_type (
    service_type_id SERIAL PRIMARY KEY,
    service_type_name VARCHAR(50)
);

CREATE TABLE ota_data_prod.dwh_products__dim_location (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(100),
    country VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE ota_data_prod.dwh_products__dim_bundle_offer (
    bundle_offer_id SERIAL PRIMARY KEY,
    bundle_offer_name VARCHAR(100),
    primary_service_type_id INT,
    secondary_service_type_id INT,
    discount_amount DECIMAL(12, 2)
);

-- Schema: dwh_customer
CREATE TABLE ota_data_prod.dwh_customer__dim_customer (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age_group VARCHAR(20),
    membership_level VARCHAR(50),
    preferred_location INT
);

CREATE TABLE ota_data_prod.dwh_customer__dim_date (
    date_id DATE PRIMARY KEY,
    date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    week INT,
    is_holiday_flag BOOLEAN,
    holiday_name VARCHAR(100),
    season VARCHAR(50)
);

-- Schema: dwh_marketing
CREATE TABLE ota_data_prod.dwh_marketing__dim_campaign (
    campaign_id SERIAL PRIMARY KEY,
    campaign_name VARCHAR(100),
    campaign_type VARCHAR(50),
    start_date DATE,
    end_date DATE
);

CREATE TABLE ota_data_prod.dwh_marketing__dim_seasonal_event (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(100),
    event_type VARCHAR(50),
    start_date DATE,
    end_date DATE
);

-- Foreign key constraints for dwh_booking fact tables
ALTER TABLE ota_data_prod.dwh_booking__fact_crosssell_transaction
    ADD CONSTRAINT fk_crosssell_transaction_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.dwh_customer__dim_customer(customer_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_crosssell_transaction
    ADD CONSTRAINT fk_crosssell_transaction_primary_service_type_id
    FOREIGN KEY (primary_service_type_id) REFERENCES ota_data_prod.dwh_products__dim_service_type(service_type_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_crosssell_transaction
    ADD CONSTRAINT fk_crosssell_transaction_secondary_service_type_id
    FOREIGN KEY (secondary_service_type_id) REFERENCES ota_data_prod.dwh_products__dim_service_type(service_type_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_crosssell_transaction
    ADD CONSTRAINT fk_crosssell_transaction_primary_product_id
    FOREIGN KEY (primary_product_id) REFERENCES ota_data_prod.dwh_products__dim_product(product_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_crosssell_transaction
    ADD CONSTRAINT fk_crosssell_transaction_secondary_product_id
    FOREIGN KEY (secondary_product_id) REFERENCES ota_data_prod.dwh_products__dim_product(product_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_crosssell_transaction
    ADD CONSTRAINT fk_crosssell_transaction_transaction_date
    FOREIGN KEY (transaction_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_crosssell_transaction
    ADD CONSTRAINT fk_crosssell_transaction_location_id
    FOREIGN KEY (location_id) REFERENCES ota_data_prod.dwh_products__dim_location(location_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_crosssell_transaction
    ADD CONSTRAINT fk_crosssell_transaction_bundle_offer_id
    FOREIGN KEY (bundle_offer_id) REFERENCES ota_data_prod.dwh_products__dim_bundle_offer(bundle_offer_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_holiday_sales
    ADD CONSTRAINT fk_holiday_sales_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.dwh_customer__dim_customer(customer_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_holiday_sales
    ADD CONSTRAINT fk_holiday_sales_service_type_id
    FOREIGN KEY (service_type_id) REFERENCES ota_data_prod.dwh_products__dim_service_type(service_type_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_holiday_sales
    ADD CONSTRAINT fk_holiday_sales_product_id
    FOREIGN KEY (product_id) REFERENCES ota_data_prod.dwh_products__dim_product(product_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_holiday_sales
    ADD CONSTRAINT fk_holiday_sales_location_id
    FOREIGN KEY (location_id) REFERENCES ota_data_prod.dwh_products__dim_location(location_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_holiday_sales
    ADD CONSTRAINT fk_holiday_sales_transaction_date
    FOREIGN KEY (transaction_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_holiday_sales
    ADD CONSTRAINT fk_holiday_sales_campaign_id
    FOREIGN KEY (campaign_id) REFERENCES ota_data_prod.dwh_marketing__dim_campaign(campaign_id);

ALTER TABLE ota_data_prod.dwh_booking__fact_holiday_sales
    ADD CONSTRAINT fk_holiday_sales_seasonal_event_id
    FOREIGN KEY (seasonal_event_id) REFERENCES ota_data_prod.dwh_marketing__dim_seasonal_event(event_id);

-- Foreign key constraints for dwh_customer fact tables
ALTER TABLE ota_data_prod.dwh_customer__fact_multiservice_user
    ADD CONSTRAINT fk_multiservice_user_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.dwh_customer__dim_customer(customer_id);

ALTER TABLE ota_data_prod.dwh_customer__fact_multiservice_user
    ADD CONSTRAINT fk_multiservice_user_primary_service_type_id
    FOREIGN KEY (primary_service_type_id) REFERENCES ota_data_prod.dwh_products__dim_service_type(service_type_id);

ALTER TABLE ota_data_prod.dwh_customer__fact_multiservice_user
    ADD CONSTRAINT fk_multiservice_user_secondary_service_type_id
    FOREIGN KEY (secondary_service_type_id) REFERENCES ota_data_prod.dwh_products__dim_service_type(service_type_id);

ALTER TABLE ota_data_prod.dwh_customer__fact_multiservice_user
    ADD CONSTRAINT fk_multiservice_user_first_transaction_date
    FOREIGN KEY (first_transaction_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.dwh_customer__fact_multiservice_user
    ADD CONSTRAINT fk_multiservice_user_last_transaction_date
    FOREIGN KEY (last_transaction_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

-- Foreign key constraints for dwh_engagement fact tables
ALTER TABLE ota_data_prod.dwh_engagement__fact_customer_journey
    ADD CONSTRAINT fk_customer_journey_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.dwh_customer__dim_customer(customer_id);

ALTER TABLE ota_data_prod.dwh_engagement__fact_customer_journey
    ADD CONSTRAINT fk_customer_journey_campaign_id
    FOREIGN KEY (campaign_id) REFERENCES ota_data_prod.dwh_marketing__dim_campaign(campaign_id);

-- Foreign key constraints for dwh_marketing fact tables
ALTER TABLE ota_data_prod.dwh_marketing__fact_campaign_performance
    ADD CONSTRAINT fk_campaign_performance_campaign_id
    FOREIGN KEY (campaign_id) REFERENCES ota_data_prod.dwh_marketing__dim_campaign(campaign_id);

ALTER TABLE ota_data_prod.dwh_marketing__fact_campaign_performance
    ADD CONSTRAINT fk_campaign_performance_start_date
    FOREIGN KEY (start_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.dwh_marketing__fact_campaign_performance
    ADD CONSTRAINT fk_campaign_performance_end_date
    FOREIGN KEY (end_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

-- Foreign key constraints for dwh_feedback fact tables
ALTER TABLE ota_data_prod.dwh_feedback__fact_product_rating_and_feedback
    ADD CONSTRAINT fk_product_rating_feedback_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.dwh_customer__dim_customer(customer_id);

ALTER TABLE ota_data_prod.dwh_feedback__fact_product_rating_and_feedback
    ADD CONSTRAINT fk_product_rating_feedback_product_id
    FOREIGN KEY (product_id) REFERENCES ota_data_prod.dwh_products__dim_product(product_id);

ALTER TABLE ota_data_prod.dwh_feedback__fact_product_rating_and_feedback
    ADD CONSTRAINT fk_product_rating_feedback_review_date
    FOREIGN KEY (review_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

-- Foreign key constraints for dwh_products dimension tables
ALTER TABLE ota_data_prod.dwh_products__dim_product
    ADD CONSTRAINT fk_dim_product_service_type_id
    FOREIGN KEY (service_type_id) REFERENCES ota_data_prod.dwh_products__dim_service_type(service_type_id);

ALTER TABLE ota_data_prod.dwh_products__dim_bundle_offer
    ADD CONSTRAINT fk_dim_bundle_offer_primary_service_type_id
    FOREIGN KEY (primary_service_type_id) REFERENCES ota_data_prod.dwh_products__dim_service_type(service_type_id);

ALTER TABLE ota_data_prod.dwh_products__dim_bundle_offer
    ADD CONSTRAINT fk_dim_bundle_offer_secondary_service_type_id
    FOREIGN KEY (secondary_service_type_id) REFERENCES ota_data_prod.dwh_products__dim_service_type(service_type_id);

-- Foreign key constraints for dwh_customer dimension tables
ALTER TABLE ota_data_prod.dwh_customer__dim_customer
    ADD CONSTRAINT fk_dim_customer_preferred_location
    FOREIGN KEY (preferred_location) REFERENCES ota_data_prod.dwh_products__dim_location(location_id);

-- Foreign key constraints for dwh_marketing dimension tables
ALTER TABLE ota_data_prod.dwh_marketing__dim_campaign
    ADD CONSTRAINT fk_dim_campaign_start_date
    FOREIGN KEY (start_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.dwh_marketing__dim_campaign
    ADD CONSTRAINT fk_dim_campaign_end_date
    FOREIGN KEY (end_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.dwh_marketing__dim_seasonal_event
    ADD CONSTRAINT fk_dim_seasonal_event_start_date
    FOREIGN KEY (start_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.dwh_marketing__dim_seasonal_event
    ADD CONSTRAINT fk_dim_seasonal_event_end_date
    FOREIGN KEY (end_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

-- Create a ota_data_prod schema (if not exists) for all Datamart tables


-- Create datamart tables with the new naming convention

-- Schema: datamart_booking
CREATE TABLE ota_data_prod.datamart_booking__seasonal_cross_sell_performance (
    crosssell_performance_id SERIAL PRIMARY KEY,
    transaction_date DATE,
    customer_id INT,
    primary_service_type_name VARCHAR(50),
    secondary_service_type_name VARCHAR(50),
    primary_product_name VARCHAR(100),
    secondary_product_name VARCHAR(100),
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    bundle_offer_name VARCHAR(100),
    transaction_amount DECIMAL(12, 2),
    bundle_discount_amount DECIMAL(12, 2),
    is_holiday_flag BOOLEAN,
    holiday_name VARCHAR(100)
);

-- Schema: datamart_marketing
CREATE TABLE ota_data_prod.datamart_marketing__holiday_service_bundle_analysis (
    bundle_analysis_id SERIAL PRIMARY KEY,
    transaction_date DATE,
    customer_id INT,
    campaign_name VARCHAR(100),
    service_type_name VARCHAR(50),
    product_name VARCHAR(100),
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    seasonal_event_name VARCHAR(100),
    sales_amount DECIMAL(12, 2),
    holiday_sales_discount DECIMAL(12, 2),
    is_bundled_flag BOOLEAN,
    bundle_offer_name VARCHAR(100)
);

-- Schema: datamart_customer
CREATE TABLE ota_data_prod.datamart_customer__multi_service_customer_behavior (
    multi_service_behavior_id SERIAL PRIMARY KEY,
    customer_id INT,
    first_transaction_date DATE,
    last_transaction_date DATE,
    total_spend DECIMAL(12, 2),
    total_transactions INT,
    total_bundles_purchased INT,
    primary_service_type_name VARCHAR(50),
    secondary_service_type_name VARCHAR(50),
    preferred_location_city VARCHAR(100),
    preferred_location_country VARCHAR(100),
    preferred_membership_level VARCHAR(50),
    loyalty_points_accrued INT
);

-- Foreign key constraints for datamart_booking__seasonal_cross_sell_performance
ALTER TABLE ota_data_prod.datamart_booking__seasonal_cross_sell_performance
    ADD CONSTRAINT fk_crosssell_performance_transaction_date
    FOREIGN KEY (transaction_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.datamart_booking__seasonal_cross_sell_performance
    ADD CONSTRAINT fk_crosssell_performance_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.dwh_customer__dim_customer(customer_id);

-- Foreign key constraints for datamart_marketing__holiday_service_bundle_analysis
ALTER TABLE ota_data_prod.datamart_marketing__holiday_service_bundle_analysis
    ADD CONSTRAINT fk_bundle_analysis_transaction_date
    FOREIGN KEY (transaction_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.datamart_marketing__holiday_service_bundle_analysis
    ADD CONSTRAINT fk_bundle_analysis_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.dwh_customer__dim_customer(customer_id);

-- Foreign key constraints for datamart_customer__multi_service_customer_behavior
ALTER TABLE ota_data_prod.datamart_customer__multi_service_customer_behavior
    ADD CONSTRAINT fk_multi_service_behavior_customer_id
    FOREIGN KEY (customer_id) REFERENCES ota_data_prod.dwh_customer__dim_customer(customer_id);

ALTER TABLE ota_data_prod.datamart_customer__multi_service_customer_behavior
    ADD CONSTRAINT fk_multi_service_behavior_first_transaction_date
    FOREIGN KEY (first_transaction_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);

ALTER TABLE ota_data_prod.datamart_customer__multi_service_customer_behavior
    ADD CONSTRAINT fk_multi_service_behavior_last_transaction_date
    FOREIGN KEY (last_transaction_date) REFERENCES ota_data_prod.dwh_customer__dim_date(date_id);
