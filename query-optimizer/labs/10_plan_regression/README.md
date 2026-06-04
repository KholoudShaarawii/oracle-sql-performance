# Lab 11 — Plan Regression

## Objective

 understand a real performance problem: A query was fast before. Later, the same query became slow.


One common reason is:

```text
The Execution Plan changed.
```

This is called:

```text
Plan Regression
```
If Plan Regression is suspected, the SQL_ID and PLAN_HASH_VALUE should be checked.
The SQL_ID helps confirm that the same SQL statement is being analyzed, 
while the PLAN_HASH_VALUE helps identify the Execution Plan used by Oracle.

If the SQL_ID is the same but the PLAN_HASH_VALUE is different, this means that Oracle used a different Execution Plan for the same query.
However, this alone does not prove that the new plan is slower. The performance impact must be confirmed by checking metrics such as A-Time, A-Rows, E-Rows, Buffers, Reads, TEMP usage, and the access methods used in the plan.

---

## The Problem :

Imagine we have an endpoint:

```text
GET /orders?city=Cairo&status=PAID
```

Behind this endpoint, the application runs a SQL query on `OPT_ORDERS`.
At first, the query was fast because Oracle used an efficient plan, such as: INDEX RANGE SCAN

This means Oracle used the index to reach the required rows quickly.

Later, the same endpoint became slower even though the SQL text did not change.

After checking the Execution Plan, 
It was found that Oracle changed the plan from using the index to doing a heavier operation, such as:

```text
TABLE ACCESS FULL
```

This means Oracle scanned much more data, so `A-Time` and `Buffers` increased.

---

## Why Can Oracle Change the Plan?

Oracle does not calculate a new plan for every execution.
Usually, Oracle reuses an existing plan from memory.
However, Oracle may calculate a new plan automatically when it needs a new hard parse.
This can happen because of changes such as:

```text
Statistics changed
Statistics became stale
Index was dropped or made invisible
Table size changed
Data distribution changed
Optimizer settings changed
Plan was removed from memory
SQL text changed slightly
Bind variable values changed
```

So, even if the developer did not change the SQL, Oracle may still choose a different plan.

---

## Important Idea

When the query is executed for the first time, Oracle performs a hard parse.
During the hard parse, Oracle reads the SQL text, checks that the syntax is valid, verifies that the referenced tables and columns exist, and confirms that the user has the required permissions.
After that, Oracle assigns a SQL_ID to identify the SQL statement,
and the Optimizer chooses the best Execution Plan based on the available statistics and access paths.
A PLAN_HASH_VALUE is then generated to represent the shape of the selected Execution Plan.

Finally, the parsed SQL and its Execution Plan are stored in memory inside the Shared Pool / Library Cache so Oracle can reuse them in future executions instead of repeating the full hard parse every time.


Oracle chooses the plan with the lowest estimated cost.
It does not know the real execution time before running the query.
The estimated cost is based on many things, including:

```text
E-Rows
Table statistics
Index statistics
Data distribution
Histograms
Selectivity
System statistics
```

`E-Rows` means Estimated Rows.

If Oracle estimates the number of rows incorrectly, it may choose a plan that looks cheap before execution but becomes slower in reality.

Example:

```text
E-Rows: 100
A-Rows: 50000
```

In this case, Oracle expected a small number of rows, but the real number was much larger.
Because of this wrong estimate, Oracle may choose a bad plan.

---

## What Is Compared

In this lab, the query is compared before and after the plan change.

### Before

```text
SQL_ID:
PLAN_HASH_VALUE:
Operation:
A-Time:
Buffers:
```

### After

```text
SQL_ID:
PLAN_HASH_VALUE:
Operation:
A-Time:
Buffers:
```

---

## Regression Lesson

If the `PLAN_HASH_VALUE` changed, this means the Execution Plan changed.
If the new plan has higher `A-Time` and higher `Buffers`, this means performance became worse.

Example conclusion:

```text
Plan changed from INDEX RANGE SCAN to TABLE ACCESS FULL.
Performance became worse because Oracle scanned more data.
This increased Buffers and A-Time.
```

---
