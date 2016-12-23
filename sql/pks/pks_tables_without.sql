

-- This view displays tables without primary keys. Useful for londiste replication.
CREATE OR REPLACE VIEW adm.pks_tables_without AS SELECT
    n.nspname AS "Schema",
    c.relname AS "Table Name",
    c.relhaspkey AS "Has PK"
    FROM
        pg_catalog.pg_class c
    JOIN
        pg_namespace n
    ON (c.relnamespace = n.oid
        AND n.nspname NOT IN ('information_schema', 'pg_catalog')
        AND c.relkind='r' ) where c.relhaspkey = 'f';



