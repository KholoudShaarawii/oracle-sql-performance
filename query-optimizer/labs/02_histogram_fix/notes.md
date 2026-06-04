# Notes — Lab 03


## Before histogram

```text
E-Rows:2500
A-Rows:7000
```

## After histogram

```text
Histogram type:
E-Rows:7000
A-Rows:7000
```

## Case B: city = Cairo
### Estimated Plan After Histogram

```text
Operation: TABLE ACCESS FULL on OPT_CUSTOMERS
Index used? No
E-Rows: 7000
Cost: 32
Predicate: filter("CITY"='Cairo')



```
### Actual Plan After Histogram

```text
Operation: INDEX FAST FULL SCAN on IX_OPT_CUSTOMERS_CITY
Index used? Yes
Index name: IX_OPT_CUSTOMERS_CITY
E-Rows: 7000
A-Rows: 7000
Cost: 9
A-Time: 00:00:00.01
Buffers: 31 -> blocks accessed in memory
Reads: 25  -> blocks read from disk
Predicate: filter("CITY"='Cairo')

Oracle accessed 31 blocks total.
25 blocks were read from disk.
The remaining blocks were already in memory (buffer cache).
```

## Case B: city = Paris
### Estimated Plan After Histogram

```text
Operation: TABLE ACCESS BY INDEX ROWID BATCHED on OPT_CUSTOMERS
Index operation: INDEX RANGE SCAN on IX_OPT_CUSTOMERS_CITY
Index used? Yes
Index name: IX_OPT_CUSTOMERS_CITY
E-Rows: 1000
Cost: 14
Predicate: access("CITY"='Paris')
```

### Actual Plan After Histogram

```text
Operation: TABLE ACCESS BY INDEX ROWID BATCHED on OPT_CUSTOMERS
Index operation: INDEX RANGE SCAN on IX_OPT_CUSTOMERS_CITY
Index used? Yes
Index name: IX_OPT_CUSTOMERS_CITY
E-Rows: 1000
A-Rows: 1000
Cost: 14
A-Time: 00:00:00.01
Buffers: 12
Predicate: access("CITY"='Paris')

For Paris, the histogram changed both the estimate and the access method.

Before histogram:
E-Rows = 2500
Plan = TABLE ACCESS FULL

After histogram:
E-Rows = 1000
Plan = INDEX RANGE SCAN + TABLE ACCESS BY INDEX ROWID BATCHED

better statistics can help Oracle choose a better access path.
```
