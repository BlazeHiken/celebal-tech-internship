#to get all in one table
import pandas as pd
import mysql.connector
from dotenv import load_dotenv
import os

load_dotenv()

# Read CSV
df = pd.read_csv(os.getenv("CSV_PATH_SUPERSTORE"), encoding="latin1")

# Connect to MySQL
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="sidadmin$46",
    database="celebaldb"
)

cursor = conn.cursor()

query = """
INSERT INTO sales (
row_id, order_id, order_date, ship_date, ship_mode,
customer_id, customer_name, segment, country, city,
state, postal_code, region, product_id, category,
sub_category, product_name, sales, quantity, discount, profit
)
VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
"""

for row in df.itertuples(index=False):
    cursor.execute(query, tuple(row))

conn.commit()

print(f"{len(df)} rows inserted successfully.")

cursor.close()
conn.close()