# SQL Analytics Portfolio Project
## Week 3 — SQL & Data Querying

**Author:** Akorede Adekoya  
**Program:** AnalystLab Africa Data Analytics Internship (Batch B)  
**Database:** PostgreSQL (Supabase)  
**Datasets:** Chinook Database & Sales Data Sample

---

# Table of Contents

1. Executive Summary
2. Project Overview
3. Database Architecture
4. Core SQL Queries
   - Filtering & Sorting
   - Aggregation & Grouping
5. Advanced SQL Techniques
   - Joins
   - Subqueries
   - Window Functions
6. Business Analysis
   - Customer Analysis
   - Product Performance
   - Revenue Trends
7. Query Optimization
8. Key Findings
9. Technical Skills Demonstrated
10. Conclusion

---

# Executive Summary

This project demonstrates practical SQL analytics skills using two datasets:

- **Chinook Database** (digital music store)
- **Sales Data Sample** (transactional sales records)

The analysis covers:

- Data retrieval and filtering
- Aggregation and business reporting
- Relational joins
- Subqueries
- Window functions
- Trend analysis
- Query optimization

The goal was to transform raw relational data into business insights while applying industry-standard SQL techniques.

---

# Project Overview

## Objective

Develop proficiency in SQL by solving business-oriented analytical questions across multiple datasets.

## Environment

| Component | Technology |
|------------|------------|
| Database | PostgreSQL |
| Hosting | Supabase |
| Query Language | SQL |
| Dataset 1 | Chinook Database |
| Dataset 2 | Sales Data Sample |

---

# Database Architecture

## Chinook Schema

```text
Customer
   │
   ▼
Invoice
   │
   ▼
Invoice_Line
   │
   ▼
Track
   │
   ▼
Album
   │
   ▼
Artist
```

### Key Relationships

| Table | Key |
|---------|---------|
| Customer | customer_id |
| Invoice | invoice_id |
| Track | track_id |
| Album | album_id |
| Artist | artist_id |

---

## Sales Dataset

A denormalized transactional table containing:

- Customer information
- Product information
- Order details
- Revenue metrics

Important fields:

```text
ORDERNUMBER
CUSTOMERNAME
PRODUCTLINE
ORDERDATE
COUNTRY
SALES
```

---

# Core SQL Queries

## 1. Filtering & Sorting

### Business Question

Which USA orders generated more than $5,000 in sales?

```sql
SELECT "CUSTOMERNAME",
       "COUNTRY",
       "SALES",
       "ORDERDATE"
FROM sales_data
WHERE "COUNTRY" = 'USA'
  AND "SALES" > 5000
ORDER BY "SALES" DESC;
```

### Insight

- Highest order value: **$14,082.80**
- Top customer: **The Sharp Gifts Warehouse**
- Several customers appeared repeatedly among large-value transactions.

---

## 2. Aggregation & Grouping

### Business Question

Which customers generated more than $50,000 in revenue?

```sql
SELECT "CUSTOMERNAME",
       SUM("SALES") AS total_sales
FROM sales_data
GROUP BY "CUSTOMERNAME"
HAVING SUM("SALES") > 50000
ORDER BY total_sales DESC;
```

### Insight

**Top Customer:**

| Customer | Revenue |
|-----------|-----------|
| Euro Shopping Channel | $912,294.11 |

Key observation:

- Revenue is heavily concentrated among a small number of customers.
- High revenue can result from:
  - Frequent purchases
  - Large average transaction values

---

# Advanced SQL Techniques

## Joins

### Customer Spending Analysis

```sql
SELECT c.first_name,
       c.last_name,
       SUM(i.total) AS total_spent
FROM customer c
INNER JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id,
         c.first_name,
         c.last_name
ORDER BY total_spent DESC;
```

### Finding

All INNER, LEFT, and RIGHT joins returned equivalent results.

This confirms:

✅ Strong referential integrity  
✅ No orphan records  
✅ Consistent relationships

---

## Subqueries

### Business Question

Which customers spend above average?

