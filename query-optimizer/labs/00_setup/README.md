# Data Understanding Notes

This document explains the data shape used in the Oracle Optimizer labs.

Before reading execution plans, it is important to understand the data, because Oracle Optimizer decisions depend heavily on:

* Table size
* Column values
* Data distribution
* Skew
* Correlation between columns
* Available indexes
* Statistics and histograms

---

## Optimizer Flow

Oracle uses statistics to estimate the best execution plan.

```text
Statistics
  ↓
Selectivity
  ↓
Estimated Rows
  ↓
Cost
  ↓
Execution Plan
```

Key idea:

```text
Wrong Estimated Rows
-> Wrong Cost
-> Wrong Plan
-> Slow Query
```

---

## Data Design Purpose

The data is intentionally designed for optimizer experiments.

It includes:

* Skewed city values
* Skewed status values
* Related columns such as `country` and `city`
* Common values
* Rare values
* Indexed columns
* Non-indexed columns
* Joinable tables

The goal is to make Oracle Optimizer decisions visible and easier to compare.

The labs are designed to show why Oracle may choose:

* `TABLE ACCESS FULL`
* `INDEX RANGE SCAN`
* `NESTED LOOPS`
* `HASH JOIN`

---

# Tables in This Lab

## 1. OPT_CUSTOMERS

This table represents customers.

Important columns:

* `customer_id`: unique customer identifier
* `full_name`: customer name
* `country`: customer country
* `city`: customer city
* `email`: customer email
* `status`: customer status
* `created_at`: customer creation date

Primary key:

* `customer_id`

Useful filters:

```sql
WHERE city = 'Cairo'
```

```sql
WHERE country = 'Egypt'
AND city = 'Cairo'
```

This table helps study:

* Filtering by city
* Filtering by country and city together
* Searching by email
* Skewed values
* Correlation between `country` and `city`
* Full table scan vs index access

---

## 2. OPT_ORDERS

This table represents customer orders.

Important columns:

* `order_id`: unique order identifier
* `customer_id`: the customer who made the order
* `status`: order status
* `city`: order city
* `order_total`: total order amount
* `created_at`: order creation date

Primary key:

* `order_id`

Foreign key:

* `customer_id` references `opt_customers(customer_id)`

Useful join:

```sql
SELECT *
FROM opt_customers c
JOIN opt_orders o
  ON o.customer_id = c.customer_id;
```

Useful filters:

```sql
WHERE status = 'PAID'
```

```sql
WHERE city = 'Cairo'
AND status = 'PAID'
```

This table helps study:

* Oracle join behavior
* `NESTED LOOPS`
* `HASH JOIN`
* Status distribution
* Estimated rows
* Composite indexes
* Pagination queries using date-based indexes

---

## 3. OPT_ORDER_ITEMS

This table represents the items inside each order.

Important columns:

* `item_id`: unique item identifier
* `order_id`: the order this item belongs to
* `product_category`: product category
* `quantity`: item quantity
* `unit_price`: item price

Primary key:

* `item_id`

Foreign key:

* `order_id` references `opt_orders(order_id)`

Useful join:

```sql
SELECT *
FROM opt_orders o
JOIN opt_order_items i
  ON i.order_id = o.order_id;
```

Relationship:

```text
customers -> orders -> order_items
```

This table helps study:

* Join behavior
* Parent/child table access
* Order-to-items access patterns
* Cases where Oracle is not the real reason for endpoint slowness

---

# Data Skew

Data skew means values are not evenly distributed.

Example:

```text
Cairo = common value
Another city = rare value
```

This matters because Oracle may estimate rows incorrectly if it does not understand the real distribution.

Example:

```text
Oracle estimated rows: 1,000
Actual rows: 7,000
```

When reading an execution plan, always compare:

```text
E-Rows vs A-Rows
```

---

# City Distribution

The `city` column is one of the most important columns in this lab.

It may contain both common and rare cities.

Example:

```sql
WHERE city = 'Cairo'
```

If the city is very common, Oracle may decide that reading a large part of the table is cheaper and choose:

