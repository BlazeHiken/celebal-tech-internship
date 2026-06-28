# Assignment 2 - SQL Sales Data Analysis Assignment

Analysis of the Sample Superstore dataset using SQL — covering data normalization, filtering, aggregation, joins, and advanced queries.

---

## Dataset

**Source:** Sample Superstore (9,994 rows, 21 columns)
**Original format:** Single denormalized CSV

**Columns:** Row ID, Order ID, Order Date, Ship Date, Ship Mode, Customer ID, Customer Name, Segment, Country, City, State, Postal Code, Region, Product ID, Category, Sub-Category, Product Name, Sales, Quantity, Discount, Profit

---

## Database Schema

The denormalized CSV was normalized into 4 tables:

```
customers (793 rows)
    customer_id   PK
    customer_name
    segment

products (1,862 rows)
    product_id    PK
    category
    sub_category
    product_name

orders (5,009 rows)
    order_id      PK
    order_date
    ship_date
    ship_mode
    customer_id   FK → customers
    city
    state
    postal_code
    region
    country

order_items (9,994 rows)
    item_id       PK (auto increment)
    order_id      FK → orders
    product_id    FK → products
    sales
    quantity
    discount
    profit
```

**Why normalize?**

- The source CSV is denormalized — customer and product data repeats on every row
- Normalization eliminates redundancy and enables meaningful JOIN queries
- Location fields (city, state, region) were placed on `orders` rather than `customers` because the same customer can order from multiple addresses

**Data quality issues fixed before loading:**

- 32 `product_id` values had 2 slightly different product names — resolved by taking the most frequently occurring name per ID
- Customer location varies per order (expected behavior) — handled by moving location to the `orders` table

---

## Setup

### Prerequisites

- Python 3.x
- MySQL 8.x
- Libraries: `pandas`, `mysql-connector-python`

```bash
pip install pandas mysql-connector-python
```

### Load Data

1. Clone this repository
2. Place `SampleSuperstore_Converted.csv` in the project root
3. Update DB credentials in `normalize_and_load.py`
4. Run:

```bash
python normalize_and_load.py
```

This script will:

- Clean and normalize the raw CSV into 4 dataframes
- Drop and recreate all 4 tables
- Insert all data with FK constraints enforced
- Print row count verification on completion

**Expected output:**

```
customers      :  793 rows
products       : 1862 rows
orders         : 5009 rows
order_items    : 9994 rows
```

---

## Folder Structure

```
sql-assignment/
│
├── normalize_and_load.py        # Data cleaning + DB load script
│
├── Section_A/
│   └── basic_queries.sql        # SELECT, DESCRIBE, DISTINCT, ORDER BY, LIMIT, NULL checks
│
├── Section_B/
│   └── filtering_queries.sql    # WHERE, BETWEEN, IN, LIKE, AND/OR/NOT
│
├── Section_C/
│   └── aggregation_queries.sql  # COUNT, SUM, AVG, MAX, MIN, GROUP BY, HAVING
│
├── Section_D/
│   └── joins_queries.sql        # INNER JOIN, LEFT JOIN, multi-table joins
│
├── Section_E/
│   └── advanced_queries.sql     # CASE, subqueries, duplicate detection, transactions
│
└── README.md
```

---

## Section Summary

### Section A — Basic Queries

- `SELECT *` from all 4 tables
- `DESCRIBE` to inspect schemas
- `DISTINCT` values across segments, categories, regions, ship modes
- `ORDER BY` and `LIMIT` for sorted results
- NULL checks for data quality validation

### Section B — Filtering

- Filter by region, category, sub-category, ship mode, segment
- Date range filters using `BETWEEN` and `>`
- Sales, profit, and discount threshold filters
- Compound filters using `AND`, `OR`, `NOT`
- Pattern matching using `LIKE`

### Section C — Aggregation

- `COUNT` — orders per region, products per category, customers per segment
- `SUM` — total sales and profit by category, region, year, segment
- `AVG` — average sales, profit, discount, quantity
- `MAX` / `MIN` — highest and lowest sales, profit, order dates
- `HAVING` — filter on aggregated results
- Monthly trends using `YEAR()` and `MONTH()`
- Top N queries (top customers, states, sub-categories)

### Section D — Joins

- `INNER JOIN` across 2, 3, and 4 tables
- `INNER JOIN` with `WHERE` filters (e.g. loss-making furniture, tech orders in West)
- `INNER JOIN` with `GROUP BY` for aggregation across tables
- `LEFT JOIN` to find customers and products with no orders
- `LEFT JOIN` with `COALESCE` to handle NULLs in aggregation
- Business queries: top/worst products, ship mode performance, state-level sales

### Section E — Advanced

- `CASE` statements for conditional labels (sales tiers, profit status, discount levels, shipping speed)
- `CASE` with `GROUP BY` for distribution analysis
- Customer value tiers (Platinum / Gold / Silver / Bronze)
- Duplicate detection (same product in same order, duplicate customer names)
- Subqueries (above-average sales, top customer per region using `RANK()`)
- Transactions: insert, rollback demonstration, cleanup

---

## Key Insights

- **Top region by sales:** West
- **Most loss-making category:** Furniture (high discounts driving negative profit)
- **Best performing sub-category:** Copiers (highest profit margin)
- **Heavy discounts correlate with losses** — items discounted above 40% are almost always unprofitable
- **Standard Class** is the most used ship mode, accounting for the majority of orders
- **Consumer segment** generates the highest total sales across all years
