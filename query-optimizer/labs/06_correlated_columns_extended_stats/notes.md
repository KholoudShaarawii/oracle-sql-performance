# Notes — Lab 07

## Actual

```text
country='UK' and city='Cairo' actual rows:
Actual Rows = 0

```

## Before extended stats

```text
E-Rows: 7500
A-Rows: 0
Plan: TABLE ACCESS FULL
```

## After extended stats

```text
E-Rows: 500
A-Rows: 0
Plan: INDEX RANGE SCAN using IX_OPT_CUSTOMERS_COUNTRY_CITY
```

## Explanation

```text
Correlation means that two columns are naturally related to each other.
country and city are correlated because each city belongs to a specific country. For example, Cairo belongs to Egypt, London belongs to the UK, and Paris belongs to France.
The condition country = 'UK' AND city = 'Cairo' is not possible in our data, so the actual rows were 0.

Before extended statistics, Oracle treated country and city as independent columns. Because of that, it estimated 7500 rows even though the actual result was 0.

After creating extended statistics on (country, city), Oracle had better information about the relationship between the two columns. The estimate improved from 7500 rows to 500 rows, and the plan changed from TABLE ACCESS FULL to INDEX RANGE SCAN.

Extended statistics helped because Oracle could estimate the combination of country and city more accurately instead of estimating each column separately. 
```
