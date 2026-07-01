# Assignment 3 - SQL Advanced Analytics (Subqueries, CTEs, Window Functions)

Sales analysis on the Sample Superstore dataset using MySQL: normalized schema, subqueries,
CTEs, and window functions to answer business questions about customer sales.

## Directory structure

```
assg3/
├── README.md                             (this file - results + insights)
├── superstore_analytics.sql              (full script: schema, load, all queries)
└── SampleSuperstore_Converted.csv        (source data)
```

## Dataset summary

| Metric                                       | Value     |
| -------------------------------------------- | --------- |
| Raw rows                                     | 9,994     |
| Unique orders (`orders1`, keyed on `row_id`) | 9,994     |
| Unique customers                             | 793       |
| Unique products                              | 1,862     |
| Average order-line sales                     | $229.85   |
| Average customer total sales                 | $2,896.49 |

## Query results

### 2.1 - Orders above average sales (subquery)

**2,359 of 9,994 order-lines** have `sales > AVG(sales)`.

### 2.2 - Highest sales order per customer (correlated subquery)

Returns one row per customer at their max `sales` value - 793 rows. Example (customer `AA-10315`,
Allen Armold): highest single order line is $3,930.07 on 2016-03-03.

### 2.3 / 2.5 - Total sales per customer, ranked (CTE + RANK/DENSE_RANK)

Top 10 of 793:

| Rank | Customer           | Total Sales |
| ---- | ------------------ | ----------- |
| 1    | Sean Miller        | $25,043.05  |
| 2    | Tamara Chand       | $19,052.22  |
| 3    | Raymond Buch       | $15,117.34  |
| 4    | Tom Ashbrook       | $14,595.62  |
| 5    | Adrian Barton      | $14,473.57  |
| 6    | Ken Lonsdale       | $14,175.23  |
| 7    | Sanjit Chand       | $14,142.33  |
| 8    | Hunter Lopez       | $12,873.30  |
| 9    | Sanjit Engle       | $12,209.44  |
| 10   | Christopher Conant | $12,129.07  |

`RANK()` and `DENSE_RANK()` match here since there are no exact total-sales ties in the top 10.

### 2.4 - Customers with above-average total sales (CTE + subquery)

**294 of 793 customers (37%)** exceed the $2,896.49 average - right-skewed distribution, a
small group of high spenders pulls the mean above the typical customer.

### 2.6 - Row number per order within each customer (ROW_NUMBER + PARTITION BY)

Assigns a running sequence per customer ordered by `order_date`. Example (Allen Armold,
`AA-10315`, first 5 of 11 order-lines):

| order_id       | sales     | order_date | seq |
| -------------- | --------- | ---------- | --- |
| CA-2015-121391 | $26.96    | 10/4/2015  | 1   |
| CA-2016-103982 | $3,930.07 | 3/3/2016   | 2   |
| CA-2016-103982 | $2.30     | 3/3/2016   | 3   |
| CA-2016-103982 | $431.98   | 3/3/2016   | 4   |
| CA-2016-103982 | $41.72    | 3/3/2016   | 5   |

### 2.7 / Step 3 - Top 3 customers (window function) & final combined query

| Rank | Customer     | Total Sales |
| ---- | ------------ | ----------- |
| 1    | Sean Miller  | $25,043.05  |
| 2    | Tamara Chand | $19,052.22  |
| 3    | Raymond Buch | $15,117.34  |

The Step 3 combined query (JOIN + CTE + `RANK()`) produces the same ranking for all 793
customers, just unfiltered.

## Mini Project: Customer Sales Insights

**Q1 - Top 5 customers**

| Customer      | Total Sales |
| ------------- | ----------- |
| Sean Miller   | $25,043.05  |
| Tamara Chand  | $19,052.22  |
| Raymond Buch  | $15,117.34  |
| Tom Ashbrook  | $14,595.62  |
| Adrian Barton | $14,473.57  |

**Q2 - Bottom 5 customers**

| Customer        | Total Sales |
| --------------- | ----------- |
| Thais Sissman   | $4.83       |
| Lela Donovan    | $5.30       |
| Carl Jackson    | $16.52      |
| Mitch Gastineau | $16.74      |
| Roy Skaria      | $22.33      |

**Q3 - Single-order customers (12 total)**

| Customer          | Order ID       | Order Total |
| ----------------- | -------------- | ----------- |
| Jenna Caffey      | CA-2017-108560 | $1,058.11   |
| Susan MacKendrick | CA-2016-129280 | $1,043.04   |
| Theresa Coyne     | CA-2017-124205 | $1,038.26   |
| Jocasta Rupert    | CA-2017-117079 | $863.88     |
| Patricia Hirasaki | CA-2017-113558 | $729.65     |
| Anthony O'Donnell | CA-2016-148096 | $161.28     |
| Roland Murray     | CA-2017-168193 | $98.35      |
| Anemone Ratner    | CA-2016-157588 | $88.15      |
| Ricardo Emerson   | CA-2014-165477 | $48.36      |
| Mitch Gastineau   | CA-2017-115070 | $16.74      |
| Carl Jackson      | CA-2016-163951 | $16.52      |
| Lela Donovan      | CA-2016-152331 | $5.30       |

**Q4 - Above-average customers**: 294 of 793 (37%) - see 2.4.

**Q5 - Highest order value per customer (top 5)**

| Customer     | Highest Order Line |
| ------------ | ------------------ |
| Sean Miller  | $22,638.48         |
| Tamara Chand | $17,499.95         |
| Raymond Buch | $13,999.96         |
| Tom Ashbrook | $11,199.97         |
| Hunter Lopez | $10,499.97         |

## Insights

- **Sales concentration is heavy at the top.** Sean Miller ($25K) and Tamara Chand ($19K) are
  each driven mostly by one outsized order line ($22.6K and $17.5K respectively) rather than
  many purchases - "consistently high-value" and "one big purchase" customers look identical in
  a total-sales ranking but need different account strategies.
- **37% of customers are above average**, not 50% - confirms the right-skew: a handful of large
  accounts pull the mean well above the median customer's spend.
- **12 single-order customers** split into two groups: a handful spent $700–$1,050 on their one
  order (Jenna Caffey, Susan MacKendrick, Theresa Coyne) - plausible re-engagement targets - and
  the rest spent under $50, likely low-intent one-off buyers.

## Known data-quality notes (handled in the script)

- `customer_id` and `product_id` each map to more than one raw-row text value (different
  ship-to addresses; minor product-name variants), so dimension tables use `GROUP BY` +
  `ANY_VALUE()` rather than a literal `SELECT DISTINCT` on the full row.
- `(order_id, product_id)` is not unique - 8 pairs repeat as separate line items in the same
  order - so `orders1` is keyed on `row_id` instead.
