# Oracle Optimizer DBeaver Labs

ده مش Java optimizer program.

ده **GitHub learning lab** معمول علشان تدرسي Oracle optimizer و execution plans بإيدك من DBeaver:

- تجهزي schema و data جوه Oracle.
- تشغلي SQL بنفسك.
- تشوفي `EXPLAIN PLAN`.
- تشوفي actual execution stats بـ `DBMS_XPLAN.DISPLAY_CURSOR`.
- تقارني `E-Rows` مع `A-Rows`.
- تفهمي هل البطء من database ولا من application layer.

## الفكرة الأساسية

```text
Wrong Estimated Rows
→ Wrong Cost
→ Wrong Plan
→ Slow Query
```

إحنا مش بنبني Oracle.
إحنا بنبني **ملفات تدريب عملية** تساعدك تشوفي Oracle نفسه وهو بيخطط وينفذ.

## هنتعلم إيه؟

كل lab هيمشي على نفس الست أسئلة:

```text
1. Oracle optimizer شاف statistics إيه؟
2. حسب selectivity إزاي تقريبًا؟
3. توقع كام row؟  E-Rows
4. حسب cost كام؟
5. اختار plan إيه وليه؟
6. التنفيذ الحقيقي طلع إيه؟  A-Rows / A-Time / Buffers
```

بعدها نطلع verdict:

```text
Database is the bottleneck
```

أو:

```text
Database query looks healthy; investigate app/network/serialization/N+1/etc.
```

## تفتحيه فين؟

افتحي الفولدر ده في VS Code أو IntelliJ أو حتى GitHub web.
لكن التنفيذ العملي هيبقى من **DBeaver** على Oracle connection.

## ترتيب التشغيل

ابدئي من هنا:

```text
docs/02-dbeaver-how-to-run.md
labs/00_setup/README.md
labs/00_setup/01_create_schema.sql
labs/00_setup/02_seed_data.sql
labs/00_setup/03_gather_stats_no_histograms.sql
```

بعدها امشي على labs بالترتيب:

```text
labs/01_table_access_full_vs_index
labs/02_ndv_skew_no_histogram
labs/03_histogram_fix
labs/04_stale_statistics
labs/05_composite_index_order
labs/06_function_on_column
labs/07_correlated_columns_extended_stats
labs/08_nested_loop_vs_hash_join
labs/09_pagination_strategy
labs/10_endpoint_verdict
labs/11_plan_regression
labs/12_n_plus_one_oracle_not_optimizer
```

## ملاحظة مهمة

لو `DBMS_XPLAN.DISPLAY_CURSOR` طلع privilege error، ده مش معناه إنك غلط.
ده معناه إن اليوزر محتاج صلاحيات قراءة من views زي `V$SQL_PLAN` و `V$SQL_PLAN_STATISTICS_ALL`.
في local Oracle XE ممكن تشتغلي بيوزر عنده صلاحيات أعلى أو تطلبي grant من DBA.
شوفي:

```text
labs/00_setup/00_optional_create_user_local_lab.sql
```

ده للاستخدام المحلي فقط، مش production.
