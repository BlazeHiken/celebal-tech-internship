import pandas as pd
import os
import re

def create_directory(path):
    if not os.path.exists(path):
        os.makedirs(path)

def clean_orders(orders_df):
    """Fix date formats, handle NULL customer_ids"""
    issues_found = []
    
    # Check NULL customer_ids
    null_customers = orders_df['customer_id'].isnull() | (orders_df['customer_id'] == '')
    num_nulls = null_customers.sum()
    if num_nulls > 0:
        issues_found.append(f"Found {num_nulls} orders with NULL or empty customer_id. Filled with 'UNKNOWN'.")
        orders_df.loc[null_customers, 'customer_id'] = 'UNKNOWN'

    # Fix date formats
    def parse_date(date_str):
        if pd.isnull(date_str):
            return date_str
        try:
            # Try YYYY-MM-DD
            return pd.to_datetime(date_str, format='%Y-%m-%d %H:%M:%S')
        except ValueError:
            try:
                # Try DD-MM-YYYY
                return pd.to_datetime(date_str, format='%d-%m-%Y %H:%M:%S')
            except ValueError:
                return pd.to_datetime(date_str, errors='coerce')
    
    orders_df['order_date'] = orders_df['order_date'].apply(parse_date)
    
    # Just checking how many were completely broken
    num_invalid_dates = orders_df['order_date'].isnull().sum()
    if num_invalid_dates > 0:
        issues_found.append(f"Found {num_invalid_dates} invalid order dates.")
        
    # Standardize back to string if needed or keep as datetime. 
    # Let's keep as string in standard YYYY-MM-DD HH:MM:SS for CSV
    orders_df['order_date'] = orders_df['order_date'].dt.strftime('%Y-%m-%d %H:%M:%S')
    
    return orders_df, issues_found

def clean_products(products_df):
    """Normalize product names (trim spaces, title case)"""
    issues_found = []
    
    # To detect issues, we check if the original matches the cleaned version
    original_names = products_df['product_name'].copy()
    products_df['product_name'] = products_df['product_name'].str.strip().str.title()
    
    changed = (original_names != products_df['product_name']).sum()
    if changed > 0:
        issues_found.append(f"Fixed {changed} product names (trimmed spaces and applied title case).")
        
    return products_df, issues_found

def validate_emails(customers_df):
    """Return list of customer_ids with invalid emails"""
    # Valid email regex (simple)
    regex = r'^[\w\.-]+@[\w\.-]+\.\w+$'
    invalid_mask = ~customers_df['email'].astype(str).str.match(regex)
    invalid_customers = customers_df.loc[invalid_mask, 'customer_id'].tolist()
    
    return invalid_customers

def check_referential_integrity(order_items_df, orders_df):
    """Find order_items that reference non-existent orders"""
    valid_order_ids = set(orders_df['order_id'])
    invalid_mask = ~order_items_df['order_id'].isin(valid_order_ids)
    
    invalid_items = order_items_df.loc[invalid_mask, 'item_id'].tolist()
    return invalid_items

def main():
    raw_dir = "data/raw"
    clean_dir = "data/cleaned"
    create_directory(clean_dir)
    
    print("Loading raw data...")
    orders_df = pd.read_csv(os.path.join(raw_dir, 'orders.csv'))
    products_df = pd.read_csv(os.path.join(raw_dir, 'products.csv'))
    customers_df = pd.read_csv(os.path.join(raw_dir, 'customers.csv'))
    order_items_df = pd.read_csv(os.path.join(raw_dir, 'order_items.csv'))
    
    report_lines = ["Data Cleaning Report", "===================="]
    
    print("Cleaning orders...")
    cleaned_orders, order_issues = clean_orders(orders_df)
    report_lines.append("\nOrders Issues:")
    report_lines.extend(["- " + issue for issue in order_issues])
    
    print("Cleaning products...")
    cleaned_products, product_issues = clean_products(products_df)
    report_lines.append("\nProducts Issues:")
    report_lines.extend(["- " + issue for issue in product_issues])
    
    print("Validating emails...")
    invalid_customer_ids = validate_emails(customers_df)
    report_lines.append("\nEmail Validation Issues:")
    if invalid_customer_ids:
        report_lines.append(f"- Found {len(invalid_customer_ids)} invalid emails.")
        report_lines.append(f"  Customer IDs: {', '.join(invalid_customer_ids[:5])} ...")
    else:
        report_lines.append("- All emails are valid.")
        
    print("Checking referential integrity...")
    invalid_order_items = check_referential_integrity(order_items_df, cleaned_orders)
    report_lines.append("\nReferential Integrity Issues:")
    if invalid_order_items:
        report_lines.append(f"- Found {len(invalid_order_items)} order items with non-existent order_ids.")
        report_lines.append(f"  Item IDs: {', '.join(invalid_order_items[:5])} ...")
    else:
        report_lines.append("- All order_items reference valid orders.")
        
    # Save cleaned data
    print("Saving cleaned data...")
    cleaned_orders.to_csv(os.path.join(clean_dir, 'orders.csv'), index=False)
    cleaned_products.to_csv(os.path.join(clean_dir, 'products.csv'), index=False)
    customers_df.to_csv(os.path.join(clean_dir, 'customers.csv'), index=False)
    order_items_df.to_csv(os.path.join(clean_dir, 'order_items.csv'), index=False)
    
    # Save report
    report_path = os.path.join(clean_dir, 'cleaning_report.txt')
    with open(report_path, 'w') as f:
        f.write("\n".join(report_lines))
        
    print(f"Data cleaning complete! Cleaned files and report saved to '{clean_dir}'.")

if __name__ == "__main__":
    main()
