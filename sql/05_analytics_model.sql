-- =========================
-- ANALYTICS MODEL
-- =========================


-- =========================
-- DIM CUSTOMER
-- =========================

-- Grain: one row per customer_id.
-- customer_unique_id is retained to identify the same real customer
-- across multiple customer records/orders.
-- Customer latitude and longitude are derived from geolocation data
-- using ZIP prefix, city, and state.

DROP TABLE IF EXISTS analytics.dim_customer;

CREATE TABLE analytics.dim_customer AS
SELECT
    c.*,
    g.avg_latitude,
    g.avg_longitude
FROM staging.customers c
LEFT JOIN (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,
        AVG(geolocation_lat) AS avg_latitude,
        AVG(geolocation_lng) AS avg_longitude
    FROM staging.geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state
) g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
   AND LOWER(TRIM(unaccent(c.customer_city))) = g.geolocation_city
   AND c.customer_state = g.geolocation_state;


-- =========================
-- DIM PRODUCT
-- =========================

-- Grain: one row per product_id.
-- English product category is added from the translation lookup.

DROP TABLE IF EXISTS analytics.dim_product;

CREATE TABLE analytics.dim_product AS
SELECT
    p.*,
    t.product_category_name_english
FROM staging.products p
LEFT JOIN staging.product_category_translation t
    ON p.product_category_name = t.product_category_name;


-- =========================
-- DIM SELLER
-- =========================

-- Grain: one row per seller_id.
-- Seller latitude and longitude are derived from geolocation data
-- using ZIP prefix, city, and state.

DROP TABLE IF EXISTS analytics.dim_seller;

CREATE TABLE analytics.dim_seller AS
SELECT
    s.*,
    g.avg_latitude,
    g.avg_longitude
FROM staging.sellers s
LEFT JOIN (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,
        AVG(geolocation_lat) AS avg_latitude,
        AVG(geolocation_lng) AS avg_longitude
    FROM staging.geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state
) g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
   AND LOWER(TRIM(unaccent(s.seller_city))) = g.geolocation_city
   AND s.seller_state = g.geolocation_state;


-- =========================
-- DIM DATE
-- =========================

-- Grain: one row per calendar date.
-- Shared calendar dimension used for time-based analysis.

DROP TABLE IF EXISTS analytics.dim_date;

CREATE TABLE analytics.dim_date AS
SELECT
    date_value::date AS date,
    EXTRACT(YEAR FROM date_value) AS year,
    EXTRACT(MONTH FROM date_value) AS month_number,
    TO_CHAR(date_value, 'FMMonth') AS month_name,
    EXTRACT(QUARTER FROM date_value) AS quarter,
    EXTRACT(DAY FROM date_value) AS day,
    TO_CHAR(date_value, 'FMDay') AS day_name
FROM generate_series(
    '2016-09-04'::date,
    '2018-11-12'::date,
    INTERVAL '1 day'
) AS date_value;


-- =========================
-- DIM ORDER STATUS
-- =========================

-- Grain: one row per order status.
-- Shared status dimension used to filter order-level and item-level facts consistently.

DROP TABLE IF EXISTS analytics.dim_order_status;

CREATE TABLE analytics.dim_order_status AS
SELECT DISTINCT
    order_status
FROM staging.orders;


-- =========================
-- FACT ORDER
-- =========================

-- Grain: one row per order.
-- Contains order-level status and lifecycle dates.

DROP TABLE IF EXISTS analytics.fact_order;

CREATE TABLE analytics.fact_order AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::date AS purchase_date,
    order_approved_at::date AS approved_date,
    order_delivered_carrier_date::date AS carrier_date,
    order_delivered_customer_date::date AS delivered_date,
    order_estimated_delivery_date::date AS estimated_delivery_date,
    delivery_date_issue
FROM staging.orders;


-- =========================
-- FACT ORDER ITEM
-- =========================

-- Grain: one row per order item.
-- Item-level sales data is combined with selected order-level attributes.
-- customer_id links to dim_customer.
-- product_id links to dim_product.
-- seller_id links to dim_seller.
-- order_status links to dim_order_status.
-- purchase_date links to dim_date.

DROP TABLE IF EXISTS analytics.fact_order_item;

CREATE TABLE analytics.fact_order_item AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_status,
    o.order_purchase_timestamp::date AS purchase_date,
    oi.price,
    oi.freight_value
FROM staging.order_items oi
INNER JOIN staging.orders o
    ON oi.order_id = o.order_id;


-- =========================
-- FACT ORDER PAYMENT
-- =========================

-- Grain: one row per payment record.
-- (order_id, payment_sequential) uniquely identifies a payment record.
-- customer_id is added to support direct customer-based filtering.
-- purchase_date is added to support direct time-based payment analysis.

DROP TABLE IF EXISTS analytics.fact_order_payment;

CREATE TABLE analytics.fact_order_payment AS
SELECT
    op.*,
    o.customer_id,
    o.order_purchase_timestamp::date AS purchase_date
FROM staging.order_payments op
LEFT JOIN staging.orders o
    ON op.order_id = o.order_id;


-- =========================
-- FACT ORDER REVIEW
-- =========================

-- Grain: one row per review record.
-- (review_id, order_id) uniquely identifies a review record.
-- customer_id is added to support direct customer-based filtering.
-- Review timestamps are converted to dates for time-based analysis.

DROP TABLE IF EXISTS analytics.fact_order_review;

CREATE TABLE analytics.fact_order_review AS
SELECT
    r.review_id,
    r.order_id,
    o.customer_id,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message,
    r.review_creation_date::date AS review_date,
    r.review_answer_timestamp::date AS review_answer_date
FROM staging.order_reviews r
LEFT JOIN staging.orders o
    ON r.order_id = o.order_id;