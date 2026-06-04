# Notes — Lab 04
Oracle does not make its decision based on the real data directly every time.
Oracle makes its decision based on the stored optimizer statistics.

# Before insert
Stats num_rows: 10000
Actual rows:    10000

# After insert, before gather stats
Stats num_rows: 10000
Actual rows:    30000

E-Rows: 7500
A-Rows: 27000

# After gather stats
Stats num_rows: 30000

E-Rows: 27000
A-Rows: 27000

# Data Change
Before inserting new Cairo customers:

City         Rows
Cairo        7000
Paris        1000
London       1000
Alexandria   1000
Total        10000

After inserting 20,000 new Cairo customers:

City         Rows
Cairo        27000
Paris        1000
London       1000
Alexandria   1000
Total        30000

The data changed, but the optimizer statistics were not refreshed yet.

# Before refresh stats
STATS_NUM_ROWS = 10000
NUM_DISTINCT   = 4
DENSITY        = 0.25
HISTOGRAM      = NONE
Estimated Cairo Rows = 2500
Actual Cairo Rows = 27000

# After refresh stats
STATS_NUM_ROWS = 30000
NUM_DISTINCT   = 4
DENSITY        = 0.000016666...
HISTOGRAM      = FREQUENCY
Estimated Rows = 27000
Plan = TABLE ACCESS FULL
Cost = 103
Estimated Cairo Rows = 27000
Actual Cairo Rows = 27000