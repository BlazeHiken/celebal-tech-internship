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

-- 15. Complex CTE: Cohort Analysis
WITH CustomerCohorts AS (
    SELECT 
        customer_id,
        strftime('%Y-%m', MIN(order_date)) AS cohort_month
    FROM orders
    GROUP BY customer_id
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
