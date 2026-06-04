# Notes — Lab 08

## Default plan
FROM opt_customers c
JOIN opt_orders o
ON o.customer_id = c.customer_id
WHERE c.city = 'Cairo'
AND o.status = 'PAID';

- this is an adaptive plan
```text
Join method: HASH JOIN
Join order: OPT_CUSTOMERS -> OPT_ORDERS
E-Rows: 48000
A-Rows: 33600
A-Time: 00:00:00.03
Buffers: 746
Hash Join cost: 206 (1% CPU)

OPT_CUSTOMERS after filter:
E-Rows = 27000
A-Rows = 27000

OPT_ORDERS after filter:
E-Rows = 48000
A-Rows = 48000

Join result:
E-Rows = 48000
A-Rows = 33600

Oracle choose HASH JOIN in the default plan.

The optimizer estimated a large number of rows from both row sources. OPT_CUSTOMERS returned 27000 actual rows after filtering city = 'Cairo', and OPT_ORDERS returned 48000 actual rows after filtering status = 'PAID'.
Nested Loops would require many repeated lookups into the inner table, which could be more expensive for this amount of data.
The join operation estimated 48000 rows and actually returned 33600 rows. The estimate was not exact, but it was still large enough to make Hash Join reasonable.
In this plan, Oracle used full table scans on both tables and then joined the filtered rows using HASH JOIN.

Data flows from bottom/child operations up to the parent operation.
But join order is read from the children under the join operation, top to bottom.
```

## Forced nested loops

```text
A-Time: 00:00:00.19
Buffers: 43132

Forced Nested Loops used OPT_CUSTOMERS as the outer/driving row source and OPT_ORDERS as the inner row source.
Oracle first scanned OPT_CUSTOMERS and returned 27000 rows after applying the filter city = 'Cairo'. Then, for each customer row, it performed an index lookup on IX_OPT_ORDERS_CUSTOMER to find matching orders.
The index range scan started 27000 times, which shows that Nested Loops repeated the inner lookup many times. Then Oracle accessed OPT_ORDERS by rowid and returned 33600 final joined rows after applying status = 'PAID'.

This plan produced the same joined result as the default plan, 33600 rows, but it used many more buffers. The Forced Nested Loops plan used 43132 buffers, while the default Hash Join used only 746 buffers.
This shows that Nested Loops was less efficient for this case because the outer row source was large. 
Larger time and buffer compared to the default Hash join that Oracle chose
```
##  forced sort merge join

```text
Join method: MERGE JOIN
Join order: OPT_CUSTOMERS -> OPT_ORDERS
E-Rows: 48000
A-Rows: 33600
A-Time: 00:00:00.07
Buffers: 746
Sort Merge Join cost: 528 (2% CPU)

The Hash Join plan had a lower cost than the Sort Merge Join plan.
Both plans returned the same result, 33600 joined rows, but Hash Join was cheaper according to the optimizer cost.
The Sort Merge Join plan required extra SORT JOIN operations before performing the MERGE JOIN. These sorting steps add extra CPU and memory work, which increased the estimated cost.
Therefore, the optimizer chose Hash Join because it was the lower-cost plan for this large equality join.
```

## Lesson

```text
Nested Loops good when:
- Outer rows are few.
- Inner table has a useful index.
- Lookups are selective and not repeated too much.


Hash Join good when:
- Data sets are large.
- Full scan is cheaper than many index lookups.
- Enough memory exists for the Hash Table.

Sort Merge Join good when:
- Inputs are already sorted.
- Sorting cost is low.
- Hash Join memory cost is high.


Quick rule:
Nested Loops = few rows + index.
Hash Join = large data + enough memory.
Sort Merge Join = sorted data or cheap sorting.
```







