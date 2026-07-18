# Week 5 — Spark Basics: Data Cleaning & Transformation

## Objective

Understand Spark fundamentals and perform data cleaning, transformation, and aggregation using DataFrames (PySpark).

## Dataset

**Sample Superstore Dataset** (`data/superstore.csv`)

The original assignment questions assume fields like `user_id`, `age`, `subscription`, `email`, `username`, and `store_id`, which aren't present in the Superstore dataset. Since Superstore already provides `Region`, `City`, `Category`, and `Sales` natively, it was used as the base dataset, and the following columns were synthetically added to cover the remaining fields:

| Assignment field        | Source in this notebook                                                                       |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| `user_id`               | `Customer ID`                                                                                 |
| `transaction_date`      | `Order Date`                                                                                  |
| `region`                | `Region`                                                                                      |
| `product_category`      | `Category`                                                                                    |
| `sale_amount` / `price` | `Sales`                                                                                       |
| `status`                | `Ship Mode`                                                                                   |
| `city`                  | `City`                                                                                        |
| `age`                   | synthetic (`Age`, randomly generated 18–68)                                                   |
| `subscription`          | synthetic (`Subscription`, randomly Premium/Standard)                                         |
| `email`                 | `Customer Name` (used as `Email`, since no real email field exists)                           |
| `username`              | `Customer ID` (used as `Username`)                                                            |
| `store_id`              | `State` (Superstore has no store concept; `State` used as the closest repeating grouping key) |

## Setup Notes

- Read with `multiLine=True, escape='"'` — `Product Name` contains embedded commas/quotes that break default CSV parsing and misalign columns downstream (see Q14).
- `Sales`, `Quantity`, `Discount` load as strings by default and are explicitly cast to numeric types before use.

## Environment

- Python 3.13.5
- Java 17.0.12 (LTS)
- PySpark (installed via `pip install pyspark`, run from terminal — not inside the notebook)

## Folder Structure

```
spark-assignment/
│── data/
│   └── superstore.csv
│── notebook/
│   └── spark_basics.ipynb
│── README.md
```

## How to Run

1. Install dependencies (in terminal, not notebook):
   ```
   pip install pyspark
   ```
2. Ensure Java 17 (or 8/11) is installed and `JAVA_HOME` is set.
3. Place `superstore.csv` in `data/`.
4. Open `notebook/spark_basics.ipynb` and run all cells top to bottom (Kernel → Restart & Run All recommended before submission, to ensure outputs are current and in order).

## What Was Covered

- Spark vs MapReduce, in-memory computing (Q1–Q2)
- Removing duplicates on key columns (Q3)
- Filtering + groupBy aggregation (Q4, Q6, Q8)
- Null handling: `.na.drop()` vs `.na.fill()` (Q5, Q9)
- DataFrame immutability in cleaning workflows (Q7)
- Schema modification: casting and renaming (Q10)
- Shuffle and wide vs narrow transformations (Q11)
- Multi-condition filtering on null/empty fields (Q12)
- Multi-statistic aggregation with `.agg()` (Q13)
- Risks of `inferSchema=True` on messy data — encountered directly via a real parsing bug caused by embedded quotes in `Product Name` (Q14)
- End-to-end pipeline: dedupe → fill nulls → group → aggregate (Q15)

## Key Observations

- The original dataset had zero nulls and no natural duplicates, so cleaning steps (`.na.fill()`, `dropDuplicates()`) run correctly but don't visibly change row counts — this is expected given the source data, not a bug.
- The `Sales`/`Quantity`/`Discount` CSV parsing issue caused by unescaped quotes in `Product Name` was a real, hands-on example of the exact risk Q14 asks about.
