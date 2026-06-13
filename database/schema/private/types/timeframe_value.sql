/********************************************************************
A ENUM of Supported Timeframe Granularities for Price Time-Series

Price and candle facts are stored at a base granularity of one minute,
and this ENUM enumerates every timeframe the store recognizes. Higher
order timeframes are retained so that aggregated bars can be persisted
or, in a future phase, derived on the fly from the one-minute base via
SQL functions.

This type was relocated from the original private/prices.sql so that
all private fact tables can share a single timeframe domain.

-- ..refactor:: 2026-06-13 relocated from private/prices.sql; typo fix
********************************************************************/

CREATE TYPE private.timeframe_value AS ENUM (
    -- ? minute (m) level granularities
    '1m'
    , '3m'
    , '5m'
    , '15m'

    -- ? hour (h) level granularity
    , '1h'

    -- ? day (D) level granularity
    , '1D'

    -- ? month (M) level granularity
    , '1M'

    -- ? year (Y) level granularity
    , '1Y'
);
