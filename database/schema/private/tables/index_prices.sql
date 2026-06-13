/********************************************************************
Market Index Price (Level) Time-Series at One-Minute Granularity

Stores open-high-low-close index levels for market indices, one row per
index per timeframe per bar, keyed by the market-index master. Volume is
nullable because many indices have no native traded volume.

NOTE: Plain heap in MVP v1; native range partitioning, TimescaleDB
conversion, and performance indexes are deferred to Phase II. The
natural UNIQUE key is an integrity constraint defining the bar grain,
not a performance index.
********************************************************************/

CREATE TABLE IF NOT EXISTS private.index_prices_tx (
    effective_time
        TIMESTAMPTZ NOT NULL,

    market_index_id
        INTEGER NOT NULL
        CONSTRAINT fk_ip_market_index
            REFERENCES common.market_index_mw(market_index_id)
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

    index_data_source_id
        CHAR(5) NOT NULL
        CONSTRAINT fk_ip_data_source
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    CONSTRAINT uq_index_prices
        UNIQUE (market_index_id, timeframe, effective_time),

    -- ? high is the bar maximum, low the minimum, levels non-negative
    CONSTRAINT ck_index_prices_ohlc CHECK (
        low_price <= open_price
        AND low_price <= close_price
        AND high_price >= open_price
        AND high_price >= close_price
        AND high_price >= low_price
        AND low_price >= 0
    )
);
