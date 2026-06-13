/********************************************************************
Full Option Chain Snapshot Time-Series

Captures a point-in-time snapshot of a derivative (primarily option)
contract as published in the option chain, one row per contract per
fetch. Each row records the timestamp the values were fetched, the
quote (last traded price, bid/ask and their sizes), open interest and
its change, traded volume, implied volatility, the option greeks, and
the underlying spot price observed at snapshot time.

The strike-by-strike chain for a given underlying and expiry at an
instant is the set of rows that share that underlying and expiry through
the derivative-contract master, filtered to the snapshot timestamp.

NOTE: Plain heap in MVP v1; native range partitioning, TimescaleDB
conversion, and performance indexes are deferred to Phase II. The greeks
(delta, gamma, theta, vega, rho) intentionally carry no sign checks -
theta, rho, and put delta are legitimately negative. The natural UNIQUE
key is an integrity constraint defining the snapshot grain.
********************************************************************/

CREATE TABLE IF NOT EXISTS private.option_chain_tx (
    snapshot_time
        TIMESTAMPTZ NOT NULL,

    derivative_contract_id
        BIGINT NOT NULL
        CONSTRAINT fk_oc_contract
            REFERENCES common.derivative_contract_mw(derivative_contract_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    last_traded_price
        NUMERIC(21, 5),

    bid_price
        NUMERIC(21, 5),

    ask_price
        NUMERIC(21, 5),

    bid_quantity
        BIGINT,

    ask_quantity
        BIGINT,

    open_interest
        BIGINT,

    change_in_open_interest
        BIGINT,

    volume
        BIGINT,

    implied_volatility
        NUMERIC(12, 6),

    delta
        NUMERIC(12, 6),

    gamma
        NUMERIC(12, 6),

    theta
        NUMERIC(12, 6),

    vega
        NUMERIC(12, 6),

    rho
        NUMERIC(12, 6),

    underlying_spot_price
        NUMERIC(21, 5),

    chain_data_source_id
        CHAR(5) NOT NULL
        CONSTRAINT fk_oc_data_source
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    CONSTRAINT uq_option_chain
        UNIQUE (derivative_contract_id, snapshot_time)
);
