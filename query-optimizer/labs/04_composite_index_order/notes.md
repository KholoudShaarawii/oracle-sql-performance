# Notes — Lab 05
no histogram

## Query A: city + status
WHERE city = 'Cairo'
AND status = 'PAID'
```text
Index used: IX_OPT_ORDERS_CITY_STATUS
E-Rows: 5000
A-Rows: 33600
```

## Query B: city only
WHERE city = 'Cairo'
```text
Index used: no, TABLE ACCESS FULL
E-Rows: 15000
A-Rows: 42000

the condition city = 'Cairo' returned a large number of rows.
In this case, reading the whole table was cheaper than using the index.
```

## Query C: status only
WHERE status = 'CANCELLED'
```text
Index used: None / TABLE ACCESS FULL
E-Rows: 20000
A-Rows: 3000
```

## composite index

```text
The index IX_OPT_ORDERS_CITY_STATUS is ordered as (city, status), so it is useful for queries that filter by city only or by city and status together.

The index IX_OPT_ORDERS_STATUS_CITY is ordered as (status, city), so it is useful for queries that filter by status only or by status and city together.

In Query A, both city and status were used, so Oracle used the composite index IX_OPT_ORDERS_CITY_STATUS.

In Query B, only city was used. Logically, the index (city, status) could be useful, but Oracle chose TABLE ACCESS FULL because it estimated many rows and the actual result was also large.

In Query C, only status was used. Logically, the index (status, city) could be useful, but Oracle chose TABLE ACCESS FULL because it overestimated the number of rows.

This shows that the order of columns inside a composite index is important, but the optimizer still chooses the final plan based on estimated cost and estimated rows.
```
