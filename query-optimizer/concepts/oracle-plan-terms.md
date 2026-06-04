# Oracle Plan Terms Cheat Sheet

## TABLE ACCESS FULL

Oracle reads the table blocks directly. Not always bad.

Good when:
large percentage of table is needed
small table
index path would do too many rowid lookups

## INDEX RANGE SCAN

Oracle scans a range in an index.

Often good when:
predicate is selective
leading column of index is usable
range/equality condition matches index

## TABLE ACCESS BY INDEX ROWID

After finding rowids in index, Oracle visits table rows. Can be expensive if many rowids.

## NESTED LOOPS

Good when outer input is small and inner lookup is indexed. Bad if outer input is huge unexpectedly.

## HASH JOIN

Often good for larger joins. Needs memory; can spill if huge.

## E-Rows

Estimated rows. Oracle prediction.

## A-Rows

Actual rows. What really happened during execution.

## Cost

Oracle internal comparison number. Not milliseconds.

## Buffers

Logical reads. High buffers often means more DB work.

## A-Time

Actual elapsed time shown by plan step.


## The optimizer plan is not random.

It depends on:

* Data size
* Data distribution
* Selectivity
* Indexes
* Statistics
* Histograms
* Correlation between columns

The main question in every lab should be: Did Oracle estimate the number of rows correctly?

Because:
Wrong Estimated Rows
-> Wrong Cost
-> Wrong Plan
-> Slow Query
