
# Functions

## Search user-created functions
Works with PostgreSQL 8.4
Written in PL/pgSQL
Depends on Nothing
From: 
original code (and any errors) by bricklen 

Search all functions in your PostgreSQL db for any matching terms.

The input will be used as the regular expresson in the regexp_matches() function.

Eg. to find 7 - 10 consecutive digits in any function:

```sql
select function_name, matching_terms 
from adm.search_public_functions('[0-9]{7,10}',true);
```

It can be called like so:

```sql
select function_name, matching_terms 
from adm.search_public_functions('crosstab|intersect|except|ctid',true);
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

