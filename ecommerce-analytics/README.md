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

### 1. `scripts/generate_data.py`

Generates four CSV files containing sample e-commerce data:
- `customers.csv`
- `products.csv`
- `orders.csv`
- `order_items.csv`

The generated data contains intentional issues required by the project specification.

Output:
```text
data/raw/
├── customers.csv
├── products.csv
├── orders.csv
└── order_items.csv
```

### 2. `scripts/clean_data.py`

Reads the raw CSV files using pandas and performs cleaning and validation. It produces cleaned CSV files with the `_clean.csv` suffix and a cleaning report.

Output:
```text
data/cleaned/
├── customers_clean.csv
├── products_clean.csv
├── orders_clean.csv
├── order_items_clean.csv
└── cleaning_report.txt
```

### 3. `scripts/load_db.py`

Creates a local SQLite database named `ecommerce.db`. It executes the database schema defined in `sql/schema.sql` and loads the cleaned CSV files into the database.

### 4. `sql/` Directory

Contains the required SQL business analyses, split into logical files:
- **`schema.sql`**: Database creation schema.
- **`aggregations.sql`**: Basic aggregations, joins, and filtering (Queries 1-6).
- **`window_functions.sql`**: Advanced window functions like ranking, running totals, and NTiles (Queries 7-9, 11, 13, 14, 16).
- **`cohort_analysis.sql`**: Complex CTEs and Cohort Analysis based on the customer's first purchase month (Queries 10, 12, 15).

### 5. `scripts/report_cli.py`

Provides the user-facing command-line reporting tool.

The user interactively selects:
- Report type: `daily`, `weekly`, or `monthly`
- Start date

The tool determines the corresponding reporting period and generates a summary containing:
- Total orders
- Total revenue
- Unique customers
- Top 3 products by revenue
- Percentage change compared with the previous period

The report is generated directly from the SQLite database.

### 6. `scripts/test_edge_cases.py`

Contains the four edge-case tests required by the project, utilizing Python's built-in `unittest` framework.

### 7. `scripts/verify_fixes.py`

An end-to-end verification/smoke-test script that runs the entire pipeline from data generation to reporting, ensuring everything works smoothly.

## Running the Project

Run the main pipeline from the root directory in this order:

```bash
python scripts/generate_data.py
python scripts/clean_data.py
python scripts/load_db.py
```

After the database has been created, the SQL analysis files in `sql/` can be executed against `ecommerce.db`.

To run the command-line reporting tool:
```bash
python scripts/report_cli.py
```

To run the required edge-case tests:
```bash
python scripts/test_edge_cases.py
```

For an end-to-end verification of the pipeline:
```bash
python scripts/verify_fixes.py
```

## Technologies

- Python
- pandas
- SQLite
- SQL
- Python `unittest`
