

/*Finding the size of your biggest relations

Relations are objects in the database such as tables and indexes, and this query shows the size of all the individual parts. Tables which have both regular and TOAST pieces will be broken out into separate components; an example showing how you might include those into the main total is available in the documentation, and as of PostgreSQL 9.0 it's possible to include it automatically by using pg_table_size here instead of pg_relation_size:

Note that all of the queries below this point on this page show you the sizes for only those objects which are in the database you are currently connected to.
*/

CREATE VIEW size_relations_biggest AS

SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_relation_size(C.oid)) AS "size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
  ORDER BY pg_relation_size(C.oid) DESC
  LIMIT 20;

COMMENT ON VIEW size_relations_biggest IS 'Finding the size of your biggest relations.';

