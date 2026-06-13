/********************************************************************
Configure and Initialize a PostgreSQL Macroeconomics Database

The macroeconomics database (macrodb) is a structured data of various
factors like - currency, inflation etc. that can be used to analyze a
country's performance using different indicators. The database is
created independently thus providing seamless access to other forward
looking models keeping the core structure intact.

Copyright © [2021] Debmalya Pramanik (ZenithClown), AivenIO DBA
********************************************************************/

\echo 'Creating Schema(s) ...'

CREATE SCHEMA IF NOT EXISTS
    common AUTHORIZATION postgres;

CREATE SCHEMA IF NOT EXISTS
    private AUTHORIZATION postgres;

/********************************************************************
SQL Table Schema Execution Order - STRICT Follow

The public schema is bootstrapped first because every common master and
private fact table carries a foreign key to public.data_source_mw for
data lineage. The common reference and master data follows, and the
private time-series facts (which reference the common masters) load last.
********************************************************************/

\i database/schema/public/initialize.sql
\i database/schema/common/initialize.sql
\i database/schema/private/initialize.sql
