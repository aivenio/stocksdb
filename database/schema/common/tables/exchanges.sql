/********************************************************************
Table(s) to Track the List of Stock Exchanges for Securities
********************************************************************/

CREATE TABLE IF NOT EXISTS common.stock_exchange_mw (
    market_identifier_code
        CHAR(4)
        CONSTRAINT pk_market_identifier_code PRIMARY KEY,
    
    operating_mic_code
        CHAR(4) NOT NULL,

    legal_exchange_name
        VARCHAR(64) NOT NULL,

    scock_exchange_acronym
        VARCHAR(16),

    stock_exchange_country_id
        CHAR(3) NOT NULL
        CONSTRAINT fk_stock_exchange_country_id
            REFERENCES common.country_mw(country_code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    registered_city_code
        CHAR(5)
        CONSTRAINT fk_stock_exchange_registered_city_code
            REFERENCES common.city_mw(city_code)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    operational_from
        DATE NOT NULL,

    operational_to
        DATE,

    data_source_id
        CHAR(5) NOT NULL
        CONSTRAINT fk_exchange_data_source_id
            REFERENCES public.data_source_mw(data_source_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    CONSTRAINT uq_stock_exchange_name
        UNIQUE (stock_exchange_country_id, legal_exchange_name)
);
