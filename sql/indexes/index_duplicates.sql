

-- based on query from http://wiki.postgresql.org/wiki/Index_Maintenance
CREATE VIEW adm.index_duplicates AS
    WITH index_duplicate AS (
        SELECT
            first_value(index_pg_class.oid) OVER (index_identity) duplicate_id,
            table_pg_namespace.nspname as schema_name,
            table_pg_class.relname as table_name,
            ARRAY(
               SELECT pg_get_indexdef(pg_index.indexrelid, k + 1, true)
               FROM generate_subscripts(pg_index.indkey, 1) as k
               ORDER BY k
            ) as indexed_columns,
            pg_index.indexrelid::regclass AS index_name,
            count(*) OVER (index_identity) AS duplicate_count,
            sum(pg_relation_size(pg_index.indexrelid)) OVER (index_identity) AS total_index_size,
            pg_relation_size(pg_index.indexrelid) AS index_size,
            pg_am.amname as index_type
        FROM
            pg_index
            LEFT JOIN pg_class as index_pg_class ON index_pg_class.oid = pg_index.indexrelid
            LEFT JOIN pg_am ON index_pg_class.relam = pg_am.oid
            LEFT JOIN pg_class as table_pg_class ON table_pg_class.oid = pg_index.indrelid
            LEFT JOIN pg_namespace table_pg_namespace ON table_pg_namespace.oid = table_pg_class.relnamespace
        WINDOW
            index_identity AS (
                PARTITION BY pg_index.indrelid::text ||E'\n'|| pg_index.indclass::text ||E'\n'||
                             pg_index.indkey::text ||E'\n'|| coalesce(pg_index.indexprs::text,'')||
                             E'\n' || coalesce(pg_index.indpred::text,'')
            )
    )
    SELECT
        *,
        pg_size_pretty(total_index_size) as total_index_size_pretty,
        pg_size_pretty(index_size) as index_size_pretty
    FROM
        index_duplicate
    WHERE
        duplicate_count > 1
    ORDER BY
        duplicate_id
;
COMMENT ON VIEW adm.index_duplicates IS 'List all indexes similar to each other, you should keep an eye on those indexes';




-- https://wiki.postgresql.org/wiki/Index_Maintenance

/*
Index size/usage statistics

Table & index sizes along which indexes are being scanned and how many tuples are fetched. See Disk Usage for another view that includes both table and index sizes.

Performance Snippets

Index statistics
Works with PostgreSQL >=8.1
Written in SQL
Depends on Nothing
*/
--TODO: compare with adm.index_duplicates_alt

CREATE VIEW adm.index_duplicates_alt AS

SELECT pg_size_pretty(SUM(pg_relation_size(idx))::BIGINT) AS SIZE,
       (array_agg(idx))[1] AS idx1, (array_agg(idx))[2] AS idx2,
       (array_agg(idx))[3] AS idx3, (array_agg(idx))[4] AS idx4
FROM (
    SELECT indexrelid::regclass AS idx, (indrelid::text ||E'\n'|| indclass::text ||E'\n'|| indkey::text ||E'\n'||
                                         COALESCE(indexprs::text,'')||E'\n' || COALESCE(indpred::text,'')) AS KEY
    FROM pg_index) sub
GROUP BY KEY HAVING COUNT(*)>1
ORDER BY SUM(pg_relation_size(idx)) DESC;




