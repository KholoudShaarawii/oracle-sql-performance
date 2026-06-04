# Lab 07 — Correlated Columns + Extended Statistics

## Goal

correlation is not PK/FK. means naturally correlated columns.
The columns have a natural relationship between them, and if Oracle does not know this relationship, it may estimate the number of rows incorrectly.
```text
customers table has 2 columns : country, city

Egypt  -> Cairo/Alexandria
UK     -> London
France -> Paris
```

This condition is impossible in the data:
```sql
country = 'UK' AND city = 'Cairo'
```

The problem is that without Extended Statistics, Oracle might treat country and city as if they were independent of each other.
estimate rows incorrectly because it treats columns as independent.

## Required

Drop the extended statistics if they already exist.
Gather normal statistics.
Run the query.
Create extended statistics on (country, city).
Run the query again.