

-- The sizes of all DBs
CREATE VIEW adm.size_databases AS
   SELECT datname AS database, pg_database_size(datname) AS size,
   pg_size_pretty(pg_database_size(datname)) AS pretty_size
   FROM pg_database;

COMMENT ON VIEW adm.size_databases IS 'Displays all DB sizes.';


-- based on query from http://wiki.postgresql.org/wiki/Disk_Usage
CREATE VIEW adm.database_size_with_privileges AS
    SELECT
        d.datname AS db_name,
        pg_catalog.pg_get_userbyid(d.datdba) AS db_owner,
        CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
            THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
            ELSE 'No Access'
        END AS db_size
    FROM
        pg_catalog.pg_database d
    ORDER BY
        db_size DESC;

COMMENT ON VIEW adm.database_size_with_privileges IS 'List all databases and their disk usage.';



-- Show the size of the provided DB
CREATE FUNCTION adm.size_database (db text) RETURNS text AS $$
   SELECT pg_size_pretty(pg_database_size($1));
$$ language sql;

COMMENT ON FUNCTION adm.size_database (text) IS 'Show the size of the provided DB.';


-- Show the size of the current DB
CREATE OR REPLACE FUNCTION adm.size_current_database() RETURNS text AS $$
SELECT pg_size_pretty(pg_database_size(current_database()));
$$ LANGUAGE SQL;

COMMENT ON FUNCTION adm.size_current_database () IS 'Show the size of the current DB.';



--Finding the largest databases in your cluster
--Databases to which the user cannot connect are sorted as if they were infinite size.
CREATE VIEW adm.size_databases_largest AS

SELECT d.datname AS Name,  pg_catalog.pg_get_userbyid(d.datdba) AS Owner,
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
        ELSE 'No Access'
    END AS SIZE
FROM pg_catalog.pg_database d
    ORDER BY
    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
        THEN pg_catalog.pg_database_size(d.datname)
        ELSE NULL
    END DESC -- nulls first
    LIMIT 20;

COMMENT ON VIEW adm.size_databases_largest IS 'Displays the largest databases in your cluster.';



