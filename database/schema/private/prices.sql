/********************************************************************
A TimeScaleDB Hyper Table to Store Price (OHLC) & Volume for a Symbol

To store the price (open, high, low, close) and volume data for a
symbol, we will be using TimeScaleDB HyperTable to index on the data
and create an chunk on security key, datetime (with timezone) with
an interval of 30 days. This should ensure that proper chunks of
optimal size is available - else will check the 25% optimization rule.

Installing Extension for TimeScaleDB:

.. code-block:: sql

    CREATE EXTENSION IF NOT EXISTS timescaledb;

Creating of HyperTables using TimeScaleDB:

.. code-block:: sql

    CREATE TABLE example_table (
        datetime TIMESTAMPTZ,
        ...
    );

    SELECT CREATE_HYPERTABLE(
        'example_table', 'datetime',
        CHUNK_TIME_INTERVAL => INTERVAL '7 days'
    );
********************************************************************/

CREATE TYPE private.timeframe_value AS ENUM (
    -- Mintue (m) Level Timeframe Values
    '1m', '3m', '5m', '15m',
    -- Hour (h) Level Timeframe Values
    '1h',
    -- Day (D) Level Timeframe Values
    '1D',
    -- Month (M) Level Timeframe Values
    '1M',
    -- Year (Y) Level Timeframe Values
    '1Y'
);

CREATE TABLE IF NOT EXISTS private.security_prices_tx (
    effective_time
        TIMESTAMPTZ NOT NULL,

    -- ! Symbol Format: <exchange>:<symbol>-<type>
    -- ? <exchange> : Short Acronym of the Exchange (NSE, BSE, ...)
    -- ? <type> : Security Symbol Series Code (EQ, ...)
    exchange_symbol_ext
        VARCHAR(72) NOT NULL,

    timeframe
        private.timeframe_value NOT NULL,

    ses_primary_id
        INTEGER
        CONSTRAINT fk_security_isin_code_symbol
            REFERENCES common.securities_exchange_symbol_mw(ses_primary_id),

    open_price
        NUMERIC(21, 5) NOT NULL,

    high_price
        NUMERIC(21, 5) NOT NULL,

    low_price
        NUMERIC(21, 5) NOT NULL,

    close_price
        NUMERIC(21, 5) NOT NULL,

    volume
        BIGINT,

    ticker_data_source_id
        CHAR(5) NOT NULL
        CONSTRAINT fk_ticker_data_source_id
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

CREATE INDEX ix_security_prices_tx_exchange_symbol_ext ON
    private.security_prices_tx (exchange_symbol_ext);

CREATE INDEX ix_security_prices_tx_timeframe ON
    private.security_prices_tx (timeframe);

SELECT create_hypertable(
    'private.security_prices_tx', 'effective_time'
    , chunk_time_interval => INTERVAL '30 days'
);
