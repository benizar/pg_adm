

--https://wiki.postgresql.org/wiki/Count_estimate
-- This one is used to parse the explain results to replace SELECT count(*)
CREATE OR REPLACE FUNCTION explain_count_estimate(query text) returns integer as $$
declare
	rec record;
	rows integer;
begin
	for rec in execute 'EXPLAIN ' || query loop
		rows := substring(rec."QUERY PLAN" from ' rows=([[:digit:]]+)');
		exit when rows is not null;
	end loop;
	return rows;
end;
$$ language plpgsql strict;

COMMENT ON FUNCTION explain_count_estimate(text) IS 'Returns an approximated SELECT count(*) for your query.';



