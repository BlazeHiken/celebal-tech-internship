-- 7. Running Totals with Window Functions
WITH DailyRegionRevenue AS (
    SELECT 
        o.region_code,
        date(o.order_date) AS order_date,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS daily_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.region_code, date(o.order_date)
)
SELECT 
    region_code,
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (PARTITION BY region_code ORDER BY order_date) AS running_total
FROM DailyRegionRevenue
ORDER BY region_code, order_date;

-- 8. Ranking with DENSE_RANK
WITH ProductRevenue AS (
    SELECT 
        p.category, 
        p.product_name, 
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
)
SELECT 
    category, 
    product_name, 
    total_revenue,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS rank_in_category
FROM ProductRevenue
ORDER BY category, rank_in_category;

-- 9. LAG/LEAD Analysis
WITH OrderGaps AS (
    SELECT 
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
        julianday(order_date) - julianday(LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_gap
    FROM orders
),
CustomerAvgGap AS (
    SELECT 
        customer_id,
        AVG(days_gap) AS avg_gap
    FROM OrderGaps
    WHERE days_gap IS NOT NULL
    GROUP BY customer_id
)
SELECT 
    o.customer_id,
    o.order_date,
    o.previous_order_date,
    o.days_gap,
    CASE WHEN c.avg_gap > 30 THEN 'At Risk' ELSE 'Healthy' END AS risk_flag
FROM OrderGaps o
JOIN CustomerAvgGap c ON o.customer_id = c.customer_id;

-- 11. NTILE for Segmentation
WITH CustomerLifetimeValue AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS total_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
),
Quartiles AS (
    SELECT 
        customer_id,
        total_value,
        NTILE(4) OVER (ORDER BY total_value DESC) AS quartile
    FROM CustomerLifetimeValue
)
SELECT 
    customer_id,
    total_value,
    quartile,
    CASE quartile
        WHEN 1 THEN 'Platinum'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
    END AS quartile_label
FROM Quartiles
ORDER BY quartile, total_value DESC;

-- 13. First/Last Value Analysis
WITH RankedPurchases AS (
    SELECT 
        o.customer_id,
        p.category,
        o.order_date,
        FIRST_VALUE(p.category) OVER (PARTITION BY o.customer_id ORDER BY o.order_date, oi.item_id) AS first_category,
        LAST_VALUE(p.category) OVER (PARTITION BY o.customer_id ORDER BY o.order_date, oi.item_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_category
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
)
SELECT DISTINCT 
    customer_id,
    first_category,
    last_category,
    CASE WHEN first_category != last_category THEN 'Yes' ELSE 'No' END AS category_shift
FROM RankedPurchases;

-- 14. Cumulative Distribution
WITH CustomerRevenue AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
),
TotalSysRevenue AS (
    SELECT SUM(revenue) AS total_sys_revenue FROM CustomerRevenue
),
RunningTotals AS (
    SELECT 
        customer_id,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC, customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
        (SELECT total_sys_revenue FROM TotalSysRevenue) AS sys_revenue
    FROM CustomerRevenue
)
SELECT 
    customer_id,
    revenue,
    cumulative_revenue,
    (cumulative_revenue / sys_revenue) * 100 AS cumulative_percent
FROM RunningTotals
ORDER BY revenue DESC, customer_id;

-- 16. Self-Join with Window Function
SELECT 
    oi1.product_id AS product_a,
    oi2.product_id AS product_b,
    COUNT(DISTINCT oi1.order_id) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
GROUP BY oi1.product_id, oi2.product_id
ORDER BY times_bought_together DESC;
