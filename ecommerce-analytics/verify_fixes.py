import os
import sqlite3
import pandas as pd
import subprocess

print("Running data_generation.py...")
subprocess.run(["python", "data_generation.py"], check=True)

print("Running data_cleaning.py...")
subprocess.run(["python", "data_cleaning.py"], check=True)

print("Running setup_db.py...")
subprocess.run(["python", "setup_db.py"], check=True)

print("\n--- Final Row Counts ---")
clean_dir = "data/cleaned"
for f in ["customers.csv", "products.csv", "orders.csv", "order_items.csv"]:
    df = pd.read_csv(os.path.join(clean_dir, f))
    print(f"{f}: {len(df)} rows")

print("\n--- Running sql_analysis.sql ---")
conn = sqlite3.connect("ecommerce.db")
with open("sql_analysis.sql", "r") as f:
    sql_script = f.read()

try:
    conn.executescript(sql_script)
    print("sql_analysis.sql executed successfully with no errors.")
except Exception as e:
    print(f"Error executing sql_analysis.sql: {e}")

print("\n--- Verifying Query 3 (Month-wise order count) ---")
q3 = """
SELECT 
    strftime('%Y-%m', order_date) AS order_month, 
    COUNT(order_id) AS order_count
FROM orders
WHERE order_date >= date('now', '-12 months')
GROUP BY order_month
ORDER BY order_month;
"""
res3 = pd.read_sql_query(q3, conn)
print(f"Query 3 returned {len(res3)} rows.")
if not res3.empty:
    print(res3.head())
else:
    print("Query 3 returned empty results.")

print("\n--- Verifying Query 14 (Cumulative distribution tie-breaking) ---")
q14 = """
WITH CustomerRevenue AS (
    SELECT 
        o.customer_id,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS revenue
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
ORDER BY revenue DESC, customer_id
LIMIT 20;
"""
res14 = pd.read_sql_query(q14, conn)
print(res14.head(10))
conn.close()

print("\n--- Running test_edge_cases.py ---")
subprocess.run(["python", "test_edge_cases.py"], check=True)
