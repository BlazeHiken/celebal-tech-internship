-- ============================================================
-- SECTION E: ADVANCED QUERIES
-- Database: celebaldb
-- Tables  : customers, products, orders, order_items
-- ============================================================


-- ============================================================
-- E1. CASE – Basic conditional labels
-- ============================================================

-- Classify order items by sales value
SELECT
    item_id,
    order_id,
    sales,
    CASE
        WHEN sales >= 1000 THEN 'High Value'
        WHEN sales >= 500  THEN 'Medium Value'
        WHEN sales >= 100  THEN 'Low Value'
        ELSE                    'Micro Sale'
    END AS sales_category
FROM order_items
ORDER BY sales DESC
LIMIT 20;

-- Classify items as profitable or loss-making
SELECT
    item_id,
    order_id,
    product_id,
    profit,
    CASE
        WHEN profit > 0  THEN 'Profitable'
        WHEN profit = 0  THEN 'Break Even'
        ELSE                  'Loss'
    END AS profit_status
FROM order_items
ORDER BY profit ASC
LIMIT 20;

-- Classify discount levels
SELECT
    item_id,
    order_id,
    discount,
    CASE
        WHEN discount = 0           THEN 'No Discount'
        WHEN discount <= 0.10       THEN 'Low Discount'
        WHEN discount <= 0.30       THEN 'Medium Discount'
        WHEN discount <= 0.50       THEN 'High Discount'
        ELSE                             'Heavy Discount'
    END AS discount_tier
FROM order_items
ORDER BY discount DESC
LIMIT 20;


-- ============================================================
-- E2. CASE – With GROUP BY (count by category)
-- ============================================================

-- Count of items per sales category
SELECT
    CASE
        WHEN sales >= 1000 THEN 'High Value'
        WHEN sales >= 500  THEN 'Medium Value'
        WHEN sales >= 100  THEN 'Low Value'
        ELSE                    'Micro Sale'
    END AS sales_category,
    COUNT(*)              AS item_count,
    ROUND(SUM(sales), 2)  AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM order_items
GROUP BY sales_category
ORDER BY total_sales DESC;

-- Count of items per profit status
SELECT
    CASE
        WHEN profit > 0 THEN 'Profitable'
        WHEN profit = 0 THEN 'Break Even'
        ELSE                 'Loss'
    END AS profit_status,
    COUNT(*)              AS item_count,
    ROUND(SUM(sales), 2)  AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM order_items
GROUP BY profit_status
ORDER BY total_profit DESC;

-- Discount tier distribution
SELECT
    CASE
        WHEN discount = 0     THEN 'No Discount'
        WHEN discount <= 0.10 THEN 'Low Discount'
        WHEN discount <= 0.30 THEN 'Medium Discount'
        WHEN discount <= 0.50 THEN 'High Discount'
        ELSE                       'Heavy Discount'
    END AS discount_tier,
    COUNT(*) AS item_count,
    ROUND(AVG(profit), 2) AS avg_profit
FROM order_items
GROUP BY discount_tier
ORDER BY avg_profit DESC;


-- ============================================================
-- E3. CASE – Across joined tables
-- ============================================================

-- Customer value tier based on total spend
SELECT
    c.customer_name,
    c.segment,
    ROUND(SUM(oi.sales), 2) AS total_spend,
    CASE
        WHEN SUM(oi.sales) >= 10000 THEN 'Platinum'
        WHEN SUM(oi.sales) >= 5000  THEN 'Gold'
        WHEN SUM(oi.sales) >= 1000  THEN 'Silver'
        ELSE                             'Bronze'
    END AS customer_tier
FROM customers c
INNER JOIN orders      o  ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY total_spend DESC
LIMIT 20;

-- Shipping performance: on-time vs delayed
-- (flag orders where ship took more than 5 days as delayed)
SELECT
    order_id,
    order_date,
    ship_date,
    ship_mode,
    DATEDIFF(ship_date, order_date) AS days_to_ship,
    CASE
        WHEN DATEDIFF(ship_date, order_date) <= 2 THEN 'Fast'
        WHEN DATEDIFF(ship_date, order_date) <= 5 THEN 'Normal'
        ELSE                                            'Delayed'
    END AS shipping_status
FROM orders
ORDER BY days_to_ship DESC
LIMIT 20;

-- Shipping status summary
SELECT
    CASE
        WHEN DATEDIFF(ship_date, order_date) <= 2 THEN 'Fast'
        WHEN DATEDIFF(ship_date, order_date) <= 5 THEN 'Normal'
        ELSE                                            'Delayed'
    END AS shipping_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY shipping_status
