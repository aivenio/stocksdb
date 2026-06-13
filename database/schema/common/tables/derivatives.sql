/********************************************************************
Derivative Contract Master for Listed Options and Futures

A derivative contract is a tradable instrument whose value derives from
an underlying asset. This master holds one row per uniquely tradable
option or future contract. Options and futures are intentionally folded
into a single master because they share the vast majority of their
attributes; the option-only fields (option_type and strike_price) are
nullable and governed by check constraints.

The underlying is polymorphic: it is either a market index or an equity
(security). Exactly one of the two underlying references is populated,
enforced by a check that also ties the populated reference to the
underlying_type discriminator. Country and trading currency are derived
through the listing exchange.

NOTE: Commodity and currency derivatives are strictly out of scope for
this project and cannot be represented by the in-scope ENUM values.

Recommended (Phase II) indexes - deferred, do not create yet:
  - btree on (underlying_index_id, expiry_date) and
    (underlying_isin, expiry_date) for option-chain lookups.
  - btree on (expiry_date) for expiry-driven scans.
********************************************************************/

CREATE TABLE IF NOT EXISTS common.derivative_contract_mw (
    derivative_contract_id
        BIGINT GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_derivative_contract_id PRIMARY KEY,

    underlying_type
        common.underlying_type NOT NULL,

    underlying_isin
        CHAR(12)
        CONSTRAINT fk_dc_underlying_isin
            REFERENCES common.securities_mw(security_isin_code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    underlying_index_id
        INTEGER
        CONSTRAINT fk_dc_underlying_index
            REFERENCES common.market_index_mw(market_index_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    instrument_type
        common.derivative_instrument_type NOT NULL,

    option_type
        common.option_type,

    strike_price
        NUMERIC(21, 5),

    expiry_date
        DATE NOT NULL,

    market_identifier_code
        CHAR(4) NOT NULL
        CONSTRAINT fk_dc_exchange
            REFERENCES common.stock_exchange_mw(market_identifier_code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    tradable_symbol
        VARCHAR(64) NOT NULL,

    lot_size
        INTEGER,

    tick_size
        NUMERIC(21, 5),

    contract_data_source_id
        CHAR(5) NOT NULL
        CONSTRAINT fk_dc_data_source
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    created_on
        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- ? exactly one underlying reference is set, and it matches the
    -- ? underlying_type discriminator (index xor equity)
    CONSTRAINT ck_dc_underlying_xor CHECK (
        NUM_NONNULLS(underlying_isin, underlying_index_id) = 1
        AND (
            (underlying_type = 'EQUITY' AND underlying_isin IS NOT NULL)
            OR (underlying_type = 'INDEX' AND underlying_index_id IS NOT NULL)
        )
    ),

    -- ? options carry an option_type and a positive strike; futures
    -- ? carry neither
    CONSTRAINT ck_dc_option_fields CHECK (
        (
            instrument_type IN ('INDEX OPTION', 'STOCK OPTION')
            AND option_type IS NOT NULL
            AND strike_price IS NOT NULL
            AND strike_price > 0
        )
        OR (
            instrument_type IN ('INDEX FUTURE', 'STOCK FUTURE')
            AND option_type IS NULL
            AND strike_price IS NULL
        )
    ),

    -- ? index instruments require an index underlying; stock
    -- ? instruments require an equity underlying
    CONSTRAINT ck_dc_inst_underlying CHECK (
        (
            instrument_type IN ('INDEX OPTION', 'INDEX FUTURE')
            AND underlying_type = 'INDEX'
        )
        OR (
            instrument_type IN ('STOCK OPTION', 'STOCK FUTURE')
            AND underlying_type = 'EQUITY'
        )
    ),

    CONSTRAINT ck_dc_lot_tick CHECK (
        (lot_size IS NULL OR lot_size > 0)
        AND (tick_size IS NULL OR tick_size > 0)
    ),

    -- ? futures leave option_type and strike_price NULL, so NULLS NOT
    -- ? DISTINCT is required to dedup them on the natural key
    CONSTRAINT uq_derivative_contract UNIQUE NULLS NOT DISTINCT (
        market_identifier_code
        , instrument_type
        , underlying_type
        , underlying_isin
        , underlying_index_id
        , expiry_date
        , option_type
        , strike_price
    )
);
