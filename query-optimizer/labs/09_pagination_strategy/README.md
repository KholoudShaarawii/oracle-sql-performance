# Lab 09: Pagination Strategy

## Goal

This lab explains why a paginated endpoint can become slow because of the pagination strategy, not only because of a missing index.

Comparing two pagination strategies: OFFSET pagination and keyset pagination

The main idea is that returning only 20 rows does not always mean the database only processed 20 rows.

A query may return 20 rows to the application, but Oracle may still need to read, sort, or skip many rows internally before returning those 20 rows.
The endpoint may return a small amount of data 'Page Size', but Oracle may have processed many rows internally to produce that result.
Therefore, check the Execution Plan indicators such as Buffers, lower-level A-Rows, and operations like SORT or TABLE ACCESS FULL to understand whether Oracle did a lot of internal work.

---

## Table Used

This lab uses the table: OPT_ORDERS


Important columns:

```text
order_id
customer_id
created_at
status
order_total
```

The endpoint use case is showing orders ordered by the newest orders first.

---

## Ordering Used

Both OFFSET and Keyset pagination will use the same ordering:

```sql
ORDER BY created_at DESC, order_id DESC
```

This means:

```text
Show the newest orders first.
If two orders have the same created_at value, use order_id as a tie-breaker.
```

Using `order_id` as a tie-breaker makes the ordering stable and prevents duplicate or missing rows between pages.

---

## Index Used

create an index that matches the pagination ordering:

```sql
CREATE INDEX ix_opt_orders_created_id
ON opt_orders(created_at DESC, order_id DESC);
```

This index is important because it can help Oracle read rows in the required order.

However, the existence of this index does not automatically make OFFSET pagination efficient for deep pages.

The index can help with ordering, but OFFSET pagination may still need to skip many rows before returning the requested page.

---

## What We Will Compare

### 1. OFFSET Pagination

OFFSET pagination uses a page position.

Example:

```sql
ORDER BY created_at DESC, order_id DESC
OFFSET 30000 ROWS FETCH NEXT 20 ROWS ONLY;
```

This means:

```text
Sort the orders by created_at DESC and order_id DESC.
Skip the first 30000 rows.
Return the next 20 rows.
```

The final result is only 20 rows, but Oracle may need to process around 30020 rows to reach that page.

---

### 2. Keyset Pagination

Keyset pagination does not skip rows by page number.

Instead, it starts after the last row seen by the user.

The cursor is based on the last seen key:

```text
last_created_at
last_order_id
```

Example:

```sql
WHERE created_at < :last_created_at
   OR (
        created_at = :last_created_at
        AND order_id < :last_order_id
      )
ORDER BY created_at DESC, order_id DESC
FETCH NEXT 20 ROWS ONLY;
```

This means:

```text
Start after the last order the user already saw.
Return the next 20 rows.
```

Because the query starts from a known key, it can avoid skipping a large number of rows like OFFSET.

---

## Why Keyset Uses `<`

The ordering is descending:

```sql
ORDER BY created_at DESC, order_id DESC
```

So the next page contains older rows.

That is why the Keyset condition uses:

```sql
created_at < :last_created_at
```

and if the timestamp is equal:

```sql
order_id < :last_order_id
```

---

## Important Concept

OFFSET pagination says:

```text
Skip many rows, then return the next rows.
```

Keyset pagination says:

```text
Continue after the last row already seen.
```

This is the main difference between the two strategies.

---


## Endpoint Lesson

A slow paginated endpoint is not always caused by a missing index.

Sometimes the SQL has an index, but the pagination strategy is still expensive.

OFFSET pagination is simple, but it can become slow for deep pages because the database may need to skip many rows.

Keyset pagination is usually better for large datasets, infinite scroll, and "Load More" endpoints because it continues from the last seen item.
