/********************************************************************
A ENUM of Security Types for Stock Market Data Table

A security can be of varied types, and maintaing the same is can be
done via an ENUM data type as the names are mostly self-explanatory.
Do check the inline comments for more information.

Since there are various data sources from which the data is fetched,
the same ENUM is used, and necessary changes are to be made during
the ETL pipeline if there is a name change.
********************************************************************/

CREATE TYPE common.security_issue_type AS ENUM (
    'ALTERNATIVE INVESTMENT FUND'
    , 'BOND'
    , 'CERTIFICATE OF DEPOSIT'
    , 'COMMERCIAL PAPER'
    , 'DEBENTURE'
    , 'DEEP DISCOUNT BOND'
    , 'EQUITY SHARES (EQ)'
    , 'FLOATING RATE BOND'
    , 'GOVERNMENT SECURITIES (G-SEC)'
    , 'INDIAN DEPOSITORY RECEIPT'
    , 'INFRASTRUCTURE INVESTMENT TRUST'
    , 'MUNICIPAL BOND'
    , 'MUTUAL FUND UNIT'
    , 'MUTUAL FUND UNIT (TRASE)'
    , 'PREFERENCE SHARES'
    , 'REAL ESTATE INVESTMENT TRUSTS (REIT)'
    , 'REGULAR RETURN BOND'
    , 'RIGHTS ENTITLEMENT'
    , 'SECURITISED INSTRUMENT'
    , 'SOVEREIGN GOLD BOND (SGB)'
    , 'TREASURY BILLS'
    , 'WARRANT'
);
