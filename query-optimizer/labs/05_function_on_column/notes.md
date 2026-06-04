# Notes — Lab 05

## email = value

```text
Index used: IX_OPT_CUSTOMERS_EMAIL
Operation: INDEX RANGE SCAN
```

## LOWER(email) before function-based index

```text
Index used: None
Operation: TABLE ACCESS FULL
```

## LOWER(email) after function-based index

```text
Index used: IX_OPT_CUSTOMERS_LOWER_EMAIL
Operation: INDEX RANGE SCAN
```

## Diagnosis

```text
When the query filters by email directly, Oracle can use the normal index on the email column.

The normal index IX_OPT_CUSTOMERS_EMAIL works with this predicate because the WHERE condition uses the column directly:
email = 'customer100@example.com'

Before creating the function-based index, the query used LOWER(email). This means the predicate was applied to the result of a function, not directly to the original email column. Therefore, the normal index on email could not be used efficiently, and Oracle used TABLE ACCESS FULL.

After creating the function-based index on LOWER(email), Oracle could use IX_OPT_CUSTOMERS_LOWER_EMAIL because the index expression matched the WHERE condition:
LOWER(email) = 'customer100@example.com'

applying a function to an indexed column can prevent the normal index from being used efficiently.create a function-based index on the same expression.
```
