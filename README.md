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
