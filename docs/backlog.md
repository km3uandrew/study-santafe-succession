# Backlog — study-santafe-succession

Deferred work for this study, routed by where the work happens rather
than by concern area (format defined in chalkboard.eda
`docs/conventions.md`). Each entry is a checkbox line with a short name
and a parenthetical concern tag, followed by an indented blockquote of
pasteable launch text — self-contained enough that pasting it into a
fresh session starts the work without other context. Code-first entries
name the repo the session runs in. Every entry ends with an origin
line: `(origin: YYYY-MM-DD, <where>)`. Item state is managed manually
by the user.

Reusable data access belongs in chalkboard.eda, not here (CLAUDE.md,
Tooling boundary). Ideas of that kind go in the last section and are
named in the handoff so a package session can transcribe them; study
sessions never write to the package repo.

## Chat-first (open design questions)

- [ ] What replaces the "locally owned" small-firm proxy? (methodology)
  > **What it is:** the study's second question asks what share of
  > Santa Fe private-sector employment is at long-established, locally
  > owned businesses. Census Business Dynamics Statistics (BDS) gives
  > firm age, but a national chain's local establishment carries the
  > chain's age, so "11+ years" mixes local businesses with chains. The
  > 2026-11-03 scoping handoff proposed restricting to small firms, using
  > BDS's published firm-size classes, as a "locally owned" proxy.
  > **What the check found** (`scripts/10_bds_firm_size_by_age.R`,
  > BDS 2022): firm age crossed with firm size is published **only for
  > the U.S.** At county, metro, and state level the API returns the
  > age and size margins separately and answers an explicit cross-cell
  > request with HTTP 204. County and metro publish only three size
  > classes (1–19, 20–499, 500+), and size is the whole firm's national
  > employment. So the proxy cannot be applied to local firm-age
  > figures.
  > **Open:** whether to (a) report local firm age for all firms with
  > the chain limitation stated, (b) report the one-way size margin
  > alongside it as separate context (it says how much local employment
  > is at 500+ firms, but not how old those firms are), (c) look for
  > another source that crosses firm age with size or ownership locally
  > — Quarterly Workforce Indicators publish firm age and firm size
  > tabulations by county, though whether they are crossed has not been
  > checked — or (d) drop "locally owned" from the question. Prior art
  > for whichever is chosen needs recording in `docs/current-work.md`.
  > **First step:** decide in Chat; the outcome is a Code handoff for
  > study-santafe-succession.
  > (origin: 2026-11-03, study-santafe-succession: firm-size-by-age check)

- [ ] How to present ABS 2023 against the 2022 consistency check (methodology)
  > **What it is:** decision 6 makes Annual Business Survey (ABS) 2023
  > the headline owner-age year and ABS 2022 a consistency check, never
  > pooled. The check is already visible in the cached responses
  > (`data/census_cache/abscbo_<year>_county_O09.json`), and the two
  > years differ for the county's oldest owners: share of owners 65 or
  > over is 39.0% (standard error 2.2 points) in 2022 and 26.8% (5.3) in
  > 2023; 55–64 is 29.6% (1.3) and 30.2% (3.4). New Mexico moves the
  > same direction, less (65+: 30.9% to 26.1%); the U.S. does not
  > (22.8% to 23.1%). The 2023 county standard errors are also two to
  > three times the 2022 ones.
  > **Open:** what the study says when the check disagrees — whether
  > the headline stays 2023 alone with the 2022 figure reported beside
  > it, whether the disagreement is stated as a caveat on the 65+ figure,
  > and whether a formal comparison (each year's interval, or a
  > difference test) is wanted. Nothing has been computed beyond reading
  > the published shares and standard errors.
  > **First step:** decide in Chat before the owner-age figures are
  > built.
  > (origin: 2026-11-03, study-santafe-succession: repo setup, ABS 2022 pull)

## Code-first (converged spec)

## Gated / operational (trigger conditions)

## Package-worthy (raise in a package session)

- [ ] Census Bureau API fetchers for chalkboard.eda (data access)
  > **What it is:** a package-level client for the Census data API
  > (`https://api.census.gov/data/`), on the pattern of
  > `f_fetch_propublica_org()`: a `cache_dir` contract, one fetch-log
  > record per retrieved response, and thin dataset wrappers for the
  > Annual Business Survey's Characteristics of Business Owners
  > (`<year>/abscbo`), Nonemployer Statistics by Demographics
  > (`<year>/absnesdo`), and Business Dynamics Statistics
  > (`timeseries/bds`).
  > **Why:** study-santafe-succession carries a study-local helper
  > (`f_census_query()` in its `scripts/00_setup.R`) that calls the
  > package's internal `f_write_fetch_log()` through `load_all()`, and
  > the API has quirks every caller would otherwise rediscover:
  > a missing or bad key **redirects** to `missing_key.html` instead of
  > erroring; values arrive as **strings** in a JSON array with the
  > header as the first row; filtering by **label** (e.g.
  > `QDESC_LABEL`) silently returns **HTTP 204**, so filters must use
  > codes (`QDESC=O09`); HTTP 204 also means "cell not published";
  > "all owners" codes **differ by dataset** (ABS `001` with race `00`,
  > NES-D `000`); filter variables come back as **duplicate columns**;
  > **unfiltered pulls truncate silently**; **row order is not fixed**
  > between fetches; and **suppression is encoded three ways** — a flag
  > letter with the value set to 0, a missing row, or a flagged count
  > with the share still published — never as `NA`. The key must never
  > reach a log, a cached URL, or an error message.
  > **Design questions for the package session:** whether 204 responses
  > are cached (the study caches them as `[]` with outcome
  > `not_found`), whether the fetcher decodes suppression flags to `NA`
  > or leaves that to callers, and how `source_release` is handled when
  > the API publishes none. The study's `docs/data.md` (API quirks,
  > Suppression) documents each quirk with the evidence.
  > **First step:** read study-santafe-succession's `scripts/00_setup.R`
  > and `docs/data.md`, then design the fetcher in a chalkboard.eda
  > session.
  > (origin: 2026-11-03, study-santafe-succession: repo setup from the census feasibility session)
