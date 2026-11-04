# Current work — Santa Fe business succession study

This is the tracking page for this effort. Three sections, two owners:

- **Intent** is authored by Kary. It is the stable anchor the work is
  checked against. **No agent session edits it.** A session that
  believes it is wrong or out of date says so and leaves it alone.
- **Current state** and **Next** are written and kept current by
  Claude Code, in the **same commit** as the work they describe.

Two further sections record what Chat has settled: **Decisions** and
**Prior art**. Sessions carry them out; changing one is a Chat
decision, recorded here by the session that implements it.

## Intent

*Not yet written — this section is Kary's to author.* The repo was set
up on 2026-11-03 from a Chat handoff ("Santa Fe business succession
study scoping"). Until the Intent exists, the study's questions are
the two quantities that handoff named, stated here in landscape terms:

1. What share of Santa Fe business owners are at or near retirement
   age?
2. What share of local private-sector employment is at
   long-established, locally owned businesses?

Each with New Mexico and the U.S. as comparisons. What the findings
are for — the decision they inform and for whom — is business strategy
and lives in chalkboard-core, not here (CLAUDE.md, Repo class).

## Decisions (settled in Chat, 2026-11-03)

1. **Firm-age threshold:** 11+ years at every geography, for
   like-for-like comparison (the county and metro classes stop at 11+).
   21+ for New Mexico and the U.S. as supplementary only. *Implementation
   note:* the decision anticipated summing finer bins for New Mexico and
   the U.S.; both publish 11+ (`FAGE 075`) directly, and it equals the
   sum of the finer bins exactly (`docs/data.md`, Codes used).
2. **Owner age is reported as shares of owners,** not as counts of
   businesses.
3. **55–64 and 65+ are reported separately,** each with its own
   interval; the combined 55+ figure is a labeled point estimate.
4. **Every figure is labeled with its data year:** owner age 2023, firm
   age 2022.
5. **Metro figures stand in where the county lacks detail,** with one
   statement in the methods that the footprints are identical.
6. **ABS 2023 is the headline year;** ABS 2022 is a consistency check,
   never pooled.

## Prior art (from the 2026-11-03 handoff)

- **Owner age, employer firms:** Census ABS, Characteristics of
  Business Owners (`2023/abscbo`), OWNRAGE — adopted.
- **Owner age, nonemployer firms:** Census NES-D (`2023/absnesdo`) —
  adopted.
- **Firm age and firm size:** Census BDS (`timeseries/bds`), published
  firm-age and firm-size classes — adopted. Firm age is defined at the
  firm level, so a national chain's local establishment carries the
  chain's age.
- **"Near retirement":** owners 55 and older, the cut used in Census
  ABS releases and Project Equity's succession research — adopted;
  55–64 and 65+ also reported separately.
- **"Long-established business":** Project Equity's local studies use
  firms 20+ years old — adapted to 11+ years, because BDS's county and
  metro firm-age classes stop at 11+.
- **"Locally owned":** Project Equity restricts to privately held,
  locally owned firms using commercial business lists; Census data
  cannot identify ownership location — adapted as a small-firm
  restriction on BDS's published firm-size classes, no settled cutoff
  found (search covered Project Equity's published methodology and
  Census BDS documentation). **Status after 2026-11-03: not
  implementable at the county or metro** — see Current state.

## Current state

*Written 2026-11-03, at the repo's first commit.*

**Repo.** Set up per the `study-*` class, modeled on
`study-santafe-nonprofits`: `scripts/`, gitignored `data/`, `output/`,
`scratch/`, and `docs/` (this page, `data.md`, `FINDINGS.md`,
`backlog.md`). No remote; the user creates the GitHub repo and pushes.

**Scripts.** `00_setup.R` holds the study parameters and the Census
query helper (`f_census_query()`), which caches each raw response in
`data/census_cache/` and appends a record to the committed fetch log.
`01_pull_census.R` pulls ABS 2023 (owner age plus two further owner
questions), ABS 2022 (owner age), NES-D 2023 (owner age), and BDS 2022
(firm age, by sector) at county, metro, New Mexico, and U.S.; it prints
row counts, suppression counts, and two integrity checks.
`05_import_feasibility_cache.R` is a committed one-shot that imported
the feasibility session's 20 raw responses with asserted fetch-log
records. `10_bds_firm_size_by_age.R` answers the firm-size question.
All run top to bottom from a fresh session, and offline once the cache
is full.

**Firm size by firm age (Task 3 of the launching handoff): not
published locally.** BDS 2022 publishes firm age crossed with firm
size only for the U.S. At county, metro, and state level, a request
with both wildcarded returns the two one-way margins and no cross
cells, and an explicit cross-cell request returns HTTP 204. County and
metro also publish only three size classes (1–19, 20–499, 500+). So the
small-firm restriction proposed as the "locally owned" proxy cannot be
applied to the local firm-age figures. Per the handoff, the work
stopped there; nothing downstream of the firm-size question was
computed.

**Not yet computed:** the headline owner-age shares, their intervals,
and the firm-age employment shares. The data for all of them is in the
cache.

## Next

- **Chat:** the "locally owned" proxy has no implementable form in
  BDS at the local level. Whether to drop it, report firm age for all
  firms with the chain limitation stated, or look for another source is
  open — see `docs/backlog.md`, Chat-first.
- **Code:** compute the owner-age shares (decisions 2, 3, 6) and the
  firm-age shares (decisions 1, 4, 5) once the proxy question is
  settled, since it determines what the firm-age figure is a share of.
- **Kary:** write the Intent section; create the GitHub repo and push.
