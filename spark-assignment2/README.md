# Week 6: Spark Architecture & Efficient Data Processing

## Objective

Understand Spark architecture and perform efficient data processing using transformations, filtering, schema handling, and optimized file formats. This covers Driver/Cluster Manager/Executor roles, lazy evaluation and DAG lineage, reading CSV/Parquet with schema handling, filtering and column selection, DataFrame modification (rename, cast, add columns), wide transformations, shuffle and predicate pushdown, and building a full read-transform-filter-write pipeline.

## Dataset

Base dataset: Superstore (`superstore.csv`), containing order-level retail data with columns such as `Row ID`, `Order ID`, `Customer ID`, `Region`, `Product ID`, `Category`, `Sales`, `Quantity`, `Discount`, and `Profit`.

The original dataset does not include several fields referenced in the assignment questions (`status`, `priority`, `base_price`, `user_id`, `Age`, `Subscription`). These were added synthetically for this exercise:

| Added column   | How it was generated                                     |
| -------------- | -------------------------------------------------------- |
| `Age`          | Random integer between 18 and 67                         |
| `Subscription` | Randomly assigned "Premium" or "Standard"                |
| `Email`        | Alias of `Customer Name` (placeholder, not a real email) |
| `Username`     | Alias of `Customer ID`                                   |
| `status`       | Randomly assigned "Completed", "Pending", or "Cancelled" |
| `priority`     | Randomly assigned "High", "Medium", or "Low"             |
| `base_price`   | Derived from real data: `Sales / Quantity`               |
| `user_id`      | Alias of `Customer ID` (real identifier, not fabricated) |

These additions are for exercise purposes only and do not reflect real order status, priority, or subscription data.

## Environment Setup

- PySpark 4.2.0
- Java 17.0.12
- Windows local setup (no cluster)

### Windows-specific fix: winutils

Spark's local file writes (`.parquet()`, `.csv()`) require Hadoop's `winutils.exe` on Windows, since Hadoop's filesystem layer needs it to set file permissions and create directories. Without it, writes fail with:

```
FileNotFoundException: HADOOP_HOME and hadoop.home.dir are unset
```

Fix applied: downloaded a Hadoop 3.3.6 build of `winutils.exe` and `hadoop.dll` (closest available match to the Hadoop client version bundled with PySpark 4.2.0, since no exact 3.5.0 build is publicly available yet), placed them under `C:\hadoop\bin`, and set the environment variables at the top of the notebook before creating the SparkSession:

```python
import os
os.environ["HADOOP_HOME"] = "C:\\hadoop"
os.environ["PATH"] += os.pathsep + "C:\\hadoop\\bin"
```

## How to Run

1. Place `superstore.csv` in `../data/superstore.csv` relative to the notebook.
2. Run all cells top to bottom in order.
3. Outputs are written to:
   - `../data/superstore_parquet/` (Parquet)
   - `../data/superstore_output_csv/` (CSV, nulls in `user_id` filtered out)

## Contents

The notebook answers Q1 to Q15 covering:

- Spark architecture: Driver, Cluster Manager, Executor, Client vs Cluster mode
- Lazy evaluation and DAG lineage, including fault tolerance
- Reading CSV with header and inferSchema
- CSV vs Parquet storage format and predicate pushdown
- Column selection, filtering (AND/OR conditions), renaming, and type casting
- Adding a computed column (tax-adjusted price)
- Transformations vs actions
- Full pipeline: read Parquet, filter nulls, write CSV
- Best practices for large datasets (`show()` vs `collect()`)

## Notes

- `Category` in this dataset only contains `Furniture`, `Office Supplies`, and `Technology` (no `Electronics`). Queries referencing category filters use `Technology` accordingly.
- `Region` only contains `South`, `Central`, `East`, and `West` (no `North`).
