# E-Commerce Order Analytics System

A local e-commerce data analytics project built with Python and SQLite.

The system generates realistic but intentionally messy order data, cleans and validates the data, loads it into SQLite, performs business-focused SQL analysis, and provides a command-line reporting tool.

## Project Workflow

```text
Data Generation
      ↓
Raw CSV Files
      ↓
Data Cleaning & Validation
      ↓
Cleaned CSV Files
      ↓
SQLite Database
      ↓
SQL Analysis
      ↓
CLI Summary Reports
```

## Project Components

### 1. `data_generation.py`

Generates four CSV files containing sample e-commerce data:

- `customers.csv`
- `products.csv`
- `orders.csv`
- `order_items.csv`

The generated data contains intentional issues required by the project specification, including:

- Missing customer IDs
- Negative quantities representing returns
- Incorrect order date formats
- Product names with inconsistent spacing/capitalization
- Invalid email addresses

The generator uses `random.seed(42)` for reproducible random behavior.

Output:

```text
data/raw/
├── customers.csv
├── products.csv
├── orders.csv
└── order_items.csv
```

### 2. `data_cleaning.py`

Reads the raw CSV files using pandas and performs cleaning and validation.

Functions include:

- `clean_orders()` — standardizes order dates and handles missing customer IDs.
- `clean_products()` — trims product names and applies title case.
- `validate_emails()` — identifies customers with invalid email addresses.
- `check_referential_integrity()` — identifies order items referencing non-existent orders.

It produces cleaned CSV files and a cleaning report.

Output:

```text
data/cleaned/
├── customers.csv
├── products.csv
├── orders.csv
├── order_items.csv
└── cleaning_report.txt
```

### 3. `setup_db.py`

Loads the cleaned CSV files into a local SQLite database named:

```text
ecommerce.db
```

The database contains four tables:

- `customers`
- `products`
- `orders`
- `order_items`

Pandas `to_sql()` is used to create and populate the tables.

### 4. `sql_analysis.sql`

Contains the required SQL business analyses, including:

1. Revenue per category
2. Top 10 customers by order value
3. Month-wise order count for the last 12 months
4. Customers who never had a delivered order
5. Products with more returns than purchases
6. Return rate per category
7. Running revenue totals by region
8. Product ranking by category using `DENSE_RANK`
9. Customer order gaps using `LAG`
10. Customer revenue segmentation using CTEs
11. Customer quartiles using `NTILE`
12. Year-over-year revenue comparison
13. First and most recent purchased categories
14. Cumulative revenue distribution
15. Customer cohort retention analysis
16. Frequently purchased product pairs

The cohort analysis uses the customer's `registration_date` as the cohort month.

### 5. `cli_tool.py`

Provides the user-facing command-line reporting tool.

The user selects:

- Report type: `daily`, `weekly`, or `monthly`
- Start date

The tool determines the corresponding reporting period and generates a summary containing:

- Total orders
- Total revenue
- Unique customers
- Top 3 products by revenue
- Percentage change compared with the previous period

The report is generated directly from the SQLite database.

### 6. `test_edge_cases.py`

Contains the four edge-case tests required by the project:

1. An order item references a non-existent order
2. Discount percentage is greater than 100
3. Quantity is zero
4. Order date is in the future

The tests use Python's built-in `unittest` framework.

### 7. `verify_fixes.py`

An additional verification utility created during development.

This file is **not an additional requirement of the project specification**. It was added to make it easier to verify that the complete pipeline still works after changes.

It:

1. Runs `data_generation.py`
2. Runs `data_cleaning.py`
3. Runs `setup_db.py`
4. Checks the final cleaned CSV row counts
5. Executes `sql_analysis.sql` against SQLite
6. Performs targeted checks for selected SQL queries
7. Runs `test_edge_cases.py`

It serves as a convenient end-to-end verification/smoke-test script for the project.

## Running the Project

Run the main pipeline in this order:

```bash
python data_generation.py
python data_cleaning.py
python setup_db.py
```

After the database has been created, the SQL analysis can be executed against `ecommerce.db`.

To run the command-line reporting tool:

```bash
python cli_tool.py
```

To run the required edge-case tests:

```bash
python test_edge_cases.py
```

For an end-to-end verification of the pipeline:

```bash
python verify_fixes.py
```

## Technologies

- Python
- pandas
- SQLite
- SQL
- Python `unittest`
