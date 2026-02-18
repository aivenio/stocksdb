\echo 'Creating Common Table(s) ...'

\i database/schema/common/reference/macrodb_currency.sql
\i database/schema/common/reference/macrodb_geography.sql

\echo 'Creating Common Data Type(s) ...'

\i database/schema/common/types/security_issue_type.sql
