# study-santafe-succession

Public-data study of business-succession need in Santa Fe: owner age
and firm age from Census Bureau tables, explored with chalkboard.eda.
What the study is for and the questions it answers live in
`docs/current-work.md`, not here — read that first.

Second repo of the `study-*` class. chalkboard.eda's
`docs/conventions.md` is canonical for conventions and carries the
`study-*` class block (data, execution, offsite):

@../chalkboard.eda/docs/conventions.md

The fuller class conventions — repo-class rules, directory layout, the
tooling boundary — have not yet graduated to `conventions.md`; they
still live in `study-santafe-nonprofits/CLAUDE.md`, whose Open
decisions section says to factor them out once a second study repo
exists. This is that second repo. The sections below marked
**provisional copy** restate only what this repo needs from there and
are to be deleted when the class conventions graduate (a package
session's task, not a study session's).

## Session start: read docs/current-work.md

Read `docs/current-work.md` at the start of every session, before doing
anything else. Its Intent section is the user's text: no session edits
it. Check the assigned work against it; if the work does not clearly
serve it, flag that before starting. Any session doing work here
updates Current state and Next in the same commit as its work.

## Repo class: study-* (provisional copy)

- Public data in, publishable analysis out. No client content, no
  proprietary business content.
- GitHub-hosted; the push is the offsite copy. Agent sessions cannot
  push — they commit locally and flag the pending push in the handoff.
  No bundle protocol, no Proton Drive symlinks.
- Business-strategic implications — prospect lists, pitch framing,
  what Chalkboard does about the findings — live in chalkboard-core,
  never here. This repo answers "what does the landscape look like?";
  cross-reference chalkboard-core by pointer only.

## Directory layout and data (provisional copy)

- `data/`, `output/`, `scratch/` are plain gitignored directories,
  excluded for reproducibility, not protection. The one committed file
  under `data/` is the fetch log, `data/census_cache/_fetch_log.ndjson`.
- `docs/data.md` describes expected files, provenance, API quirks, and
  suppression. Every output states the data year it covers (owner age
  2023; firm age 2022).

## The Census API key

- Read `CENSUS_API_KEY` from `~/.Renviron` via `Sys.getenv()`, inside
  `f_census_key()` in `scripts/00_setup.R` and nowhere else. Never print,
  log, or commit it, and never write a request URL that includes it.
- Before every commit, scan the staged files and the run logs for the
  key (the check is in `docs/data.md`, Key hygiene).

## Tooling boundary (provisional copy)

- Reusable data access belongs in chalkboard.eda as `f_*` functions.
  The Census query helper in `scripts/00_setup.R` is study-local only
  until a package session builds the fetcher (`docs/backlog.md`,
  Package-worthy). Study sessions never write to the package repo.
- Study-specific analysis scripts stay in `scripts/`: `0x` is the
  ordered pipeline, `1x` independent analysis scripts that each source
  `00_setup.R`. Every script runs top to bottom from a fresh session.

## Conventions

- Commit locally with imperative-mood messages; the user pushes.
- Deferred work goes in `docs/backlog.md` in the launch-text format.
- Unpromoted explorations are logged in `docs/FINDINGS.md`.

## Open decisions

- **Visibility and license:** private initially; decide with the
  first polished outputs.
- **Repo naming:** this repo's name matches `study-santafe-nonprofits`;
  whether that naming convention holds is open and not settled here.
