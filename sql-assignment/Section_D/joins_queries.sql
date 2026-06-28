-- ============================================================
-- SECTION D: JOIN QUERIES
-- Database: celebaldb
-- Tables  : customers, products, orders, order_items
-- ============================================================


-- ============================================================
-- D1. Basic INNER JOIN (only matching records)
-- ============================================================

-- Orders with customer details
SELECT
    o.order_id,
    o.order_date,
    o.ship_mode,
    o.region,
    c.customer_name,
    c.segment
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
LIMIT 10;

-- Order items with product details
SELECT
    oi.item_id,
    oi.order_id,
    p.product_name,
    p.category,
    p.sub_category,
    oi.sales,
    oi.quantity,
    oi.profit
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
LIMIT 10;

-- Orders with order items (one order → many items)
SELECT
    o.order_id,
    o.order_date,
    o.region,
    oi.product_id,
    oi.sales,
    oi.quantity
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
LIMIT 10;


-- ============================================================
-- D2. Three-table INNER JOIN
-- ============================================================

-- Full order details: customer + order + item
SELECT
    c.customer_name,
    c.segment,
    o.order_id,
    o.order_date,
    o.region,
    oi.sales,
    oi.quantity,
    oi.profit
FROM customers c
INNER JOIN orders      o  ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id    = oi.order_id
LIMIT 10;

-- Full line item detail: customer + order + item + product
SELECT
    c.customer_name,
    c.segment,
    o.order_date,
    o.ship_mode,
    o.region,
    p.category,
    p.sub_category,
    p.product_name,
    oi.sales,
    oi.quantity,
    oi.discount,
    oi.profit
FROM customers c
INNER JOIN orders      o  ON c.customer_id  = o.customer_id
INNER JOIN order_items oi ON o.order_id     = oi.order_id
INNER JOIN products    p  ON oi.product_id  = p.product_id
LIMIT 10;


-- ============================================================
-- D3. INNER JOIN with WHERE filter
-- ============================================================

-- All Technology orders in the West region
SELECT
    c.customer_name,
    o.order_date,
    o.region,
    p.category,
    p.product_name,
    oi.sales,
    oi.profit
FROM customers c
INNER JOIN orders      o  ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id    = oi.order_id
INNER JOIN products    p  ON oi.product_id = p.product_id
WHERE p.category = 'Technology'
  AND o.region   = 'West';

-- Corporate customers with sales above 1000
SELECT
    c.customer_name,
    c.segment,
    o.order_id,
    o.order_date,
    oi.sales,
    oi.profit
FROM customers c
INNER JOIN orders      o  ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id    = oi.order_id
WHERE c.segment  = 'Corporate'
  AND oi.sales   > 1000
ORDER BY oi.sales DESC;

-- Loss-making Furniture orders
SELECT
    o.order_id,
    o.order_date,
    o.region,
    p.sub_category,
    p.product_name,
    oi.sales,
    oi.discount,
    oi.profit
FROM order_items oi
INNER JOIN orders   o ON oi.order_id   = o.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE p.category = 'Furniture'
  AND oi.profit  < 0
ORDER BY oi.profit ASC;


-- ============================================================
-- D4. INNER JOIN with GROUP BY (aggregation across tables)
-- ============================================================

-- Total sales per customer (top 10)
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    ROUND(SUM(oi.sales), 2)  AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
INNER JOIN orders      o  ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY total_sales DESC
LIMIT 10;

-- Total sales and profit per category per region
SELECT
    o.region,
    p.category,
    ROUND(SUM(oi.sales), 2)  AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
INNER JOIN orders   o ON oi.order_id   = o.order_id
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY o.region, p.category
ORDER BY o.region ASC, total_sales DESC;

-- Number of orders and total sales per customer segment per year
SELECT
    YEAR(o.order_date)         AS order_year,
    c.segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.sales), 2)    AS total_sales
FROM customers c
INNER JOIN orders      o  ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY order_year, c.segment
ORDER BY order_year ASC, total_sales DESC;


-- ============================================================
-- D5. LEFT JOIN (include all records from left table)
-- ============================================================

-- All customers, including those with no orders
-- (customers with no orders will show NULL in order columns)
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_name ASC
LIMIT 20;

-- Customers who have NEVER placed an order
SELECT
    c.customer_id,
    c.customer_name,
    c.segment
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- All products, including those never ordered
SELECT
    p.product_id,
    p.product_name,
    p.category,
    oi.order_id,
    oi.sales
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
ORDER BY p.category ASC
LIMIT 20;

-- Products that have never been ordered
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;


-- ============================================================
-- D6. LEFT JOIN with aggregation
-- ============================================================

-- All customers with their total order count
-- (customers with no orders show 0)
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY total_orders DESC
LIMIT 10;

-- All products with total quantity sold
-- (products never ordered show 0)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(ROUND(SUM(oi.sales), 2), 0) AS total_sales
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_sales DESC
LIMIT 10;


-- ============================================================
-- D7. Practical business queries using JOINs
-- ============================================================

-- Top 5 most profitable products
SELECT
    p.product_id,
    p.product_name,
    p.category,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_profit DESC
LIMIT 5;

-- Top 5 most loss-making products
SELECT
    p.product_id,
    p.product_name,
    p.category,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_profit ASC
LIMIT 5;

-- Which ship mode generates the most sales?
SELECT
    o.ship_mode,
    COUNT(DISTINCT o.order_id)  AS total_orders,
    ROUND(SUM(oi.sales), 2)     AS total_sales,
    ROUND(SUM(oi.profit), 2)    AS total_profit
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.ship_mode
ORDER BY total_sales DESC;

-- Sales performance by state (top 10)
SELECT
    o.state,
    o.region,
    COUNT(DISTINCT o.order_id)  AS total_orders,
    ROUND(SUM(oi.sales), 2)     AS total_sales,
    ROUND(SUM(oi.profit), 2)    AS total_profit
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.state, o.region
ORDER BY total_sales DESC
LIMIT 10;