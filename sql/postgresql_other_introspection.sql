-- get table sizes
SELECT ic.*, a.description FROM
(SELECT
  pg_class_objoid.relname AS tab,
  pg_attribute.attname AS col,
  pg_description.description
FROM
  pg_description
LEFT JOIN
  pg_class AS pg_class_objoid   ON pg_description.objoid   = pg_class_objoid.oid
LEFT JOIN
  pg_class AS pg_class_classoid ON pg_description.classoid = pg_class_classoid.oid
LEFT JOIN
  pg_attribute ON pg_attribute.attnum   = pg_description.objsubid AND pg_attribute.attrelid = pg_description.objoid
WHERE
  pg_class_classoid.relname = 'pg_class')a
FULL JOIN  information_schema.columns ic on a.col = ic.column_name
WHERE ic.table_schema = 'public'
ORDER BY ic.table_name ASC
