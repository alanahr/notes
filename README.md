# Notes + Snippets
As of January 2026, still deciding whether or not it's worth it to migrate all my snippets and little scripts to here from another github account and other git repos (hosted  - my domain)

## Local Scripts (shell, etc.)

### Daily Git (Bitbucket) repo report - checks local repos for uncommitted changes, gets log of changes

### Daily report of Slack reminders in pretty format

### Daily, detailed Jira report
Checks user's assigned issues, watched issues, get's list with basic info, AND for linked issues, gets updates. 
todo: get user mentions

## Contents
## General Notes
## Jupyter Notebooks
## Snippets/Useful code/etc.
## JS

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
