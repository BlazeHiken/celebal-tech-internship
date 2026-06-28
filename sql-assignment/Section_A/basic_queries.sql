-- ============================================================
-- SECTION A: BASIC QUERIES
-- Database: celebaldb
-- Tables  : customers, products, orders, order_items
-- ============================================================


-- ============================================================
-- A1. View all records from each table
-- ============================================================

-- All customers
SELECT * FROM customers;

-- All products
SELECT * FROM products;

-- All orders
SELECT * FROM orders;

-- All order items
SELECT * FROM order_items;


-- ============================================================
-- A2. View table schemas
-- ============================================================

DESCRIBE customers;
DESCRIBE products;
DESCRIBE orders;
DESCRIBE order_items;


-- ============================================================
-- A3. Row counts per table
-- ============================================================

SELECT 'customers'   AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products',                  COUNT(*)              FROM products
UNION ALL
SELECT 'orders',                    COUNT(*)              FROM orders
UNION ALL
SELECT 'order_items',               COUNT(*)              FROM order_items;


-- ============================================================
-- A4. Sample data (first 10 rows from each table)
-- ============================================================

SELECT * FROM customers   LIMIT 10;
SELECT * FROM products    LIMIT 10;
SELECT * FROM orders      LIMIT 10;
SELECT * FROM order_items LIMIT 10;


-- ============================================================
-- A5. Select specific columns
-- ============================================================

-- Customer names and segments only
SELECT customer_id, customer_name, segment
FROM customers;

-- Product names and categories only
SELECT product_id, product_name, category, sub_category
FROM products;

-- Order dates and ship modes only
SELECT order_id, order_date, ship_date, ship_mode
FROM orders;


-- ============================================================
-- A6. Distinct values
-- ============================================================

-- Distinct customer segments
SELECT DISTINCT segment FROM customers;

-- Distinct product categories
SELECT DISTINCT category FROM products;

-- Distinct sub-categories
SELECT DISTINCT sub_category FROM products;

-- Distinct ship modes
SELECT DISTINCT ship_mode FROM orders;

-- Distinct regions
SELECT DISTINCT region FROM orders;


-- ============================================================
-- A7. Basic column aliases
-- ============================================================

SELECT
    customer_id   AS "Customer ID",
    customer_name AS "Customer Name",
    segment       AS "Segment"
FROM customers;

SELECT
    product_id   AS "Product ID",
    product_name AS "Product Name",
    category     AS "Category"
FROM products;


-- ============================================================
-- A8. ORDER BY (basic sorting)
-- ============================================================

-- Customers alphabetically
SELECT customer_id, customer_name, segment
FROM customers
ORDER BY customer_name ASC;

-- Products by category then sub-category
SELECT product_id, category, sub_category, product_name
FROM products
ORDER BY category ASC, sub_category ASC;

-- Orders by most recent order date
SELECT order_id, order_date, ship_date, ship_mode
FROM orders
ORDER BY order_date DESC;

-- Order items by sales descending
SELECT item_id, order_id, product_id, sales
FROM order_items
ORDER BY sales DESC;


-- ============================================================
-- A9. LIMIT results
-- ============================================================

-- Top 5 most recent orders
SELECT order_id, order_date, ship_mode, region
FROM orders
ORDER BY order_date DESC
LIMIT 5;

-- Top 10 highest sales line items
SELECT item_id, order_id, product_id, sales, quantity
FROM order_items
ORDER BY sales DESC
LIMIT 10;


-- ============================================================
-- A10. NULL checks (data quality)
-- ============================================================

-- Check for NULLs in customers
SELECT COUNT(*) AS null_customer_name FROM customers WHERE customer_name IS NULL;
SELECT COUNT(*) AS null_segment       FROM customers WHERE segment IS NULL;

-- Check for NULLs in products
SELECT COUNT(*) AS null_product_name  FROM products  WHERE product_name IS NULL;
SELECT COUNT(*) AS null_category      FROM products  WHERE category IS NULL;

-- Check for NULLs in orders
SELECT COUNT(*) AS null_order_date    FROM orders    WHERE order_date IS NULL;
SELECT COUNT(*) AS null_ship_date     FROM orders    WHERE ship_date IS NULL;

-- Check for NULLs in order_items
SELECT COUNT(*) AS null_sales         FROM order_items WHERE sales IS NULL;
SELECT COUNT(*) AS null_profit        FROM order_items WHERE profit IS NULL;