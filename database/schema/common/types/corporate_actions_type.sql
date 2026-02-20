/********************************************************************
A ENUM of Corporate Actions for Securities Exchange Symbol Table

A company listed in a stock exchange can have multiple actions like
listed, delisted, suspended, etc. The same ENUM is used to track the
different actions that may have happened to the company, ordering by
the date of action gives us the sequence of actions.
********************************************************************/

CREATE TYPE common.corporate_actions_type AS ENUM (
    -- ? Corporate Status
    'INCORPORATION'
    , 'MERGER ANNOUNCED'
    , 'MERGER COMPLETED'
    , 'ACQUISITION ANNOUNCED'
    , 'ACQUISITION COMPLETED'
    , 'SPIN-OFF'
    , 'DEMERGER'
    , 'RESTRUCTURING'
    , 'BANKRUPTCY FILED'
    , 'BANKRUPTCY EXIT'
    , 'LIQUIDATION'
    , 'NAME CHANGE'
    , 'TICKER CHANGE'
    , 'RELOCATION'

    -- ? Listing Status
    , 'IPO'
    , 'DIRECT LISTING'
    , 'LISTED'
    , 'DUAL LISTING'
    , 'DELISTED'
    , 'VOLUNTARY DELISTING'
    , 'FORCED DELISTING'
    , 'RELISTED'
    , 'SUSPENDED'
    , 'TRADING HALT'
    , 'TRADING RESUMED'
    , 'REVOKED'

    -- ? Share Capital Actions
    , 'BONUS SHARES'
    , 'RIGHTS ISSUE'
    , 'PREFERENTIAL ALLOTMENT'
    , 'PRIVATE PLACEMENT'
    , 'FOLLOW-ON OFFERING'
    , 'STOCK SPLIT'
    , 'REVERSE STOCK SPLIT'
    , 'SHARE BUYBACK'
    , 'SHARE CANCELLATION'
    , 'CAPITAL REDUCTION'
    , 'ESOP ISSUANCE'
    , 'WARRANT CONVERSION'
    , 'CONVERTIBLE BOND CONVERSION'

    -- ? Dividends Report
    , 'INTERIM DIVIDEND'
    , 'FINAL DIVIDEND'
    , 'SPECIAL DIVIDEND'
    , 'EX-DIVIDEND'
    , 'DIVIDEND REINVESTMENT'

    -- ? Financial Reporting
    , 'QUARTERLY RESULTS'
    , 'HALF YEAR RESULTS'
    , 'ANNUAL RESULTS'
    , 'EARNINGS GUIDANCE'
    , 'PROFIT WARNING'
    , 'RESTATED RESULTS'
    , 'ANNUAL REPORT RELEASE'

    -- ? Governance Actions
    , 'BOARD MEETING'
    , 'AGM'
    , 'EGM'
    , 'BOARD RESHUFFLE'
    , 'CEO CHANGE'
    , 'AUDITOR CHANGE'

    -- ? Debt & Credit
    , 'BOND ISSUANCE'
    , 'BOND REDEMPTION'
    , 'CREDIT RATING UPGRADE'
    , 'CREDIT RATING DOWNGRADE'
    , 'DEFAULT'

    -- ? Regulatory / Legal
    , 'REGULATORY INVESTIGATION'
    , 'LEGAL SETTLEMENT'
    , 'SANCTIONS'
    , 'FINE'

    -- ? Misc Actions
    , 'INDEX INCLUSION'
    , 'INDEX EXCLUSION'
    , 'MAJOR CONTRACT WIN'
    , 'MAJOR CONTRACT LOSS'
    , 'ASSET SALE'
    , 'ASSET PURCHASE'
);
