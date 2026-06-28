#to get all in 4 tables
import pandas as pd
import mysql.connector
from dotenv import load_dotenv
import os

load_dotenv()

DB_CONFIG = {
    "host":     os.getenv("DB_HOST"),
    "user":     os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "database": os.getenv("DB_NAME")
}

CSV_PATH = os.getenv("CSV_PATH_SUPERSTORE")

print("Loading CSV...")
df = pd.read_csv(CSV_PATH, encoding="latin1")

# Normalize column names to lowercase with underscores
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
    .str.replace("-", "_")
)

print(f"  Raw rows: {len(df)}")
print(f"  Columns : {list(df.columns)}")

# customers
# Keep only stable fields (city/state varies per order — belongs on orders)
customers = (
    df[["customer_id", "customer_name", "segment"]]
    .drop_duplicates(subset=["customer_id"])
    .reset_index(drop=True)
)
print(f"\ncustomers : {len(customers)} rows")

# products
# 32 product_ids have 2 slightly different names (dirty data in source CSV).
# Fix: pick the most frequently occurring name per product_id.
prod_name_fix = (
    df.groupby(["product_id", "product_name"])
    .size()
    .reset_index(name="freq")
    .sort_values(["product_id", "freq"], ascending=[True, False])
    .drop_duplicates(subset=["product_id"])   # keep highest-freq name
    [["product_id", "product_name"]]
)

products = (
    df[["product_id", "category", "sub_category"]]
    .drop_duplicates(subset=["product_id"])
    .merge(prod_name_fix, on="product_id", how="left")
    [["product_id", "category", "sub_category", "product_name"]]
    .reset_index(drop=True)
)
print(f"products  : {len(products)} rows")

# orders
# Location columns live here 
orders = (
    df[["order_id", "order_date", "ship_date", "ship_mode",
        "customer_id", "city", "state", "postal_code", "region", "country"]]
    .drop_duplicates(subset=["order_id"])
    .reset_index(drop=True)
)
print(f"orders    : {len(orders)} rows")

# order_items
# Every line item no dedup needed
order_items = (
    df[["order_id", "product_id", "sales", "quantity", "discount", "profit"]]
    .reset_index(drop=True)
)
print(f"order_items: {len(order_items)} rows  (should equal raw rows: {len(df)})")

print("\nConnecting to MySQL...")
conn   = mysql.connector.connect(**DB_CONFIG)
cursor = conn.cursor()

# drop and recreate to keep rerunning
print("Recreating tables...")

cursor.execute("SET FOREIGN_KEY_CHECKS = 0")

cursor.execute("DROP TABLE IF EXISTS order_items")
cursor.execute("DROP TABLE IF EXISTS orders")
cursor.execute("DROP TABLE IF EXISTS products")
cursor.execute("DROP TABLE IF EXISTS customers")

cursor.execute("""
CREATE TABLE customers (
    customer_id   VARCHAR(20)  PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    segment       VARCHAR(30)
)
""")

cursor.execute("""
CREATE TABLE products (
    product_id   VARCHAR(30) PRIMARY KEY,
    category     VARCHAR(30),
    sub_category VARCHAR(30),
    product_name TEXT
)
""")

cursor.execute("""
CREATE TABLE orders (
    order_id    VARCHAR(20) PRIMARY KEY,
    order_date  DATE,
    ship_date   DATE,
    ship_mode   VARCHAR(30),
    customer_id VARCHAR(20),
    city        VARCHAR(50),
    state       VARCHAR(50),
    postal_code INT,
    region      VARCHAR(20),
    country     VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
)
""")

cursor.execute("""
CREATE TABLE order_items (
    item_id    INT AUTO_INCREMENT PRIMARY KEY,
    order_id   VARCHAR(20),
    product_id VARCHAR(30),
    sales      DECIMAL(10,2),
    quantity   INT,
    discount   DECIMAL(5,2),
    profit     DECIMAL(10,2),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
)
""")

cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
conn.commit()
print("  Tables created.")

# insert data
def bulk_insert(cursor, table, dataframe, query, label):
    rows = [tuple(r) for r in dataframe.itertuples(index=False)]
    cursor.executemany(query, rows)
    print(f"  {label}: {cursor.rowcount} rows inserted")

print("\nInserting data...")

# customers
bulk_insert(cursor, "customers", customers, """
    INSERT INTO customers (customer_id, customer_name, segment)
    VALUES (%s, %s, %s)
""", "customers")

# products
bulk_insert(cursor, "products", products, """
    INSERT INTO products (product_id, category, sub_category, product_name)
    VALUES (%s, %s, %s, %s)
""", "products")

# orders
bulk_insert(cursor, "orders", orders, """
    INSERT INTO orders (
        order_id, order_date, ship_date, ship_mode,
        customer_id, city, state, postal_code, region, country
    )
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
""", "orders")

# order_items
bulk_insert(cursor, "order_items", order_items, """
    INSERT INTO order_items (
        order_id, product_id, sales, quantity, discount, profit
    )
    VALUES (%s, %s, %s, %s, %s, %s)
""", "order_items")

conn.commit()

# verify if ran properly
print("\nVerification:")
for tbl in ["customers", "products", "orders", "order_items"]:
    cursor.execute(f"SELECT COUNT(*) FROM {tbl}")
    count = cursor.fetchone()[0]
    print(f"  {tbl:<15}: {count} rows")

print("\nExpected:")
print("  customers      :  793")
print("  products       : 1862")
print("  orders         : 5009")
print("  order_items    : 9994")

cursor.close()
conn.close()
print("\nDone. All tables loaded successfully.")