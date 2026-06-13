/********************************************************************
Security (Equity) Price Time-Series at One-Minute Granularity

Stores open-high-low-close prices and traded volume for exchange-listed
equities (securities), one row per security-symbol per timeframe per
bar. The grain is identified by the securities-exchange-symbol bridge
key, completing the normalization - the previously denormalized
<exchange>:<symbol>-<series> string has been removed in favour of the
ses_primary_id foreign key.

Indices and derivatives are stored in their own fact tables
(index_prices_tx, derivative_prices_tx, option_chain_tx).

NOTE: This table is a plain heap in MVP v1. Native range partitioning,
TimescaleDB conversion, and performance indexes are deferred to Phase
II. The natural UNIQUE key below is an integrity constraint (it defines
the bar grain and enables idempotent upserts), not a performance index.

-- ..refactor:: 2026-06-13 drop hypertable + denormalized symbol string
********************************************************************/

CREATE TABLE IF NOT EXISTS private.security_prices_tx (
    effective_time
        TIMESTAMPTZ NOT NULL,

    ses_primary_id
        INTEGER NOT NULL
        CONSTRAINT fk_sp_exchange_symbol
            REFERENCES common.securities_exchange_symbol_mw(ses_primary_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    timeframe
        private.timeframe_value NOT NULL,

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
        CONSTRAINT fk_sp_data_source
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    CONSTRAINT uq_security_prices
        UNIQUE (ses_primary_id, timeframe, effective_time),

    -- ? high is the bar maximum, low the minimum, prices non-negative
    CONSTRAINT ck_security_prices_ohlc CHECK (
        low_price <= open_price
        AND low_price <= close_price
        AND high_price >= open_price
        AND high_price >= close_price
        AND high_price >= low_price
        AND low_price >= 0
    )
);
