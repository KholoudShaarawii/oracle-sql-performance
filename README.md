# Oracle SQL Performance Labs

A practical collection of Oracle SQL performance labs focused on understanding how the Oracle Optimizer chooses execution plans and how to analyze SQL performance using real execution evidence.

This repository is designed as a hands-on learning project for Oracle SQL tuning, execution plan analysis, indexing, statistics, histograms, join methods, pagination, and plan regression.

---

## Project Goal

The goal of this project is not only to write SQL queries, but to understand how Oracle thinks before executing them.

Each lab focuses on a specific performance concept and answers questions such as:

* Why did Oracle choose a full table scan?
* Why did Oracle use or ignore an index?
* How do statistics affect execution plans?
* What happens when data is skewed?
* How do histograms improve cardinality estimates?
* Why does composite index column order matter?
* When are Nested Loops better than Hash Joins?
* Why can pagination become slow?
* How can the same SQL logic become slower after a plan change?

The main skill developed in this repository is reading execution plans and making a clear database verdict.

---

## Topics Covered

* Oracle Optimizer basics
* Execution Plan analysis
* Estimated rows vs actual rows
* Table access methods
* Index access methods
* Full table scan vs index range scan
* Basic statistics
* Histograms
* Data skew
* Column correlation
* Extended statistics
* Composite indexes
* Join methods
* Nested Loops
* Hash Join
* Pagination strategy
* Plan regression
* SQL performance diagnosis

---

## Skills Demonstrated

This project demonstrates practical skills in:

* Reading and analyzing Oracle execution plans
* Comparing estimated rows with actual rows
* Understanding optimizer decisions
* Diagnosing SQL performance issues using evidence
* Working with indexes, statistics, histograms, and join methods
* Explaining database behavior clearly through structured labs

---

## Repository Structure

```text
oracle-sql-performance/
├── concepts/
├── labs/
│   ├── 00_setup/
│   ├── 01_skew_without_histogram/
│   ├── 02_histogram_fix/
│   ├── 03_stale_statistics/
│   ├── 04_composite_index_order/
│   ├── 05_function_on_column/
│   ├── 06_correlated_columns_extended_stats/
│   ├── 07_nested_loop_vs_hash_join/
│   ├── 08_pagination_strategy/
│   ├── 09_endpoint_verdict/
│   └── 10_plan_regression/
├── README.md
└── .gitignore
```

---

## Labs Overview

| Lab | Topic                               | Main Idea                                                                        |
| --: | ----------------------------------- | -------------------------------------------------------------------------------- |
|  00 | Setup                               | Create tables, indexes, and test data for optimizer experiments                  |
|  01 | Skew Without Histogram              | Show how Oracle may estimate skewed values incorrectly without histograms        |
|  02 | Histogram Fix                       | Show how histograms help Oracle understand common and rare values                |
|  03 | Stale Statistics                    | Demonstrate how outdated statistics can lead to wrong estimates                  |
|  04 | Composite Index Order               | Explain why composite index column order matters                                 |
|  05 | Function on Column                  | Show how applying a function to an indexed column can prevent normal index usage |
|  06 | Correlated Columns / Extended Stats | Show how Oracle can misestimate related columns and how extended statistics help |
|  07 | Nested Loops vs Hash Join           | Compare join methods and when each one may be useful                             |
|  08 | Pagination Strategy                 | Compare OFFSET pagination with keyset pagination                                 |
|  09 | Endpoint Verdict                    | Decide whether the database is really the bottleneck                             |
|  10 | Plan Regression                     | Show how a changed execution plan can make the same logical SQL slower           |

---

## Data Model

The labs use three main tables:

```text
OPT_CUSTOMERS
OPT_ORDERS
OPT_ORDER_ITEMS
```

Relationship:

```text
customers -> orders -> order_items
```

The data is intentionally designed to include:

* Common values
* Rare values
* Skewed city values
* Skewed status values
* Related columns such as `country` and `city`
* Indexed columns
* Non-indexed columns
* Tables suitable for join experiments

This makes Oracle Optimizer decisions easier to observe and compare.

---

## Main Learning Pattern

Most labs follow this pattern:

1. Understand the data shape.
2. Run the SQL query.
3. Check the estimated plan.
4. Run the query with actual execution statistics.
5. Compare `E-Rows` with `A-Rows`.
6. Check access methods such as `TABLE ACCESS FULL` or `INDEX RANGE SCAN`.
7. Review `Buffers`, `Reads`, `A-Time`, and `Cost`.
8. Write a final database verdict.

---

## Final Takeaway

Oracle SQL performance analysis is not about guessing.

It is about reading the execution plan, understanding the data, comparing estimates with reality, and making a clear verdict.

The most important habit is:

```text
Always compare what Oracle expected with what actually happened.
```

That means comparing:

```text
E-Rows vs A-Rows
Estimated Cost vs Actual Work
Plan Choice vs Real Execution Evidence
```
