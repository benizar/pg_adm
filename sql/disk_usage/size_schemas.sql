

-- Total on-disk sizes of all schemas of current database;
CREATE VIEW adm.size_schemas AS
    select  schemaname
            ,sum(pg_total_relation_size(schemaname||'.'||tablename))::bigint as size_bytes
            ,pg_size_pretty(sum(pg_total_relation_size(schemaname||'.'||tablename))::bigint) as size
            from pg_tables
            where schemaname != 'information_schema'
            group by schemaname
            order by size_bytes desc;

COMMENT ON VIEW adm.size_schemas IS 'Total on-disk sizes of all schemas of current database';


/*
Schema Size
Based on the snippet by Emanuel Calvo https://wiki.postgresql.org/wiki/Schema_Size
One way to execute:
general_base=# select pg_size_pretty(pg_schema_size('public'));
-[ RECORD 1 ]--+--------
pg_size_pretty | 4782 MB

TODO: Always use pg_size_pretty
*/
CREATE OR REPLACE FUNCTION adm.size_schema(text) RETURNS TEXT AS $$
SELECT pg_size_pretty(SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::BIGINT) FROM pg_tables WHERE schemaname = $1
$$ LANGUAGE SQL;

COMMENT ON FUNCTION adm.size_schema(text) IS 'Returns the pretty size of the given schema.';



/*
Here is a modified version of the script that allows you to supply a case-sensitive regular expression to only consider a subset of table names within the schema: 
*/
CREATE OR REPLACE FUNCTION adm.size_schema_filter(text, text) RETURNS TEXT AS $$
SELECT pg_size_pretty(SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::BIGINT) FROM pg_tables WHERE schemaname = $1 AND tablename ~ $2
$$ LANGUAGE SQL;

COMMENT ON FUNCTION adm.size_schema_filter(text, text) IS 'Returns the pretty size of the given schema. Allows you to supply a case-sensitive regular expression to only consider a subset of table names within the schema.';



