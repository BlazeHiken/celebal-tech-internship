-- SQL Advanced Analytics: Subqueries, CTEs, Window Functions

-- STEP 1: SETUP DATA

-- 1a. Staging table
CREATE TABLE IF NOT EXISTS superstore_raw (
    row_id          INT PRIMARY KEY,
    order_id        VARCHAR(20),
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR(50),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(50),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(20),
    region          VARCHAR(50),
    product_id      VARCHAR(20),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(255),
    sales           DECIMAL(10,2),
    quantity        INT,
    discount        DECIMAL(4,2),
    profit          DECIMAL(10,2)
);

-- Loaded table through python script by reading csv

-- 1b. Normalized tables
CREATE TABLE IF NOT EXISTS customers1 (
    customer_id     VARCHAR(20) PRIMARY KEY,
    customer_name   VARCHAR(100),
    segment         VARCHAR(50),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(20),
    region          VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS products1 (
    product_id      VARCHAR(20) PRIMARY KEY,
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS orders1 (
    row_id          INT PRIMARY KEY,
    order_id        VARCHAR(20),
    customer_id     VARCHAR(20),
    product_id      VARCHAR(20),
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR(50),
    sales           DECIMAL(10,2),
    quantity        INT,
    discount        DECIMAL(4,2),
    profit          DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers1(customer_id),
    FOREIGN KEY (product_id) REFERENCES products1(product_id)
);

-- 1c. Populate
-- select distinct does not work because one cust id or prod id map to multiple row values
INSERT INTO customers1 (customer_id, customer_name, segment, country, city, state, postal_code, region)
SELECT customer_id,
       ANY_VALUE(customer_name), ANY_VALUE(segment), ANY_VALUE(country),
       ANY_VALUE(city), ANY_VALUE(state), ANY_VALUE(postal_code), ANY_VALUE(region)
FROM superstore_raw
GROUP BY customer_id;

INSERT INTO products1 (product_id, category, sub_category, product_name)
SELECT product_id,
       ANY_VALUE(category), ANY_VALUE(sub_category), ANY_VALUE(product_name)
FROM superstore_raw
GROUP BY product_id;

-- PRIMARY KEY (order_id, product_id) on orders1 can't work. 
-- 8 order/product pairs repeat in the raw CSV (same product added as two separate line items in one order)
INSERT INTO orders1 (row_id, order_id, customer_id, product_id, order_date, ship_date, ship_mode, sales, quantity, discount, profit)
SELECT DISTINCT row_id, order_id, customer_id, product_id, order_date, ship_date, ship_mode, sales, quantity, discount, profit
FROM superstore_raw;

-- STEP 2: REQUIRED QUERIES

-- 2.1 Orders where sales > average sales (Subquery)
SELECT *
FROM orders1
WHERE sales > (SELECT AVG(sales) FROM orders1);

-- 2.2 Highest sales order for each customer (Subquery, correlated)
SELECT o.*
FROM orders1 o
WHERE o.sales = (
    SELECT MAX(o2.sales)
    FROM orders1 o2
    WHERE o2.customer_id = o.customer_id
);

-- 2.3 Total sales per customer (CTE)
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders1
    GROUP BY customer_id
)
SELECT c.customer_name, ct.total_sales
FROM customer_totals ct
JOIN customers1 c ON c.customer_id = ct.customer_id
ORDER BY ct.total_sales DESC;

-- 2.4 Customers whose total sales are above average (CTE + Subquery)
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders1
    GROUP BY customer_id
)
SELECT c.customer_name, ct.total_sales
FROM customer_totals ct
JOIN customers1 c ON c.customer_id = ct.customer_id
WHERE ct.total_sales > (SELECT AVG(total_sales) FROM customer_totals)
ORDER BY ct.total_sales DESC;

-- 2.5 Rank all customers by total sales (Window Function)
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders1
    GROUP BY customer_id
)
SELECT
    c.customer_name,
    ct.total_sales,
    RANK() OVER (ORDER BY ct.total_sales DESC)       AS sales_rank,
    DENSE_RANK() OVER (ORDER BY ct.total_sales DESC) AS sales_dense_rank
FROM customer_totals ct
JOIN customers1 c ON c.customer_id = ct.customer_id
ORDER BY sales_rank;

-- 2.6 Row number for each order within a customer (Window Function + PARTITION BY)
SELECT
    order_id,
    customer_id,
    sales,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_seq
FROM orders1;

-- 2.7 Top 3 customers by total sales (Window Function)
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders1
    GROUP BY customer_id
),
ranked AS (
    SELECT
        c.customer_name,
        ct.total_sales,
        RANK() OVER (ORDER BY ct.total_sales DESC) AS sales_rank
    FROM customer_totals ct
    JOIN customers1 c ON c.customer_id = ct.customer_id
)
SELECT * FROM ranked WHERE sales_rank <= 3;

-- STEP 3: FINAL COMBINED QUERY (JOIN + CTE + WINDOW FUNCTION)

WITH customer_totals AS (
    SELECT o.customer_id, SUM(o.sales) AS total_sales
    FROM orders1 o
    GROUP BY o.customer_id
)
SELECT
    c.customer_name                                    AS `Customer Name`,
    ct.total_sales                                      AS `Total Sales`,
    RANK() OVER (ORDER BY ct.total_sales DESC)          AS `Rank`
FROM customer_totals ct
JOIN customers1 c ON c.customer_id = ct.customer_id
ORDER BY `Rank`;

-- MINI PROJECT: CUSTOMER SALES INSIGHTS

-- Q1: Top 5 customers
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders1 GROUP BY customer_id
)
SELECT c.customer_name, ct.total_sales
FROM customer_totals ct
JOIN customers1 c ON c.customer_id = ct.customer_id
ORDER BY ct.total_sales DESC
LIMIT 5;

-- Q2: Bottom 5 customers
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders1 GROUP BY customer_id
)
SELECT c.customer_name, ct.total_sales
FROM customer_totals ct
JOIN customers1 c ON c.customer_id = ct.customer_id
ORDER BY ct.total_sales ASC
LIMIT 5;

-- Q3: Customers who made only one order
SELECT c.customer_name, COUNT(DISTINCT o.order_id) AS order_count
FROM orders1 o
JOIN customers1 c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) = 1;

-- Q4: Customers with above-average sales
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders1 GROUP BY customer_id
)
SELECT c.customer_name, ct.total_sales
FROM customer_totals ct
JOIN customers1 c ON c.customer_id = ct.customer_id
WHERE ct.total_sales > (SELECT AVG(total_sales) FROM customer_totals)
ORDER BY ct.total_sales DESC;

-- Q5: Highest order value per customer
SELECT c.customer_name, MAX(o.sales) AS highest_order_value
FROM orders1 o
JOIN customers1 c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY highest_order_value DESC;