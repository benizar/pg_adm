

--https://wiki.postgresql.org/wiki/Normalize_whitespace
--This SQL function normalizes the space in a string, removing any leading or trailing space and reducing any internal whitespace to one space character per occurrence. It can be useful in creating domains.
CREATE OR REPLACE FUNCTION adm.normalize_space(TEXT)
RETURNS TEXT
AS $$
SELECT regexp_replace(TRIM($1), E'\\s+', ' ', 'g');
$$
IMMUTABLE LANGUAGE SQL;

COMMENT ON FUNCTION adm.normalize_space(TEXT) IS 'Normalizes the space in a string, removing any leading or trailing space and reducing any internal whitespace to one space character per occurrence.';



