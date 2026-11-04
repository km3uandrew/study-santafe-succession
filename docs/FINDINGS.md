# Findings from unpromoted explorations

A few lines per question that was explored in `scratch/` but never
promoted to a numbered script: what was looked at, what the data
showed, why it was dropped.

This file is committed, and the repo's visibility is an open decision
(CLAUDE.md) — write entries as if they may become public.

<!-- Example entry format:

## YYYY-MM-DD: <the question>

- Explored: YYYY-MM-DD to YYYY-MM-DD
- Data years covered: owner age YYYY; firm age YYYY
- What the raw data showed: ...
- Why dropped: ...

-->

## 2026-11-03: Do the Quarterly Workforce Indicators cross firm age with firm size for Santa Fe? — DEAD END

- Explored: 2026-11-03, one session. A candidate "locally owned" proxy:
  employment by firm age for small firms only, which BDS publishes for
  the U.S. but not for the county, metro, or state
  (`scripts/10_bds_firm_size_by_age.R`).
- Source: Census Quarterly Workforce Indicators (QWI), from the
  Longitudinal Employer-Household Dynamics (LEHD) program, API
  `timeseries/qwi/sa`.
- What the documentation says: firm age and size cannot be requested
  together. *QWI 101* (LEHD, version QWI20260310, "Firm Age and Size")
  says they "are not interacted with each other", and are reported only
  for private-sector firms. Census's QWI API page says firm age and firm
  size "cannot be selected at the same time." The LEHD public-use schema
  (V4.14.1) carries them as separate tabulations (`fa` and `fs`).
- Firm level: *QWI 101* says firm age and size are "defined at the
  national level, rather than the state level," and are taken from BDS.
  So QWI shares the chain limitation BDS has: a chain's local branch
  carries the chain's age and size.
- What the API did (Santa Fe County, 2024-Q4, `ownercode=A05`):
  - A wildcard on firm age was refused (HTTP 400, "wildcard operator is
    not allowed for this predicate"). Nothing was cached.
  - Explicit firm age 11+ (`firmage=5`) × firm size 0–19 (`firmsize=1`):
    HTTP 204, cached as `qwi_sa_county_firmage5_firmsize1_2024Q4.json`.
  - Control, firm age 11+ alone: returned a row (status flag 1, OK),
    cached as `qwi_sa_county_firmage5_2024Q4.json`. So the quarter and
    county exist and the empty cross response is due to the crossing.
    The control's value is not used anywhere.
- QWI size classes, for reference: 0–19, 20–49, 50–249, 250–499, 500+.
  Age classes: 0–1, 2–3, 4–5, 6–10, 11+. Status flags include 5
  (suppressed) and 9 ("data significantly distorted – fuzzed value
  released"). All released QWI values carry multiplicative noise
  infusion.
- Why dropped: the crossing the proxy needs is not published, and the
  firm-level measure would carry the same chain limitation as BDS.
  Sources: <https://lehd.ces.census.gov/doc/QWI_101.pdf>,
  <https://www.census.gov/data/developers/data-sets/qwi.html>,
  <https://lehd.ces.census.gov/data/schema/latest/lehd_public_use_schema.html>.
