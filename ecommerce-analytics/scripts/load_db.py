import sqlite3
import pandas as pd
import os

def create_db():
    db_path = "ecommerce.db"
    clean_dir = "data/cleaned"
    schema_path = "sql/schema.sql"
    
    if not os.path.exists(clean_dir):
        print(f"Error: {clean_dir} does not exist. Run scripts/clean_data.py first.")
        return
        
    print(f"Connecting to SQLite database: {db_path}...")
    conn = sqlite3.connect(db_path)
    
    print(f"Executing schema from {schema_path}...")
    with open(schema_path, 'r') as f:
        schema_sql = f.read()
    conn.executescript(schema_sql)
    
    print("Loading customers into DB...")
    customers = pd.read_csv(os.path.join(clean_dir, 'customers_clean.csv'))
    customers.to_sql('customers', conn, if_exists='append', index=False)
    
    print("Loading products into DB...")
    products = pd.read_csv(os.path.join(clean_dir, 'products_clean.csv'))
    products.to_sql('products', conn, if_exists='append', index=False)
    
    print("Loading orders into DB...")
    orders = pd.read_csv(os.path.join(clean_dir, 'orders_clean.csv'))
    orders.to_sql('orders', conn, if_exists='append', index=False)
    
    print("Loading order_items into DB...")
    order_items = pd.read_csv(os.path.join(clean_dir, 'order_items_clean.csv'))
    order_items.to_sql('order_items', conn, if_exists='append', index=False)
    
    print("Database setup complete! All tables loaded successfully.")
    conn.close()

if __name__ == "__main__":
    create_db()
