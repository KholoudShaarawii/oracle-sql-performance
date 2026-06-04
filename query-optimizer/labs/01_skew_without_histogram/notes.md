# Notes 

## Case A: city = Cairo

### Query

```sql
SELECT customer_id, full_name, city
FROM opt_customers
WHERE city = 'Cairo';
```

### Data Meaning

Cairo is a common value.
Cairo exists in 7,000 out of 10,000 customers.


### Estimated Plan

```text
Operation: TABLE ACCESS FULL on OPT_CUSTOMERS
Index used? No
E-Rows: 2500
Cost: 32
Predicate: filter("CITY"='Cairo')
```

### Actual Plan

```text
Operation: TABLE ACCESS FULL on OPT_CUSTOMERS
Index used? No
E-Rows: 2500
A-Rows: 7000
Cost: 32
A-Time: 00:00:00.01
Buffers: 142
Predicate: filter("CITY"='Cairo')
```


### Explanation
Oracle chose TABLE ACCESS FULL based on its estimate of 2,500 rows, not because it knew that Cairo was actually a common value.
Even though the CITY column has an index, Oracle did not use it.

Oracle estimated 2500 rows, and the actual rows shown were 7000.

Oracle does not know the real distribution of CITY values.
The optimizer estimate was not accurate.
Oracle assumed that the cities were distributed equally.

Oracle estimated 2500 rows for all cities,but the actual number of rows was 7000.
This happened because the CITY column has no histogram, so Oracle used density 0.25 and assumed an even distribution.

** Oracle used only basic column statistics, and it did not have a histogram to show the real distribution of the values.

NUM_DISTINCT = 4
HISTOGRAM = NONE

Density = 1 / NUM_DISTINCT
Density = 1 / 4 = 0.25

Estimated Rows = Total Table Rows × Selectivity
Estimated Rows = 10000 × 0.25 = 2500

---

## Case B: city = Paris

### Query

```sql
SELECT customer_id, full_name, city
FROM opt_customers
WHERE city = 'Paris';
```
### Data Meaning

```text
Paris is a less common value.
Paris exists in 1,000 out of 10,000 customers.
```

### Estimated Plan

```text
Operation: TABLE ACCESS FULL on OPT_CUSTOMERS
Index used? No
E-Rows: 2500
Cost: 32
Predicate: filter("CITY"='Paris')
```

### Actual Plan

```text
Operation: TABLE ACCESS FULL on OPT_CUSTOMERS
Index used? No
E-Rows: 2500
A-Rows: 1000
Cost: 32
A-Time: 00:00:00.01
Buffers: 119
Predicate: filter("CITY"='Paris')
```

### Explanation

Since there is no histogram, Oracle does not know the real distribution of each city value.
So Oracle assumes the values are evenly distributed.

100% / 4 values = 25% per value
That is why Oracle estimated both Cairo and Paris as 2500 rows.


```