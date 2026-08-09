import os
import sqlite3
import pandas as pd
import subprocess
import sys

def main():
    # Make sure we're in the project root
    if not os.path.exists("scripts"):
        print("Please run this script from the project root: python scripts/verify_fixes.py")
        sys.exit(1)

    print("Running scripts/generate_data.py...")
    subprocess.run(["python", "scripts/generate_data.py"], check=True)

    print("Running scripts/clean_data.py...")
    subprocess.run(["python", "scripts/clean_data.py"], check=True)

    print("Running scripts/load_db.py...")
    subprocess.run(["python", "scripts/load_db.py"], check=True)

    print("\n--- Final Row Counts ---")
    clean_dir = "data/cleaned"
    for f in ["customers_clean.csv", "products_clean.csv", "orders_clean.csv", "order_items_clean.csv"]:
        df = pd.read_csv(os.path.join(clean_dir, f))
        print(f"{f}: {len(df)} rows")

    print("\n--- Verifying SQL Setup ---")
    conn = sqlite3.connect("ecommerce.db")

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
    LIMIT 5;
    """
    res14 = pd.read_sql_query(q14, conn)
    print(res14)
    conn.close()

    print("\n--- Running scripts/test_edge_cases.py ---")
    subprocess.run(["python", "scripts/test_edge_cases.py"], check=True)
    
    print("\nVerification Complete!")

if __name__ == "__main__":
    main()
