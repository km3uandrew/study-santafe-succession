# 00_setup.R — shared setup, sourced at the top of every script
#
# Study-wide parameters and the Census API query helper live here and
# nowhere else. Every script sources this file plainly — never inside
# capture.output() or another sink — because f_run_log() refuses to stack
# on an active sink and the run would go untee'd.

# ── Load chalkboard.eda ───────────────────────────────────────────────────────
# During active development, load from the local checkout. If this study
# goes dormant, pin instead:
#   remotes::install_github("km3uandrew/chalkboard.eda@vX.Y.Z")
#   library(chalkboard.eda)
path_chalkboard_eda <- "/Users/chalkboard/Codebase/chalkboard.eda"
devtools::load_all(path_chalkboard_eda, quiet = TRUE)

suppressPackageStartupMessages({
  library(httr2)
  library(jsonlite)
  library(dplyr)
  library(tidyr)
  library(readr)
})

# ── Run log ───────────────────────────────────────────────────────────────────
# Non-interactive runs (Rscript) tee console output to
# scratch/logs/<script>_<date>.log. No-op interactively. Nothing below
# ever prints the API key, so these logs are safe to keep — but they are
# scanned for it before every commit all the same (docs/data.md).
f_run_log()

# ── STUDY PARAMETERS ──────────────────────────────────────────────────────────
study_name <- "Santa Fe business succession"  # display name for plot titles

# Data years (docs/current-work.md, decisions 4 and 6). Owner age comes
# from the Annual Business Survey (ABS) and Nonemployer Statistics by
# Demographics (NES-D); firm age from Business Dynamics Statistics (BDS),
# whose latest returnable year is 2022.
abs_year_headline <- 2023  # headline owner-age year
abs_year_check    <- 2022  # consistency check only — never pooled
nesd_year         <- 2023
bds_year          <- 2022

# Geographies. Santa Fe County (state 35, county 049) and the Santa Fe
# metro (CBSA 42140) share one footprint; every value the two publish in
# common matched exactly in the 2026-11-03 feasibility session.
# Metro figures stand in where the county lacks detail (decision 5).
census_geos <- list(
  us     = list(`for` = "us:1",        `in` = NULL),
  nm     = list(`for` = "state:35",    `in` = NULL),
  metro  = list(`for` = "metropolitan statistical area/micropolitan statistical area:42140",
                `in` = NULL),
  county = list(`for` = "county:049",  `in` = "state:35")
)

# Geography identifier columns the API echoes back; dropped after parsing
# in favor of the study's own `geo` label.
census_geo_cols <- c("us", "state", "county",
                     "metropolitan statistical area/micropolitan statistical area")

# ── Paths ─────────────────────────────────────────────────────────────────────
dir_census_cache <- "data/census_cache"
dir_scratch_figs <- "scratch/figs"
for (d in c(dir_census_cache, dir_scratch_figs)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# ── Census API helper ─────────────────────────────────────────────────────────
# The study's only network access. Every query is cached as its raw JSON
# body in data/census_cache/<resource>.json, and every network retrieval
# appends one record to data/census_cache/_fetch_log.ndjson (payload
# first, record after). A cache hit reads the file and appends nothing.
#
# Quirks this helper absorbs, all observed in the 2026-11-03 feasibility
# session and written up in docs/data.md:
#   - A missing or bad key REDIRECTS (to missing_key.html) instead of
#     erroring, so redirects are switched off and any non-200/204 stops.
#   - HTTP 204 means "no rows match" — including when a filter is spelled
#     by label (QDESC_LABEL) rather than code. Cached as an empty array
#     and logged with outcome "not_found", so re-runs are offline too.
#   - Values arrive as strings in a JSON array whose first row is the
#     header; parsed here to an all-character tibble.
#   - Filter (predicate) variables are echoed back as duplicate columns;
#     only the first copy is kept.
#
# THE KEY: read from CENSUS_API_KEY (set in ~/.Renviron), added to the
# request at the last moment, and never stored, printed, or logged. The
# URL recorded in the fetch log is built WITHOUT it, and any network
# error message is scrubbed of it before being raised.
#
# The fetch-log writer f_write_fetch_log() is internal to chalkboard.eda
# and reachable here only because load_all() exposes internals. A Census
# fetcher in the package would retire this helper — see docs/backlog.md,
# Package-worthy.

f_census_key <- function() {
  key <- Sys.getenv("CENSUS_API_KEY")
  if (!nzchar(key)) {
    stop("CENSUS_API_KEY is not set. Add it to ~/.Renviron and restart R.",
         call. = FALSE)
  }
  key
}

f_census_parse <- function(body) {
  m <- jsonlite::fromJSON(body)
  if (length(m) == 0) {
    return(tibble())
  }
  df <- as.data.frame(m[-1, , drop = FALSE], stringsAsFactors = FALSE)
  names(df) <- m[1, ]
  df <- df[, !duplicated(names(df)), drop = FALSE]
  as_tibble(df)
}

f_census_query <- function(dataset, get, geo, resource, ..., refresh = FALSE) {
  path <- file.path(dir_census_cache, paste0(resource, ".json"))

  if (file.exists(path) && !refresh) {
    body <- paste(readLines(path, warn = FALSE), collapse = "\n")
  } else {
    params <- c(list(get = paste(get, collapse = ",")),
                Filter(Negate(is.null), census_geos[[geo]]),
                list(...))
    req <- request(paste0("https://api.census.gov/data/", dataset)) |>
      req_url_query(!!!params)
    url_without_key <- req$url

    key <- f_census_key()
    retrieved_at <- Sys.time()
    resp <- tryCatch(
      req |>
        req_url_query(key = key) |>
        req_options(followlocation = FALSE) |>
        req_error(is_error = function(r) FALSE) |>
        req_perform(),
      error = function(e) {
        stop(gsub(key, "<key>", conditionMessage(e), fixed = TRUE),
             call. = FALSE)
      }
    )
    status <- resp_status(resp)

    if (status == 204) {
      body <- "[]"
      outcome <- "not_found"
    } else if (status == 200) {
      body <- resp_body_string(resp)
      outcome <- "ok"
    } else {
      msg <- substr(gsub("\\s+", " ", resp_body_string(resp)), 1, 300)
      stop(sprintf("[%s / %s] HTTP %d%s: %s", dataset, resource, status,
                   if (status %in% 300:399) " (redirect: missing or invalid key?)" else "",
                   gsub(key, "<key>", msg, fixed = TRUE)),
           call. = FALSE)
    }

    writeLines(body, path)
    f_write_fetch_log(
      dir          = dir_census_cache,
      source       = "census_api",
      resource     = basename(path),
      retrieved_at = retrieved_at,
      source_url   = url_without_key,
      outcome      = outcome,
      refresh      = refresh,
      extra        = list(dataset = dataset, geo = geo, http_status = status)
    )
  }

  out <- f_census_parse(body)
  if (nrow(out) == 0) {
    return(out)
  }
  out |>
    select(-any_of(census_geo_cols)) |>
    mutate(geo = geo, .before = 1)
}

# Run one query at every study geography and row-bind. `resource_stem`
# gets "_<geo>" (and any `suffix`) appended to name each cache file.
f_census_query_geos <- function(dataset, get, resource_stem, ..., suffix = NULL,
                                geos = names(census_geos), refresh = FALSE) {
  bind_rows(lapply(geos, function(g) {
    f_census_query(dataset, get, g,
                   resource = paste(c(resource_stem, g, suffix), collapse = "_"),
                   ..., refresh = refresh)
  }))
}
