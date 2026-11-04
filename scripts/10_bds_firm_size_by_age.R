# 10_bds_firm_size_by_age.R — is firm age crossed with firm size published locally?
#
# Question:  Does Business Dynamics Statistics (BDS) publish firm age
#            crossed with firm employment size (EMPSZFI) for Santa Fe
#            County or the Santa Fe metro? If so, a small-firm restriction
#            could stand in for "locally owned" in the firm-age figures
#            (docs/current-work.md, Prior art: the "locally owned" proxy).
# Started:   2026-11-03
#
# Data year: BDS 2022.
#
# Two probes per geography, so the answer does not rest on one query
# shape:
#   A. FAGE=* and EMPSZFI=* together — returns every published cell. A
#      cross is published only if some row has a specific age AND a
#      specific size (neither code 001, "all").
#   B. One explicit cross cell, FAGE 075 (11+ years) by EMPSZFI 635
#      (1 to 19 employees) — the API answers HTTP 204 (cached as an empty
#      response) when the cell is not published.
#
# Also printed: which size classes each geography publishes at all, since
# any small-firm cutoff has to be drawn from those.

source("scripts/00_setup.R")

probe_get <- c("FAGE", "FAGE_LABEL", "EMPSZFI", "EMPSZFI_LABEL", "FIRM", "FIRM_F", "EMP", "EMP_F")

probe_a <- f_census_query_geos(
  "timeseries/bds", probe_get,
  resource_stem = paste0("bds_", bds_year, "_fage_by_empszfi"),
  time = as.character(bds_year), FAGE = "*", EMPSZFI = "*"
)

probe_b <- lapply(names(census_geos), function(g) {
  out <- f_census_query(
    "timeseries/bds", probe_get, g,
    resource = paste0("bds_", bds_year, "_fage075_empszfi635_", g),
    time = as.character(bds_year), FAGE = "075", EMPSZFI = "635"
  )
  tibble(geo = g, explicit_cell_rows = nrow(out))
}) |>
  bind_rows()

# ── Answer ────────────────────────────────────────────────────────────────────
answer <- probe_a |>
  group_by(geo) |>
  summarize(
    cross_cells       = sum(FAGE != "001" & EMPSZFI != "001"),
    age_classes       = n_distinct(FAGE[FAGE != "001"]),
    size_classes      = n_distinct(EMPSZFI[EMPSZFI != "001"]),
    .groups = "drop"
  ) |>
  left_join(probe_b, by = "geo") |>
  mutate(cross_published = cross_cells > 0 & explicit_cell_rows > 0) |>
  arrange(match(geo, names(census_geos)))

cat("\nFirm age x firm size, BDS", bds_year, "— published cross cells by geography:\n")
print(answer)

# ── Size classes available at each geography (all ages) ──────────────────────
cat("\nFirm employment-size classes published (all firm ages):\n")
probe_a |>
  filter(FAGE == "001", EMPSZFI != "001") |>
  distinct(geo, EMPSZFI, EMPSZFI_LABEL) |>
  arrange(EMPSZFI) |>
  mutate(present = "x") |>
  pivot_wider(id_cols = c(EMPSZFI, EMPSZFI_LABEL), names_from = geo,
              values_from = present, values_fill = "") |>
  print(n = Inf)
