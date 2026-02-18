/********************************************************************
Subscription Table Schema from MacroDB Currency Code Publication

The following subscription tables are fetched from `macrodb` which
provides currency information. Please refer to the original
repository (https://github.com/aivenio/macrodb) for more information.

All the foreign key constraints are removed and only select query is
allowed in the subscription table to maintain single source of truth.
********************************************************************/

CREATE TABLE IF NOT EXISTS common.currency_mw (
    currency_code
        CHAR(3)
        CONSTRAINT pk_currency_code PRIMARY KEY,

    currency_name
        VARCHAR(64) NOT NULL
        CONSTRAINT uq_currency_name UNIQUE,

    currency_symbol
        VARCHAR(16)
        CONSTRAINT uq_currency_symbol UNIQUE,

    currency_type
        CHAR(1) NOT NULL,

    currency_subtype
        CHAR(1),

    n_decimals
        INTEGER NOT NULL DEFAULT 2,

    minor_unit_name
        VARCHAR(32),

    minor_unit_symbol
        VARCHAR(16),

    minor_unit_factor
        INTEGER,

    CONSTRAINT ck_minor_currency_null CHECK (
        NUM_NULLS(
            minor_unit_name, minor_unit_symbol, minor_unit_factor
        ) IN (0, 3)
    )
);


REVOKE INSERT, UPDATE, DELETE ON common.currency_mw FROM PUBLIC;

/********************************************************************
Subscription Statement & Slot from the MacroDB Publication Server
********************************************************************/

CREATE SUBSCRIPTION macrodb_currency_reference
    CONNECTION '
        host=***
        port=***
        user=***
        dbname=***
        password=***
    '
    PUBLICATION macrodb_currency_table
    WITH (
        slot_name = macrodb_currency_reference_stocksdb
    );
