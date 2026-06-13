<div align = "center">

# CHANGELOG

</div>

<div align = "justify">

All notable changes to this *PostgreSQL DB Management* project will be documented in this file. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project adheres to [`semver`](https://semver.org/) styling.

## Release Note(s)

The release notes are documented, the list of changes to each different release are documented. The `major.minor` are indicated
under `h3` tags, while the `patch` and other below identifiers are listed under `h4` and subsequent headlines. The legend for
changelogs are provided in the detail pane, while the version wise note is as available below.

<details>
<summary>Click Here to View Legend</summary>

<p><small>
<ul style = "list-style-type:circle">
  <li>✨ - <b>Major Feature</b> : something big that was not available before.</li>
  <li>🎉 - <b>Feature Enhancement</b> : a miscellaneous minor improvement of an existing feature.</li>
  <li>🛠️ - <b>Patch/Fix</b> : something that previously didn't work as documented should now work.</li>
  <li>🐛 - <b>Bug/Fix</b> : a bug in the code was resolved and documented.</li>
  <li>⚙️ - <b>Code Efficiency</b> : an existing feature now may not require as much computation or memory.</li>
  <li>💣 - <b>Code Refactoring</b> : a breakable change often associated with `major` version bump.</li>
</ul>
</small></p>

</details><br>

### Barbarian Overlord `v0` Release

We're pleased to announce that the PostgreSQL database management to track, take data driven trading actions and much more
using the stock data is made public. The **`v0`** is an experimental release to check feasibility and compatibility with
other existing models.

#### v1.0.0 | WIP

The first production-oriented iteration delivers a fully normalized, extension-free data model for security and index prices,
a derivative contract master, and the full option chain. The store is treated as global and multi-currency, with country and
trading currency derived through the exchange; commodities and currencies (as tradable assets) are out of scope. The changes
below span commits `0f2d22b` through `ab29717`:

  * ✨ Add the normalized **derivative contract master** (`common.derivative_contract_mw`) covering options and futures with a
    polymorphic underlying (market index or equity), enforced by exclusive-or, option/future field, instrument/underlying, and
    lot/tick check constraints, and a `UNIQUE NULLS NOT DISTINCT` natural key. `lot_size` and `tick_size` are nullable
    (positive-when-present) for flexible ingestion.
  * ✨ Add the **market index master** (`common.market_index_mw`) for index underlyings, which have no ISIN and so are tracked
    separately from `common.securities_mw`.
  * ✨ Add the **full option chain** fact table (`private.option_chain_tx`) storing a per-fetch snapshot - last traded price,
    bid/ask and sizes, open interest and its change, volume, implied volatility, the greeks, and the underlying spot price.
  * ✨ Add minute-granularity fact tables for **index prices** (`private.index_prices_tx`) and **derivative (option/future)
    candles** (`private.derivative_prices_tx`, including open interest).
  * ✨ Add the derivative-domain ENUM types `common.option_type`, `common.derivative_instrument_type`, and
    `common.underlying_type`.
  * ✨ Link each stock exchange to its trading currency via a new `trading_currency_code` reference on
    `common.stock_exchange_mw`, so prices and contracts inherit denomination through the venue.
  * ✨ Add four reusable database subagents under `.claude/agents/` - `db-planner`, `db-optimizer`, `db-code-reviewer`, and
    `db-security-reviewer` - and the schema design-of-record at `.claude/plans/DB Schema.md`.
  * 💣 Refactor `private.security_prices_tx` off the **TimescaleDB** hypertable into a plain heap table; drop the denormalized
    `<exchange>:<symbol>-<series>` string in favour of a non-null `ses_primary_id` foreign key, and relocate the
    `private.timeframe_value` ENUM into its own type file. Partitioning, performance indexation, and TimescaleDB are deferred
    to Phase II.
  * 🐛 Fix the schema build order to load `public` before `common` before `private`, so every `data_source_mw` and master
    foreign key resolves on a fresh build.
  * 🐛 Fix a missing include - `common/initialize.sql` now creates `corporate_actions_type` before `securities.sql` uses it.
  * 🐛 Wire the previously orphaned `private` schema into the build through the new `database/schema/private/initialize.sql`.
  * 🛠️ Harden the fact tables - add non-negativity check constraints on prices, sizes, volume, and open interest, and
    `REVOKE INSERT, UPDATE, DELETE ... FROM PUBLIC` on every `private` fact table.
  * 🛠️ Update `schema.dbml` to mirror the new model and replace all em dashes with hyphens across the documentation.

#### v0.0.1 | 2026-02-19

Establish a basic database schema with minimal information, but provides scripts to update data mainly for the ISIN codes of
securities listed in the NSDL (India) website. The following features are available:

  * ✨ The data uses a *subscription model* to sync data across a single source of truth, check
    [aivenio/macrodb](https://github.com/aivenio/macrodb/tree/master) for more details.
  * ✨ A minimial skeleton is provided with Python script and GitHub Action to fetch ISIN code from NSDL website, check
    the script file for more information.

</div>
