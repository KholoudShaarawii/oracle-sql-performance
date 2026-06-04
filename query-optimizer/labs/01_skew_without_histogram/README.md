-- Lab 01: Full Table Scan vs Index, ndv_skew_no_histogram
-- Goal:
This lab shows how Oracle estimates rows when a column has skewed data but no histogram.
 
The city column has an index.

--------------------------------------------------------------------------------

-- Case A: Common value
-- Cairo is 7,000 out of 10,000 customers.

-- Case B: Less common value
-- Paris is 1,000 out of 10,000 customers.

--------------------------------------------------------------------------------
Statistics 

NUM_DISTINCT: 4 values of cities 
DENSITY: 0.25,  10000 rows / 4 distinct cities = 2500 rows per city
NUM_NULLS: 0
NUM_BUCKETS: 1
HISTOGRAM: NONE
SAMPLE_SIZE: 10000

>>Oracle applied the same statistics to all city values because it assumed that all cities were evenly distributed.
--------------------------------------------------------------------------------
