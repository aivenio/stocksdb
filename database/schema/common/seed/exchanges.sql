INSERT INTO common.stock_exchange_mw (
    market_identifier_code
    , operating_mic_code
    , legal_exchange_name
    , scock_exchange_acronym
    , stock_exchange_country_id
    , registered_city_code
    , trading_currency_code
    , operational_from
    , operational_to
    , data_source_id
) VALUES
    ('XBOM', 'XBOM', 'BSE Limited', 'BSE', 'IND', NULL, 'INR', '2011-09-26', NULL, 'MIC00'),
    ('XIMC', 'XIMC', 'Multi Commodity Exchange', 'MCX', 'IND', NULL, 'INR', '2006-04-24', NULL, 'MIC00'),
    ('XNSE', 'XNSE', 'NSE Limited', 'NSE', 'IND', NULL, 'INR', '2005-06-27', NULL, 'MIC00'),
    ('XCAL', 'XCAL', 'Calcutta Stock Exchange', NULL, 'IND', NULL, 'INR', '2005-06-27', NULL, 'MIC00');
