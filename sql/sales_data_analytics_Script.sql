-- =========================================================
-- WEEK 3: SQL & DATA QUERYING
-- AnalystLab Africa Data Analytics Internship Program
-- Datasets: Chinook (music store) + sales_data (Kaggle sample sales)
-- =========================================================


-- =========================================================
-- 2. CORE SQL QUERIES
-- =========================================================

-- 2.1 SELECT / WHERE / ORDER BY
-- Business question: Which USA orders generated more than $5000 in sales?
SELECT "CUSTOMERNAME", "COUNTRY", "SALES", "ORDERDATE"
FROM sales_data
WHERE "COUNTRY" = 'USA' AND "SALES" > 5000
ORDER BY "SALES" DESC;


-- 2.2 GROUP BY / HAVING / Aggregate functions (SUM)
-- Business question: Which customers have spent more than $50,000 in total?
SELECT "CUSTOMERNAME", SUM("SALES") AS total_sales
FROM sales_data
GROUP BY "CUSTOMERNAME"
HAVING SUM("SALES") > 50000
ORDER BY total_sales DESC;


-- 2.3 Aggregate functions (COUNT, AVG)
-- Business question: How many orders has each customer placed, and what's their average order value?
SELECT "CUSTOMERNAME", 
       COUNT(*) AS num_orders, 
       AVG("SALES") AS avg_order_value
FROM sales_data
GROUP BY "CUSTOMERNAME"
ORDER BY num_orders DESC;


-- =========================================================
-- 3. ADVANCED SQL CONCEPTS - JOINS
-- =========================================================

-- 3.1 INNER JOIN
-- Business question: How much has each Chinook customer spent in total?
SELECT c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;


-- 3.2 LEFT JOIN
-- Business question: List every customer, including any with zero purchases
SELECT c.first_name, c.last_name, COALESCE(SUM(i.total), 0) AS total_spent
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent ASC;


-- 3.3 RIGHT JOIN
-- Business question: List every invoice along with its customer (mirror of LEFT JOIN)
SELECT c.first_name, c.last_name, i.invoice_id, i.total
FROM customer c
RIGHT JOIN invoice i ON c.customer_id = i.customer_id
ORDER BY i.invoice_id;


-- =========================================================
-- 3. ADVANCED SQL CONCEPTS - SUBQUERIES
-- =========================================================

-- 3.4 Subquery
-- Business question: Which customers spend above the average customer spend?
SELECT c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(i.total) > (
  SELECT AVG(customer_total)
  FROM (
    SELECT SUM(i2.total) AS customer_total
    FROM invoice i2
    GROUP BY i2.customer_id
  ) AS sub
)
ORDER BY total_spent DESC;


-- =========================================================
-- 3. ADVANCED SQL CONCEPTS - WINDOW FUNCTIONS
-- =========================================================

-- 3.5 ROW_NUMBER
-- Business question: Give every customer a unique sequential rank by spend
SELECT 
  c.first_name, c.last_name, SUM(i.total) AS total_spent,
  ROW_NUMBER() OVER (ORDER BY SUM(i.total) DESC) AS spend_rank
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY spend_rank;


-- 3.6 RANK
-- Business question: Rank customers by spend, allowing ties to share a rank
SELECT 
  c.first_name, c.last_name, SUM(i.total) AS total_spent,
  RANK() OVER (ORDER BY SUM(i.total) DESC) AS spend_rank
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY spend_rank;


-- 3.7 PARTITION BY
-- Business question: Rank tracks by length within each genre separately
SELECT 
  g.name AS genre,
  t.name AS track_name,
  t.milliseconds,
  RANK() OVER (PARTITION BY g.genre_id ORDER BY t.milliseconds DESC) AS length_rank_in_genre
FROM track t
JOIN genre g ON t.genre_id = g.genre_id
ORDER BY g.name, length_rank_in_genre;


-- =========================================================
-- 4. BUSINESS PROBLEM SOLVING
-- =========================================================

-- 4.1 Top-performing products (Chinook): best-selling artists by revenue
SELECT 
  ar.name AS artist_name,
  SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY ar.name
ORDER BY total_revenue DESC
LIMIT 10;

-- 4.2 Top-performing products (sales_data): best-selling product lines
SELECT "PRODUCTLINE", SUM("SALES") AS total_revenue
FROM sales_data
GROUP BY "PRODUCTLINE"
ORDER BY total_revenue DESC;

-- 4.3 Revenue trends over time (Chinook): monthly revenue
SELECT 
  DATE_TRUNC('month', invoice_date) AS month,
  SUM(total) AS monthly_revenue
FROM invoice
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY month;

-- 4.4 Revenue trends over time (sales_data): monthly revenue
SELECT 
  DATE_TRUNC('month', TO_DATE("ORDERDATE", 'MM/DD/YYYY')) AS month,
  SUM("SALES") AS monthly_revenue
FROM sales_data
GROUP BY DATE_TRUNC('month', TO_DATE("ORDERDATE", 'MM/DD/YYYY'))
ORDER BY month;

-- 4.5 Customer purchasing behavior (Chinook): first/last purchase + frequency
SELECT 
  c.first_name, c.last_name,
  MIN(i.invoice_date) AS first_purchase,
  MAX(i.invoice_date) AS most_recent_purchase,
  COUNT(i.invoice_id) AS total_purchases
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_purchases DESC;


-- =========================================================
-- 5. QUERY OPTIMIZATION
-- =========================================================

-- 5.1 Check baseline performance of a heavy join query (before indexing)
EXPLAIN ANALYZE
SELECT 
  ar.name AS artist_name,
  SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY ar.name
ORDER BY total_revenue DESC;

-- 5.2 Add indexes on join columns to test optimization impact
CREATE INDEX IF NOT EXISTS idx_invoice_line_track_id ON invoice_line(track_id);
CREATE INDEX IF NOT EXISTS idx_track_album_id ON track(album_id);
CREATE INDEX IF NOT EXISTS idx_album_artist_id ON album(artist_id);

-- 5.3 Re-run the same EXPLAIN ANALYZE after indexing, to compare plans
EXPLAIN ANALYZE
SELECT 
  ar.name AS artist_name,
  SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY ar.name
ORDER BY total_revenue DESC;
