-- ============================================================
-- SWYNEX - Data Cleaning & Preparation
-- Tool: PostgreSQL
-- Dataset: Brazilian E-Commerce (Olist)
-- ============================================================


-- ============================================================
-- 1. CHECK TABLES
-- ============================================================

SELECT COUNT(*) AS customers_rows FROM customers_raw;
SELECT COUNT(*) AS orders_rows FROM orders_raw;
SELECT COUNT(*) AS order_items_rows FROM order_items_raw;
SELECT COUNT(*) AS payments_rows FROM payments_raw;
SELECT COUNT(*) AS reviews_rows FROM reviews_raw;
SELECT COUNT(*) AS products_rows FROM products_raw;
SELECT COUNT(*) AS sellers_rows FROM sellers_raw;


-- ============================================================
-- 2. MISSING VALUE CHECKS
-- ============================================================

SELECT
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS missing_customer_unique_id,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS missing_zip_code,
    COUNT(*) FILTER (WHERE customer_city IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE customer_state IS NULL) AS missing_state
FROM customers_raw;


SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS missing_order_status,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS missing_purchase_date
FROM orders_raw;


SELECT
    COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS missing_seller_id,
    COUNT(*) FILTER (WHERE price IS NULL) AS missing_price,
    COUNT(*) FILTER (WHERE freight_value IS NULL) AS missing_freight
FROM order_items_raw;


SELECT
    COUNT(*) FILTER (WHERE payment_type IS NULL) AS missing_payment_type,
    COUNT(*) FILTER (WHERE payment_value IS NULL) AS missing_payment_value
FROM payments_raw;


-- ============================================================
-- 3. DUPLICATE CHECKS
-- ============================================================

SELECT customer_id, COUNT(*)
FROM customers_raw
GROUP BY customer_id
HAVING COUNT(*) > 1;


SELECT order_id, COUNT(*)
FROM orders_raw
GROUP BY order_id
HAVING COUNT(*) > 1;


SELECT seller_id, COUNT(*)
FROM sellers_raw
GROUP BY seller_id
HAVING COUNT(*) > 1;


SELECT product_id, COUNT(*)
FROM products_raw
GROUP BY product_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. INVALID VALUE CHECKS
-- ============================================================

-- Invalid prices
SELECT *
FROM order_items_raw
WHERE price < 0
   OR freight_value < 0;


-- Invalid payment values
SELECT *
FROM payments_raw
WHERE payment_value < 0;


-- Invalid review scores
SELECT *
FROM reviews_raw
WHERE review_score NOT BETWEEN 1 AND 5;


-- Invalid order status
SELECT DISTINCT order_status
FROM orders_raw;


-- Invalid payment types
SELECT DISTINCT payment_type
FROM payments_raw;


-- ============================================================
-- 5. INCONSISTENT VALUE CHECKS
-- ============================================================

-- City/state values
SELECT DISTINCT customer_state
FROM customers_raw
ORDER BY customer_state;


SELECT DISTINCT seller_state
FROM sellers_raw
ORDER BY seller_state;


-- Payment types
SELECT DISTINCT payment_type
FROM payments_raw
ORDER BY payment_type;


-- Order statuses
SELECT DISTINCT order_status
FROM orders_raw
ORDER BY order_status;


-- ============================================================
-- 6. CREATE CLEANED CUSTOMERS TABLE
-- ============================================================

DROP TABLE IF EXISTS customers_cleaned_sql;

