\echo 'Creating Public Table(s) ...'

\i database/schema/public/tables/data_source.sql

\echo 'Populating with Initial Seed Data ...'

\i database/schema/public/seed/data_source.sql
