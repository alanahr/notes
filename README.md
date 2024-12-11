# Notes repo
## Contents
## General Notes
## Jupyter Notebooks
## Snippets/Useful code/etc.
## JS
## Local Scripts (shell, etc.)
### Daily Git repo report
### Daily report of Slack reminders in pretty format
### Daily, detailed Jira report
## SQL
### introspection (PostgreSQL)
```sql
        create or replace function get_col_names(rel regclass, cols int2[])
        returns text language sql as $$
            select string_agg(attname, ', ' order by ordinality)
            from pg_attribute,
            unnest(cols) with ordinality
            where attrelid = rel
            and attnum = unnest
        $$;
        create or replace function get_col_types(rel regclass, cols int2[])
        returns text language sql as $$
            select string_agg(typname, ', ' order by ordinality)
            from pg_attribute a
            join pg_type t on t.oid = atttypid,
            unnest(cols) with ordinality
            where attrelid = rel
            and attnum = unnest
        $$;
```
## PHP
### Specifically for use with CTA API for getting train/bus times


... 
