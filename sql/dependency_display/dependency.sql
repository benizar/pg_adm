CREATE OR REPLACE VIEW report.dependency AS
WITH RECURSIVE preference AS (
  SELECT 10 AS max_depth
    , 16384 AS min_oid -- user objects only
    , '^(londiste|pgq|pg_toast)'::text AS schema_exclusion
    , '^pg_(conversion|language|ts_(dict|template))'::text AS class_exclusion
    , '{"SCHEMA":"00", "TABLE":"01", "TABLE CONSTRAINT":"02", "DEFAULT VALUE":"03",
        "INDEX":"05", "SEQUENCE":"06", "TRIGGER":"07", "FUNCTION":"08",
        "VIEW":"10", "MATERIALIZED VIEW":"11", "FOREIGN TABLE":"12"}'::json AS type_sort_orders
)
, dependency_pair AS (
    SELECT objid
      , array_agg(objsubid ORDER BY objsubid) AS objsubids
      , UPPER(obj.TYPE) AS object_type
      , COALESCE(obj.schema, SUBSTRING(obj.IDENTITY, E'(\\w+?)\\.'), '') AS object_schema
      , obj.name AS object_name
      , obj.IDENTITY AS object_identity
      , refobjid
      , array_agg(refobjsubid ORDER BY refobjsubid) AS refobjsubids
      , UPPER(refobj.TYPE) AS refobj_type
      , COALESCE(CASE WHEN refobj.TYPE='schema' THEN refobj.IDENTITY
                                                ELSE refobj.schema END
          , SUBSTRING(refobj.IDENTITY, E'(\\w+?)\\.'), '') AS refobj_schema
      , refobj.name AS refobj_name
      , refobj.IDENTITY AS refobj_identity
      , CASE deptype
            WHEN 'n' THEN 'normal'
            WHEN 'a' THEN 'automatic'
            WHEN 'i' THEN 'internal'
            WHEN 'e' THEN 'extension'
            WHEN 'p' THEN 'pinned'
        END AS dependency_type
    FROM pg_depend dep
      , LATERAL pg_identify_object(classid, objid, 0) AS obj
      , LATERAL pg_identify_object(refclassid, refobjid, 0) AS refobj
      , preference
    WHERE deptype = ANY('{n,a}')
    AND objid >= preference.min_oid
    AND (refobjid >= preference.min_oid OR refobjid = 2200) -- need public schema as root node
    AND COALESCE(obj.schema, SUBSTRING(obj.IDENTITY, E'(\\w+?)\\.'), '') !~ preference.schema_exclusion
    AND COALESCE(CASE WHEN refobj.TYPE='schema' THEN refobj.IDENTITY
                                                ELSE refobj.schema END
          , SUBSTRING(refobj.IDENTITY, E'(\\w+?)\\.'), '') !~ preference.schema_exclusion
    GROUP BY objid, obj.TYPE, obj.schema, obj.name, obj.IDENTITY
      , refobjid, refobj.TYPE, refobj.schema, refobj.name, refobj.IDENTITY, deptype
)
, dependency_hierarchy AS (
    SELECT DISTINCT
        0 AS level,
        refobjid AS objid,
        refobj_type AS object_type,
        refobj_identity AS object_identity,
        --refobjsubids AS objsubids,
        NULL::text AS dependency_type,
        ARRAY[refobjid] AS dependency_chain,
        ARRAY[concat(preference.type_sort_orders->>refobj_type,refobj_type,':',refobj_identity)] AS dependency_sort_chain
    FROM dependency_pair root
    , preference
    WHERE NOT EXISTS
       (SELECT 'x' FROM dependency_pair branch WHERE branch.objid = root.refobjid)
    AND refobj_schema !~ preference.schema_exclusion
    UNION ALL
    SELECT
        level + 1 AS level,
        child.objid,
        child.object_type,
        child.object_identity,
        --child.objsubids,
        child.dependency_type,
        parent.dependency_chain || child.objid,
        parent.dependency_sort_chain || concat(preference.type_sort_orders->>child.object_type,child.object_type,':',child.object_identity)
    FROM dependency_pair child
    JOIN dependency_hierarchy parent ON (parent.objid = child.refobjid)
    , preference
    WHERE level < preference.max_depth
    AND child.object_schema !~ preference.schema_exclusion
    AND child.refobj_schema !~ preference.schema_exclusion
    AND NOT (child.objid = ANY(parent.dependency_chain)) -- prevent circular referencing
)
SELECT * FROM dependency_hierarchy
ORDER BY dependency_chain ;

