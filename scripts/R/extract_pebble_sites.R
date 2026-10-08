# Stage 1 of the Pebble site-extraction pipeline.
#
# Parses the 2008 cumulative station-location tables from the Pebble Project
# Environmental Baseline Document, Appendix F (field sampling plans):
#   - Table 3 (p. 1011): "Surface Hydrology and Water-quality Stream Station
#     Locations, 2008" -- stream sites, Mine Study Area
#   - Table 4 (p. 1012): "Seep Sampling Locations, 2008" -- seep sites
#
# These two pages were identified by manual document review as the most
# complete, self-contained station-coordinate table in the source PDF (see
# AGENTS.md, "Findings from document investigation"). No equivalent table was
# found for the Road/Port transportation corridor; coverage there is
# unconfirmed and out of scope for this script.
#
# Output: a candidate site CSV (site_id, longitude, latitude, type, source
# page) to be spatially filtered to the Nushagak HUC8s by
# filter_pebble_by_huc8.R (Stage 2).

library(pdftools)

pdf_path <- "other/input/pebble/appx_f_field_sampling_plans.pdf"
out_path <- "other/output/pebble_candidate_sites.csv"

stopifnot(file.exists(pdf_path))

# Pull just the two known pages rather than the full 1,032-page document.
pages <- pdf_text(pdf_path)[1011:1012]
names(pages) <- c("1011", "1012")

#' Parse station rows out of a Table 3/4-style page.
#'
#' Each data row is: Station ID, DMM longitude, DMM latitude, DD longitude,
#' DD latitude -- all on one line. We only need the ID and the two trailing
#' decimal-degree values (already converted in the source table), which are
#' the two tokens at the end of the line.
parse_station_lines <- function(page_text, type) {
  lines <- strsplit(page_text, "\n")[[1]]
  row_pattern <- "^\\s*([A-Z0-9]+)\\s+.*?(-?\\d{2,3}\\.\\d+)\\s+(\\d{2}\\.\\d+)\\s*$"
  hits <- grep(row_pattern, lines, value = TRUE)
  m <- regmatches(hits, regexec(row_pattern, hits))
  rows <- lapply(m, function(x) {
    data.frame(
      site_id = x[2],
      longitude = as.numeric(x[3]),
      latitude = as.numeric(x[4]),
      type = type,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

streams <- parse_station_lines(pages[["1011"]], "stream")
seeps <- parse_station_lines(pages[["1012"]], "seep")

sites <- rbind(streams, seeps)
sites$source_pdf <- "appx_f_field_sampling_plans.pdf"
sites$source_page <- c(rep(1011, nrow(streams)), rep(1012, nrow(seeps)))
sites$source_table <- c(
  rep("Table 3: Surface Hydrology and Water-quality Stream Station Locations, 2008", nrow(streams)),
  rep("Table 4: Seep Sampling Locations, 2008", nrow(seeps))
)

stopifnot(
  !anyNA(sites$longitude),
  !anyNA(sites$latitude),
  all(sites$longitude < 0),   # western hemisphere
  all(sites$latitude > 0)     # northern hemisphere
)

dir.create("other/output", showWarnings = FALSE, recursive = TRUE)
write.csv(sites, out_path, row.names = FALSE)

message(sprintf(
  "Wrote %d candidate sites (%d stream, %d seep) to %s",
  nrow(sites), nrow(streams), nrow(seeps), out_path
))
