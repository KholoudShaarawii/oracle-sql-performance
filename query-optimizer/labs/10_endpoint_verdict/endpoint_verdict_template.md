# Endpoint Verdict

## Endpoint

```text
Endpoint: GET /orders/12345      'get 1 order by Id' 
```

## Plan evidence

```text
Main operations:
- INDEX UNIQUE SCAN on PK_OPT_ORDERS
- TABLE ACCESS BY INDEX ROWID on OPT_ORDERS

E-Rows: 1
A-Rows: 1
A-Time: 00:00:00.01
Buffers: 3
Reads: Not shown
```

## Decision

```text
[x] Database is the bottleneck.
[ ] Database query looks healthy; investigate outside SQL.
```

## Why?

```text
The query used the primary key index PK_OPT_ORDERS with an INDEX UNIQUE SCAN.
Oracle estimated 1 row and actually returned 1 row, so the estimate was accurate.
The query completed with very low A-Time and only 3 buffers.
There is no large scan, no expensive sort, no join, and no temp usage.
Therefore, this SQL does not look like the endpoint bottleneck.
```

## Endpoint

```text
Endpoint: GET /orders?city=Cairo&status=PAID
```

## Plan evidence

```text
Main operations:
- TABLE ACCESS FULL on OPT_ORDERS
- TABLE ACCESS FULL on OPT_CUSTOMERS
- HASH JOIN
- SORT ORDER BY

E-Rows:
- OPT_ORDERS: 48000
- OPT_CUSTOMERS: 27000
- HASH JOIN: 48000
- SORT ORDER BY: 48000

A-Rows:
- OPT_ORDERS: 48000
- OPT_CUSTOMERS: 27000
- HASH JOIN: 33600
- SORT ORDER BY: 33600

A-Time:
- Final query time: 00:00:00.13
- HASH JOIN: 00:00:00.09
- SORT ORDER BY: 00:00:00.13

Buffers: 746
Reads: 371
```

## Decision

```text
[] Database is the bottleneck.
[x] Database query looks healthy; investigate outside SQL.
```

## Why?

```text
The query is much heavier than Scenario A.
Oracle performed full table scans on both OPT_ORDERS and OPT_CUSTOMERS.
The query processed 48000 rows from OPT_ORDERS and 27000 rows from OPT_CUSTOMERS, then joined the data using a HASH JOIN.

After the join, Oracle sorted 33600 rows using SORT ORDER BY.
The query used 746 buffers and 371 reads, which shows more database work compared to the healthy primary key lookup in Scenario A.
Therefore, this SQL is suspicious and the database/query plan should be investigated as a possible endpoint bottleneck.
```
