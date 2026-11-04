# 01_pull_census.R — pull (or read from cache) every Census table the study uses
#
# Question:  none of its own — this is the study's data acquisition step.
#            It fills data/census_cache/ and prints what came back.
# Started:   2026-11-03 (promoted from the feasibility session's pull.R)
#
# Data years: owner age ABS reference year 2023 (headline; Census's "2024
# ABS") and reference year 2022 (consistency check, never pooled; the
# "2023 ABS"); NES-D 2023; firm age BDS 2022. All industries combined:
# county and metro owner age is published for all industries only.
#
# Re-running is offline once the cache is full: f_census_query() reads
# a cached response and appends nothing to the fetch log. Pass
# refresh = TRUE to a call to re-fetch it (and append a new record).
#
# Every pull filters by question code (QDESC), never by label and never
# unfiltered: label filters return HTTP 204 and unfiltered ABS pulls
# truncate silently (docs/data.md, API quirks).

source("scripts/00_setup.R")

# ── ABS: Characteristics of Business Owners (employer firms) ──────────────────
# O09 = owner age (OWNRAGE). O02 and O05 are carried over from the
# feasibility pull (two further owner characteristics it scoped) so the
# cache keeps every response that session examined; nothing reads them yet.
# "All owners" on the demographic filters is 001, except race, which is 00.
abs_get <- c("NAME", "YEAR", "QDESC", "QDESC_LABEL", "OWNCHAR", "OWNCHAR_LABEL",
             "NAICS2022", "NAICS2022_LABEL", "INDLEVEL",
             "OWNPDEMP", "OWNPDEMP_F", "OWNPDEMP_S", "OWNPDEMP_S_F",
             "OWNPDEMP_PCT", "OWNPDEMP_PCT_F", "OWNPDEMP_PCT_S", "OWNPDEMP_PCT_S_F")

f_pull_abs <- function(year, qdesc) {
  f_census_query_geos(
    paste0(year, "/abscbo"), abs_get,
    resource_stem = paste0("abscbo_", year), suffix = qdesc,
    QDESC = qdesc, OWNER_SEX = "001", OWNER_ETH = "001",
    OWNER_RACE = "00", OWNER_VET = "001"
  ) |>
    mutate(abs_year = year, .after = geo)
}

abs_headline <- bind_rows(lapply(c("O09", "O02", "O05"),
                                 function(q) f_pull_abs(abs_year_headline, q)))
abs_check    <- f_pull_abs(abs_year_check, "O09")

# ── NES-D: owner age, nonemployer firms ───────────────────────────────────────
# "All owners" on every demographic filter is 000 here, not 001.
nesd_get <- c("NAME", "YEAR", "QDESC", "QDESC_LABEL", "OWNCHAR", "OWNCHAR_LABEL",
              "NAICS2022", "NAICS2022_LABEL", "INDLEVEL",
              "OWNNOPD", "OWNNOPD_F", "OWNNOPD_PCT", "OWNNOPD_PCT_F")

nesd <- f_census_query_geos(
  paste0(nesd_year, "/absnesdo"), nesd_get,
  resource_stem = paste0("absnesdo_", nesd_year), suffix = "O09",
  QDESC = "O09", OWNER_SEX = "000", OWNER_ETH = "000",
  OWNER_RACE = "000", OWNER_VET = "000"
)

# ── BDS: firms and employment by firm age (and sector) ────────────────────────
bds_get <- c("NAME", "FAGE", "FAGE_LABEL", "NAICS", "NAICS_LABEL",
             "FIRM", "FIRM_F", "ESTAB", "ESTAB_F", "EMP", "EMP_F")

bds <- f_census_query_geos(
  "timeseries/bds", bds_get,
  resource_stem = paste0("bds_", bds_year),
  time = as.character(bds_year)
)

# ── What came back ────────────────────────────────────────────────────────────
cat("\nRows returned, by table and geography:\n")
bind_rows(
  abs_headline |> count(table = paste0("ABS ref ", abs_year_headline, " ", QDESC), geo),
  abs_check    |> count(table = paste0("ABS ref ", abs_year_check, " O09"), geo),
  nesd         |> count(table = paste0("NES-D ", nesd_year, " O09"), geo),
  bds          |> count(table = paste0("BDS ", bds_year), geo)
) |>
  pivot_wider(names_from = geo, values_from = n) |>
  print()

# Suppression flags present, by table (docs/data.md, Suppression).
cat("\nRows carrying a suppression or noise flag (any *_F column non-missing):\n")
flagged <- function(df) {
  f_cols <- grep("_F$", names(df), value = TRUE)
  df |>
    filter(if_any(all_of(f_cols), ~ !is.na(.x))) |>
    nrow()
}
tibble(
  table   = c(paste("ABS ref", abs_year_headline), paste("ABS ref", abs_year_check),
              paste("NES-D", nesd_year), paste("BDS", bds_year)),
  flagged = c(flagged(abs_headline), flagged(abs_check), flagged(nesd), flagged(bds)),
  rows    = c(nrow(abs_headline), nrow(abs_check), nrow(nesd), nrow(bds))
) |>
  print()

# ── Integrity checks ──────────────────────────────────────────────────────────
# 1. County and metro share one footprint: every BDS value they both
#    publish should match exactly.
bds_cm <- bds |>
  filter(geo %in% c("county", "metro")) |>
  select(geo, FAGE, NAICS, FIRM, ESTAB, EMP) |>
  pivot_wider(names_from = geo, values_from = c(FIRM, ESTAB, EMP))
shared <- bds_cm |> filter(!is.na(FIRM_county), !is.na(FIRM_metro))
cat(sprintf(
  "\nBDS county vs metro: %d cells published by both; %d differ.\n",
  nrow(shared),
  sum(shared$FIRM_county != shared$FIRM_metro |
      shared$ESTAB_county != shared$ESTAB_metro |
      shared$EMP_county != shared$EMP_metro)
))

# 2. Decision 1 compares 11+ at every geography. The state and U.S. publish
#    finer bins (11-15, 16-20, 21-25, 26+); check whether they also publish
#    11+ directly (FAGE 075) and whether it equals the sum of the finer bins.
cat("\nBDS 11+ (FAGE 075) vs sum of 11-15/16-20/21-25/26+ (080/090/100/110), all sectors:\n")
bds |>
  filter(NAICS == "00", geo %in% c("nm", "us")) |>
  mutate(across(c(FIRM, EMP), as.numeric)) |>
  group_by(geo) |>
  summarize(
    firm_075      = sum(FIRM[FAGE == "075"]),
    firm_finer    = sum(FIRM[FAGE %in% c("080", "090", "100", "110")]),
    emp_075       = sum(EMP[FAGE == "075"]),
    emp_finer     = sum(EMP[FAGE %in% c("080", "090", "100", "110")]),
    .groups = "drop"
  ) |>
  print()
