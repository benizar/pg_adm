

-- Procedure to report depedency tree using regexp search pattern (relation-only)
CREATE OR REPLACE FUNCTION adm.dependency_tree(search_pattern text)
  RETURNS TABLE(dependency_tree text)
  SECURITY DEFINER LANGUAGE SQL
  AS $function$
WITH target AS (
  SELECT objid, dependency_chain
  FROM adm.dependency
  WHERE object_identity ~ search_pattern
)
, list AS (
  SELECT
    format('%*s%s %s', -4*level
          , CASE WHEN object_identity ~ search_pattern THEN '*' END
          , object_type, object_identity
    ) AS dependency_tree
  , dependency_sort_chain
  FROM target
  JOIN adm.dependency report
    ON report.objid = ANY(target.dependency_chain) -- root-bound chain
    OR target.objid = ANY(report.dependency_chain) -- leaf-bound chain
  WHERE LENGTH(search_pattern) > 0
  -- Do NOT waste search time on blank/null search_pattern.
  UNION
  -- Query the entire dependencies instead.
  SELECT
    format('%*s%s %s', 4*level, '', object_type, object_identity) AS depedency_tree
  , dependency_sort_chain
  FROM adm.dependency
  WHERE LENGTH(COALESCE(search_pattern,'')) = 0
)
SELECT dependency_tree FROM list
ORDER BY dependency_sort_chain;
$function$ ;


-- Procedure to report depedency tree by specific relation name(s) (in text array)
CREATE OR REPLACE FUNCTION adm.dependency_tree(object_names text[])
  RETURNS TABLE(dependency_tree text)
  SECURITY DEFINER LANGUAGE SQL
  AS $function$
WITH target AS (
  SELECT objid, dependency_chain
  FROM adm.dependency
  JOIN unnest(object_names) AS target(objname) ON objid = objname::regclass
)
, list AS (
  SELECT DISTINCT
    format('%*s%s %s', -4*level
          , CASE WHEN object_identity = ANY(object_names) THEN '*' END
          , object_type, object_identity
    ) AS dependency_tree
  , dependency_sort_chain
  FROM target
  JOIN adm.dependency report
    ON report.objid = ANY(target.dependency_chain) -- root-bound chain
    OR target.objid = ANY(report.dependency_chain) -- leaf-bound chain
)
SELECT dependency_tree FROM list
ORDER BY dependency_sort_chain;
$function$ ;


-- Procedure to report depedency tree by oid
CREATE OR REPLACE FUNCTION adm.dependency_tree(object_ids oid[])
  RETURNS TABLE(dependency_tree text)
  SECURITY DEFINER LANGUAGE SQL
  AS $function$
WITH target AS (
  SELECT objid, dependency_chain
  FROM adm.dependency
  JOIN unnest(object_ids) AS target(objid) USING (objid)
)
, list AS (
  SELECT DISTINCT
    format('%*s%s %s', -4*level
          , CASE WHEN report.objid = ANY(object_ids) THEN '*' END
          , object_type, object_identity
    ) AS dependency_tree
  , dependency_sort_chain
  FROM target
  JOIN adm.dependency report
    ON report.objid = ANY(target.dependency_chain) -- root-bound chain
    OR target.objid = ANY(report.dependency_chain) -- leaf-bound chain
)
SELECT dependency_tree FROM list
ORDER BY dependency_sort_chain;
$function$ ;




