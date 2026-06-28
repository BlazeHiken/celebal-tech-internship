-- ============================================================
-- SECTION C: AGGREGATION QUERIES
-- Database: celebaldb
-- Tables  : customers, products, orders, order_items
-- ============================================================


-- ============================================================
-- C1. COUNT
-- ============================================================

-- Total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Total number of line items
SELECT COUNT(*) AS total_line_items
FROM order_items;

-- Number of orders per region
SELECT region, COUNT(*) AS order_count
FROM orders
GROUP BY region
ORDER BY order_count DESC;

-- Number of orders per ship mode
SELECT ship_mode, COUNT(*) AS order_count
FROM orders
GROUP BY ship_mode
ORDER BY order_count DESC;

-- Number of products per category
SELECT category, COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY product_count DESC;

-- Number of products per sub-category
SELECT sub_category, COUNT(*) AS product_count
FROM products
GROUP BY sub_category
ORDER BY product_count DESC;

-- Number of customers per segment
SELECT segment, COUNT(*) AS customer_count
FROM customers
GROUP BY segment
ORDER BY customer_count DESC;

-- Number of orders per year
SELECT YEAR(order_date) AS order_year, COUNT(*) AS order_count
FROM orders
GROUP BY order_year
ORDER BY order_year ASC;

-- Number of orders per state (top 10)
SELECT state, COUNT(*) AS order_count
FROM orders
GROUP BY state
ORDER BY order_count DESC
LIMIT 10;


-- ============================================================
-- C2. SUM
-- ============================================================

-- Total sales across all line items
SELECT ROUND(SUM(sales), 2) AS total_sales
FROM order_items;

-- Total profit across all line items
SELECT ROUND(SUM(profit), 2) AS total_profit
FROM order_items;

-- Total sales by category
SELECT p.category, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

-- Total sales by sub-category
SELECT p.sub_category, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.sub_category
ORDER BY total_sales DESC;

-- Total sales by region
SELECT o.region, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.region
ORDER BY total_sales DESC;

-- Total profit by region
SELECT o.region, ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.region
ORDER BY total_profit DESC;

-- Total sales by year
SELECT YEAR(o.order_date) AS order_year, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY order_year
ORDER BY order_year ASC;

-- Total sales by customer segment
SELECT c.segment, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN orders o  ON oi.order_id  = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_sales DESC;

-- Total quantity sold by category
SELECT p.category, SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_quantity DESC;


-- ============================================================
-- C3. AVG
-- ============================================================

-- Average sales per line item
SELECT ROUND(AVG(sales), 2) AS avg_sales_per_item
FROM order_items;

-- Average profit per line item
SELECT ROUND(AVG(profit), 2) AS avg_profit_per_item
FROM order_items;

-- Average discount applied
SELECT ROUND(AVG(discount), 4) AS avg_discount
FROM order_items;

-- Average sales by category
SELECT p.category, ROUND(AVG(oi.sales), 2) AS avg_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_sales DESC;

-- Average profit by region
SELECT o.region, ROUND(AVG(oi.profit), 2) AS avg_profit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.region
ORDER BY avg_profit DESC;

-- Average discount by category
SELECT p.category, ROUND(AVG(oi.discount), 4) AS avg_discount
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_discount DESC;

-- Average quantity per order
SELECT ROUND(AVG(quantity), 2) AS avg_quantity_per_item
FROM order_items;


-- ============================================================
-- C4. MAX and MIN
-- ============================================================

-- Highest and lowest single sale
SELECT
    MAX(sales) AS max_sale,
    MIN(sales) AS min_sale
FROM order_items;

-- Highest and lowest profit on a single line item
SELECT
    MAX(profit) AS max_profit,
    MIN(profit) AS min_profit
FROM order_items;

-- Highest discount ever applied
SELECT MAX(discount) AS max_discount
FROM order_items;

-- Max and min sales by category
SELECT p.category,
    ROUND(MAX(oi.sales), 2) AS max_sale,
    ROUND(MIN(oi.sales), 2) AS min_sale
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category;

-- Most recent and oldest order date
SELECT
    MAX(order_date) AS latest_order,
    MIN(order_date) AS earliest_order
FROM orders;


-- ============================================================
-- C5. GROUP BY with HAVING (filter on aggregated results)
-- ============================================================

-- Categories with total sales above 500,000
SELECT p.category, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
HAVING total_sales > 500000;

-- Sub-categories with average discount above 20%
SELECT p.sub_category, ROUND(AVG(oi.discount), 4) AS avg_discount
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.sub_category
HAVING avg_discount > 0.20
ORDER BY avg_discount DESC;

-- Regions with total profit below 50,000
SELECT o.region, ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.region
HAVING total_profit < 50000;

-- States with more than 100 orders
SELECT state, COUNT(*) AS order_count
FROM orders
GROUP BY state
HAVING order_count > 100
ORDER BY order_count DESC;

-- Customers with more than 10 orders
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING order_count > 10
ORDER BY order_count DESC;


-- ============================================================
-- C6. Monthly trends (year + month aggregation)
-- ============================================================

-- Total sales per month across all years
SELECT
    YEAR(o.order_date)  AS order_year,
    MONTH(o.order_date) AS order_month,
    ROUND(SUM(oi.sales), 2)  AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    COUNT(DISTINCT o.order_id) AS order_count
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY order_year, order_month
ORDER BY order_year ASC, order_month ASC;


-- ============================================================
-- C7. Top N using aggregation + ORDER BY + LIMIT
-- ============================================================

-- Top 5 sub-categories by total sales
SELECT p.sub_category, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.sub_category
ORDER BY total_sales DESC
LIMIT 5;

-- Top 10 customers by total spend
SELECT c.customer_id, c.customer_name, ROUND(SUM(oi.sales), 2) AS total_spend
FROM order_items oi
JOIN orders o     ON oi.order_id  = o.order_id
JOIN customers c  ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spend DESC
LIMIT 10;

-- Top 5 states by total sales
SELECT o.state, ROUND(SUM(oi.sales), 2) AS total_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.state
ORDER BY total_sales DESC
LIMIT 5;

-- Bottom 5 sub-categories by profit (most loss-making)
SELECT p.sub_category, ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.sub_category
ORDER BY total_profit ASC
LIMIT 5;