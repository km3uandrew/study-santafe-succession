# study-santafe-succession

A public-data study of business-succession need in Santa Fe, New
Mexico: how many business owners are at or near retirement age, and how
much local employment sits at long-established firms, from Census
Bureau tables (the Annual Business Survey, Nonemployer Statistics by
Demographics, and Business Dynamics Statistics), explored with the
[chalkboard.eda](https://github.com/km3uandrew/chalkboard.eda) package.
Every output states its data year.

`docs/current-work.md` is the authority for what this study is for and
where it stands; read it first. `CLAUDE.md` holds the repo's
conventions.

## Layout

- `scripts/` — `00_setup.R` first (parameters and the Census query
  helper; sourced by everything), then `01_pull_census.R` (every pull,
  cached). `05_import_feasibility_cache.R` is a committed one-shot.
  `1x` scripts are independent analyses: `10_bds_firm_size_by_age.R`.
  `_template.R` is the skeleton for a new exploratory question.
- `data/` — raw API responses (gitignored; re-downloadable — see
  `docs/data.md`). The fetch log, `data/census_cache/_fetch_log.ndjson`,
  is committed.
- `output/` — rendered plots (gitignored)
- `scratch/` — ephemeral exploratory code and run logs (gitignored)
- `docs/` — `current-work.md` (intent, decisions, current state, next),
  `data.md` (sources, provenance, API quirks, suppression),
  `FINDINGS.md` (questions explored but never promoted), `backlog.md`
  (deferred work)

## Setup

1. A Census API key (free, from
   <https://api.census.gov/data/key_signup.html>) in `~/.Renviron`:
   `CENSUS_API_KEY=...`. Never in this repo.
2. A local checkout of chalkboard.eda at the path in
   `scripts/00_setup.R`, plus `httr2`, `jsonlite`, `dplyr`, `tidyr`,
   `readr`, and `devtools`.
3. From the repo root: `Rscript scripts/01_pull_census.R`, then any
   `1x` script.
