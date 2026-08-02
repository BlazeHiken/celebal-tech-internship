# Delta Lake Incremental Processing Assignment

Incremental data processing (SCD Type 1 and SCD Type 2) on a customer dataset derived from the Sample Superstore data, using PySpark and Delta Lake.

## Objective

Load a customer dataset into a Delta table, clean it, simulate an incremental batch of new and updated records, apply a MERGE operation to update the table (SCD1) and separately to preserve full history (SCD2), then validate the results.

## Data

- `data/superstore.csv`: source dataset (Sample Superstore).
- `data/customer_master.csv`: customer master data derived from the Superstore dataset, deduplicated by Customer ID (793 unique customers). A few nulls and duplicate rows were added on purpose so the cleaning step has something real to fix (798 rows before cleaning).
- `data/customer_incremental.csv`: simulated incremental batch of 30 records: 20 existing customers with changed segment and city values (updates), and 10 brand new customers (inserts).

## Environment

Requires Java 11+, PySpark, and delta-spark.

```bash
pip install pyspark==3.5.3 delta-spark==3.2.0
```

Note: pyspark 4.x and the latest delta-spark do not yet have a matching released build, this version pairing is the stable one.

On Windows, Spark needs a local Hadoop winutils build to work with the local file system. This notebook expects `C:\hadoop\bin\winutils.exe` and `hadoop.dll` to be present, and sets `HADOOP_HOME` accordingly in the first cell.

On first run, Spark resolves the `io.delta:delta-spark` package from Maven Central, so an internet connection is needed the first time the notebook runs (the JAR is cached locally after that).

## Notebook

`notebooks/delta_scd_assignment.ipynb` covers:

1. **Load data**: read the Superstore CSV, build a deduplicated customer master table, inject a few nulls and duplicate rows.
2. **Load into a Delta table**: write the master data as an actual Delta table (not just a CSV or DataFrame).
3. **Basic cleaning**: identify and drop null rows and exact duplicates, overwrite the Delta table with the cleaned version (798 rows down to 785).
4. **Create incremental data**: simulate a new batch (20 updates, 10 new customers).
5. **SCD Type 1 merge**: update matched rows in place, insert unmatched rows. No history is kept, only the latest state (785 rows to 795 rows).
6. **SCD Type 2 merge**: seed a fresh Delta table with `effective_date`, `end_date`, and `is_current` columns. Expire the old row for any customer whose data changed, then insert a new current row for both updated and brand new customers, preserving full history (785 rows to 815 rows: 795 current, 20 expired).
7. **Validation**: row counts before and after each merge, and a duplicate key check confirming no customer has more than one active row at a time.
8. **Final output**: side by side comparison of the SCD1 table (point in time, no history) and the SCD2 table (current records plus full history), including one customer's full before and after history as an example.

## Results Summary

Loaded Superstore customer data into a Delta table (798 raw rows, cleaned to 785 by removing 5 duplicate rows and 8 rows with null segment or postal code). Simulated an incremental batch of 30 records (20 updates, 10 new customers).

Applied an SCD Type 1 merge: updated matched rows in place, inserted unmatched rows, no history kept. Result: 785 to 795 rows, 0 duplicate keys.

Applied an SCD Type 2 merge on a fresh copy of the cleaned data: expired the old version of any changed row and inserted a new current version, preserving full history. Result: 785 to 815 rows (795 current, 20 expired), 0 customers with more than one active row at a time.

## Screenshots

Screenshots of key cell outputs are in `screenshots/`, organized by step:

- `data_loading/`: Delta table creation and file confirmation
- `data_cleaning/`: null and duplicate counts, before and after cleaning
- `scd1/`: SCD1 merge execution and result
- `scd2/`: SCD2 seed, expire step, insert step
- `validation/`: row count and duplicate key checks for both merges
- `final_output/`: SCD1 vs SCD2 comparison and example customer history

## Project Structure

```
delta-lake-assignment/
├── data/
│   ├── superstore.csv
│   ├── customer_master.csv
│   └── customer_incremental.csv
├── notebooks/
│   └── delta_scd_assignment.ipynb
├── screenshots/
│   ├── data_loading/
│   ├── data_cleaning/
│   ├── scd1/
│   ├── scd2/
│   ├── validation/
│   └── final_output/
└── README.md
```
