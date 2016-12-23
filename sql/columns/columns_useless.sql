

/*
Finding useless columns

Works with PostgreSQL 8.2+
Written in SQL
Depends on Nothing

This query finds columns in the whole database that have no more than 1 distinct value in its table, using planner's estimates.

This is useful for finding redundant and unused columns.

See also: pg_statistic catalog documentation
*/

CREATE VIEW adm.columns_useless AS
SELECT nspname, relname, attname, typname,
    (stanullfrac*100)::INT AS null_percent,
    CASE WHEN stadistinct >= 0 THEN stadistinct ELSE abs(stadistinct)*reltuples END AS "distinct",
    CASE 1 WHEN stakind1 THEN stavalues1 WHEN stakind2 THEN stavalues2 END AS "values"
FROM pg_class c
JOIN pg_namespace ns ON (ns.oid=relnamespace)
JOIN pg_attribute ON (c.oid=attrelid)
JOIN pg_type t ON (t.oid=atttypid)
JOIN pg_statistic ON (c.oid=starelid AND staattnum=attnum)
WHERE nspname NOT LIKE E'pg\\_%' AND nspname != 'information_schema'
  AND relkind='r' AND NOT attisdropped AND attstattarget != 0
  AND reltuples >= 100              -- ignore tables with fewer than 100 rows
  AND stadistinct BETWEEN 0 AND 1   -- 0 to 1 distinct values
ORDER BY nspname, relname, attname;



