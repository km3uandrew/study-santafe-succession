# 05_import_feasibility_cache.R — committed one-shot, already run 2026-11-03
#
# Copies the raw Census responses saved by the 2026-11-03 feasibility
# session into data/census_cache/ under the names 01_pull_census.R uses,
# and asserts one fetch-log record per file. Kept for the record of how
# those cache entries and their asserted records came to exist.
#
# Safe to re-run, and a no-op on any other machine or later date:
#   - it skips entirely when the feasibility scratchpad is gone (it lived
#     in a session temp folder and will not survive);
#   - it never overwrites a file already in the cache.
#
# Why asserted, and why a date with no time: the files were fetched by
# the feasibility session's pull.R, not by this repo's helper, so no
# fetcher observed them here. The retrieval date is the feasibility
# session's own date, stated in the handoff that launched this repo.
# It is deliberately not read off the files' modification times
# (chalkboard.eda docs/conventions.md, Source provenance).
#
# The feasibility pull used exactly the `get` lists and filters that
# 01_pull_census.R uses, so a cache hit there serves the same response a
# fresh fetch would have.

source("scripts/00_setup.R")

feasibility_raw <- paste0(
  "/private/tmp/claude-502/-Users-chalkboard--claude-spares-spare-vsxlQz/",
  "312ccc77-eee7-4058-9f7b-764e47bef320/scratchpad/raw"
)
feasibility_date <- as.Date("2026-11-03")

if (!dir.exists(feasibility_raw)) {
  message("Feasibility scratchpad is gone; nothing to import. ",
          "01_pull_census.R fetches anything the cache lacks.")
} else {
  # feasibility tag -> study resource name. abscbo_us_codes.json is
  # deliberately not imported: no pull script produced it, so no query
  # here would ever read it back.
  src <- list.files(feasibility_raw, pattern = "\\.json$")
  src <- setdiff(src, "abscbo_us_codes.json")
  map <- tibble(src = src) |>
    mutate(
      stem = sub("\\.json$", "", src),
      resource = case_when(
        grepl("^abscbo_", stem)   ~ sub("^abscbo_(.*)_(O\\d\\d)$",
                                        paste0("abscbo_", abs_year_headline, "_\\1_\\2"), stem),
        grepl("^absnesdo_", stem) ~ sub("^absnesdo_(.*)$",
                                        paste0("absnesdo_", nesd_year, "_\\1_O09"), stem),
        grepl("^bds_", stem)      ~ sub("^bds_(.*)$", paste0("bds_", bds_year, "_\\1"), stem)
      ),
      dest = file.path(dir_census_cache, paste0(resource, ".json")),
      already = file.exists(dest)
    )
  stopifnot(!anyNA(map$resource))

  todo <- filter(map, !already)
  if (nrow(todo) > 0) {
    ok <- file.copy(file.path(feasibility_raw, todo$src), todo$dest, overwrite = FALSE)
    stopifnot(all(ok))
    # Artifact first, record after (the fetch-log ordering contract).
    f_assert_fetch_record(
      dir          = dir_census_cache,
      source       = "census_api",
      resource     = basename(todo$dest),
      retrieved_at = feasibility_date,
      note = paste(
        "Fetched by the 2026-11-03 feasibility session's pull.R (same get",
        "lists and filters as 01_pull_census.R) and imported by",
        "05_import_feasibility_cache.R. Date from the launching handoff;",
        "time of day not recorded."
      )
    )
  }
  cat(sprintf("Feasibility responses: %d found, %d imported, %d already cached.\n",
              nrow(map), nrow(todo), sum(map$already)))
}
