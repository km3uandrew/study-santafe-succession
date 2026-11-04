# scratch/<slug>.R — one exploratory question per file
#
# Question:   TODO — what are we trying to learn?
# Started:    YYYY-MM-DD
# Data years: TODO — every output states its data year (owner age 2023;
#             firm age 2022)
#
# Copy this template to scratch/<slug>.R to start a new question. Scratch
# copies are not committed (only this template and FINDINGS.md are). Log
# unpromoted questions in docs/FINDINGS.md.

source("scripts/00_setup.R")

# Read data through the cached Census helper — f_census_query() or
# f_census_query_geos() in 00_setup.R, with the same `get` list, filters,
# and resource name as 01_pull_census.R so the call is a cache hit.
df <- NULL # TODO

# ── Raw-data plot(s) ──────────────────────────────────────────────────────────
# Plot the raw data before choosing any statistical tool. Keep
# f_theme_chalkboard(); skip only content polish. Every exploratory figure
# carries its question as the subtitle. Save with f_ggsave_chalkboard().
# library(ggplot2)
# p_raw <- ggplot(df, aes()) + # TODO
#   f_labs_chalkboard(x = "TODO", y = "TODO", subtitle = "TODO — the question?") +
#   f_theme_chalkboard()
# f_ggsave_chalkboard(file.path(dir_scratch_figs, "TODO-slug_raw.png"),
#                     p_raw, width = 10, height = 6)

# ---- STOP: review raw plots before computing any downstream measure ----
# The exploratory gate (chalkboard.eda docs/conventions.md): the user
# reviews these plots. Describing the data's character and proposing
# measures happen in Chat. Nothing below this line is computed until
# approved.
