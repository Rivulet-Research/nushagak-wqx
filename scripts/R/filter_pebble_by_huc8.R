#!/usr/bin/env Rscript
# Filter Pebble Project monitoring sites to those within the Nushagak River
# drainage, using actual HUC8 polygon boundaries rather than keyword matching.
#
# Part of the Nushagak WQX book's reproducible data pipeline. See
# scripts/README.md and chapters/02_data_sources.qmd for the full documented
# workflow. Runs entirely locally; no coordinates or site data are sent to
# any AI model.
#
# Inclusion rule (per project notes, 10/5/2026): a Pebble monitoring site is
# retained only if its coordinates fall within one of the four HUC8
# sub-basins that drain into the Nushagak River (19030301-19030304). HUC8
# 19030305 (Togiak River) drains separately into Bristol Bay and is excluded,
# consistent with chapters/03_spatial_coverage.qmd.
#
# Input:
#   other/input/pebble/pebble_site_coordinates.csv (gitignored; user-created)
#   Columns: station_id, lat, lon, source_pdf, page, notes
#   See scripts/R/pebble_site_coordinates_template.csv for the expected format.
#   Populate this file by hand after reviewing the tables flagged by
#   scripts/python/extract_pebble_nushagak.py (station coordinates are
#   usually listed in a separate station-location table in the source PDF,
#   not inline with the results table).
#
# Output:
#   other/output/pebble_sites_huc8_check.csv - every input site, with the
#     HUC8 it falls in (NA if outside all four)
#   other/output/pebble_nushagak_confirmed_sites.csv - only sites confirmed
#     within the four HUC8s; this is the file later chapters should read
#
# Usage:
#   Rscript scripts/R/filter_pebble_by_huc8.R

library(sf)
library(dplyr)
library(nhdplusTools)

nushagak_hucs <- c("19030301", "19030302", "19030303", "19030304")

input_csv <- "other/input/pebble/pebble_site_coordinates.csv"
boundary_cache <- "other/output/nushagak_huc8_boundary.gpkg"
check_csv <- "other/output/pebble_sites_huc8_check.csv"
confirmed_csv <- "other/output/pebble_nushagak_confirmed_sites.csv"

if (!file.exists(input_csv)) {
  stop(
    "Expected coordinates file not found: ", input_csv, "\n",
    "Create it from scripts/R/pebble_site_coordinates_template.csv first."
  )
}

dir.create(dirname(boundary_cache), recursive = TRUE, showWarnings = FALSE)

# Cache the boundary locally so repeat runs don't re-hit the WBD web service
if (file.exists(boundary_cache)) {
  huc8_boundary <- st_read(boundary_cache, quiet = TRUE)
} else {
  message("Fetching HUC8 boundaries from USGS WBD...")
  huc8_boundary <- get_huc(id = nushagak_hucs, type = "huc08")
  st_write(huc8_boundary, boundary_cache, quiet = TRUE)
}

sites <- read.csv(input_csv, stringsAsFactors = FALSE)

missing_coords <- is.na(sites$lat) | is.na(sites$lon)
if (any(missing_coords)) {
  message(
    sum(missing_coords), " site(s) have missing coordinates and cannot be ",
    "spatially checked; they will be excluded. Review source PDFs for: ",
    paste(sites$station_id[missing_coords], collapse = ", ")
  )
}

sites_sf <- sites %>%
  filter(!missing_coords) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = FALSE)

# st_within is strict containment; st_intersects would also catch points
# exactly on a shared sub-basin boundary line, which matters little here
# given coordinate precision in printed PDF tables
joined <- st_join(sites_sf, huc8_boundary[, c("huc8", "name")], join = st_within)

result <- joined %>%
  st_drop_geometry() %>%
  rename(huc8_name = name)

write.csv(result, check_csv, row.names = FALSE)

confirmed <- result %>% filter(!is.na(huc8))
write.csv(confirmed, confirmed_csv, row.names = FALSE)

message(
  "\n", nrow(confirmed), " of ", nrow(sites),
  " site(s) fall within the four Nushagak HUC8s."
)
message("Full check results: ", check_csv)
message("Confirmed Nushagak sites: ", confirmed_csv)

excluded <- result %>% filter(is.na(huc8))
if (nrow(excluded) > 0) {
  message(
    "\nExcluded (outside the four Nushagak HUC8s): ",
    paste(excluded$station_id, collapse = ", ")
  )
}
