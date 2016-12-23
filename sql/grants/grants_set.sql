

-- Function that grants given permissions to given role on tables with given LIKE mask within given schema
-- Example:
--   SELECT grant_on_tables('role_developer','SELECT, INSERT, UPDATE, DELETE, RULE, REFERENCE, TRIGGER','%','public');
-- will grant all the maximum permissions on all tables within public schema to role_developer role
CREATE OR REPLACE FUNCTION adm.grant_on_tables(role_name text, permission text, mask text, schema_name text) RETURNS integer
    AS $$

DECLARE
	obj record;
	num integer;
BEGIN
	num := 0;
	FOR obj IN
			SELECT relname FROM  pg_class c JOIN pg_namespace ns ON (c.relnamespace = ns.oid)
			WHERE relkind in ('r','v','S')  AND nspname = schema_name  AND relname LIKE mask
			ORDER BY relname
	LOOP
		EXECUTE 'GRANT ' || permission || ' ON ' || obj.relname || ' TO ' || role_name;
		RAISE NOTICE '%', 'Done: GRANT ' || permission || ' ON ' || obj.relname || ' TO ' || role_name;
		num := num + 1;
	END LOOP;
	RETURN num;
END;
$$ language plpgsql;



