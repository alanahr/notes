-- postgreSQL recursive query to find all dependencies of a given object
WITH RECURSIVE recursive_dependencies AS (
    SELECT
        0 AS "dep_level",
        :dependency AS "dep_name",
        '' AS "dep_table",
        '' AS "dep_type",
        '' AS "ref_name",
        '' AS "ref_type"
    UNION ALL
    -- Recursive member: find dependencies of the dependencies
    SELECT
        dep_level + 1 AS "dep_level",
        depedencies.dep_name,
        depedencies.dep_table,
        depedencies.dep_type,
        depedencies.ref_name,
        depedencies.ref_type
    FROM (
        WITH classType AS (
            -- CTE to map pg_class OIDs to their types (TABLE, INDEX, SEQUENCE, etc.)
            SELECT
                oid,
                CASE relkind
                    WHEN 'r' THEN 'TABLE'::text
                    WHEN 'i' THEN 'INDEX'::text
                    WHEN 'S' THEN 'SEQUENCE'::text
                    WHEN 'v' THEN 'VIEW'::text
                    WHEN 'm' THEN 'MATERIALIZEDVIEW'::text
                    WHEN 'c' THEN 'TYPE'::text
                    WHEN 't' THEN 'TABLE'::text
                END AS "type"
            FROM pg_class
        )
        -- Subquery to extract dependencies from pg_depend, mapping classid and refclassid to human-readable names and types
        SELECT DISTINCT
            CASE classid
                WHEN 'pg_class'::regclass THEN objid::regclass::text
                WHEN 'pg_type'::regclass THEN objid::regtype::text
                WHEN 'pg_proc'::regclass THEN objid::regprocedure::text
                WHEN 'pg_constraint'::regclass THEN (SELECT conname FROM pg_constraint WHERE OID = objid)
                WHEN 'pg_attrdef'::regclass THEN 'default'
                WHEN 'pg_rewrite'::regclass THEN (SELECT ev_class::regclass::text FROM pg_rewrite WHERE OID = objid)
                WHEN 'pg_trigger'::regclass THEN (SELECT tgname FROM pg_trigger WHERE OID = objid)
                ELSE objid::text
            END AS "dep_name",
            CASE classid
                WHEN 'pg_constraint'::regclass THEN (SELECT conrelid::regclass::text FROM pg_constraint WHERE OID = objid)
                WHEN 'pg_attrdef'::regclass THEN (SELECT adrelid::regclass::text FROM pg_attrdef WHERE OID = objid)
                WHEN 'pg_trigger'::regclass THEN (SELECT tgrelid::regclass::text FROM pg_trigger WHERE OID = objid)
                ELSE ''
            END AS "dep_table",
            CASE classid
                WHEN 'pg_class'::regclass THEN (SELECT TYPE FROM classType WHERE OID = objid)
                WHEN 'pg_type'::regclass THEN 'TYPE'
                WHEN 'pg_proc'::regclass THEN 'FUNCTION'
                WHEN 'pg_constraint'::regclass THEN 'TABLE CONSTRAINT'
                WHEN 'pg_attrdef'::regclass THEN 'TABLE DEFAULT'
                WHEN 'pg_rewrite'::regclass THEN (SELECT TYPE FROM classType WHERE OID = (SELECT ev_class FROM pg_rewrite WHERE OID = objid))
                WHEN 'pg_trigger'::regclass THEN 'TRIGGER'
                ELSE objid::text
            END AS "dep_type",
            CASE refclassid
                WHEN 'pg_class'::regclass THEN refobjid::regclass::text
                WHEN 'pg_type'::regclass THEN refobjid::regtype::text
                WHEN 'pg_proc'::regclass THEN refobjid::regprocedure::text
                ELSE refobjid::text
            END AS "ref_name",
            CASE refclassid
                WHEN 'pg_class'::regclass THEN (SELECT TYPE FROM classType WHERE OID = refobjid)
                WHEN 'pg_type'::regclass THEN 'TYPE'
                WHEN 'pg_proc'::regclass THEN 'FUNCTION'
                ELSE refobjid::text
            END AS "ref_type",
            CASE deptype
                WHEN 'n' THEN 'normal'
                WHEN 'a' THEN 'automatic'
                WHEN 'i' THEN 'internal'
                WHEN 'e' THEN 'extension'
                WHEN 'p' THEN 'pinned'
            END AS "dependency type"
        FROM pg_catalog.pg_depend
         WHERE deptype = 'n' OR deptype = 'p' OR deptype = 'a' OR deptype = 'i'
        AND refclassid NOT IN (2615, 2612)
    ) depedencies
    JOIN recursive_dependencies ON (recursive_dependencies.dep_name = depedencies.ref_name)
    WHERE depedencies.ref_name NOT IN(depedencies.dep_name, depedencies.dep_table)
-- Final select to aggregate dependencies by name and level, and join with constraints information
SELECT * FROM ((SELECT MAX(dep_level) AS "dep_level",
            dep_name,
            MIN(dep_table)             AS "dep_table",
            MIN(dep_type)              AS "dep_type",
            string_agg(ref_name, ', ') AS "ref_names",
            string_agg(ref_type, ', ') AS "ref_types"
        FROM recursive_dependencies
        WHERE dep_level > 0
        GROUP BY dep_name
        ORDER BY dep_level desc, dep_name) wc
LEFT JOIN
-- Subquery to extract primary key and foreign key constraints, along with their source and target tables and columns
-- taken from https://stackoverflow.com/questions/1152260/how-to-list-table-foreign-keys
    (SELECT contype,
            o.conname AS constraint_name, 
            (SELECT nspname 
                FROM pg_namespace 
                WHERE oid = m.relnamespace) 
            AS source_schema,
            m.relname AS source_table,
            get_col_names(conrelid, conkey) col_names,
            get_col_types(conrelid, conkey) col_types,
            (SELECT nspname 
                FROM pg_namespace 
                WHERE oid = f.relnamespace
            ) AS target_schema,
            f.relname AS target_table,
            (SELECT a.attname
                FROM pg_attribute a
                WHERE a.attrelid = f.oid
                AND a.attnum = o.confkey[1]
                AND a.attisdropped = false) 
            AS target_column
        FROM pg_constraint o
                LEFT JOIN pg_class f ON f.oid = o.confrelid
                LEFT JOIN pg_class m ON m.oid = o.conrelid
        WHERE o.contype = 'p'
        OR o.contype = 'f' AND o.conrelid IN (SELECT oid FROM pg_class c WHERE c.relkind = 'r')
        ) rc
        ON wc.dep_name = rc.constraint_name);