```sql
SELECT c.first_name,
       c.last_name,
       SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id,
         c.first_name,
         c.last_name
HAVING SUM(i.total) >
(
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(i2.total) AS customer_total
        FROM invoice i2
        GROUP BY i2.customer_id
    ) sub
);
```

### Finding

- 22 of 59 customers spend above average.
- Approximately 37% exceed the dataset-wide average.

---

## Window Functions

### Customer Ranking

```sql
SELECT c.first_name,
       c.last_name,
       SUM(i.total) AS total_spent,
       ROW_NUMBER() OVER (
           ORDER BY SUM(i.total) DESC
       ) AS spend_rank
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id,
         c.first_name,
         c.last_name;
```

### Key Learning

| Function | Behavior |
|-----------|-----------|
| ROW_NUMBER() | Always unique |
| RANK() | Handles ties and skips positions |

---

# Business Analysis

## Top Revenue Generators

### Chinook Artists

| Rank | Artist |
|--------|--------|
| 1 | Iron Maiden |
| 2 | U2 |
| 3 | Metallica |
| 4 | Led Zeppelin |

### Sales Dataset Product Lines

| Product Line | Revenue |
|--------------|-----------|
| Classic Cars | $3,919,615.66 |
| Vintage Cars | $1,903,150.84 |
| Trains | $226,243.47 |

### Insight

Classic Cars generated more than double the revenue of the next best-performing category.

---

## Revenue Trends

### Monthly Revenue Analysis

```sql
SELECT DATE_TRUNC('month', invoice_date) AS month,
       SUM(total) AS monthly_revenue
FROM invoice
GROUP BY DATE_TRUNC('month', invoice_date);
```

### Key Findings

#### Chinook

- Flat monthly revenue patterns
- Minimal variation over five years
- Indicates synthetic sample data

#### Sales Dataset

- Strong November revenue spikes
- Elevated October performance
- Clear retail seasonality
- Year-over-year growth trend

---

## Customer Purchasing Behavior

Analysis revealed:

- 58 of 59 customers made exactly 7 purchases.
- One customer made 6 purchases.
- Purchase behavior is highly uniform.

This further supports the conclusion that the Chinook dataset is primarily intended for training and demonstration purposes.

---

# Query Optimization

## Performance Testing

### Query Profiled

Artist revenue aggregation query using multiple joins.

### Indexes Added

```sql
CREATE INDEX idx_invoice_line_track_id
ON invoice_line(track_id);

CREATE INDEX idx_track_album_id
ON track(album_id);

CREATE INDEX idx_album_artist_id
ON album(artist_id);
```

### Results

| Metric | Before | After |
|----------|----------|----------|
| Execution Time | 4.405 ms | 4.613 ms |
| Planning Time | 4.088 ms | 1.625 ms |

### Conclusion

The PostgreSQL optimizer continued to use sequential scans because:

- Tables are small
- Full scans remain cheaper than index lookups
- Indexing is not always beneficial

---

# Key Findings

1. Revenue concentration differs dramatically across datasets.
2. Euro Shopping Channel dominates sales revenue.
3. Chinook demonstrates strong referential integrity.
4. Window functions provide powerful ranking capabilities.
5. Sales data exhibits realistic seasonality.
6. Chinook behaves like synthetic training data.
7. Classic Cars is the highest-performing product line.
8. Indexing should be applied strategically, not automatically.

---

# Technical Skills Demonstrated

### SQL Fundamentals

- SELECT
- WHERE
- ORDER BY
- GROUP BY
- HAVING

### Advanced SQL

- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- Subqueries
- Window Functions
- DATE_TRUNC
- Aggregate Functions

### Database Performance

- EXPLAIN ANALYZE
- Index Design
- Query Optimization

---

# Conclusion

This project demonstrates end-to-end SQL analysis within PostgreSQL using realistic business scenarios. The work showcases the ability to retrieve, transform, analyze, and optimize relational data while generating actionable business insights.

The project highlights practical proficiency in SQL and serves as a portfolio-ready example suitable for GitHub repositories, internship submissions, and data analytics portfolios.
