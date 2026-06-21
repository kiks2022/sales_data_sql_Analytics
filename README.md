# Sales Data SQL Analytics Project

SQL analytics project using the Chinook relational database and a Kaggle sales dataset. The project demonstrates end-to-end SQL analytics skills including data modeling, joins, window functions, and performance evaluation using PostgreSQL (Supabase).

---

## 📊 Datasets

| Dataset | Source | Description |
|---|---|---|
| Chinook Database | GitHub – [lerocha/chinook-databas](url)e | Music store transactional database containing customers, invoices, tracks, and albums |
| Sample Sales Data | [Kaggle – Sample Sales Data](url) | E-commerce sales dataset with 2,800+ orders across multiple product lines |

---

## 🧱 Database Schema

The project uses a relational model built on the Chinook dataset and a separate sales dataset.

- `invoice_line` serves as the primary fact table for transactional revenue
- `track`, `album`, and `artist` define the product hierarchy
- The schema follows a star-like analytical structure optimized for SQL querying

![Chinook Star Schema](chinook_star_schema.png)

---

## 🛠️ Tools & Technologies

- **Database:** PostgreSQL (Supabase-hosted)
- **Query Interface:** Supabase SQL Editor, pgAdmin 4
- **Language:** SQL
- **Visualization:** Python (Matplotlib)

---

## 🧠 Skills Demonstrated

### 1. Core SQL Querying
- Filtering and sorting using `SELECT`, `WHERE`, and `ORDER BY`
- Aggregation using `GROUP BY`, `HAVING`, `SUM`, `AVG`, and `COUNT`
- Customer-level and product-level revenue analysis

---

### 2. Table Joins
- `INNER JOIN` for linking customers to invoices in Chinook
- `LEFT JOIN` for retaining all customers regardless of transaction history
- `RIGHT JOIN` for preserving invoice-level completeness
- Consistent join outputs indicate strong referential integrity in the dataset

---

### 3. Advanced SQL Techniques
- **Subqueries:** Identified above-average spenders (22 of 59 customers, ~37%)
- **Window Functions:**
  - `ROW_NUMBER()` for unique ranking
  - `RANK()` to demonstrate tie behavior in revenue distribution
  - `PARTITION BY` to rank tracks within each genre group
- Analysis of ranking logic differences and their business implications

---

### 4. Business Analysis

- **Top Revenue Artists:**
  - Iron Maiden – $138.60  
  - U2 – $105.93  
  - Metallica – $90.09  

- **Top Product Line:**
  - Classic Cars generated $3.9M in revenue, significantly outperforming other categories

- **Seasonality Insights:**
  - Sales dataset shows consistent November peaks across years, indicating strong holiday-driven demand

- **Customer Behaviour:**
  - 58 of 59 Chinook customers made exactly 7 purchases, indicating a structured or synthetic dataset design

---

### 5. Query Optimization & Performance

- Indexes created on:
  - `invoice_line.track_id`
  - `track.album_id`
  - `album.artist_id`

- Performance testing using `EXPLAIN ANALYZE` revealed:
  - PostgreSQL optimizer continued using sequential scans
  - Indexes were not utilized due to small dataset size
  - Demonstrates an important real-world insight: indexing benefits depend on scale and query patterns

---

## 📌 Key Insights

1. Revenue is concentrated in a small number of high-performing artists and product categories, indicating strong skew in distribution.
2. Referential integrity across the Chinook dataset is well maintained, as join operations consistently return complete and consistent results.
3. Window functions provide deeper analytical capabilities beyond standard aggregation, particularly for ranking and segmentation.
4. The Chinook dataset exhibits characteristics of synthetic data, including uniform purchase distribution and consistent transaction patterns.
5. The Kaggle sales dataset shows realistic seasonality effects, particularly recurring Q4 (November) revenue spikes driven by consumer purchasing behavior.

---

## 📈 Project Outcome

This project demonstrates the ability to:
- Design and query relational databases using SQL
- Perform multi-table joins and advanced analytics
- Apply window functions for ranking and segmentation
- Evaluate query performance and indexing behavior
- Extract business insights from structured datasets
