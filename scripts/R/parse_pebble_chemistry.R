# Stage 4 of the Pebble site-extraction pipeline.
#
# Parses the actual chemistry data tables on the pages flagged by Stage 3
# (other/output/pebble_site_chemistry_table_pages.csv) into a tidy long
# format: one row per site/date/parameter/value.
#
# Why pdf_data() instead of pdf_text(): these are wide multi-column tables
# with wrapped, stacked headers (a parameter name spans 2-3 lines, its unit
# on a separate line) and rows with missing values that break simple
# whitespace/line-based parsing. pdf_data() returns word-level bounding boxes
# (x, y, width, height, text), which lets the parser reconstruct rows and
# columns from word position rather than guessing at whitespace alignment.
#
# Two physical table layouts are both handled by the same parser:
#   - Stream tables: one site's data per page block (3 pages/site: general
#     chemistry, then two pages of metals).
#   - Seep tables: multiple sites' data stacked on the same page when each
#     site's block is short (4 pages/site, but pages are shared across
#     sites) -- parse_chem_table_page() splits a page into per-site blocks
#     using the "Sample" + "Date" header that precedes each site's rows.
#
# Known source-document defect (see project AGENTS.md "In-progress work"
# notes): every seep table's general-chemistry page reuses the stream
# template's second "Field Water Temperature" header for what is actually a
# Turbidity (NTU) column -- temperature is never reported in NTU. Confirmed
# systematic across multiple seep sites (SP112, SP41, ...), not a one-off
# OCR glitch. The parser relabels any column whose header contains
# "Temperature" but whose unit is NTU to "Turbidity", and flags the
# correction in `label_corrected` so it's auditable rather than silent.
#
# Two further parsing fixes (found while validating at scale, both about
# header-to-column assignment, not the data values themselves):
#   - Merged Total/Dissolved sub-columns: a parent label (e.g. a metal name)
#     visually spans both of its Total/Dissolved sub-columns, but
#     nearest-point assignment only attributes it to one, leaving the other
#     a bare "Total"/"Dissolved" with no parent name. Fixed by backfilling
#     the parent name from the immediate left-neighbor column.
#   - Orphaned header labels: a parameter with no data at a given site can
#     still print a header label with no matching unit-row token (no column
#     of its own), which otherwise bleeds into a neighboring column's label.
#     Fixed by dropping header words further than max_label_dist from every
#     column center.
#
# Input:
#   other/input/pebble/ch_09_water_quality_bb.pdf
#   other/output/pebble_site_chemistry_table_pages.csv (Stage 3 output)
#
# Output:
#   other/output/pebble_chemistry_long.csv -- site_id, date, parameter, unit,
#     value, label_corrected, source_page

library(pdftools)
library(dplyr)

pdf_path <- "other/input/pebble/ch_09_water_quality_bb.pdf"
table_pages_csv <- "other/output/pebble_site_chemistry_table_pages.csv"
out_csv <- "other/output/pebble_chemistry_long.csv"

stopifnot(file.exists(pdf_path), file.exists(table_pages_csv))

# --- Reconstruct visual table rows from word-level data ---------------------
# pdf_data() returns one row per word with its (x, y) position. Sort by
# (y, x) and start a new row whenever y jumps by more than y_tol, since words
# on the same printed line share (approximately) the same y.
assemble_lines <- function(wd, y_tol = 2) {
  wd <- arrange(wd, y, x)
  wd$row_id <- cumsum(c(1, diff(wd$y) > y_tol))
  wd
}