ORDER BY order_count DESC;

-- Regional performance label
SELECT
    o.region,
    ROUND(SUM(oi.sales), 2)  AS total_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    CASE
        WHEN SUM(oi.profit) >= 100000 THEN 'Top Performer'
        WHEN SUM(oi.profit) >= 50000  THEN 'Average Performer'
        ELSE                               'Underperformer'
    END AS region_status
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.region
ORDER BY total_profit DESC;


-- ============================================================
-- E4. Duplicate detection
-- ============================================================

-- Detect duplicate order_id + product_id combinations in order_items
-- (same product appearing twice in same order)
SELECT
    order_id,
    product_id,
    COUNT(*) AS occurrence_count
FROM order_items
GROUP BY order_id, product_id
HAVING occurrence_count > 1
ORDER BY occurrence_count DESC;

-- Detect duplicate customer names (different IDs, same name)
SELECT
    customer_name,
    COUNT(DISTINCT customer_id) AS id_count
FROM customers
GROUP BY customer_name
HAVING id_count > 1;


-- ============================================================
-- E5. Subqueries
-- ============================================================

-- Orders with above-average sales
SELECT order_id, sales, profit
FROM order_items
WHERE sales > (SELECT AVG(sales) FROM order_items)
ORDER BY sales DESC
LIMIT 10;

-- Products that have generated above-average profit
SELECT
    p.product_name,
    p.category,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING total_profit > (SELECT AVG(profit) FROM order_items)
ORDER BY total_profit DESC
LIMIT 10;

-- Top customer per region (subquery approach)
SELECT
    region,
    customer_name,
    total_sales
FROM (
    SELECT
        o.region,
        c.customer_name,
        ROUND(SUM(oi.sales), 2) AS total_sales,
        RANK() OVER (
            PARTITION BY o.region
            ORDER BY SUM(oi.sales) DESC
        ) AS rnk
    FROM customers c
    INNER JOIN orders      o  ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id    = oi.order_id
    GROUP BY o.region, c.customer_id, c.customer_name
) ranked
WHERE rnk = 1
ORDER BY region;


-- ============================================================
-- E6. TRANSACTIONS
-- ============================================================

-- Transaction 1: Insert a new customer and their order atomically
-- If any statement fails, the entire transaction is rolled back.
START TRANSACTION;

    INSERT INTO customers (customer_id, customer_name, segment)
    VALUES ('TC-99999', 'Test Customer', 'Consumer');

    INSERT INTO orders (
        order_id, order_date, ship_date, ship_mode,
        customer_id, city, state, postal_code, region, country
    )
    VALUES (
        'TC-2024-001', '2024-01-15', '2024-01-18', 'Standard Class',
        'TC-99999', 'Mumbai', 'Maharashtra', 400001, 'West', 'India'
    );

    INSERT INTO order_items (order_id, product_id, sales, quantity, discount, profit)
    VALUES ('TC-2024-001', 'TEC-PH-10001530', 899.99, 2, 0.10, 150.00);

COMMIT;

-- Verify the transaction inserted correctly
SELECT 'New Customer' AS check_type, customer_id, customer_name
FROM customers WHERE customer_id = 'TC-99999'
UNION ALL
SELECT 'New Order', order_id, ship_mode
FROM orders WHERE order_id = 'TC-2024-001';

-- Transaction 2: Update with ROLLBACK demonstration
-- Simulates catching an error and undoing changes
START TRANSACTION;

    -- Apply a 10% sales adjustment to a specific order
    UPDATE order_items
    SET sales = sales * 1.10
    WHERE order_id = 'TC-2024-001';

    -- Verify before committing
    SELECT order_id, sales, profit
    FROM order_items
    WHERE order_id = 'TC-2024-001';

-- Roll back instead of committing — original values restored
ROLLBACK;

-- Confirm rollback worked (sales should be original value)
SELECT order_id, sales, profit
FROM order_items
WHERE order_id = 'TC-2024-001';

-- Transaction 3: Clean up test data
START TRANSACTION;

    DELETE FROM order_items WHERE order_id   = 'TC-2024-001';
    DELETE FROM orders      WHERE order_id   = 'TC-2024-001';
    DELETE FROM customers   WHERE customer_id = 'TC-99999';

COMMIT;

-- Confirm cleanup (should return 0 rows)
SELECT COUNT(*) AS remaining FROM customers WHERE customer_id = 'TC-99999';