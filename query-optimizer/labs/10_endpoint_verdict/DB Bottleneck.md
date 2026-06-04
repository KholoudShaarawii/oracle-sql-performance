# How to Decide if the Database is the Bottleneck

## 1. Main Idea

When an endpoint is slow, the database is only one possible reason.

The correct question is:

```text
Is the SQL execution time responsible for most of the endpoint time?
```

Example:

```text
Endpoint total time = 3 seconds
SQL A-Time = 2.7 seconds
```

In this case, the database is likely the bottleneck.

But if:

```text
Endpoint total time = 3 seconds
SQL A-Time = 0.05 seconds
```

Then the SQL looks healthy, and the problem is probably outside the database.

Possible outside-DB causes:

```text
Application logic
Network latency
JSON serialization
External API calls
Middleware
N+1 queries
Frontend delay
```

---

# 2. The Correct Diagnosis Flow

When a slow endpoint is detected, the following flow should be used:

```text
1. Check the endpoint total time.
2. Check the SQL A-Time.
3. If SQL time is high, read the Execution Plan.
4. Find which operation is causing the high time.
5. Check Buffers, Reads, A-Rows, E-Rows, Sort, Temp, Join, and Access Method.
6. Decide if the database is the bottleneck.
7. Suggest the correct next action.
```

Important sentence:

```text
A-Time indicates that there may be a performance problem.
The Execution Plan explains why the problem happened.
```

---

# 3. Check A-Time First

`A-Time` means actual execution time.
It shows the real time spent during SQL execution.
If `A-Time` is very small, the SQL is probably healthy.

Example of healthy SQL:

```text
A-Time = 00:00:00.01
```
Example of suspicious SQL:

```text
A-Time = 00:00:05
A-Time = 00:00:20
A-Time = 00:01:00
```
If the SQL A-Time is high and close to the endpoint total time, the database is likely the bottleneck.

---

# 4. Find What Increased the A-Time

After high A-Time is observed, the analysis should not stop there.

The next question should be: What operation made the SQL slow?

Possible causes:

```text
Full Table Scan
Expensive Sort
Expensive Join
Too many rows processed
High Buffers
High Reads
Wrong E-Rows compared to A-Rows
Temp usage
Missing or unsuitable index
Bad pagination strategy
Old or inaccurate statistics
```

---

# 5. Check Buffers

`Buffers` means how many Oracle blocks were touched in memory.

High Buffers means Oracle did a lot of work.

Example:

```text
Buffers = 3   This is usually healthy.

```
Example:

```text
Buffers = 50000
Buffers = 200000   This is suspicious.

```

If a query should return a small number of rows but has very high Buffers, the database may be doing unnecessary work.

---

# 6. Check Reads

`Reads` means Oracle had to read blocks from disk. Disk reads are slower than memory reads. High Reads can make the SQL slower.

Example:

```text
Reads = 0   This is usually good.

```

Example:

```text
Reads = 50000   This is suspicious.

```
---

# 7. Compare E-Rows and A-Rows

`E-Rows` means Estimated Rows.

This is what the Optimizer expected before execution.

`A-Rows` means Actual Rows.

This is what really happened during execution.

Good estimate:

```text
E-Rows = 1
A-Rows = 1
```

Bad estimate:

```text
E-Rows = 10
A-Rows = 50000
```

If E-Rows is very different from A-Rows, the Optimizer may choose a bad plan.

This can lead to:

```text
Wrong join method
Wrong access method
Bad index choice
Expensive sort
High buffers
High runtime
```

---

# 8. Check Access Method

The access method shows how Oracle reached the data.

Common access methods:

```text
INDEX UNIQUE SCAN
INDEX RANGE SCAN
INDEX FULL SCAN
TABLE ACCESS BY INDEX ROWID
TABLE ACCESS FULL
```

Healthy example:

```text
INDEX UNIQUE SCAN
A-Rows = 1
Buffers = 3
A-Time = 00:00:00.01   This usually means the query is efficient.

```

Suspicious example:

