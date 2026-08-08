# Data Engineering Assignments

Weekly assignments completed as part of the CelebalTech Data Engineering internship program, covering Python, SQL, Cloud, and Big Data tools.

---

## Assignment Index

| Week   | Topic                                                    | Tools                               |
| ------ | -------------------------------------------------------- | ----------------------------------- |
| Week 1 | Basic Data Exploration and Cleaning                      | Python, Pandas, Matplotlib, Jupyter |
| Week 2 | SQL-based Sales Data Analysis                            | Python, Pandas, MySQL               |
| Week 3 | Advanced SQL — Subqueries, CTEs, Window Functions        | MySQL                               |
| Week 4 | Azure Cloud Fundamentals and ADF Data Pipeline           | Azure Portal, ADF, Blob Storage     |
| Week 5 | Spark Fundamentals — DataFrames, Cleaning, Aggregation   | PySpark, Jupyter                    |
| Week 6 | Spark Architecture — Transformations, Parquet, Pipelines | PySpark                             |
| Week 7 | Delta Lake MERGE and Incremental Data Processing         | Delta Lake, PySpark                 |
| Week 8 | E-Commerce Order Analytics System                        | Python, Pandas, SQLite, SQL         |

---

## Week 1 — Basic Data Exploration and Cleaning

**Objective:** Learn Python basics and perform EDA and data cleaning using Pandas.

- Loaded a shopping dataset (1,000 products, 24 columns) into a Pandas DataFrame
- Explored shape, data types, missing values, and summary statistics
- Cleaned price columns (string → numeric), handled nulls via median imputation
- Engineered features: Final Price, Price Difference, Popularity Metric
- Generated visualizations: rating histogram, category bar chart, price boxplot

**Output:** Jupyter Notebook + cleaned CSV

---

## Week 2 — SQL-based Sales Data Analysis

**Objective:** Analyze sales data using SQL with filtering, aggregation, and business queries.

- Normalized the Superstore CSV (9,994 rows) from a single denormalized table into 4 relational tables: `customers`, `products`, `orders`, `order_items`
- Wrote queries across 5 sections covering basic selects, WHERE filters, GROUP BY aggregations, INNER/LEFT JOINs, and advanced CASE logic with transactions

**Output:** Python load script + 5 SQL files (one per section)

---

## Week 3 — Advanced SQL Analytics

**Objective:** Apply Subqueries, CTEs, and Window Functions to analyze sales data.

- Used subqueries to identify above-average sales and highest-value orders
- Used CTEs for customer-level aggregations and intermediate calculations
- Applied Window Functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`) for customer ranking
- Combined JOINs, CTEs, and Window Functions for customer sales insights

**Output:** SQL script + query results + insights

---

## Week 4 — Azure Cloud and ADF Pipeline

**Objective:** Understand Azure fundamentals and build an end-to-end data pipeline.

- Created Resource Group, Storage Account, and Blob Container on Azure Portal
- Uploaded the Superstore dataset to Blob Storage
- Built an Azure Data Factory pipeline using Get Metadata and Copy Data activities
- Configured Linked Services, Datasets, and IAM roles
- Executed and monitored a Blob → ADF → Destination pipeline

**Output:** Screenshots + pipeline execution results + architecture summary

---

## Week 5 — Spark Fundamentals

**Objective:** Understand Spark basics and perform data cleaning, transformation, and aggregation using DataFrames.

- Created a Spark session and loaded CSV data into a DataFrame
- Performed data cleaning: removed duplicates, handled nulls
- Applied filters by age, category, and region
- Used `groupBy()` with `count()`, `sum()`, `avg()`, `min()`, `max()`
- Built a simple end-to-end pipeline: load → clean → filter → aggregate

**Output:** PySpark notebook + results + brief insights

---

## Week 6 — Spark Architecture and Optimized Processing

**Objective:** Understand Spark architecture and perform efficient data processing.

- Explored Spark architecture: Driver, Cluster Manager, Executors
- Applied Lazy Evaluation and DAG concepts
- Read and processed CSV and Parquet files with schema handling
- Performed column renaming, type casting, and null handling
- Understood wide transformations, shuffle, and Predicate Pushdown
- Saved processed data in CSV and Parquet formats

**Output:** PySpark code + execution results + performance insights

---

## Week 7 — Delta Lake MERGE and Incremental Processing

**Objective:** Perform incremental data processing using Delta Lake.

- Loaded dataset into a Delta table
- Cleaned data: handled nulls and removed duplicates
- Created an incremental dataset simulating new/updated records
- Applied `MERGE` operation to upsert records into the Delta table
- Validated results: row counts, duplicate checks

**Output:** Jupyter Notebook + screenshots + summary

---

## Week 8 — E-Commerce Order Analytics System

**Objective:** Build a local data engineering and analytics pipeline using Python and SQL.

* Generated 4 realistic e-commerce datasets with intentional data quality issues using Python
* Cleaned and validated data using Pandas, including date standardization, product name normalization, email validation, and referential integrity checks
* Loaded cleaned CSV data into a SQLite database with relational tables for customers, products, orders, and order items
* Wrote 16 SQL analytics queries covering aggregations, CTEs, subqueries, and Window Functions such as `DENSE_RANK`, `LAG`, `NTILE`, `FIRST_VALUE`, and `LAST_VALUE`
* Performed advanced analyses including revenue trends, customer segmentation, cohort retention, year-over-year comparison, and frequently purchased product pairs
* Built a command-line reporting tool that generates daily, weekly, or monthly business summaries with period-over-period comparisons
* Added edge-case tests for invalid order references, invalid discounts, zero quantities, and future order dates
* Added an additional end-to-end verification script to rerun the pipeline and verify data generation, cleaning, database setup, SQL execution, and edge-case tests

**Output:** Python scripts + cleaned CSVs + SQLite database + SQL analysis + CLI reporting tool + test and verification scripts
