<div align = "center">

# Database Schema Roadmap - Price & Option Chain (MVP v1)

</div>

<div align = "justify">

This document is the design-of-record for the **MVP v1** normalization of the
`stocksdb` price and derivatives store. It captures *what* is being built, the
*scope boundaries*, the *data model*, the *build order*, and the work that is
**deliberately deferred** to later phases. Read it alongside
[schema.dbml](../../schema.dbml), which is the rendered entity-relationship
reference and is updated as the final step of the build.

## Context

`stocksdb` is a **global, multi-country, multi-currency** PostgreSQL store
(Aiven `v18.1`) that aggregates equity and index market data from many open and
closed data sources. Country, currency, and geography reference data are received
read-only via PostgreSQL logical-replication subscriptions from the `macrodb`
reference database. Every operational record carries a `data_source_id` so the
origin of each row is auditable.

Before this work the store held master data (exchanges, securities, the
ISIN-to-symbol bridge, corporate actions) plus a single TimescaleDB hypertable
for OHLC prices. MVP v1 replaces that with a **fully-normalized, production-ready**
model covering spot prices, a derivatives contract master, derivative candles,
and the full option chain - **without** the TimescaleDB extension for now.

---

## Scope

### In Scope (MVP v1)

  * Spot minute-level OHLC prices for **securities (equities)**.
  * Spot minute-level OHLC prices for **indices** (for example `NIFTY 50`, `NASDAQ`).
  * A normalized **derivative contract master** for **options and futures** whose
    underlying is either an **index** or an **equity**.
  * Minute-level OHLC + open-interest candles for derivative contracts.
  * The **full option chain** snapshot - strike-by-strike, with the timestamp the
    values were fetched, open interest, change in open interest, volume, implied
    volatility, the greeks, bid/ask, and the underlying spot at snapshot time.
  * `data_source_id` lineage and ENUM-typed constants on every new object.

### Strictly Out of Scope

  * **Commodities** are **not** part of this project.
  * **Currencies (as a tradable asset / currency derivatives)** are **not** part
    of this project.

> The `underlying_type` and `derivative_instrument_type` ENUMs intentionally omit
> commodity and currency values. ENUM values are append-only in PostgreSQL, so
> these can be added later at near-zero cost **if and only if** the project scope
> is formally expanded.

### Deferred (see Phase II and Future Scope)

  * Table partitioning, performance indexation, and the TimescaleDB extension.
  * Higher-order timeframe roll-ups computed on the fly via SQL functions.

---

## Schema Layout

| Schema | Purpose |
| :---: | --- |
| `public` | Operational bootstrap - the `data_source_mw` lineage table |
| `common` | Master and reference data - exchanges, securities, indices, contracts, geography |
| `private` | Transactional time-series facts - prices, candles, option-chain snapshots |

Table suffix convention: `*_mw` is a master / reference table, `*_tx` is a
transactional fact table.

---

## Data Model

### New ENUM Types (`common`)

| Type | Values | Used By |
| :---: | --- | --- |
| `common.option_type` | `CALL`, `PUT` | `derivative_contract_mw.option_type` |
| `common.derivative_instrument_type` | `INDEX OPTION`, `STOCK OPTION`, `INDEX FUTURE`, `STOCK FUTURE` | `derivative_contract_mw.instrument_type` |
| `common.underlying_type` | `INDEX`, `EQUITY` | `derivative_contract_mw.underlying_type` |

The existing `private.timeframe_value` ENUM (`1m`, `3m`, `5m`, `15m`, `1h`, `1D`,
`1M`, `1Y`) is retained and relocated into its own type file. `option_style`
(`EUROPEAN` / `AMERICAN`) is **deferred** - all in-scope contracts are treated
uniformly in v1.

### Modified Master - `common.stock_exchange_mw`

A trading-currency reference is added so price and contract denomination is
derivable through the venue (country is already present via
`stock_exchange_country_id`):

  * `trading_currency_code CHAR(3) NOT NULL` - foreign key to
    `common.currency_mw(currency_code)`, `ON UPDATE CASCADE ON DELETE RESTRICT`.
  * The four seeded venues are set to `INR`.

### New Master - `common.market_index_mw`

Indices are underlyings but have no ISIN, so they get a dedicated master rather
than polluting the ISIN key domain of `securities_mw`.

