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
