-- ============================================================
-- SECTION B: FILTERING QUERIES
-- Database: celebaldb
-- Tables  : customers, products, orders, order_items
-- ============================================================


-- ============================================================
-- B1. Filter by region
-- ============================================================

-- All orders from the West region
SELECT order_id, order_date, city, state, region
FROM orders
WHERE region = 'West';

-- Orders NOT from the South region
SELECT order_id, order_date, city, state, region
FROM orders
WHERE region != 'South';

-- Orders from East or Central region
SELECT order_id, order_date, city, state, region
FROM orders
WHERE region IN ('East', 'Central');


-- ============================================================
-- B2. Filter by category / sub-category
-- ============================================================

-- All Furniture products
SELECT product_id, product_name, category, sub_category
FROM products
WHERE category = 'Furniture';

-- All Office Supplies products
SELECT product_id, product_name, category, sub_category
FROM products
WHERE category = 'Office Supplies';

-- Products in Phones or Chairs sub-category
SELECT product_id, product_name, category, sub_category
FROM products
WHERE sub_category IN ('Phones', 'Chairs');

-- Products that are NOT Technology
SELECT product_id, product_name, category
FROM products
WHERE category != 'Technology';


-- ============================================================
-- B3. Filter by date range
-- ============================================================

-- Orders placed in the year 2017
SELECT order_id, order_date, ship_date, ship_mode
FROM orders
WHERE order_date BETWEEN '2017-01-01' AND '2017-12-31';

-- Orders placed in Q1 2018 (Jan–Mar)
SELECT order_id, order_date, ship_date, region
FROM orders
WHERE order_date BETWEEN '2018-01-01' AND '2018-03-31';

-- Orders placed after January 1, 2019
SELECT order_id, order_date, ship_mode, region
FROM orders
WHERE order_date > '2019-01-01';

-- Orders shipped in November 2017
SELECT order_id, order_date, ship_date, ship_mode
FROM orders
WHERE ship_date BETWEEN '2017-11-01' AND '2017-11-30';


-- ============================================================
-- B4. Filter by sales amount
-- ============================================================

-- Line items with sales greater than 1000
SELECT item_id, order_id, product_id, sales, quantity, profit
FROM order_items
WHERE sales > 1000;

-- Line items with sales between 500 and 1000
SELECT item_id, order_id, product_id, sales, profit
FROM order_items
WHERE sales BETWEEN 500 AND 1000;

-- Line items with sales less than 50 (low value orders)
SELECT item_id, order_id, product_id, sales, quantity
FROM order_items
WHERE sales < 50;


-- ============================================================
-- B5. Filter by discount
-- ============================================================

-- Items sold with no discount
SELECT item_id, order_id, product_id, sales, discount
FROM order_items
WHERE discount = 0;

-- Items with discount greater than 20%
SELECT item_id, order_id, product_id, sales, discount, profit
FROM order_items
WHERE discount > 0.20;

-- Items with maximum discount (80%)
SELECT item_id, order_id, product_id, sales, discount, profit
FROM order_items
WHERE discount = 0.80;


-- ============================================================
-- B6. Filter by profit (loss detection)
-- ============================================================

-- Items sold at a loss (negative profit)
SELECT item_id, order_id, product_id, sales, discount, profit
FROM order_items
WHERE profit < 0;

-- Items with profit greater than 500
SELECT item_id, order_id, product_id, sales, profit
FROM order_items
WHERE profit > 500;

-- Items with zero profit
SELECT item_id, order_id, product_id, sales, discount, profit
FROM order_items
WHERE profit = 0;


-- ============================================================
-- B7. Filter by customer segment
-- ============================================================

-- All Corporate customers
SELECT customer_id, customer_name, segment
FROM customers
WHERE segment = 'Corporate';

-- All Consumer customers
SELECT customer_id, customer_name, segment
FROM customers
WHERE segment = 'Consumer';

-- Non-Consumer customers
SELECT customer_id, customer_name, segment
FROM customers
WHERE segment != 'Consumer';


-- ============================================================
-- B8. Filter by ship mode
-- ============================================================

-- Orders shipped via First Class
SELECT order_id, order_date, ship_date, ship_mode, city, state
FROM orders
WHERE ship_mode = 'First Class';

-- Orders NOT shipped via Standard Class
SELECT order_id, order_date, ship_date, ship_mode
FROM orders
WHERE ship_mode != 'Standard Class';

-- Same-day shipments
SELECT order_id, order_date, ship_date, ship_mode, city, state
FROM orders
WHERE ship_mode = 'Same Day';


-- ============================================================
-- B9. Filter by quantity
-- ============================================================

-- Line items where quantity ordered is greater than 5
SELECT item_id, order_id, product_id, quantity, sales
FROM order_items
WHERE quantity > 5;

-- Line items where exactly 1 unit was ordered
SELECT item_id, order_id, product_id, quantity, sales
FROM order_items
WHERE quantity = 1;


-- ============================================================
-- B10. Compound filters (AND / OR / NOT)
-- ============================================================

-- High-value orders in the West region (sales > 500)
-- Requires joining orders and order_items
SELECT oi.order_id, o.region, oi.sales, oi.profit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.region = 'West'
  AND oi.sales > 500;

-- Loss-making items with a discount applied
SELECT item_id, order_id, product_id, sales, discount, profit
FROM order_items
WHERE profit < 0
  AND discount > 0;

-- Technology products with sales over 1000
SELECT oi.item_id, oi.order_id, p.category, oi.sales, oi.profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE p.category = 'Technology'
  AND oi.sales > 1000;

-- Consumer segment customers OR orders from California
SELECT DISTINCT o.order_id, c.customer_name, c.segment, o.state
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.segment = 'Consumer'
   OR o.state = 'California';

-- Orders in 2018 with Same Day shipping
SELECT order_id, order_date, ship_date, ship_mode, region
FROM orders
WHERE ship_mode = 'Same Day'
  AND order_date BETWEEN '2018-01-01' AND '2018-12-31';


-- ============================================================
-- B11. Pattern matching with LIKE
-- ============================================================

-- Customers whose name starts with 'A'
SELECT customer_id, customer_name, segment
FROM customers
WHERE customer_name LIKE 'A%';

-- Products containing the word 'Chair' in the name
SELECT product_id, product_name, category
FROM products
WHERE product_name LIKE '%Chair%';

-- Orders from cities starting with 'New'
SELECT order_id, city, state, region
FROM orders
WHERE city LIKE 'New%';