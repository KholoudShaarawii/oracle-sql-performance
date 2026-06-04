-- Baseline stats: deliberately gather WITHOUT histograms.
-- This helps us see how NDV-only estimates can be wrong.

BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_CUSTOMERS',
    cascade    => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1'
  );

  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_ORDERS',
    cascade    => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1'
  );

  DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'OPT_ORDER_ITEMS',
    cascade    => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1'
  );
END;
/
