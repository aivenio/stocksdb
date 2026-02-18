/********************************************************************
Subscription Table Schema from MacroDB Geography Code Publication

The following subscription tables are fetched from `macrodb` which
provides geography information. Please refer to the original
repository (https://github.com/aivenio/macrodb) for more information.

All the foreign key constraints are removed and only select query is
allowed in the subscription table to maintain single source of truth.
********************************************************************/


CREATE TABLE IF NOT EXISTS common.country_mw (
    country_code
        CHAR(3)
        CONSTRAINT pk_country_code PRIMARY KEY,

    country_name
        VARCHAR(64) NOT NULL
        CONSTRAINT uq_country_name UNIQUE,

    continent_code
        CHAR(2) NOT NULL,

    region_code
        CHAR(3) NOT NULL,

    subregion_code
        CHAR(3) NOT NULL,

    iso2_code
        CHAR(2) NOT NULL
        CONSTRAINT uq_country_iso2 UNIQUE,

    numeric_code
        CHAR(3) NOT NULL
        CONSTRAINT uq_country_numeric_code UNIQUE,

    top_level_domain
        CHAR(3)
        CONSTRAINT uq_country_top_level_domain UNIQUE,

    wikidata_id
        VARCHAR(8)
        CONSTRAINT uq_country_wikidata_id UNIQUE,

    geoname_id
        VARCHAR(8)
        CONSTRAINT uq_country_geoname_id UNIQUE,

    country_flag_uri
        VARCHAR(256)
        CONSTRAINT uq_country_flag_uri UNIQUE
);


CREATE TABLE IF NOT EXISTS common.state_mw (
    state_uuid
        CHAR(5)
        CONSTRAINT pk_state_uuid PRIMARY KEY,

    state_code
        VARCHAR(5),

    state_name
        VARCHAR(64) NOT NULL,

    country_code
        CHAR(3) NOT NULL,

    state_type
        CHAR(3),

    state_latitude
        NUMERIC(9, 6),

    state_longitude
        NUMERIC(9, 6),

    wikidata_id
        VARCHAR(8)
        CONSTRAINT uq_state_wikidata_id UNIQUE,

    geoname_id
        VARCHAR(8)
        CONSTRAINT uq_state_geoname_id UNIQUE,

    CONSTRAINT uq_state_name UNIQUE (country_code, state_name),
    CONSTRAINT uq_state_code UNIQUE (country_code, state_code)
);


CREATE TABLE IF NOT EXISTS common.city_mw (
    city_code
        CHAR(5)
        CONSTRAINT pk_city_code PRIMARY KEY,

    city_name
        VARCHAR(64) NOT NULL,

    country_code
        CHAR(3) NOT NULL,

    state_uuid
        CHAR(5) NOT NULL,

    city_type
        VARCHAR(32),

    city_latitude
        NUMERIC(9, 6),

    city_longitude
        NUMERIC(9, 6),

    wikidata_id
        VARCHAR(8)
        CONSTRAINT uq_city_wikidata_id UNIQUE,

    geoname_id
        VARCHAR(8)
        CONSTRAINT uq_city_geoname_id UNIQUE,

    CONSTRAINT uq_city_name UNIQUE (country_code, state_uuid, city_name)
);

REVOKE INSERT, UPDATE, DELETE ON common.country_mw FROM PUBLIC;
REVOKE INSERT, UPDATE, DELETE ON common.state_mw FROM PUBLIC;
REVOKE INSERT, UPDATE, DELETE ON common.city_mw FROM PUBLIC;

/********************************************************************
Subscription Statement & Slot from the MacroDB Publication Server
********************************************************************/

CREATE SUBSCRIPTION macrodb_geography_reference
    CONNECTION '
        host=***
        port=***
        user=***
        dbname=***
        password=***
    '
    PUBLICATION macrodb_geography_table
    WITH (
        slot_name = macrodb_geography_reference_stocksdb
    );
