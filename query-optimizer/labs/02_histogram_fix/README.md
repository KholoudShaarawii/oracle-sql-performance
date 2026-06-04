--------------------------------------------------------------------------------
# Lab 02 — Histogram Fix

## Goal 

Histogram helps Oracle understand skewed data.
--------------------------------------------------------------------------------

## Statistics Before histogram:
-- Oracle estimated Cairo and Paris as 2500 rows because:
-- NUM_DISTINCT = 4
-- DENSITY = 0.25
-- HISTOGRAM = NONE


### Statistics After Histogram

Table name: OPT_CUSTOMERS
Column name: CITY
NUM_DISTINCT: 4
DENSITY: 0.00005
NUM_NULLS: 0
NUM_BUCKETS: 4
HISTOGRAM: FREQUENCY = 4 Buckets = 4 Distinct V
SAMPLE_SIZE: 10000

--------------------------------------------------------------------------------
Cairo

Histogram helps Oracle estimate rows more accurately.

Cairo was 7000 rows before the histogram.
Cairo is still 7000 rows after the histogram.

E-Rows changed from 2500 to 7000.

Before histogram:
E-Rows = 2500
A-Rows = 7000

After histogram:
E-Rows = 7000
A-Rows = 7000

The histogram improved the optimizer's estimates by making the estimated rows much closer to the actual rows.
Before the histogram, the estimated row count was less accurate due to skewed data distribution.

Oracle chooses the execution plan before the query runs.

So Oracle uses Estimated Rows to calculate cost and choose the plan.
If E-Rows are close to A-Rows, Oracle has a better chance of choosing the correct execution plan.
If E-Rows are very different from A-Rows, Oracle may calculate the wrong cost and choose a bad plan.

After creating the histogram, Oracle understood the real data distribution better, so its decision was based on a number closer to the actual result.

--------------------------------------------------------------------------------
Paris

The actual number of Paris rows did not change.

Paris actual rows before histogram = 1000
Paris actual rows after histogram  = 1000

The histogram changed Oracle's estimate and plan choice.

Before histogram:
E-Rows = 2500
A-Rows = 1000
Plan = TABLE ACCESS FULL
Index used? No

Oracle overestimated Paris because it did not have a histogram.
It assumed all city values were evenly distributed.

After histogram:
E-Rows = 1000
A-Rows = 1000
Plan = INDEX RANGE SCAN + TABLE ACCESS BY INDEX ROWID BATCHED
Index used? Yes

Oracle estimated Paris correctly after the histogram.
Because the estimate became lower and more accurate, Oracle chose to use the CITY index.