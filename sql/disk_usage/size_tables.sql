

CREATE VIEW adm.size_tables AS
select
        table_schema as table_schema,
        table_name as table_name,
        pg_size_pretty(pg_total_relation_size(table_schema||'.'||table_name)) as total_size_pretty,
        pg_size_pretty(pg_relation_size(table_schema||'.'||table_name)) as table_size_pretty,
        pg_size_pretty(pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name)) as index_size_pretty,
        -- table size / index size
        case when pg_relation_size(table_schema||'.'||table_name) <> 0 then
                round(
                        (pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name))::numeric
                        / pg_relation_size(table_schema||'.'||table_name)::numeric
                , 3)
        else null
        end as index_over_table_ratio,
        -- index size / table size
        case when (pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name)) <> 0 then
                round(
                        pg_relation_size(table_schema||'.'||table_name)::numeric
                        / (pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name))::numeric
                        , 3)
        else null
        end as table_over_index_ratio,
        pg_total_relation_size(table_schema||'.'||table_name) as total_size,
        pg_relation_size(table_schema||'.'||table_name) as table_size,
        (pg_total_relation_size(table_schema||'.'||table_name) - pg_relation_size(table_schema||'.'||table_name)) as index_size
from
        information_schema.tables
where
        table_schema <> 'pg_catalog'
        and table_schema <> 'information_schema'
        and table_type <> 'VIEW'
order by
        index_size desc;

COMMENT ON VIEW adm.size_tables IS 'List all table sizes, index sizes and various size-related metrics';


-- View table and index sizes
-- TODO: compare with size_table
CREATE VIEW adm.size_tables_alt AS
SELECT n.nspname, c.relname, c.relkind AS type,
    pg_size_pretty(pg_table_size(c.oid::regclass)) AS size,
    pg_size_pretty(pg_indexes_size(c.oid::regclass)) AS idxsize,
    pg_size_pretty(pg_total_relation_size(c.oid::regclass)) AS total,

    pg_table_size(c.oid::regclass) AS size_raw,
    pg_indexes_size(c.oid::regclass) AS idxsize_raw,
    pg_total_relation_size(c.oid::regclass) AS total_raw,
    c.oid as rel_oid,
    n.oid as schema_oid,
    c.relkind as relkind
   FROM pg_class c
   LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name])) AND n.nspname !~ '^pg_toast'::text AND (c.relkind = ANY (ARRAY['r'::"char", 'i'::"char"]))
  ORDER BY pg_total_relation_size(c.oid::regclass) DESC;


-- Same as above, but with seq scan and idx scan info. Useful to extract seqscan info on large tables.
CREATE VIEW adm.size_tables_with_scans AS
SELECT
  tsize.*,
  tstat.seq_scan, tstat.seq_tup_read, tstat.idx_scan, tstat.idx_tup_fetch
FROM
  adm.size_tables_alt tsize,
  pg_stat_all_tables tstat
WHERE
tsize.rel_oid = tstat.relid
ORDER BY
tstat.seq_scan * tsize.size_raw DESC;

COMMENT ON VIEW adm.size_tables_with_scans IS 'View table sizes + seq scan and idx scan info. Useful to analyze how often seqscans are executed on large tables';



/*
General Table Size Information

Works with PostgreSQL >=9.0
Written in SQL
Depends on Nothing

This will report size information for all tables, in both raw bytes and "pretty" form.
*/
CREATE VIEW adm.size_tables_general AS

SELECT *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r'
  ) a
) a;



/*Finding the total size of your biggest tables

This version of the query uses pg_total_relation_size, which sums total disk space used by the table including indexes and toasted data rather than breaking out the individual pieces:
*/
CREATE VIEW adm.size_tables_biggest AS

SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;