| Column | Type | Notes |
| :---: | :---: | --- |
| `market_index_id` | `INTEGER` identity | `pk_market_index_id` |
| `index_symbol` | `VARCHAR(32)` | Short code, e.g. `NIFTY 50` |
| `index_name` | `VARCHAR(128)` | Full descriptive name |
| `market_identifier_code` | `CHAR(4)` | FK to `stock_exchange_mw` |
| `index_provider` | `VARCHAR(64)` | Nullable, e.g. index administrator |
| `base_date` | `DATE` | Nullable base date |
| `base_value` | `NUMERIC(21,5)` | Nullable base value |
| `index_data_source_id` | `CHAR(5)` | FK to `data_source_mw` |
| `created_on` | `TIMESTAMPTZ` | Default `CURRENT_TIMESTAMP` |

Natural key `uq_market_index_symbol (market_identifier_code, index_symbol)`.

### New Master - `common.derivative_contract_mw`

One row per tradable option or future contract. Futures are folded into the same
master because they share roughly ninety percent of their columns with options.

| Column | Type | Notes |
| :---: | :---: | --- |
| `derivative_contract_id` | `BIGINT` identity | `pk_derivative_contract_id` (BIGINT - the contract space is large) |
| `underlying_type` | `common.underlying_type` | `INDEX` or `EQUITY` |
| `underlying_isin` | `CHAR(12)` | Nullable FK to `securities_mw` |
| `underlying_index_id` | `INTEGER` | Nullable FK to `market_index_mw` |
| `instrument_type` | `common.derivative_instrument_type` | Option / future, index / stock |
| `option_type` | `common.option_type` | `NULL` for futures |
| `strike_price` | `NUMERIC(21,5)` | `NULL` for futures |
| `expiry_date` | `DATE` | Distinct dates carry weekly / monthly expiries |
| `market_identifier_code` | `CHAR(4)` | FK to `stock_exchange_mw` |
| `tradable_symbol` | `VARCHAR(64)` | Exchange tradable symbol |
| `lot_size` | `INTEGER` | Contract lot size |
| `tick_size` | `NUMERIC(21,5)` | Minimum price increment |
| `contract_data_source_id` | `CHAR(5)` | FK to `data_source_mw` |
| `created_on` | `TIMESTAMPTZ` | Default `CURRENT_TIMESTAMP` |

Integrity constraints:

  * `ck_dc_underlying_xor` - exactly one of `underlying_isin` /
    `underlying_index_id` is set, and the populated side matches `underlying_type`.
  * `ck_dc_option_fields` - options require `option_type` and `strike_price > 0`;
    futures require both to be `NULL`.
  * `ck_dc_inst_underlying` - `INDEX OPTION` / `INDEX FUTURE` imply an index
    underlying; `STOCK OPTION` / `STOCK FUTURE` imply an equity underlying.
  * `ck_dc_lot_tick` - `lot_size > 0` and `tick_size > 0` when present.
  * `uq_derivative_contract` - the natural key over `(market_identifier_code,
    instrument_type, underlying_type, underlying_isin, underlying_index_id,
    expiry_date, option_type, strike_price)` using `UNIQUE NULLS NOT DISTINCT`
    so a future's `NULL` option / strike cannot bypass de-duplication.

### Fact Tables (`private`)

All fact tables are **plain heap tables** in v1 - no partitioning and no
performance indexes (see Phase II). Each retains the natural `UNIQUE` constraint
that defines its grain and prevents duplicate bars - that is an *integrity*
constraint, not performance indexation.

| Table | Grain | Key Columns | Lineage |
| :---: | --- | --- | :---: |
| `private.security_prices_tx` | One equity OHLC bar | `(ses_primary_id, timeframe, effective_time)` | `ticker_data_source_id` |
| `private.index_prices_tx` | One index OHLC bar | `(market_index_id, timeframe, effective_time)` | `index_data_source_id` |
| `private.derivative_prices_tx` | One contract OHLC + OI bar | `(derivative_contract_id, timeframe, effective_time)` | `ticker_data_source_id` |
| `private.option_chain_tx` | One contract snapshot | `(derivative_contract_id, snapshot_time)` | `chain_data_source_id` |

  * `security_prices_tx` is **refactored** off TimescaleDB. The denormalized
    `exchange_symbol_ext` string is dropped in favour of a non-null
    `ses_primary_id` foreign key, completing the normalization.
  * Price tables carry an OHLC sanity check (`high` is the maximum, `low` is the
    minimum, prices non-negative).
  * `option_chain_tx` holds the full chain row - last traded price, bid / ask and
    sizes, open interest, change in open interest, volume, implied volatility, the
    greeks (`delta`, `gamma`, `theta`, `vega`, `rho`), and the underlying spot at
    snapshot time. Greeks have **no** non-negativity checks because `theta`, `rho`,
    and `PUT` delta are legitimately negative.

