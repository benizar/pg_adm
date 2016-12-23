

Search user-created functions
Works with PostgreSQL 8.4
Written in PL/pgSQL
Depends on Nothing
From: https://wiki.postgresql.org/wiki/Search_public_functions
original code (and any errors) by bricklen 

Search all functions in your PostgreSQL db for any matching terms.

The input will be used as the regular expresson in the regexp_matches() function.

Eg. to find 7 - 10 consecutive digits in any function:

select function_name,matching_terms from search_public_functions('[0-9]{7,10}',true);

string example at the bottom of page 

```sql
-- load into db as superuser
CREATE OR REPLACE FUNCTION search_public_functions(p_search_strings TEXT, p_case_insensitive BOOLEAN, OUT function_name TEXT, OUT matching_terms TEXT) RETURNS SETOF RECORD AS
$body$
DECLARE
        x                       RECORD;
        qry                     TEXT;
        v_match                 BOOLEAN := 'false';
        v_matches               TEXT;
        v_search_strings        TEXT := p_search_strings;
        v_case_insensitive      BOOLEAN := p_case_insensitive;
        v_funcdef               TEXT;
BEGIN
        /* v_search_strings is a list, pipe-separated, exactly what we want to search against.
           NOTE: works on postgresql v8.4
           example:
           select function_name,matching_terms from search_public_functions('crosstab|intersect|except|ctid',true);
        */
 
        IF (v_case_insensitive IS NOT FALSE) THEN
                v_case_insensitive := TRUE;
        END IF;
 
        qry :=  'SELECT n.nspname||''.''||p.proname||'' (''||pg_catalog.pg_get_function_arguments(p.oid)||'')''::TEXT as funcname,
                        (select pg_catalog.pg_get_functiondef(p.oid)) as funcdef,
                        p.oid as funcoid
                FROM pg_catalog.pg_proc p
                     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
                WHERE pg_catalog.pg_function_is_visible(p.oid)
                AND n.nspname <> ''pg_catalog''
                AND n.nspname <> ''information_schema''
                AND NOT p.proisagg
                ORDER BY 1';
 
        IF (p_case_insensitive IS TRUE) THEN
                v_search_strings := LOWER(v_search_strings);
        END IF;
 
        FOR x IN EXECUTE qry LOOP
                v_match := 'false';
                function_name := NULL;
                v_funcdef := NULL;
 
                SELECT INTO v_match x.funcdef ~* v_search_strings;
 
                IF ( v_match IS TRUE ) THEN
                        v_matches := NULL;
                        v_funcdef := x.funcdef;
                        IF (p_case_insensitive IS TRUE) THEN
                                v_funcdef := LOWER(v_funcdef);
                        END IF;
                        SELECT array_to_string(array_agg(val),',') INTO v_matches FROM (SELECT DISTINCT array_to_string(regexp_matches(v_funcdef, v_search_strings ,'g'),',') AS val) AS y2;
 
                        function_name := x.funcname;
                        matching_terms := v_matches;
                        RETURN NEXT;
                END IF;
        END LOOP;
END;
$body$ language plpgsql SECURITY DEFINER;
```

It can be called like so:

```sql
select function_name,matching_terms from search_public_functions('crosstab|intersect|except|ctid',true);
```

               function_name                           | matching_terms 
-------------------------------------------------------+----------------
 public.array_intersect (anyarray, anyarray)           | intersect
 public.cant_delete_error ()                           | except
 public.crosstab2 (text)                               | crosstab
 public.crosstab3 (text)                               | crosstab
 public.crosstab4 (text)                               | crosstab
 public.crosstab (text)                                | crosstab
 public.crosstab (text, integer)                       | crosstab
 public.crosstab (text, text)                          | crosstab
 public.find_bad_block (p_tablename text)              | ctid,except

