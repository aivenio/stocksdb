/********************************************************************
A ENUM of Option Types for the Derivative Contract Master Table

An option contract grants the right to buy or sell an underlying at a
fixed strike price on or before its expiry. The two exercise
directions are represented by this ENUM and are used by the column
common.derivative_contract_mw.option_type to distinguish call and put
contracts. The values are deliberately exchange-neutral (CALL / PUT)
rather than locale-specific (such as CE / PE) so that the contract
master stays valid across every global venue tracked by the database.

NOTE: This field is NULL for futures contracts, which carry no option
direction; the parent table enforces that rule via a check constraint.
********************************************************************/

CREATE TYPE common.option_type AS ENUM (
    'CALL'
    , 'PUT'
);
