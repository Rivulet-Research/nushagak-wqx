#!/usr/bin/env Rscript
# Stage 5: join Pebble Project chemistry records to their confirmed
# Nushagak-watershed site coordinates, and summarize each site's sampling
# record for use as a map popup.
#
# Part of the Nushagak WQX book's reproducible data pipeline. See
# scripts/README.md and chapters/03_spatial_coverage.qmd for the full
# documented workflow.
#
# Inputs:
#   other/output/pebble_nushagak_confirmed_sites.csv (Stage 2 output)
#     Columns: station_id, lon, lat, type, source_pdf, source_page,
#     source_table, huc8, huc8_name.
#   other/output/pebble_chemistry_long.csv (Stage 4 output)
#     Columns: site_id, date, parameter, unit, value, label_corrected,
#     source_page.
#
# Output:
#   other/output/pebble_sites_chemistry_summary.csv - one row per confirmed
#     site with its coordinates plus sampling-record summary stats
#     (n_samples, n_parameters, date_min, date_max). Sites with no matching
#     chemistry records (e.g. seeps not covered in ch_09) keep NA summary
#     columns and are flagged in console output, but are still written out
#     so the map can show the full confirmed-site set.
#
# Usage:
#   Rscript scripts/R/join_pebble_sites_chemistry.R

library(dplyr)

sites_csv <- "other/output/pebble_nushagak_confirmed_sites.csv"
chem_csv <- "other/output/pebble_chemistry_long.csv"
out_csv <- "other/output/pebble_sites_chemistry_summary.csv"

if (!file.exists(sites_csv)) {
  stop(
    "Expected confirmed sites file not found: ", sites_csv, "\n",
    "Run scripts/R/filter_pebble_by_huc8.R first."
  )
}
if (!file.exists(chem_csv)) {
  stop(
    "Expected chemistry file not found: ", chem_csv, "\n",
    "Run scripts/R/parse_pebble_chemistry.R first."
  )
}

sites <- read.csv(sites_csv, stringsAsFactors = FALSE)
chem <- read.csv(chem_csv, stringsAsFactors = FALSE)

chem_dates <- as.Date(chem$date, format = "%m/%d/%y")
if (any(is.na(chem_dates) & !is.na(chem$date))) {
  message(
    sum(is.na(chem_dates) & !is.na(chem$date)),
    " chemistry record(s) have a date that failed to parse as %m/%d/%y; ",
    "excluded from date-range summary but still counted toward n_samples/n_parameters."
  )
}
chem$date_parsed <- chem_dates

chem_summary <- chem %>%
  group_by(site_id) %>%
  summarize(
    n_samples = n_distinct(date),
    n_parameters = n_distinct(parameter),
    n_results = n(),
    date_min = suppressWarnings(min(date_parsed, na.rm = TRUE)),
    date_max = suppressWarnings(max(date_parsed, na.rm = TRUE)),
    .groups = "drop"
  )

joined <- sites %>%
  left_join(chem_summary, by = c("station_id" = "site_id"))

write.csv(joined, out_csv, row.names = FALSE)

unmatched <- joined %>% filter(is.na(n_samples))
message(
  nrow(joined) - nrow(unmatched), " of ", nrow(joined),
  " confirmed site(s) matched to chemistry records."
)
if (nrow(unmatched) > 0) {
  message(
    "No chemistry records found for: ",
    paste(unmatched$station_id, collapse = ", ")
  )
}
message("Joined summary written to: ", out_csv)
