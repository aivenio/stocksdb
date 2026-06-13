/********************************************************************
Market Index Master without a Geographical Restriction

A market index (for example NIFTY 50 or the NASDAQ Composite) is a
statistical measure over a basket of securities and serves as the
underlying for index derivatives. Unlike a security, an index has no
ISIN, so it is tracked in its own master rather than being forced into
the ISIN key domain of the securities master. Each index is tied to the
exchange that lists or publishes it, through which its country and
trading currency are derived.

This master is intentionally minimal and provides one of the two
permitted derivative underlyings (the other being an equity).

NOTE: Commodity and currency indices are strictly out of scope for this
project.
********************************************************************/

CREATE TABLE IF NOT EXISTS common.market_index_mw (
    market_index_id
        INTEGER GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_market_index_id PRIMARY KEY,

    index_symbol
        VARCHAR(32) NOT NULL,

    index_name
        VARCHAR(128) NOT NULL,

    market_identifier_code
        CHAR(4) NOT NULL
        CONSTRAINT fk_market_index_exchange
            REFERENCES common.stock_exchange_mw(market_identifier_code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    index_provider
        VARCHAR(64),

    base_date
        DATE,

    base_value
        NUMERIC(21, 5),

    index_data_source_id
        CHAR(5) NOT NULL
        CONSTRAINT fk_market_index_data_source
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    created_on
        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_market_index_symbol
        UNIQUE (market_identifier_code, index_symbol)
);