CREATE TABLE customers_cleaned_sql AS
SELECT DISTINCT
    TRIM(customer_id) AS customer_id,
    TRIM(customer_unique_id) AS customer_unique_id,
    customer_zip_code_prefix,
    INITCAP(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM customers_raw
WHERE customer_id IS NOT NULL
  AND customer_unique_id IS NOT NULL;


-- ============================================================
-- 7. CREATE CLEANED ORDERS TABLE
-- ============================================================

DROP TABLE IF EXISTS orders_cleaned_sql;

CREATE TABLE orders_cleaned_sql AS
SELECT DISTINCT
    TRIM(order_id) AS order_id,
    TRIM(customer_id) AS customer_id,
    LOWER(TRIM(order_status)) AS order_status,
    CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
    CAST(order_approved_at AS TIMESTAMP) AS order_approved_at,
    CAST(order_delivered_carrier_date AS TIMESTAMP) AS order_delivered_carrier_date,
    CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date
FROM orders_raw
WHERE order_id IS NOT NULL
  AND customer_id IS NOT NULL
  AND order_status IS NOT NULL;


-- ============================================================
-- 8. CREATE CLEANED ORDER ITEMS TABLE
-- ============================================================

DROP TABLE IF EXISTS order_items_cleaned_sql;

CREATE TABLE order_items_cleaned_sql AS
SELECT DISTINCT
    TRIM(order_id) AS order_id,
    order_item_id,
    TRIM(product_id) AS product_id,
    TRIM(seller_id) AS seller_id,
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
    CAST(price AS NUMERIC(12,2)) AS price,
    CAST(freight_value AS NUMERIC(12,2)) AS freight_value
FROM order_items_raw
WHERE order_id IS NOT NULL
  AND product_id IS NOT NULL
  AND seller_id IS NOT NULL
  AND price >= 0
  AND freight_value >= 0;


-- ============================================================
-- 9. CREATE CLEANED PAYMENTS TABLE
-- ============================================================

DROP TABLE IF EXISTS payments_cleaned_sql;

CREATE TABLE payments_cleaned_sql AS
SELECT DISTINCT
    TRIM(order_id) AS order_id,
    payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    payment_installments,
    CAST(payment_value AS NUMERIC(12,2)) AS payment_value
FROM payments_raw
WHERE order_id IS NOT NULL
  AND payment_type IS NOT NULL
  AND payment_value >= 0
  AND payment_installments >= 0;


-- ============================================================
-- 10. CREATE CLEANED REVIEWS TABLE
-- ============================================================

DROP TABLE IF EXISTS reviews_cleaned_sql;

CREATE TABLE reviews_cleaned_sql AS
SELECT DISTINCT
    TRIM(review_id) AS review_id,
    TRIM(order_id) AS order_id,
    review_score,
    CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
    CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp,
    NULLIF(TRIM(review_comment_title), '') AS review_comment_title,
    NULLIF(TRIM(review_comment_message), '') AS review_comment_message
FROM reviews_raw
WHERE review_id IS NOT NULL
  AND order_id IS NOT NULL
  AND review_score BETWEEN 1 AND 5;


-- ============================================================
-- 11. CREATE CLEANED PRODUCTS TABLE
-- ============================================================

DROP TABLE IF EXISTS products_cleaned_sql;

CREATE TABLE products_cleaned_sql AS
SELECT DISTINCT
    TRIM(product_id) AS product_id,
    NULLIF(TRIM(product_category_name), '') AS product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products_raw
WHERE product_id IS NOT NULL;


-- ============================================================
-- 12. CREATE CLEANED SELLERS TABLE
-- ============================================================

DROP TABLE IF EXISTS sellers_cleaned_sql;

CREATE TABLE sellers_cleaned_sql AS
SELECT DISTINCT
    TRIM(seller_id) AS seller_id,
    seller_zip_code_prefix,
    INITCAP(TRIM(seller_city)) AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
FROM sellers_raw
WHERE seller_id IS NOT NULL;


-- ============================================================
-- 13. FINAL DATA QUALITY CHECK
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS cleaned_rows
FROM customers_cleaned_sql

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders_cleaned_sql

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items_cleaned_sql

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments_cleaned_sql

UNION ALL

SELECT 'reviews', COUNT(*)
FROM reviews_cleaned_sql

UNION ALL

SELECT 'products', COUNT(*)
FROM products_cleaned_sql

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers_cleaned_sql;


-- ============================================================
-- 14. VERIFY NO INVALID REVIEW SCORES
-- ============================================================

SELECT COUNT(*) AS invalid_review_scores
FROM reviews_cleaned_sql
WHERE review_score NOT BETWEEN 1 AND 5;


-- ============================================================
-- 15. VERIFY NO NEGATIVE TRANSACTION VALUES
-- ============================================================

SELECT COUNT(*) AS invalid_prices
FROM order_items_cleaned_sql
WHERE price < 0 OR freight_value < 0;

SELECT COUNT(*) AS invalid_payments
FROM payments_cleaned_sql
WHERE payment_value < 0;






