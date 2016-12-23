
/*
Finding the operators usable with an index

Works with PostgreSQL >=8.1
Written in SQL
Depends on Nothing


When working with GiST or GIN indexes, it might not be immediately obvious which types of queries can use a particular index. Typically, an indexable query has a WHERE clause of the form "indexed_column indexable_operator constant". For regular btree and hash indexes, the indexable operators are just =, <, <=, >, >=. For a GiST or GIN index the indexable operators might be something else entirely. Here are queries that let you find out what operators can be used with any particular existing index.

This works with Postgres 8.3 and up:
*/

CREATE OR REPLACE FUNCTION adm.index_operators(text) 
returns table (index_col text, indexable_operator text) AS $$

SELECT
  pg_get_indexdef(ss.indexrelid, (ss.iopc).n, TRUE) AS index_col,
  amop.amopopr::regoperator AS indexable_operator
FROM pg_opclass opc, pg_amop amop,
  (SELECT indexrelid, information_schema._pg_expandarray(indclass) AS iopc
   FROM pg_index
   WHERE indexrelid = $1::regclass) ss
WHERE amop.amopfamily = opc.opcfamily AND opc.oid = (ss.iopc).x
ORDER BY (ss.iopc).n, indexable_operator;

$$ LANGUAGE SQL;


/*
(Replace INDEXNAME with the name of the index you're interested in.)

This works with Postgres 8.1 and 8.2:

SELECT
  pg_get_indexdef(ss.indexrelid, (ss.iopc).n, TRUE) AS index_col,
  amop.amopopr::regoperator AS indexable_operator
FROM pg_amop amop,
  (SELECT indexrelid, information_schema._pg_expandarray(indclass) AS iopc
   FROM pg_index
   WHERE indexrelid = 'INDEXNAME'::regclass) ss
WHERE amop.amopclaid = (ss.iopc).x
ORDER BY (ss.iopc).n, indexable_operator;
*/

/*
 Sample Output

Given

create table t1 (f1 polygon);
create index i1 on t1 using gist(f1);

the output for index i1 would look like

 index_col |  indexable_operator  
-----------+----------------------
 f1        | <<(polygon,polygon)
 f1        | &<(polygon,polygon)
 f1        | &>(polygon,polygon)
 f1        | >>(polygon,polygon)
 f1        | <@(polygon,polygon)
 f1        | @>(polygon,polygon)
 f1        | ~=(polygon,polygon)
 f1        | &&(polygon,polygon)
 f1        | <<|(polygon,polygon)
 f1        | &<|(polygon,polygon)
 f1        | |&>(polygon,polygon)
 f1        | |>>(polygon,polygon)
 f1        | @(polygon,polygon)
 f1        | ~(polygon,polygon)
(14 rows)

*/
