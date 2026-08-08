import sqlite3
import pandas as pd
import os

def create_db():
    db_path = "ecommerce.db"
    clean_dir = "data/cleaned"
    
    if not os.path.exists(clean_dir):
        print(f"Error: {clean_dir} does not exist. Run data_cleaning.py first.")
        return
        
    print(f"Connecting to SQLite database: {db_path}...")
    conn = sqlite3.connect(db_path)
    
    print("Loading customers into DB...")
    customers = pd.read_csv(os.path.join(clean_dir, 'customers.csv'))
    customers.to_sql('customers', conn, if_exists='replace', index=False)
    
    print("Loading products into DB...")
    products = pd.read_csv(os.path.join(clean_dir, 'products.csv'))
    products.to_sql('products', conn, if_exists='replace', index=False)
    
    print("Loading orders into DB...")
    orders = pd.read_csv(os.path.join(clean_dir, 'orders.csv'))
    orders.to_sql('orders', conn, if_exists='replace', index=False)
    
    print("Loading order_items into DB...")
    order_items = pd.read_csv(os.path.join(clean_dir, 'order_items.csv'))
    order_items.to_sql('order_items', conn, if_exists='replace', index=False)
    
    print("Database setup complete! All tables loaded successfully.")
    conn.close()

if __name__ == "__main__":
    create_db()