---

## Build Orchestration

New files mirror the existing `types/`, `tables/`, `seed/` folder convention.

```text
database/schema/common/types/option_type.sql
database/schema/common/types/derivative_instrument_type.sql
database/schema/common/types/underlying_type.sql
database/schema/common/tables/market_index.sql
database/schema/common/tables/derivatives.sql
database/schema/private/types/timeframe_value.sql
database/schema/private/tables/security_prices.sql
database/schema/private/tables/index_prices.sql
database/schema/private/tables/derivative_prices.sql
database/schema/private/tables/option_chain.sql
database/schema/private/initialize.sql
```

Strict include order so foreign keys resolve cleanly:

  1. `common/initialize.sql` gains the **missing** `corporate_actions_type.sql`
     include, then the three new ENUM files, then `market_index.sql` and
     `derivatives.sql` after `securities.sql`.
  2. `private/initialize.sql` (new) loads `timeframe_value.sql`, then
     `security_prices.sql`, `index_prices.sql`, `derivative_prices.sql`, and
     `option_chain.sql`.
  3. `database/initialize.sql` appends `\i database/schema/private/initialize.sql`
     last.

### Build Defects Corrected

  * `common/initialize.sql` never included `corporate_actions_type.sql`, although
    `securities.sql` uses that ENUM - a fresh build failed. Now included.
  * The `private` schema had no `initialize.sql` and its `prices.sql` was
    orphaned - the schema never built. A proper orchestrator is added.

---

## Specialized Agents

Four reusable subagents under `.claude/agents/` support this and future database
work:

| Agent | Responsibility |
| :---: | --- |
| `db-planner` | Schema and architecture planning for the finance domain |
| `db-optimizer` | Indexing, partitioning, and storage tuning (drives Phase II) |
| `db-code-reviewer` | DDL correctness, normalization, naming, and format compliance |
| `db-security-reviewer` | Privilege posture, FK actions, constraint integrity, exposure |

---

## Phase II (Deferred - Do Not Build Yet)

  * Native PostgreSQL `RANGE` partitioning (monthly) on every `*_tx` table, with a
    partition-roll function, a scheduled job, and a `DEFAULT` partition guard.
  * Performance indexes - `BRIN` on the time columns and `btree` on
    `(<entity_id>, timeframe, time)` access paths.
  * Optional migration back to a TimescaleDB hypertable once partitioning is proven.

These recommendations are owned by the `db-optimizer` agent.

## Future Scope (Not Scheduled)

  * Higher-order timeframe roll-ups (`3m`, `5m`, `15m`, `1h`, `1D`, and beyond)
    computed on the fly from the 1-minute base bars via SQL functions.
  * A `common.derivative_underlying_vw` helper view to resolve the polymorphic
    underlying (index or equity) behind a single logical reference.

---

## Security Posture

  * The four `private` fact tables `REVOKE INSERT, UPDATE, DELETE ... FROM PUBLIC`,
    mirroring the hardening already applied to the subscription reference tables,
    so the restricted intent of the `private` schema is explicit in the DDL.
  * **Deferred (hardening):** a committed role model - a read-only consumer role
    and an ingestion writer role - with `ALTER DEFAULT PRIVILEGES IN SCHEMA private`
    so the write restriction is self-enforcing for future tables rather than
    re-declared per table. Left out of v1 because roles are deployment-specific
    (Aiven-managed).
  * `public.data_source_mw.data_source_uri` must store bare base URLs only - never
    a query string or an embedded credential / token.

---

## Verification

  - [ ] Load the new DDL into a scratch PostgreSQL 18 instance, excluding the
        `macrodb` subscription files, and confirm every ENUM, master, and fact
        table creates cleanly with foreign keys resolving in include order.
  - [ ] Insert a valid option row and a valid future row successfully.
  - [ ] Confirm an option with a `NULL` strike is rejected by `ck_dc_option_fields`.
  - [ ] Confirm a contract with both or neither underlying set is rejected by
        `ck_dc_underlying_xor`.
  - [ ] Confirm an OHLC bar with `high < low` is rejected by the price check.
  - [ ] Confirm a duplicate `(derivative_contract_id, snapshot_time)` is rejected
        by `uq_option_chain`.
  - [ ] `db-code-reviewer` and `db-security-reviewer` sign off.

</div>
