# Data

All data comes from the Census Bureau's data API
(`https://api.census.gov/data/`). Raw responses are cached in
`data/census_cache/`, a gitignored directory. They are excluded for
reproducibility, not protection: everything is public and
re-downloadable, so the reproducible artifact is the pull script, not
the download. This file records what the scripts expect, where it came
from, when it was retrieved, and how the API behaves.

Every output states its data year: **owner age 2023** (ABS 2022 is a
consistency check only), **firm age 2022**. For the ABS these are
**reference years** — the year the data describe — not the survey
names Census gave those releases (see ABS releases and reference years,
below).

## Sources

| Table | Endpoint | Year(s) | What it gives this study |
| --- | --- | --- | --- |
| Annual Business Survey (ABS), Characteristics of Business Owners | `2023/abscbo`, `2022/abscbo` | Reference year 2023 headline (Census's "2024 ABS"); reference year 2022 check (the "2023 ABS") | Owner age (question O09, OWNRAGE) for owners of **employer** firms, with standard errors |
| Nonemployer Statistics by Demographics (NES-D) | `2023/absnesdo` | 2023 | Owner age (O09) for owners of **nonemployer** firms; counts rounded, no standard errors |
| Business Dynamics Statistics (BDS) | `timeseries/bds` | 2022 (latest the API returns) | Firms, establishments, and employment by firm age; by sector at the metro; by firm size (not crossed with age) |

ABS county owner age exists for reference years 2017, 2022, and 2023
(the 2018, 2023, and 2024 ABS). Reference years 2018–2021 have no
county estimates (the 2019–2022 ABS published nation, states, and metro
areas only). Until 2026-11-03 this file said "ABS county coverage begins
with 2022"; a probe of `2017/abscbo` that day showed otherwise. County
owner age, from both ABS and NES-D, is published for all industries
combined only.

## ABS releases and reference years

Census names each ABS release by the year it was **collected**, one year
after the year its data describe: the 2023 ABS covers reference year
2022, and the 2024 ABS covers reference year 2023. The data API's path
year is the **reference year**: `2022/abscbo` is the 2023 ABS and
`2023/abscbo` is the 2024 ABS. Census's API page pairs them this way;
both cached responses carry a `YEAR` column equal to the path year.
From the release fielded in 2026, Census will name releases by reference
year instead, so the "2025 ABS" will cover 2025. Earlier releases keep
their old names.

**This study labels the ABS by reference year throughout**, in the
scripts (`abs_year_headline`, `abs_year_check`), the cache filenames,
and every doc. "ABS 2023" here means reference year 2023 (Census's
"2024 ABS"). Read a Census page that says "2023 ABS" as reference year
2022. Before 2026-11-03 the docs used the bare year without saying
which year it was. The years were right, but a reader could take
"ABS 2023" for Census's "2023 ABS", which is the other release.

### Methodology for the two county releases

Read 2026-11-03 from Census's ABS methodology pages
(<https://www.census.gov/programs-surveys/abs/technical-documentation/methodology.2023.html>
for the 2023 ABS;
<https://www.census.gov/programs-surveys/abs/technical-documentation/methodology.html>,
the 2024 section, for the 2024 ABS) and the API page
(<https://www.census.gov/data/developers/data-sets/abs.html>). The
fetched text of both methodology pages cut off partway. Items that come
only from the later, summarized portion are marked *(summary)*.

| | Reference year 2022 (2023 ABS) | Reference year 2023 (2024 ABS) |
| --- | --- | --- |
| Employer businesses mailed | about 850,000 | about 330,000 |
| Stratification | state, race/ethnicity, industry (not county) | same |
| Race/ethnicity strata | 8, including "Women" and "Publicly owned" | 7; non-Hispanic White men and women stratified separately |
| Certainty cases | includes firms selected for the Business Enterprise R&D Survey (BERD); R&D cutoffs as in the 2022 ABS | over 500 employees; BERD firms; stratum payroll/receipt cutoffs; R&D cutoffs changed for some industries |
| Industry classification | 2022 NAICS | 2022 NAICS |
| Firms that responded (of non-deaths) | about 61.9% | about 63.3% |
| Owner tables, sufficient response | about 53.8% *(summary)* | about 54.6% |
| Firm-count estimates that are imputed | about 12.7% | about 14.4% |
| Sex, ethnicity, race, veteran status for nonrespondents | assigned from prior ABS, 2010 Census, or ACS; else imputed from donors in the stratum | same |
| Weighting | reciprocal of selection probability; no nonresponse weighting adjustment | same |
| Suppression rule stated | relative standard error 50% or more | same |
| Disclosure avoidance | noise infusion *(summary)* | noise infusion *(summary)* |
| County estimates published | yes | yes |

What neither page states: the reason for the larger reference-2022
sample (that year is also an Economic Census year), how county
estimates are produced or vetted beyond the 50% rule, any sample size
or response count below the national level, and how **owner age** is
handled when a respondent skips it. The assignment and imputation
statements name sex, ethnicity, race, and veteran status only. The
`EG` "Item not reported" row suggests owner-age nonresponse is
tabulated rather than imputed. Neither page says so. Both pages say
published standard errors include an adjustment for imputation, and
both use 90% (1.6 standard errors) in their worked confidence-interval
example.

### Published standard errors, owner age 55–64 and 65+

Share of owners of respondent employer firms (`OWNPDEMP_PCT`), with its
published standard error in percentage points (`OWNPDEMP_PCT_S`), and
the relative standard error of the owner count (`OWNPDEMP_S`). All
industries. The metro's figures are identical to the county's.

| Geography | Age | Ref. 2022 share (SE) | Ref. 2023 share (SE) | Ref. 2022 count RSE | Ref. 2023 count RSE |
| --- | --- | --- | --- | --- | --- |
| Santa Fe County | 55–64 | 29.6% (1.3) | 30.2% (3.4) | 9.1% | 14.3% |
| Santa Fe County | 65+ | 39.0% (2.2) | 26.8% (5.3) | 10.7% | 16.6% |
| New Mexico | 55–64 | 28.9% (1.2) | 28.4% (1.5) | 2.2% | 4.9% |
| New Mexico | 65+ | 30.9% (1.2) | 26.1% (1.8) | 5.3% | 6.2% |
| United States | 55–64 | 28.9% (0.2) | 28.2% (0.1) | 0.3% | 0.5% |
| United States | 65+ | 22.8% (0.5) | 23.1% (0.2) | 0.4% | 0.4% |

County owners reporting age (`EF`): 2,609 in reference year 2022 and
2,438 in 2023. Both are weighted estimates, not sample counts.

## Geography

- **Santa Fe County** — `for=county:049&in=state:35`
- **Santa Fe metro** — `for=metropolitan statistical area/micropolitan statistical area:42140`
  (CBSA 42140, Santa Fe, NM Metropolitan Statistical Area)
- **New Mexico** — `for=state:35`
- **United States** — `for=us:1`

The county and the metro have the same footprint: the metro is the one
county. Every value the two publish in common matches exactly (25 of 25
shared BDS cells, checked on every run of `01_pull_census.R`; ABS and
NES-D shared values matched in the 2026-11-03 feasibility session).
Where the county lacks detail, metro figures stand in, and the methods
say once that the footprints are identical (decision 5 in
`docs/current-work.md`).

All geography definitions live once in `scripts/00_setup.R`
(`census_geos`).

## Expected files

`data/census_cache/<resource>.json` — one raw response body per query,
exactly as the API returned it (a JSON array of string arrays, header
first). A query the API answered with HTTP 204 (no rows) is cached as
`[]`. Names follow `<table>_<year>_<geo>[_<question>].json`:

| Pattern | Written by | Contents |
| --- | --- | --- |
| `abscbo_2023_<geo>_O09.json` | `01_pull_census.R` | ABS reference year 2023 owner age, all industries and (NM, U.S.) sector detail |
| `abscbo_2023_<geo>_O02.json`, `_O05.json` | `01_pull_census.R` | ABS reference year 2023, two further owner characteristics scoped by the feasibility session; not yet read by any analysis |
| `abscbo_2022_<geo>_O09.json` | `01_pull_census.R` | ABS reference year 2022 owner age (consistency check) |
| `abscbo_2017_county_O09_probe.json` | scratch probe, 2026-11-03 | Existence check only: does reference year 2017 publish county owner age? Pulled without the demographic filters, so not a usable table |
| `qwi_sa_county_firmage5_firmsize1_2024Q4.json` | scratch probe, 2026-11-03 | QWI firm age 11+ × firm size 0–19, county, 2024-Q4: `[]` (not published). See `docs/FINDINGS.md` |
| `qwi_sa_county_firmage5_2024Q4.json` | scratch probe, 2026-11-03 | Control for the row above: same request with firm age only, which returns a row |
| `absnesdo_2023_<geo>_O09.json` | `01_pull_census.R` | NES-D 2023 owner age |
| `bds_2022_<geo>.json` | `01_pull_census.R` | BDS 2022 firm age by sector (sector detail by age at metro, NM, U.S.; county gives the two margins only) |
| `bds_2022_fage_by_empszfi_<geo>.json` | `10_bds_firm_size_by_age.R` | BDS 2022 firm age and firm size, both wildcarded |
| `bds_2022_fage075_empszfi635_<geo>.json` | `10_bds_firm_size_by_age.R` | One explicit age-by-size cell; `[]` everywhere but the U.S. |

`<geo>` is one of `us`, `nm`, `metro`, `county`.

## Provenance

`data/census_cache/_fetch_log.ndjson` is the retrieval record: one line
per retrieved file, in chalkboard.eda's fetch-log format (read it with
`f_read_fetch_log("data/census_cache")`). It is committed; the responses
are not. Every network fetch by `f_census_query()` appends an
**observed** record carrying `retrieved_at` (UTC), the request URL
**without the key**, the outcome (`ok`, or `not_found` for HTTP 204),
and the dataset and geography. A cache hit appends nothing.
`source_release` is `NA` throughout: the API publishes no release date
for a cut.

**The 20 responses from the feasibility session** were imported by
`scripts/05_import_feasibility_cache.R` with **asserted** records dated
2026-11-03 — the feasibility session's own date, taken from the
handoff that launched this repo, not from file modification times. The
date is the local (Mountain) date with no time of day recorded, so the
log renders it as `2026-11-03T00:00:00Z`; read it as a date only. Those
imports were checked the same day against a fresh fetch: all 20 parse
to identical tables once row order is ignored.

**Retrieval dates as of 2026-11-03:**

- ABS reference year 2023 (O09, O02, O05), NES-D 2023, BDS 2022 by age
  and sector — 2026-11-03, feasibility session (asserted)
- ABS reference year 2022 (O09) — 2026-11-03, `01_pull_census.R`
  (observed)
- BDS 2022 age-by-size probes — 2026-11-03, `10_bds_firm_size_by_age.R`
  (observed)
- QWI firm-age and firm-size probes, ABS reference year 2017 county
  probe — 2026-11-03, scratch (observed)

The fetch log is authoritative over this list; refresh the list when a
pull changes it.

## Codes used

- **Owner age (OWNCHAR, question O09):** `DZ` Under 25, `EA` 25 to 34,
  `EB` 35 to 44, `EC` 45 to 54, `ED` 55 to 64, `EE` 65 or over,
  `EF` Total reporting, `EG` Item not reported (ABS only).
- **"All owners" filters:** ABS uses `OWNER_SEX=001`, `OWNER_ETH=001`,
  `OWNER_VET=001`, but `OWNER_RACE=00`. NES-D uses `000` on all four.
- **ABS uncertainty:** `OWNPDEMP_S` is the *relative* standard error of
  the owner count (%); `OWNPDEMP_PCT_S` is the standard error of the
  owner share, in percentage points. NES-D publishes neither.
- **Firm age (FAGE):** `001` all; `010` 0 years; `065` 1–5; `070` 6–10;
  `075` 11+; `150` left-censored (firms whose age cannot be determined
  because they predate the Longitudinal Business Database's start, so
  they are at least as old as the series). The state and U.S. also
  publish `020`–`060` (single years 1–5) and `080` 11–15, `090` 16–20,
  `100` 21–25, `110` 26+. **They publish `075` directly too**, and it
  equals the sum of `080`–`110` exactly at both levels (checked on every
  run of `01_pull_census.R`).
- **Firm size (EMPSZFI):** county and metro publish only `635` 1–19,
  `650` 20–499, `657` 500+. The state and U.S. add `612` 1–4, `620` 5–9,
  `630` 10–19, `640` 20–99, `649` 100–499, and five classes from 500
  upward. Firm size is the **whole firm's** employment, nationally: a
  national chain's local establishment is in the chain's size class.

## API quirks

Observed in the 2026-11-03 feasibility session and absorbed by
`f_census_query()` in `scripts/00_setup.R`:

- **A key is required on every data query, and a missing or bad key
  redirects** to `missing_key.html` instead of returning an error. The
  helper turns redirects off and stops on anything but 200 or 204.
- **Values arrive as strings** in a JSON array whose first row is the
  header. The helper returns an all-character tibble; convert where
  used.
- **Filtering by label silently returns HTTP 204** (no content). Filter
  by code — `QDESC=O09`, never `QDESC_LABEL=OWNRAGE`.
- **"All owners" codes differ by dataset** (ABS `001` with race `00`;
  NES-D `000`). See Codes used.
- **Filter variables come back as duplicate columns** (every predicate
  is echoed after the requested variables). The helper keeps the first
  copy.
- **Unfiltered pulls truncate silently.** Always filter ABS and NES-D
  by question code. (A related caution: the U.S. firm-age-by-size
  response in `10_bds_firm_size_by_age.R` returned 135 cross cells
  where 14 ages × 13 sizes allows 182. Not investigated — the U.S. cross
  is not used — but do not read it as complete.)
- **Row order is not fixed.** The same query can return rows in a
  different order on a later fetch; compare responses as sets.
- **HTTP 204 also means "this cell is not published"** — the BDS answers
  an explicit firm-age-by-size request with 204 at county, metro, and
  state level.

## Suppression

Suppression appears in three ways, and none of them is an `NA`:

1. **A flag with the value set to 0.** The value columns read `0` (or
   `0.0`) and the paired `_F` column carries a letter. Observed letters:
   - `S` (ABS) — estimate does not meet publication standards. All four
     ABS value columns are 0 and all four flags read `S`. At the county
     and metro this is the "Item not reported" row only.
   - `X` (ABS, share columns) — not applicable. The count is published;
     the share and its standard error read 0.0 with flag `X`.
   - `D` (BDS) — withheld to avoid disclosing individual companies.
     `FIRM`, `ESTAB`, and `EMP` all read 0. In the metro sector-by-age
     table, 9 of 120 cells carry `D`, all in four sectors (11, 21, 22,
     55). The BDS also has true zeros with no flag (37 rows across the
     cache): a 0 means suppressed only when its flag says so.
2. **A missing row.** The category is simply absent. ABS county and
   metro owner age have no `DZ` (Under 25) row in either year, while
   NES-D publishes it.
3. **A flagged count with the share still published.** NES-D flag `Y`:
   `OWNNOPD` reads 0 with flag `Y` while `OWNNOPD_PCT` carries a real,
   unflagged value (42 rows in the U.S. table, 2 in New Mexico, none at
   county or metro). The meaning of `Y` was not confirmed against
   Census's symbol table in this session.

`01_pull_census.R` prints the number of flagged rows per table on every
run.

## Key hygiene

`CENSUS_API_KEY` lives in `~/.Renviron` and is read only by
`f_census_key()`. The fetch log records the request URL built before the
key is added. Network error messages are scrubbed of the key before
they are raised. Run logs (`scratch/logs/`) never see it.

Before every commit, scan everything staged and the run logs. The check
reads the key from the environment, so it never appears on screen:

```r
k <- Sys.getenv("CENSUS_API_KEY")
files <- c(system("git ls-files --cached --others --exclude-standard", intern = TRUE),
           list.files("data", recursive = TRUE, full.names = TRUE, all.files = TRUE),
           list.files("scratch", recursive = TRUE, full.names = TRUE, all.files = TRUE))
hits <- Filter(function(f) any(grepl(k, readLines(f, warn = FALSE), fixed = TRUE)), unique(files))
stopifnot(nzchar(k), length(hits) == 0)
```

Also search for the literal `key=` in the same files: a request URL
with `&key=` in it is the likeliest leak.