# --- Parse one page of a chemistry table into tidy long rows ----------------
parse_chem_table_page <- function(wd) {
  sl <- assemble_lines(wd, y_tol = 2)

  unit_like <- function(tok) grepl("^(°C|pH|mg/L|%|mS/cm|mV|μmhos/cm|μg/L|NTU|uS/cm|Units|mg/kg|lbs/day)$", tok)
  row_stats <- summarise(group_by(sl, row_id), y = min(y), n_unit = sum(unit_like(text)), n = n())
  # The units row is the anchor: it has exactly one token per data column.
  unit_row_id <- row_stats$row_id[which.max(row_stats$n_unit)]

  # "Total/Dissolved" marks the right edge of the row-label columns (site ID,
  # sample date); data columns start just after it.
  label_row <- filter(sl, grepl("Total/Dissolved", text))
  data_start_x <- if (nrow(label_row) > 0) min(label_row$x + label_row$width) + 3 else 171

  header_block <- filter(sl, row_id >= 2, row_id <= unit_row_id, x >= data_start_x)
  unit_tokens <- arrange(filter(header_block, row_id == unit_row_id), x)
  if (nrow(unit_tokens) == 0) return(NULL)

  # Cluster unit-row tokens into columns by x-gap; each cluster is one column.
  gaps <- c(0, diff(unit_tokens$x))
  unit_tokens$col_group <- cumsum(gaps > 15)
  col_anchors <- summarise(group_by(unit_tokens, col_group), x_center = mean(x), unit = paste(text, collapse = " "))

  nearest_dist <- function(x) min(abs(col_anchors$x_center - x))
  assign_col <- function(x) col_anchors$col_group[which.min(abs(col_anchors$x_center - x))]

  # A column with no real data (e.g. a parameter never sampled at this site)
  # can still print a header label with no corresponding unit-row token, so
  # it has no column of its own. Nearest-column assignment would otherwise
  # bleed those orphaned header words into an unrelated neighboring column's
  # label (observed: Turbidity's header text bleeding into an adjacent ORP
  # column on pages where turbidity was never sampled). Drop header words
  # sitting further than max_label_dist from every column center instead of
  # force-assigning them.
  max_label_dist <- 25
  header_only <- filter(header_block, row_id < unit_row_id)
  header_only$dist <- sapply(header_only$x, nearest_dist)
  header_only <- filter(header_only, dist <= max_label_dist)
  header_only$col_group <- sapply(header_only$x, assign_col)

  # Build each column's label by concatenating header words above the unit
  # row, in row order, within that column group.
  labels <- summarise(
    group_by(arrange(header_only, col_group, row_id), col_group),
    label = paste(text, collapse = " ")
  )
  labels$label <- trimws(gsub("\\s*\\([0-9,]+\\)\\s*", " ", labels$label))

  col_schema <- left_join(col_anchors, labels, by = "col_group")
  col_schema <- arrange(col_schema, col_group)

  # A parent header word (e.g. a metal name) that visually spans a merged
  # Total/Dissolved sub-column pair gets nearest-point-assigned to only one
  # of the two, orphaning the other with a bare "Total"/"Dissolved" label and
  # no parent name. Backfill: when a column's label is exactly "Total" or
  # "Dissolved" and its immediate left-neighbor column's label ends in the
  # other of that pair, prefix the neighbor's parent name onto this column.
  for (i in seq_len(nrow(col_schema))) {
    lbl <- col_schema$label[i]
    if (!is.na(lbl) && lbl %in% c("Total", "Dissolved") && i > 1) {
      left_lbl <- col_schema$label[i - 1]
      other <- if (lbl == "Total") "Dissolved" else "Total"
      if (!is.na(left_lbl) && grepl(paste0("\\b", other, "\\b"), left_lbl)) {
        parent <- trimws(sub(paste0("\\s*\\b", other, "\\b\\s*"), " ", left_lbl))
        col_schema$label[i] <- trimws(paste(parent, lbl))
      }
    }
  }

  # Source-document defect fix (see header comment): relabel mislabeled
  # Temperature/NTU columns as Turbidity, flagged for auditability.
  mislabel <- grepl("Temperature", col_schema$label, ignore.case = TRUE) & col_schema$unit == "NTU"
  col_schema$label_corrected <- mislabel
  col_schema$label[mislabel] <- "Turbidity"

  # Each site's data block on the page is preceded by a "Sample" / "Date"
  # header line; seep pages can stack several site blocks on one page.
  sd_row_ids <- unique(pull(
    inner_join(
      filter(sl, row_id > unit_row_id, text == "Date"),
      filter(sl, text == "Sample"),
      by = "row_id", suffix = c("_date", "_sample")
    ),
    row_id
  ))
  if (length(sd_row_ids) == 0) return(NULL)

  block_bounds <- data.frame(sd_row = sort(sd_row_ids), next_sd_row = c(sort(sd_row_ids)[-1], Inf))

  all_rows <- lapply(seq_len(nrow(block_bounds)), function(i) {
    sd_row <- block_bounds$sd_row[i]
    end_row <- block_bounds$next_sd_row[i]

    site_id_candidates <- filter(
      sl, row_id < sd_row, row_id > unit_row_id, x < data_start_x,
      grepl("^[A-Z]{2,3}[0-9]+[A-Z0-9]*$", text)
    )
    if (nrow(site_id_candidates) == 0) return(NULL)
    site_id <- site_id_candidates$text[nrow(site_id_candidates)]

    data_rows <- filter(sl, row_id > sd_row, row_id < end_row, grepl("^\\d{2}/\\d{2}/\\d{2,4}", text))
    if (nrow(data_rows) == 0) return(NULL)

    res <- lapply(unique(data_rows$row_id), function(rid) {
      row <- arrange(filter(sl, row_id == rid), x)
      date_tok <- row$text[1]
      vals <- row[-1, ]
      if (nrow(vals) == 0) return(NULL)
      vals$col_group <- sapply(vals$x, assign_col)
      vals <- left_join(vals, col_schema[, c("col_group", "label", "unit", "label_corrected")], by = "col_group")
      data.frame(
        site_id = site_id, date = date_tok, parameter = vals$label, unit = vals$unit,
        value = vals$text, label_corrected = vals$label_corrected
      )
    })
    bind_rows(res)
  })

  bind_rows(all_rows)
}

