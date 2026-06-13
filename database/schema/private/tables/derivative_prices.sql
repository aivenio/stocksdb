/********************************************************************
Derivative (Option & Future) Price Time-Series at One-Minute Grain

Stores open-high-low-close prices, traded volume, and open interest for
listed option and future contracts, one row per contract per timeframe
per bar, keyed by the derivative-contract master. Open interest is
nullable as it is not reported for every contract or data source.

NOTE: Plain heap in MVP v1; native range partitioning, TimescaleDB
conversion, and performance indexes are deferred to Phase II. The
natural UNIQUE key is an integrity constraint defining the bar grain,
not a performance index.
********************************************************************/

CREATE TABLE IF NOT EXISTS private.derivative_prices_tx (
    effective_time
        TIMESTAMPTZ NOT NULL,

    derivative_contract_id
        BIGINT NOT NULL
        CONSTRAINT fk_dp_contract
            REFERENCES common.derivative_contract_mw(derivative_contract_id)
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

    open_interest
        BIGINT,

    ticker_data_source_id
        CHAR(5) NOT NULL
        CONSTRAINT fk_dp_data_source
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    CONSTRAINT uq_derivative_prices
        UNIQUE (derivative_contract_id, timeframe, effective_time),

    -- ? high is the bar maximum, low the minimum, prices non-negative
    CONSTRAINT ck_derivative_prices_ohlc CHECK (
        low_price <= open_price
        AND low_price <= close_price
        AND high_price >= open_price
        AND high_price >= close_price
        AND high_price >= low_price
        AND low_price >= 0
    ),

    CONSTRAINT ck_derivative_prices_volume CHECK (
        (volume IS NULL OR volume >= 0)
        AND (open_interest IS NULL OR open_interest >= 0)
    )
);

REVOKE INSERT, UPDATE, DELETE ON private.derivative_prices_tx FROM PUBLIC;