```text
TABLE ACCESS FULL
```

If the city is rare, Oracle may decide that using an index is cheaper and choose:

```text
INDEX RANGE SCAN
```

Important idea:

```text
An index exists, but Oracle does not always have to use it.
```

Oracle chooses the access path based on estimated cost.

---

# Status Distribution

The `status` column is also important.

Some status values may be common, and others may be rare.

Example:

```text
PAID = common
CANCELLED = less common
```

Useful filters:

```sql
WHERE status = 'PAID'
```

```sql
WHERE status = 'CANCELLED'
```

If the status value is common, Oracle may avoid using an index.

If the status value is rare, Oracle may prefer using an index.

This helps explain selectivity.

Selectivity means:

```text
How much of the table is expected to pass the filter.
```

Low selectivity means many rows match.

High selectivity means few rows match.

---

# Correlation Between Columns

Some columns are naturally related.

Example:

```text
country -> city
```

If the country is `Egypt`, then `Cairo` is more likely than a random city.

Example query:

```sql
WHERE country = 'Egypt'
AND city = 'Cairo'
```

Oracle may estimate this incorrectly if it assumes that `country` and `city` are independent.

Important note:

```text
Correlation is not the same thing as a foreign key.
```

A foreign key is a database relationship between tables.

Correlation means two columns have a natural relationship in the data.

This will be useful later when studying extended statistics.

---

# Indexes in This Lab

Indexes exist so the labs can show when Oracle uses them and when Oracle ignores them.

Important idea:

```text
The existence of an index does not mean Oracle must use it.
```

Oracle compares possible access paths and chooses the plan it estimates to be cheaper.

---

## Indexes on OPT_CUSTOMERS

### 1. ix_opt_customers_city

Index on:

```text
city
```

Created as:

```sql
CREATE INDEX ix_opt_customers_city
ON opt_customers(city);
```

Useful for:

```sql
WHERE city = 'Cairo'
```

Why this index matters:

* If the city is rare, Oracle may use the index.
* If the city is very common, Oracle may choose a full table scan.

This helps compare:

```text
TABLE ACCESS FULL vs INDEX RANGE SCAN
```

---

### 2. ix_opt_customers_country_city

Index on:

```text
country, city
```

Created as:

```sql
CREATE INDEX ix_opt_customers_country_city
ON opt_customers(country, city);
```

This is a composite index.

Leading column:

```text
country
```

Useful for:

```sql
WHERE country = 'Egypt'
```

```sql
WHERE country = 'Egypt'
AND city = 'Cairo'
```

Why this index matters:

It shows that composite index column order matters.

Because `country` is the first column, this index is naturally useful when the query filters by `country`.

---

### 3. ix_opt_customers_email

Index on:

```text
email
```

Created as:

```sql
CREATE INDEX ix_opt_customers_email
ON opt_customers(email);
```

Useful for:

```sql
WHERE email = 'someone@example.com'
```

Why this index matters:

Email is usually very selective, so Oracle is likely to use an index for this type of query.

---

## Indexes on OPT_ORDERS

### 1. ix_opt_orders_customer

Index on:

```text
customer_id
```

Created as:

```sql
CREATE INDEX ix_opt_orders_customer
ON opt_orders(customer_id);
```

Useful for joins between customers and orders:

```sql
o.customer_id = c.customer_id
```

Why this index matters:

It helps Oracle find orders for a specific customer.

---

### 2. ix_opt_orders_city_status

Index on:

```text
city, status
```

Created as:

```sql
CREATE INDEX ix_opt_orders_city_status
ON opt_orders(city, status);
```

This is a composite index.

Leading column:

```text
city
```

Useful for:

```sql
WHERE city = 'Cairo'
```

```sql
WHERE city = 'Cairo'
AND status = 'PAID'
```

Why this index matters:

It helps study composite indexes when the query filters by the first column.

---

### 3. ix_opt_orders_status_city

Index on:

```text
status, city
```

Created as:

```sql
CREATE INDEX ix_opt_orders_status_city
ON opt_orders(status, city);
```

This is a composite index.

Leading column:

