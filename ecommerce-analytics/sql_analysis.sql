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

-- 10. CTE with Multiple Levels
WITH MonthlyCustomerRevenue AS (
    SELECT 
        o.customer_id,
        strftime('%Y-%m', o.order_date) AS revenue_month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id, strftime('%Y-%m', o.order_date)
),
CategorizedCustomers AS (
    SELECT 
        customer_id,
        revenue_month,
        CASE 
            WHEN monthly_revenue > 10000 THEN 'High'
            WHEN monthly_revenue >= 5000 AND monthly_revenue <= 10000 THEN 'Medium'
            ELSE 'Low'
        END AS revenue_category
    FROM MonthlyCustomerRevenue
)
SELECT 
    revenue_month,
    revenue_category,
    COUNT(customer_id) AS customer_count
FROM CategorizedCustomers
GROUP BY revenue_month, revenue_category
ORDER BY revenue_month, revenue_category;

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

-- 12. Year-over-Year Comparison
WITH MonthlyRevenue AS (
    SELECT 
        strftime('%Y', order_date) AS order_year,
        strftime('%m', order_date) AS order_month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY strftime('%Y', order_date), strftime('%m', order_date)
)
SELECT 
    curr.order_year AS year,
    curr.order_month AS month,
    curr.revenue,
    prev.revenue AS prev_year_revenue,
    CASE 
        WHEN prev.revenue IS NOT NULL AND prev.revenue != 0 
        THEN ((curr.revenue - prev.revenue) / prev.revenue) * 100 
        ELSE NULL 
    END AS yoy_growth_percent
FROM MonthlyRevenue curr
LEFT JOIN MonthlyRevenue prev 
    ON curr.order_month = prev.order_month 
    AND CAST(curr.order_year AS INTEGER) = CAST(prev.order_year AS INTEGER) + 1
ORDER BY year, month;

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

-- 15. Complex CTE: Cohort Analysis
WITH CustomerCohorts AS (
    SELECT 
        c.customer_id,
        strftime('%Y-%m', c.registration_date) AS cohort_month
    FROM customers c
),
CustomerActivity AS (
    SELECT 
        o.customer_id,
        strftime('%Y-%m', o.order_date) AS activity_month,
        c.cohort_month,
        (CAST(strftime('%Y', o.order_date) AS INTEGER) - CAST(substr(c.cohort_month, 1, 4) AS INTEGER)) * 12 + 
        (CAST(strftime('%m', o.order_date) AS INTEGER) - CAST(substr(c.cohort_month, 6, 2) AS INTEGER)) AS month_index
    FROM orders o
    JOIN CustomerCohorts c ON o.customer_id = c.customer_id
),
CohortSizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) AS initial_size
    FROM CustomerCohorts
    GROUP BY cohort_month
),
RetentionCounts AS (
    SELECT 
        cohort_month,
        month_index,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM CustomerActivity
    WHERE month_index <= 3
    GROUP BY cohort_month, month_index
)
SELECT 
    r.cohort_month,
    s.initial_size,
    MAX(CASE WHEN r.month_index = 0 THEN r.active_customers ELSE 0 END) AS month_0_active,
    MAX(CASE WHEN r.month_index = 1 THEN r.active_customers ELSE 0 END) AS month_1_active,
    MAX(CASE WHEN r.month_index = 2 THEN r.active_customers ELSE 0 END) AS month_2_active,
    MAX(CASE WHEN r.month_index = 3 THEN r.active_customers ELSE 0 END) AS month_3_active,
    
    CAST(MAX(CASE WHEN r.month_index = 1 THEN r.active_customers ELSE 0 END) AS FLOAT) / s.initial_size * 100 AS month_1_retention_rate,
    CAST(MAX(CASE WHEN r.month_index = 2 THEN r.active_customers ELSE 0 END) AS FLOAT) / s.initial_size * 100 AS month_2_retention_rate,
    CAST(MAX(CASE WHEN r.month_index = 3 THEN r.active_customers ELSE 0 END) AS FLOAT) / s.initial_size * 100 AS month_3_retention_rate

FROM RetentionCounts r
JOIN CohortSizes s ON r.cohort_month = s.cohort_month
GROUP BY r.cohort_month, s.initial_size
ORDER BY r.cohort_month;

-- 16. Self-Join with Window Function
SELECT 
    oi1.product_id AS product_a,
    oi2.product_id AS product_b,
    COUNT(DISTINCT oi1.order_id) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
GROUP BY oi1.product_id, oi2.product_id
ORDER BY times_bought_together DESC;
