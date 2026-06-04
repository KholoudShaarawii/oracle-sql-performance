# Notes — Lab 09

## OFFSET

```text
Final A-Rows: 20
Rows processed by WINDOW SORT PUSHED RANK: 30020 
Rows read from table: 60000
A-Time: 00:00:00.07
Buffers: 373
Sort? Yes, WINDOW SORT PUSHED RANK
Access method: TABLE ACCESS FULL on OPT_ORDERS
Index used? No

Oracle processed much more than it returned.

The OFFSET query returned only 20 rows to the application, but Oracle did much more work internally. 
Oracle first read 60000 rows from OPT_ORDERS using TABLE ACCESS FULL. Because the query had ORDER BY created_at DESC, order_id DESC 
and Oracle did not use the ordering index, Oracle had to sort/rank the rows internally using WINDOW SORT PUSHED RANK.
The OFFSET value was 30000 and the FETCH value was 20, so Oracle needed to reach the first 30020 ordered rows.
After that, the VIEW operation skipped the first 30000 rows and returned only rows 30001 to 30020.
This shows that a paginated endpoint may return a small result set, but the database can still process many rows internally. 
The problem here is not only about having an index. The pagination strategy itself can be expensive for deep pages.
```

## Keyset

```text
CURSOR_ORDER_ID: 250 The order_id represents the last row reached by the cursor. The next page should start after this row.

Final A-Rows: 20
A-Time: 00:00:00.01 
Buffers: 134
Sort? Small SORT ORDER BY on 20 rows only
Main pagination operation: WINDOW NOSORT STOPKEY 
Access method: Oracle used the index first, then accessed the table by ROWID to fetch the remaining columns.
Index used? Yes, IX_OPT_ORDERS_CREATED_ID

OFFSET : Skip the first 30000 rows, then return 20. 
Keyset : Start after the last seen row, then return 20.
To make Keyset continue from the same place as OFFSET.
First, the cursor value of row number 30000 needs to be found.

The Keyset query also returned 20 rows, but Oracle did much less work internally. 
Oracle used the composite index: IX_OPT_ORDERS_CREATED_ID This index matches the ordering: created_at DESC, order_id DESC The plan showed WINDOW NOSORT STOPKEY, which means Oracle did not need a large sort operation for pagination it most likely avoided sorting completely because it used the index order unlike OFFSET.
Oracle used the index order and stopped after fetching the required 20 rows.
Oracle then accessed the table by ROWID only to fetch the remaining columns that were not stored in the index. 
This made the Keyset query faster and lighter than the OFFSET query.
```