```text
status
```

Useful for:

```sql
WHERE status = 'PAID'
```

```sql
WHERE status = 'PAID'
AND city = 'Cairo'
```

Why this index matters:

This index has the same columns as `ix_opt_orders_city_status`, but in a different order.

It helps compare:

```text
(city, status)
```

versus:

```text
(status, city)
```

and understand why index column order matters.

---

### 4. ix_opt_orders_created_id

Index on:

```text
created_at DESC, order_id DESC
```

Created as:

```sql
CREATE INDEX ix_opt_orders_created_id
ON opt_orders(created_at DESC, order_id DESC);
```

Useful for:

```sql
ORDER BY created_at DESC, order_id DESC
```

Pagination example:

```sql
ORDER BY created_at DESC, order_id DESC
FETCH NEXT 20 ROWS ONLY
```

Why this index matters:

It helps later when studying pagination strategies.

---

## Indexes on OPT_ORDER_ITEMS

### 1. ix_opt_items_order

Index on:

```text
order_id
```

Created as:

```sql
CREATE INDEX ix_opt_items_order
ON opt_order_items(order_id);
```

Useful for joins between orders and order items:

```sql
i.order_id = o.order_id
```

Why this index matters:

It helps Oracle find all items for a specific order.

---

# Indexed Columns

Important indexed columns:

```text
opt_customers.customer_id
opt_customers.city
opt_customers.country, city
opt_customers.email

opt_orders.order_id
opt_orders.customer_id
opt_orders.city, status
opt_orders.status, city
opt_orders.created_at, order_id

opt_order_items.item_id
opt_order_items.order_id
```

These columns may provide possible index access paths.

---

# Columns Without Direct Indexes

Some columns do not have direct indexes.

Examples:

```text
opt_order_items.product_category
opt_order_items.quantity
opt_order_items.unit_price
opt_orders.order_total
```

If a query filters only on a column without a useful index, Oracle may choose:

```text
TABLE ACCESS FULL
```

This helps compare indexed access with non-indexed access.

---

# Statistics

Oracle Optimizer uses statistics to estimate how many rows a query will return.

Statistics can include:

* Number of rows in a table
* Number of blocks
* Number of distinct values in a column
* Number of nulls
* Density
* Index statistics
* Last analyzed date

Important idea:

```text
Oracle does not scan all data before choosing every plan.
```

Instead, Oracle uses statistics to estimate:

```text
How many rows will match?
How expensive is each access path?
Which plan is likely cheaper?
```

---

# Statistics Status in This Setup

After creating tables, inserting data, and creating indexes, statistics should be gathered.

At this stage, the goal is:

```text
Gather statistics without histograms first.
```

This is usually done using:

```sql
DBMS_STATS.GATHER_TABLE_STATS(...)
```

with:

```sql
method_opt => 'FOR ALL COLUMNS SIZE 1'
```

Meaning:

```text
Gather basic column statistics, but do not create histograms.
```

Why no histograms first?

Because the first labs need to show how Oracle estimates skewed data using only basic statistics.

Later, histograms will be added and compared.

---

# Histograms

A histogram helps Oracle understand skewed data.

Without a histogram, Oracle may treat values as if they are evenly distributed.

Example:

If `city` has 10 distinct values, Oracle may roughly estimate:

```text
Each city = about 10% of the table
```

But the real data may be:

```text
Cairo = 70%
Another city = 1%
```

In that case, Oracle may estimate rows incorrectly.

Important idea:

```text
NDV alone may not be enough when the data is skewed.
```

NDV means:

```text
Number of Distinct Values
```

A histogram can help Oracle understand which values are common and which values are rare.

---

# Current Histogram Status

At the beginning of the labs:

```text
Histograms are intentionally not added yet.
```

This helps study the before-histogram behavior.

Later comparison:

```text
Before histogram:
Oracle may estimate skewed values badly.

After histogram:
Oracle may estimate common and rare values better.
```

Columns that may need histogram investigation later:

```text
opt_customers.city
opt_customers.status
opt_orders.city
opt_orders.status
```

---
