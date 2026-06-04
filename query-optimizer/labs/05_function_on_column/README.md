# Lab 06 — Function on Column

## الهدف

putting a function on a column in the WHERE, might the regular index not be used?

Example: 
```sql
WHERE LOWER(email) = 'customer100@example.com'
```

`email` email column has a regular index.
   `LOWER(email)`.

## Solution

try function-based index: based on the result of the function, not on the original column.

```sql
CREATE INDEX ix_opt_customers_lower_email
ON opt_customers(LOWER(email));
```
