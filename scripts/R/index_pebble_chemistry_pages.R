# Stage 3 of the Pebble site-extraction pipeline.
#
# ch_09_water_quality_bb.pdf (Chapter 9.1, "Water Quality-Bristol Bay
# Drainages") is 2,247 pages and holds the actual chemistry data, keyed by
# the same site-ID scheme as the field sampling plan (e.g. SK100B, NK100A).
# This script:
#   1. Extracts (and caches) the full text layer once, since re-extraction
#      takes ~25s and is wasteful to repeat on every run.
#   2. Builds a site_id -> page number index, restricted to the 37 sites
#      confirmed within the Nushagak HUC8s (Stage 2 output), so Stage 4 only
#      has to open and parse chemistry tables on the handful of flagged
#      pages, not scan the whole document.
#
# Input:
#   other/input/pebble/ch_09_water_quality_bb.pdf
#   other/output/pebble_nushagak_confirmed_sites.csv (Stage 2 output)
#
# Output:
#   other/output/ch09_fulltext_cache.rds (gitignored; cached page-text vector)
#   other/output/pebble_site_chemistry_page_index.csv -- site_id, page,
#     num_mentions_on_page

library(pdftools)
library(dplyr)

pdf_path <- "other/input/pebble/ch_09_water_quality_bb.pdf"
confirmed_csv <- "other/output/pebble_nushagak_confirmed_sites.csv"
cache_path <- "other/output/ch09_fulltext_cache.rds"
index_csv <- "other/output/pebble_site_chemistry_page_index.csv"

stopifnot(file.exists(pdf_path), file.exists(confirmed_csv))

if (file.exists(cache_path)) {
  message("Loading cached full-text extraction: ", cache_path)
  pages <- readRDS(cache_path)
} else {
  message("Extracting full text from ", pdf_path, " (one-time, ~25s)...")
  pages <- pdf_text(pdf_path)
  saveRDS(pages, cache_path)
}

confirmed <- read.csv(confirmed_csv, stringsAsFactors = FALSE)
site_ids <- unique(confirmed$station_id)

# Literal, exact-ID matching (not keyword guessing) -- word-boundary match
# per site ID, counted per page.
index <- lapply(site_ids, function(id) {
  pattern <- paste0("\\b", id, "\\b")
  hits <- vapply(pages, function(p) length(gregexpr(pattern, p)[[1]][gregexpr(pattern, p)[[1]] > 0]), integer(1))
  pg <- which(hits > 0)
  if (length(pg) == 0) return(NULL)
  data.frame(site_id = id, page = pg, num_mentions_on_page = hits[pg], row.names = NULL)
})

index <- bind_rows(index)
write.csv(index, index_csv, row.names = FALSE)

sites_found <- length(unique(index$site_id))
message(sprintf(
  "%d of %d confirmed sites found in ch_09 text (%d page hits total). Index: %s",
  sites_found, length(site_ids), nrow(index), index_csv
))

missing <- setdiff(site_ids, unique(index$site_id))
if (length(missing) > 0) {
  message("Sites with no hits in ch_09 (may use a naming variant): ", paste(missing, collapse = ", "))
}

# --- Stage 3b: narrow raw page hits down to actual chemistry data-table
# pages. Most of the 1,322 raw hits above are incidental (narrative text,
# figure captions, cross-reference tables), not data tables. Validated
# heuristic: on an actual data-table page, the site ID is immediately
# followed (next line) by "Sample Date" -- this collapses dozens-to-hundreds
# of candidate pages per site down to the 3-4 pages that hold its real data
# (e.g. SK100B: 76 candidates -> pages 588-590). Restricting the regex scan
# to each site's already-identified candidate pages (not the full document)
# keeps this fast.
table_pages_csv <- "other/output/pebble_site_chemistry_table_pages.csv"

table_pages <- lapply(split(index, index$site_id), function(df) {
  id <- df$site_id[1]
  pattern <- paste0(id, "\\s*\\n\\s*Sample Date")
  hit <- vapply(df$page, function(pg) grepl(pattern, pages[pg]), logical(1))
  if (!any(hit)) return(NULL)
  data.frame(site_id = id, page = df$page[hit], row.names = NULL)
})
table_pages <- bind_rows(table_pages)
write.csv(table_pages, table_pages_csv, row.names = FALSE)

sites_with_tables <- length(unique(table_pages$site_id))
message(sprintf(
  "%d of %d confirmed sites have identifiable data-table pages (%d pages total, down from %d raw hits). Index: %s",
  sites_with_tables, length(site_ids), nrow(table_pages), nrow(index), table_pages_csv
))

no_table_pages <- setdiff(site_ids, unique(table_pages$site_id))
if (length(no_table_pages) > 0) {
  message("Sites with raw hits but no identifiable data-table page (needs manual check): ", paste(no_table_pages, collapse = ", "))
}


# Known site-ID renames: the 2008 field sampling plan (Appendix F, Stage 1/2
# source) and ch_09 (chemistry data) use different IDs for two confirmed
# sites. ch_09 states explicitly (p. 849 of the PDF): "SK100I and SK100H were
# previously known as SK136B and SK136A respectively." Map their data-table
# pages under the ch_09 names, but keep the Stage 2 (field-plan) ID in
# site_id so downstream joins to the confirmed-sites table still work.
site_renames <- c(SK136A = "SK100H", SK136B = "SK100I")
renamed_table_pages <- lapply(names(site_renames), function(old_id) {
  new_id <- site_renames[[old_id]]
  pattern <- paste0(new_id, "\\s*\\n\\s*Sample Date")
  pg <- which(grepl(pattern, pages))
  if (length(pg) == 0) return(NULL)
  data.frame(site_id = old_id, page = pg, row.names = NULL)
})
renamed_table_pages <- bind_rows(renamed_table_pages)
if (nrow(renamed_table_pages) > 0) {
  table_pages <- bind_rows(table_pages, renamed_table_pages)
  write.csv(table_pages, table_pages_csv, row.names = FALSE)
  message(sprintf(
    "Resolved %d renamed site(s) via known ch_09 alias (%s) -- %d additional pages added.",
    length(unique(renamed_table_pages$site_id)), paste(site_renames, collapse = ", "), nrow(renamed_table_pages)
  ))
}
