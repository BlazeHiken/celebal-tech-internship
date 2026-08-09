-- 1. Total revenue per category
SELECT 
    p.category, 
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category;

-- 2. Top 10 customers by total order value
SELECT 
    c.customer_id, 
    c.customer_name, 
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS total_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_order_value DESC
LIMIT 10;

-- 3. Month-wise order count for the last 12 months
SELECT 
    strftime('%Y-%m', order_date) AS order_month, 
    COUNT(order_id) AS order_count
FROM orders
WHERE order_date >= date('now', '-12 months')
GROUP BY order_month
ORDER BY order_month;

-- 4. Find customers who placed orders but never had any item delivered
SELECT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(CASE WHEN o.status = 'DELIVERED' THEN 1 ELSE 0 END) = 0;

-- 5. Products that were ordered but had more returns than purchases
SELECT p.product_id, p.product_name
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(CASE WHEN oi.quantity < 0 THEN ABS(oi.quantity) ELSE 0 END) > SUM(CASE WHEN oi.quantity > 0 THEN oi.quantity ELSE 0 END);

-- 6. Calculate the return rate (returned items / total items) per category
SELECT 
    p.category,
    CAST(SUM(CASE WHEN oi.quantity < 0 THEN ABS(oi.quantity) ELSE 0 END) AS FLOAT) / 
    NULLIF(SUM(ABS(oi.quantity)), 0) AS return_rate
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category;