```text
TABLE ACCESS FULL
A-Rows = 1000000
Buffers = 80000
A-Time = 00:00:15    This may mean Oracle is scanning too much data.
```

---

# 9. Check Sort Operations

Sort operations can be expensive, especially with many rows.

Common sort operations:

```text
SORT ORDER BY
SORT GROUP BY
WINDOW SORT
HASH UNIQUE
```

A sort becomes suspicious when it has:

```text
High A-Rows
High A-Time
High memory usage
Temp usage
```

Example:

```text
SORT ORDER BY
A-Rows = 500000
A-Time = 00:00:10
Temp = used
```

This means Oracle is sorting a large amount of data.

Possible fixes:

```text
Add pagination
Reduce returned rows
Create a suitable index for ORDER BY
Rewrite the query
Avoid unnecessary sorting
```

---

# 10. Check Temp Usage

`Temp` means Oracle used temporary space during execution.
TEMP is a temporary tablespace in Oracle, stored on disk as tempfiles. It is used when operations such as SORT, HASH JOIN, GROUP BY, or WINDOW SORT need more workspace than the available memory.
Temp usage usually appears with heavy operations like:

```text
Large Sort
Hash Join
Group By
Distinct
Window sort functions
```

If Temp is used with high A-Time, the database is likely doing expensive work.

Sort starts in memory
↓
Memory not enough
↓
Spill to TEMP on disk
↓
Read/write from disk
↓
Slower query

Example:

```text
SORT ORDER BY
Temp = 500MB
A-Time = 00:00:20    This is a strong sign that the database/query plan is suspicious.

```
---

# 11. Check Join Method

Common join methods:

```text
Nested Loops
Hash Join
Sort Merge Join
```

The join method is not bad by itself.
It becomes suspicious when it processes too many rows or repeats too many times.
Suspicious Nested Loops example:

```text
Nested Loops
Outer A-Rows = 50000
Inner Starts = 50000
Buffers = 300000
```
This means Oracle is repeatedly accessing the inner table many times.

Suspicious Hash Join example:

```text
Hash Join
A-Rows = 1000000
Buffers = 200000
Temp = used
```
This means Oracle is joining a large amount of data.

---

# 12. Check Rows Processed vs Final Rows

Sometimes the final result is small, but Oracle processes many rows internally.

Example:

```text
Final A-Rows = 20
Rows processed inside the plan = 60000
```

This means the application receives only 20 rows, but Oracle worked on thousands of rows.

This happened in deep OFFSET pagination.

Possible fix:

```text
Use Keyset Pagination instead of deep OFFSET
Add a better index
Reduce scanned rows
Rewrite the query
```

---

# 13. When should the verdict be: Database is the bottleneck?

```text
SQL A-Time is high
SQL A-Time explains most of the endpoint time
Buffers are high
Reads are high
A-Rows are very large
E-Rows are very different from A-Rows
Expensive Full Table Scan
Expensive Sort
Temp usage
Expensive Join
Too many rows processed before returning the result
```


# 14. Does Every Problem Need an Index?

No.

An index is only one possible solution.

A database problem may be solved by:

```text
Creating a suitable index
Creating a composite index
Updating statistics
Rewriting the query
Adding pagination
Changing OFFSET pagination to Keyset pagination
Reducing returned rows
Removing unnecessary ORDER BY
Fixing join conditions
Avoiding N+1 queries
Improving filtering conditions
```

---

# 15. Final Checklist

```text
1. Is the SQL A-Time high?
2. Is the SQL time close to the endpoint total time?
3. Which operation has the highest A-Time?
4. Are Buffers high?
5. Are Reads high?
6. Are E-Rows and A-Rows close or very different?
7. Is there a Full Table Scan on a large table?
8. Is there a big Sort operation?
9. Is Temp used?
10. Is the Join method expensive?
11. Is Oracle processing too many rows?
12. Is the final result small but internal work huge?
13. Is an index missing or unsuitable?
14. Is pagination needed?
15. Is the problem really inside Oracle or outside Oracle?
```

---

