

-- Taken from the awesome "PostgreSQL 9.0 High Performance" book by Greg Smith.
-- Buffer contents summary, with percentages
CREATE VIEW adm.buffers_breakdown AS
SELECT
  c.relname,
  pg_size_pretty(count(*) * 8192) as buffered,
  round(100.0 * count(*) /
    (SELECT setting FROM pg_settings WHERE name='shared_buffers')::integer,1)
    AS buffers_percent,
  round(100.0 * count(*) * 8192 / pg_relation_size(c.oid),1)
    AS percent_of_relation
FROM pg_class c
  INNER JOIN pg_buffercache b
    ON b.relfilenode = c.relfilenode
  INNER JOIN pg_database d
    ON (b.reldatabase = d.oid AND d.datname = current_database())
GROUP BY c.oid,c.relname
ORDER BY 3 DESC;

COMMENT ON VIEW adm.buffers_breakdown IS 'Displays a buffer contents summary, with percentages';



