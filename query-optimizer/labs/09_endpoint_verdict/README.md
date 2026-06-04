# Lab 10 — Endpoint DB Verdict

## Objective

The goal of this lab is to decide whether a slow backend endpoint is slow because of the database query or because of something outside the database.

learn how to write a clear database verdict based on actual execution plan evidence.

---

## Main Question

For a slow endpoint,the main question: Is the database the bottleneck? or Is the SQL healthy and the problem outside the database?

---

## Scenarios

### Scenario A — Healthy Query

run a selective query using `order_id`.

This query should be fast and should use efficient access.

If the SQL has low `A-Time`, low `Buffers`, and accurate `E-Rows` vs `A-Rows`, then the database query is healthy.

Verdict: Database query looks healthy; investigate outside SQL.


---

### Scenario B — Suspicious Query

run a larger query with: JOIN, Filters, ORDER BY

This query may require more database work.

check the execution plan for:
E-Rows vs A-Rows
A-Time
Buffers
Reads
Temp
Join method
Sort operations
Access method

If the plan shows high cost, high runtime, bad estimates, or expensive operations, then the database/query plan is suspicious.
Verdict: Database is the bottleneck.


---

