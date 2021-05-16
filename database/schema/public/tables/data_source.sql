/********************************************************************
Table(s) to Track the List of Data Sources, Associated Plans, etc.

An enduser are free to check and understand the data source used for
building the database and reference the same for further analysis. The
table is created to keep track of the data source, associated plans,
scheduler information, etc.
********************************************************************/

CREATE TABLE IF NOT EXISTS private.data_source_mw (
    data_source_id
        CHAR(5)
        CONSTRAINT pk_data_source_id PRIMARY KEY,

    data_source_name
        VARCHAR(64) NOT NULL
        CONSTRAINT uq_data_source_name UNIQUE,

    data_source_desc
        VARCHAR(256) NOT NULL,

    data_source_uri
        VARCHAR(128) NOT NULL
        CONSTRAINT uq_data_source_uri UNIQUE
);
