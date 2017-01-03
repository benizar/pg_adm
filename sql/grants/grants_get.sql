

--TODO: convert to sql functions and views

CREATE VIEW adm.object_list_databases AS
select datname from pg_database where datname <> 'template0';




/*CREATE VIEW adm.grants_summary AS
  select
    usename,
    relation,
    relation_type,
    array_to_string(array_agg(priv order by priv), ', ') permissions
   from ($1) data
  group by usename, relation, relation_type
  order by relation, usename;*/


CREATE VIEW adm.grants_databases AS
select
  usename,
  p.priv,
  d.datname relation,
  'database'::text relation_type
from
  pg_user u
  cross join pg_database d
  cross join (
    values('connect', 1),
    ('create', 2),
    ('temporary', 3)
  ) p(priv, privorder)
where has_database_privilege(u.usename, d.datname, p.priv);




CREATE VIEW adm.grants_roles AS
select
  source.rolname usename,
  'member'::text priv,
  target.rolname relation,
  'group'::text relation_type
from
  pg_roles source
  join pg_auth_members am on source.oid = am.member
  join pg_roles target on am.roleid = target.oid;




CREATE VIEW adm.grants_table AS
select
  usename,
  p.priv,
  n.nspname || '.' || c.relname relation,
  case c.relkind when 'r' then 'table' when 'v' then 'view' end relation_type
from
  pg_namespace n join (
    (values('select', 1),
           ('insert', 2),
           ('delete', 3),
           ('update', 4),
           ('truncate', 6),
           ('trigger', 7)
    ) p(priv, privorder)
      cross join pg_user u
      cross join pg_class c
  ) on n.oid = c.relnamespace
where
  (c.relkind IN ('r', 'v') and has_table_privilege(u.usesysid, c.oid, priv))
  and n.nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
order by n.nspname, c.relname, p.privorder;




--TODO: convert this to a view
/*
( psql -qtc "$(sql_grants_summary "$(sql_grants_database) union $(sql_grants_roles)")"
  for db in $(psql -qtc "$(sql_databases)"); do
    psql -qtc "$(sql_grants_summary "$(sql_grants_table)")" $db
  done) | column -s '|' -t
*/




