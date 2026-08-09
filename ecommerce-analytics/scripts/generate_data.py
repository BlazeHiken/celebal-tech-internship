import csv
import random
import uuid
import os
from datetime import datetime, timedelta

def create_directory(path):
    if not os.path.exists(path):
        os.makedirs(path)

# Parameters for generation
NUM_CUSTOMERS = 600
NUM_PRODUCTS = 550
NUM_ORDERS = 1000
NUM_ORDER_ITEMS = 2500

# Constants
CUSTOMER_TYPES = ['REGULAR', 'PREMIUM', 'VIP']
CATEGORIES = {
    'Electronics': ['Phones', 'Laptops', 'Accessories', 'Tablets', 'Cameras'],
    'Clothing': ['Men', 'Women', 'Kids', 'Shoes', 'Activewear'],
    'Home': ['Furniture', 'Decor', 'Kitchen', 'Bedding', 'Lighting'],
    'Books': ['Fiction', 'Non-Fiction', 'Educational', 'Comics', 'Biography']
}
STATUSES = ['PLACED', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'RETURNED']
REGIONS = ['NORTH', 'SOUTH', 'EAST', 'WEST', 'CENTRAL']

def random_date(start_year=2022):
    """Generate a random datetime between start_year and now."""
    start_date = datetime(start_year, 1, 1)
    end_date = datetime.now()
    time_between_dates = end_date - start_date
    days_between_dates = time_between_dates.days
    random_number_of_days = random.randrange(days_between_dates)
    random_dt = start_date + timedelta(days=random_number_of_days)
    # Add random time
    random_dt = random_dt + timedelta(
        hours=random.randint(0, 23), 
        minutes=random.randint(0, 59), 
        seconds=random.randint(0, 59)
    )
    return random_dt

def generate_customers():
    customers = []
    for _ in range(NUM_CUSTOMERS):
        customer_id = f"CUST_{uuid.uuid4().hex[:8].upper()}"
        first_name = random.choice(['John', 'Jane', 'Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank', 'Grace', 'Henry'])
        last_name = random.choice(['Smith', 'Doe', 'Johnson', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson'])
        name = f"{first_name} {last_name}"
        email = f"{first_name.lower()}.{last_name.lower()}@example.com"
        
        # 2% invalid emails (missing @ or domain)
        if random.random() < 0.02:
            email = random.choice([f"{first_name.lower()}{last_name.lower()}example.com", f"{first_name.lower()}@"])
            
        reg_date = random_date(2020).strftime("%Y-%m-%d")
        cust_type = random.choices(CUSTOMER_TYPES, weights=[0.6, 0.3, 0.1])[0]
        customers.append([customer_id, name, email, reg_date, cust_type])
    return customers

def generate_products():
    products = []
    for _ in range(NUM_PRODUCTS):
        product_id = f"PROD_{uuid.uuid4().hex[:8].upper()}"
        category = random.choice(list(CATEGORIES.keys()))
        subcategory = random.choice(CATEGORIES[category])
        name_base = f"{subcategory} {random.choice(['Model X', 'Pro', 'Basic', 'Advanced', 'Ultra', 'Lite', 'Max'])}"
        
        # Some bad product names (extra spaces or mixed case)
        if random.random() < 0.15:
            if random.random() < 0.5:
                name_base = f"  {name_base.lower()}  "
            else:
                name_base = name_base.upper() + "   "
                
        cost_price = round(random.uniform(5, 500), 2)
        products.append([product_id, name_base, category, subcategory, cost_price])
    return products

def generate_orders(customer_ids):
    orders = []
    order_ids = []
    for _ in range(NUM_ORDERS):
        order_id = f"ORD_{uuid.uuid4().hex[:8].upper()}"
        order_ids.append(order_id)
        
        customer_id = random.choice(customer_ids)
        # 5% NULL customer_id
        if random.random() < 0.05:
            customer_id = "" # Represents NULL in CSV
            
        dt = random_date(2022)
        # Some order dates in wrong format (DD-MM-YYYY)
        if random.random() < 0.10:
            order_date_str = dt.strftime("%d-%m-%Y %H:%M:%S")
        else:
            order_date_str = dt.strftime("%Y-%m-%d %H:%M:%S")
            
        status = random.choices(STATUSES, weights=[0.1, 0.1, 0.6, 0.1, 0.1])[0]
        region = random.choice(REGIONS)
        orders.append([order_id, customer_id, order_date_str, status, region])
    return orders, order_ids

def generate_order_items(order_ids, product_ids):
    order_items = []
    for _ in range(NUM_ORDER_ITEMS):
        item_id = f"ITEM_{uuid.uuid4().hex[:8].upper()}"
        order_id = random.choice(order_ids) # Ensures order_id exists in orders
        product_id = random.choice(product_ids)
        
        quantity = random.randint(1, 10)
        # 3% negative quantity
        if random.random() < 0.03:
            quantity = -quantity
            
        unit_price = round(random.uniform(10, 1000), 2)
        discount = round(random.uniform(0, 100), 2) # Discount 0-100%
        
        order_items.append([item_id, order_id, product_id, quantity, unit_price, discount])
    return order_items

def main():
    raw_dir = "data/raw"
    create_directory(raw_dir)
    
    print("Generating customers...")
    customers = generate_customers()
    customer_ids = [c[0] for c in customers]
    
    with open(os.path.join(raw_dir, 'customers.csv'), 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['customer_id', 'customer_name', 'email', 'registration_date', 'customer_type'])
        writer.writerows(customers)
        
    print("Generating products...")
    products = generate_products()
    product_ids = [p[0] for p in products]
    
    with open(os.path.join(raw_dir, 'products.csv'), 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['product_id', 'product_name', 'category', 'subcategory', 'cost_price'])
        writer.writerows(products)
        
    print("Generating orders...")
    orders, order_ids = generate_orders(customer_ids)
    
    with open(os.path.join(raw_dir, 'orders.csv'), 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['order_id', 'customer_id', 'order_date', 'status', 'region_code'])
        writer.writerows(orders)
        
    print("Generating order items...")
    order_items = generate_order_items(order_ids, product_ids)
    
    with open(os.path.join(raw_dir, 'order_items.csv'), 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['item_id', 'order_id', 'product_id', 'quantity', 'unit_price', 'discount_percent'])
        writer.writerows(order_items)
        
    print(f"Data generation complete! Files saved to '{raw_dir}'.")

if __name__ == "__main__":
    main()
