

/*
Index size/usage statistics
based on query from http://wiki.postgresql.org/wiki/Index_Maintenance
*/
CREATE VIEW adm.index_size_usage AS

SELECT
    t.tablename,
    indexname,
    c.reltuples AS num_rows,
    pg_size_pretty(pg_relation_size(quote_ident(t.tablename)::text)) AS table_size,
    pg_size_pretty(pg_relation_size(quote_ident(indexrelname)::text)) AS index_size,
    CASE WHEN indisunique THEN 'Y'
       ELSE 'N'
    END AS UNIQUE,
    idx_scan AS number_of_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_tables t
LEFT OUTER JOIN pg_class c ON t.tablename=c.relname
LEFT OUTER JOIN
    ( SELECT c.relname AS ctablename, ipg.relname AS indexname, x.indnatts AS number_of_columns, idx_scan, idx_tup_read, idx_tup_fetch, indexrelname, indisunique FROM pg_index x
           JOIN pg_class c ON c.oid = x.indrelid
           JOIN pg_class ipg ON ipg.oid = x.indexrelid
           JOIN pg_stat_all_indexes psai ON x.indexrelid = psai.indexrelid )
    AS foo
    ON t.tablename = foo.ctablename
WHERE t.schemaname='public'
ORDER BY 1,2;

COMMENT ON VIEW adm.index_size_usage IS 'List all indexes and index usage statistics, easily find unused indexes';


--Alternative
CREATE VIEW adm.index_size_usage_alt AS
    SELECT
        pg_tables.schemaname as schema_name,
        pg_tables.tablename as table_name,
        index_pg_class.relname as index_name,
        table_pg_class.reltuples AS num_rows,
        pg_size_pretty(pg_relation_size(pg_tables.schemaname||'.'||pg_tables.tablename)) AS table_size,
        pg_size_pretty(pg_relation_size(pg_tables.schemaname||'.'||index_pg_class.relname)) AS index_size,
        CASE WHEN pg_index.indisunique THEN 'Y' ELSE 'N' END AS unique,
        pg_stat_all_indexes.idx_scan AS number_of_scans,
        pg_stat_all_indexes.idx_tup_read AS tuples_read,
        pg_stat_all_indexes.idx_tup_fetch AS tuples_fetched
    FROM pg_tables
        LEFT JOIN pg_class table_pg_class ON pg_tables.tablename = table_pg_class.relname
        LEFT JOIN pg_index ON table_pg_class.oid = pg_index.indrelid
        LEFT JOIN pg_class as index_pg_class ON index_pg_class.oid = pg_index.indexrelid
        LEFT JOIN pg_stat_all_indexes ON pg_index.indexrelid = pg_stat_all_indexes.indexrelid
    WHERE
        pg_tables.schemaname not in ('pg_catalog', 'information_schema')
    ORDER BY
        schema_name,
        table_name;



