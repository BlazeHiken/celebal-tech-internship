import sqlite3
from datetime import datetime, timedelta

def get_date_range(report_type):
    print("Enter start date (YYYY-MM-DD):")
    start_date = input("> ").strip()

    start = datetime.strptime(start_date, "%Y-%m-%d")

    if report_type == 'daily':
        end = start
    elif report_type == 'weekly':
        end = start + timedelta(days=6)
    elif report_type == 'monthly':
        end = start + timedelta(days=30)  # We'll fix this later

    return start.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")

def get_report_type():
    print("Enter report type (daily/weekly/monthly):")
    report_type = input("> ").strip().lower()
    return report_type

def calculate_previous_period(start_date_str, end_date_str, report_type):
    try:
        start = datetime.strptime(start_date_str, "%Y-%m-%d")
        end = datetime.strptime(end_date_str, "%Y-%m-%d")
    except ValueError:
        print("Invalid date format. Using 7 days ago to today as default.")
        end = datetime.today()
        start = end - timedelta(days=7)
        
    if report_type == 'daily':
        prev_end = start - timedelta(days=1)
        prev_start = prev_end
    elif report_type == 'weekly':
        prev_end = start - timedelta(days=1)
        prev_start = prev_end - timedelta(days=6)
    elif report_type == 'monthly':
        # Approximate 30 days
        diff = (end - start).days
        prev_end = start - timedelta(days=1)
        prev_start = prev_end - timedelta(days=diff)
    else:
        # Default to same duration
        diff = (end - start).days
        prev_end = start - timedelta(days=1)
        prev_start = prev_end - timedelta(days=diff)
        
    return prev_start.strftime("%Y-%m-%d"), prev_end.strftime("%Y-%m-%d")

def fetch_summary(conn, start_date, end_date):
    cursor = conn.cursor()
    # Revenue, Orders, Unique Customers
    query = """
    SELECT 
        COUNT(DISTINCT o.order_id) as total_orders,
        COUNT(DISTINCT o.customer_id) as unique_customers,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) as total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE date(o.order_date) BETWEEN ? AND ?
    """
    cursor.execute(query, (start_date, end_date))
    row = cursor.fetchone()
    
    total_orders = row[0] or 0
    unique_customers = row[1] or 0
    total_revenue = row[2] or 0.0
    
    return total_orders, unique_customers, total_revenue

def fetch_top_products(conn, start_date, end_date):
    cursor = conn.cursor()
    query = """
    SELECT 
        p.product_name,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) as revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE date(o.order_date) BETWEEN ? AND ?
    GROUP BY p.product_id, p.product_name
    ORDER BY revenue DESC
    LIMIT 3
    """
    cursor.execute(query, (start_date, end_date))
    return cursor.fetchall()

def main():
    conn = sqlite3.connect('ecommerce.db')
    
    print("=== E-Commerce Order Analytics System ===")
    report_type = get_report_type()
    start_date, end_date = get_date_range(report_type)
    
    print(f"\nGenerating {report_type.capitalize()} Report for {start_date} to {end_date}...\n")
    
    orders, customers, revenue = fetch_summary(conn, start_date, end_date)
    top_products = fetch_top_products(conn, start_date, end_date)
    
    # Previous period comparison
    prev_start, prev_end = calculate_previous_period(start_date, end_date, report_type)
    prev_orders, prev_customers, prev_revenue = fetch_summary(conn, prev_start, prev_end)
    
    def calc_change(curr, prev):
        if prev == 0:
            return "N/A"
        return f"{((curr - prev) / prev) * 100:.2f}%"

    print("=========================================")
    print("              SUMMARY REPORT             ")
    print("=========================================")
    print(f"Total Orders:     {orders} (Change: {calc_change(orders, prev_orders)})")
    print(f"Total Revenue:    ${revenue:.2f} (Change: {calc_change(revenue, prev_revenue)})")
    print(f"Unique Customers: {customers} (Change: {calc_change(customers, prev_customers)})")
    print("\n--- Top 3 Products by Revenue ---")
    if not top_products:
        print("No products sold in this period.")
    else:
        for i, (name, rev) in enumerate(top_products, 1):
            print(f"{i}. {name} - ${rev:.2f}")
    
    print("=========================================")
    print(f"Previous Period Used: {prev_start} to {prev_end}")
    
    conn.close()

if __name__ == "__main__":
    main()
