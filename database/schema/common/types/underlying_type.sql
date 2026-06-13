/********************************************************************
A ENUM of Underlying Asset Types for the Derivative Contract Master

Every derivative contract references an underlying asset, which within
the scope of this database is either a market index or an individual
equity (security). This ENUM acts as the discriminator on
common.derivative_contract_mw that decides which underlying foreign
key - the index reference or the ISIN reference - must be populated.

NOTE: Commodity and currency underlyings are strictly out of scope for
this project and are deliberately omitted. ENUM values are append-only
in PostgreSQL, so further values may be added later only if the
project scope is formally expanded.
********************************************************************/

CREATE TYPE common.underlying_type AS ENUM (
    'INDEX'
    , 'EQUITY'
);
