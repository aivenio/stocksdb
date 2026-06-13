\echo 'Creating Private Data Type(s) ...'

\i database/schema/private/types/timeframe_value.sql

\echo 'Creating Private Table(s) ...'

\i database/schema/private/tables/security_prices.sql
\i database/schema/private/tables/index_prices.sql
\i database/schema/private/tables/derivative_prices.sql
\i database/schema/private/tables/option_chain.sql
