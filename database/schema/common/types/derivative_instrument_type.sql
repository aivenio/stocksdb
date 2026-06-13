/********************************************************************
A ENUM of Derivative Instrument Types for the Contract Master Table

A listed derivative is classified both by the kind of underlying it
tracks (a market index or an individual stock) and by its contract
form (an option or a future). This ENUM enumerates the four in-scope
combinations and is used by the column
common.derivative_contract_mw.instrument_type.

NOTE: Commodity and currency derivatives are strictly out of scope for
this project and are deliberately omitted. ENUM values are append-only
in PostgreSQL, so further values may be added later only if the
project scope is formally expanded.
********************************************************************/

CREATE TYPE common.derivative_instrument_type AS ENUM (
    'INDEX OPTION'
    , 'STOCK OPTION'
    , 'INDEX FUTURE'
    , 'STOCK FUTURE'
);
