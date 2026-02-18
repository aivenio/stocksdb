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

#### v0.0.1 | 2026-02-19

Establish a basic database schema with minimal information, but provides scripts to update data mainly for the ISIN codes of
securities listed in the NSDL (India) website. The following features are available:

  * ✨ The data uses a *subscription model* to sync data across a single source of truth, check
    [aivenio/macrodb](https://github.com/aivenio/macrodb/tree/master) for more details.
  * ✨ A minimial skeleton is provided with Python script and GitHub Action to fetch ISIN code from NSDL website, check
    the script file for more information.

</div>