# --- Driver: parse every flagged page once, then filter to confirmed sites --

table_pages <- read.csv(table_pages_csv, stringsAsFactors = FALSE)

# ch_09 uses post-rename IDs (SK100H/SK100I) for two sites that the Stage 2
# confirmed-sites table lists under their original field-plan IDs
# (SK136A/SK136B, see Stage 3). Parse pages under the ch_09 ID actually
# printed on the page, then map back to the field-plan ID for output.
ch09_to_field_plan_id <- c(SK100H = "SK136A", SK100I = "SK136B")

unique_pages <- sort(unique(table_pages$page))
message(sprintf("Parsing %d unique chemistry data-table pages...", length(unique_pages)))

parsed <- lapply(unique_pages, function(pg) {
  tmp <- tempfile(fileext = ".pdf")
  on.exit(unlink(tmp), add = TRUE)
  pdf_subset(pdf_path, pages = pg, output = tmp)
  wd <- pdf_data(tmp)[[1]]
  result <- tryCatch(parse_chem_table_page(wd), error = function(e) {
    message("  Failed to parse page ", pg, ": ", conditionMessage(e))
    NULL
  })
  if (!is.null(result) && nrow(result) > 0) result$source_page <- pg
  result
})
parsed <- bind_rows(parsed)

# Map ch_09 IDs back to field-plan IDs where applicable, then restrict to the
# confirmed-site IDs actually requested in Stage 3 (drops incidental other
# sites' data that happens to share a seep page).
parsed$site_id <- ifelse(
  parsed$site_id %in% names(ch09_to_field_plan_id),
  ch09_to_field_plan_id[parsed$site_id],
  parsed$site_id
)
confirmed_ids <- unique(table_pages$site_id)
long_chem <- filter(parsed, site_id %in% confirmed_ids)

# Canonicalize known cross-page text-variant duplicates of the same
# parameter (OCR/line-wrap spacing differences, not distinct measurements).
# "Field Turbidity" (its own header on some pages) and "Turbidity" (the
# relabeled mislabel fix above) are the same NTU measurement; the three
# Nitrate+Nitrite spacing variants are the same combined determination.
canonical_names <- c(
  "Field Turbidity" = "Turbidity",
  "Nitrate + Nitrite" = "Nitrate + Nitrite",
  "Nitrate+ Nitrite" = "Nitrate + Nitrite",
  "Nitrate/ Nitrite" = "Nitrate + Nitrite"
)
long_chem$parameter <- ifelse(
  long_chem$parameter %in% names(canonical_names),
  canonical_names[long_chem$parameter],
  long_chem$parameter
)

write.csv(long_chem, out_csv, row.names = FALSE)

sites_parsed <- length(unique(long_chem$site_id))
message(sprintf(
  "Parsed chemistry data for %d of %d confirmed sites (%d rows, %d distinct parameters). Output: %s",
  sites_parsed, length(confirmed_ids), nrow(long_chem), length(unique(long_chem$parameter)), out_csv
))

missing_sites <- setdiff(confirmed_ids, unique(long_chem$site_id))
if (length(missing_sites) > 0) {
  message("Confirmed sites with no parsed chemistry rows (needs manual check): ", paste(missing_sites, collapse = ", "))
}
