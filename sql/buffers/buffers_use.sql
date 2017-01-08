

-- How many buffers does each table use. Taken from pg_buffercache documentation
CREATE VIEW buffers_use AS
SELECT
  c.relname,
  count(*) AS buffers
FROM pg_class c
  INNER JOIN pg_buffercache b
    ON b.relfilenode=c.relfilenode
  INNER JOIN pg_database d
    ON (b.reldatabase=d.oid AND d.datname=current_database())
GROUP BY c.relname
ORDER BY 2 DESC;

COMMENT ON VIEW buffers_use IS 'Displays how many buffers does each table use.';



