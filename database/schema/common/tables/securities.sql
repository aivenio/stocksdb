/********************************************************************
Securities Master Table without a Geographical Restrictions

A security instrument is a financial instrument like equity shares,
bonds, debentures, etc. This table contains the master list of all
securities that are available globally. The table can be used as a
metadata and serves as a single source of truth for all securities.

The security master table is kept minimal such that it can be easily
published in the public domain with minimum overheads. Also, this
ensures that any number can be attached to the table using a star
schema with security master at the center.
********************************************************************/

CREATE TABLE IF NOT EXISTS common.securities_mw (
    security_isin_code
        CHAR(12)
        CONSTRAINT pk_security_isin_code PRIMARY KEY,

    security_description
        VARCHAR(255) NOT NULL,

    security_issuer_name
        VARCHAR(255),

    security_issuer_type
        common.security_issue_type,

    isin_data_source_id
        CHAR(5) NOT NULL
        CONSTRAINT fk_isin_data_source_id
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS common.securities_exchange_symbol_mw (
    ses_primary_id
        INTEGER GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_securities_exchange_symbol_id PRIMARY KEY,

    security_isin_code
        CHAR(12) NOT NULL
        CONSTRAINT fk_security_isin_code_symbol
            REFERENCES common.securities_mw(security_isin_code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    market_identifier_code
        CHAR(4) NOT NULL
        CONSTRAINT fk_ses_market_identifier_code
            REFERENCES common.stock_exchange_mw(market_identifier_code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    exchange_symbol
        VARCHAR(32) NOT NULL,

    exchange_symbol_name
        VARCHAR(255) NOT NULL,

    symbol_series_code
        VARCHAR(16),

    ses_data_source_id
        CHAR(5) NOT NULL
        CONSTRAINT fk_ses_data_source_id
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    created_on
        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_exchange_symbol UNIQUE(
        security_isin_code
        , market_identifier_code
        , exchange_symbol
        , exchange_symbol_name
    )
);

CREATE TABLE IF NOT EXISTS common.corporate_actions_mw (
    corporate_actions_id
        INTEGER GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_corporate_actions_id PRIMARY KEY,

    security_isin_code
        CHAR(12) NOT NULL
        CONSTRAINT fk_security_isin_code_corp_action
            REFERENCES common.securities_mw(security_isin_code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    corporate_actions_type
        common.corporate_actions_type NOT NULL,

    corporate_actions_date
        DATE NOT NULL,

    corporate_actions_description
        VARCHAR(255),

    actions_data_source
        VARCHAR(255) NOT NULL,

    created_on
        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_corporate_actions UNIQUE(
        security_isin_code
        , corporate_actions_type
        , corporate_actions_date
    )
);
