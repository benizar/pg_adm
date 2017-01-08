

-- How many shared buffers are in the database.
-- Taken from the awesome "PostgreSQL 9.0 High Performance" book by Greg Smith.
CREATE VIEW buffers_count AS
SELECT
  setting AS shared_buffers,
  pg_size_pretty((SELECT setting FROM pg_settings WHERE name='block_size')::int8 * setting::int8) AS size
FROM pg_settings WHERE name='shared_buffers';

COMMENT ON VIEW buffers_count IS 'Displays how many shared buffers are in the database.';




