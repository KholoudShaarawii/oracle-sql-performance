# Notes — Lab 11

## Before

```text
SQL_ID: 1hdfdn4kbqx8m
PLAN_HASH_VALUE: 3877343833
Operation:
- INDEX RANGE SCAN on IX_LAB11_ORDERS_OID_CHAR
- TABLE ACCESS BY INDEX ROWID BATCHED on OPT_ORDERS

A-Rows: 1
A-Time: 00:00:00.01
Buffers: 3
Cost: 48
```

## After index invisible

```text
SQL_ID: 9uky6vh0gfjnw
PLAN_HASH_VALUE: 3522860551
Operation:
- TABLE ACCESS FULL on OPT_ORDERS

E-Rows: 1
A-Rows: 1
A-Time: 00:00:00.01
Buffers: 373
Cost: 103
Disk Reads: 0
```

## Regression 

```text
Plan changed from INDEX RANGE SCAN to TABLE ACCESS FULL.
Performance became worse because the index access path became unavailable.
Oracle scanned more data to return the same result.
This increased Buffers and changed the PLAN_HASH_VALUE.
```
