\echo 'Creating Common Reference Table(s) ...'

\i database/schema/common/reference/macrodb_currency.sql
\i database/schema/common/reference/macrodb_geography.sql

\echo 'Creating Common Data Type(s) ...'

\i database/schema/common/types/security_issue_type.sql
\i database/schema/common/types/corporate_actions_type.sql
\i database/schema/common/types/underlying_type.sql
\i database/schema/common/types/option_type.sql
\i database/schema/common/types/derivative_instrument_type.sql

\echo 'Creating Common Table(s) ...'

\i database/schema/common/tables/exchanges.sql
\i database/schema/common/tables/securities.sql
\i database/schema/common/tables/market_index.sql
\i database/schema/common/tables/derivatives.sql
