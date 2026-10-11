# Scripts

Code that runs outside the Quarto render process, because it operates on
large local-only inputs (raw PDFs) that are not checked into this repository.

## scripts/python/extract_pebble_nushagak.py

Scans Pebble Project EIS PDFs for tables relevant to the Nushagak River
watershed and writes a CSV of flagged table locations (source PDF, page,
preview text) for manual review and transcription.

**Why this step runs locally, not inside the book:**

- Pebble EIS documents run to thousands of pages; sending that text through
  an AI model's context window would be slow and unnecessarily costly.
- This script only needs pattern matching on extracted text, a task
  `pdfplumber` + `pandas` handle directly on your machine.
- The raw PDFs are gitignored (`other/input/pebble/`); anyone reproducing
  this analysis must download them separately (see "Inputs" below).

### Setup (one-time)

From the repository root:

```bash
python -m venv scripts/python/.venv
source scripts/python/.venv/bin/activate   # Windows: scripts\python\.venv\Scripts\activate
pip install -r scripts/python/requirements.txt
```

Tesseract OCR is not required for this script's normal path (most Pebble EIS
PDFs are already text-searchable). Install it only as a fallback, if a
specific PDF turns out to be scanned images with no extractable text layer:

- Windows/macOS/Linux installers: <https://github.com/tesseract-ocr/tesseract>
- If needed, convert the scanned PDF to a text-searchable one with
  `ocrmypdf input.pdf output_searchable.pdf` (`pip install ocrmypdf`), then
  point this script at the OCR'd version.

### Inputs

Place source PDFs in `other/input/pebble/` (gitignored). Example source used
during development of this pipeline:

- <https://pebbleresearch.com/wp-content/uploads/2014/03/ch_09_water_quality_bb.pdf>
- <https://pebbleresearch.com/wp-content/uploads/2025/04/pebble-feis_ch3-section-16.pdf>

### Running

```bash
python scripts/python/extract_pebble_nushagak.py \
    --pdf_dir other/input/pebble \
    --output other/output/pebble_nushagak_sites.csv
```

### Output

`other/output/pebble_nushagak_sites.csv` (gitignored; regenerate as needed):
one row per flagged table, with source PDF name, page number, table index,
and a text preview of the first three rows for manual review.

### After running

This script only locates candidate tables; it does not transcribe full
tables into clean data, and keyword matches are a fast first pass, not the
final inclusion test (a table can mention "Nushagak" in a discussion
paragraph for a site that isn't actually in the Nushagak drainage, or use a
local place name the keyword list doesn't catch). Review the CSV, open the
indicated PDF pages, and transcribe candidate sites into a coordinates CSV
for the spatial check described below.

### Keyword list

The script matches on: `nushagak`, `mulchatna`, `koktuli`, `tikchik`,
`wood`, `igushik`, `bristol bay`, `dillingham`. Edit `NUSHAGAK_KEYWORDS` in
the script if the keyword list needs to change (e.g., to add specific
station names found during review).

## scripts/R/filter_pebble_by_huc8.R

The authoritative inclusion test for Pebble sites: does a site's coordinate
fall inside one of the four HUC8 sub-basins that drain into the Nushagak
(19030301-19030304, per `chapters/03_spatial_coverage.qmd`)? Keyword
matching above only narrows which PDF pages to look at; this script decides
what actually gets kept.

**Why coordinates, not keywords:** a site description can mention
"Nushagak" without draining into it (e.g., a regional comparison table), or
use a local creek name the keyword list misses. Testing the station's
reported lat/lon against the real HUC8 polygon boundary removes that
ambiguity.

### Setup (one-time)

```r
install.packages(c("sf", "dplyr", "nhdplusTools"))
```

`nhdplusTools::get_huc()` fetches the official USGS Watershed Boundary
Dataset (WBD) polygon for each HUC8 code from the USGS web service (one
request, run once; the result is cached to
`other/output/nushagak_huc8_boundary.gpkg` and reused on later runs). No
site data is sent anywhere; only the four HUC8 ID codes are part of the
request.

### Inputs

`other/input/pebble/pebble_site_coordinates.csv` (gitignored; you create
this by hand). Start from the template:

```
scripts/R/pebble_site_coordinates_template.csv
```

Columns: `station_id`, `lat`, `lon`, `source_pdf`, `page`, `notes`. Populate
one row per site flagged by the Python script above, transcribing
coordinates from the PDF's station-location table (Pebble EIS reports
typically list station coordinates separately from the water quality
results tables, so this usually means checking a different page or
appendix than the one flagged).

### Running

```bash
Rscript scripts/R/filter_pebble_by_huc8.R
```

### Output

Both gitignored; regenerate as needed:

- `other/output/pebble_sites_huc8_check.csv` - every input site with the
  HUC8 it falls in (`NA` if outside all four)
- `other/output/pebble_nushagak_confirmed_sites.csv` - only sites confirmed
  within the four HUC8s; this is the file later chapters should read when
  incorporating Pebble EIS data

Sites with missing coordinates, or coordinates outside the four HUC8s, are
reported in the console output and excluded from the confirmed file.

## scripts/R/extract_pebble_sites.R

Stage 1: parses the 2008 cumulative station table (pp. 1011-1012 of
`appx_f_field_sampling_plans.pdf`, "Surface Hydrology and Water-quality
Stream Station Locations", plus the companion seep-locations table) into a
candidate site CSV with coordinates.

### Input

`other/input/pebble/appx_f_field_sampling_plans.pdf` (gitignored; download
separately, see above).

### Output

`other/output/pebble_candidate_sites.csv` (gitignored) - one row per
candidate site: site_id, longitude, latitude, type (stream/seep),
source_pdf, source_page, source_table.

### Running

```bash
Rscript scripts/R/extract_pebble_sites.R
```

## scripts/R/index_pebble_chemistry_pages.R

Stage 3: locates the chemistry data table pages for each confirmed site
(Stage 2 output) inside `ch_09_water_quality_bb.pdf` (2,247 pages), using
exact site-ID text matching rather than keyword search. Caches the full-text
extraction to disk on first run (~25s) and reuses it on later runs. Raw
page hits are narrowed to genuine data-table pages via a validated
heuristic (site ID immediately followed by "Sample Date" on the next line).

Two confirmed sites, SK136A and SK136B, were renamed SK100I and SK100H
respectively in the chemistry chapter; the script hard-codes this rename
map to resolve their pages, and Stage 4 maps the result back to the
original field-plan ID for output.

### Input

- `other/input/pebble/ch_09_water_quality_bb.pdf` (gitignored; download
  separately, see above)
- `other/output/pebble_nushagak_confirmed_sites.csv` (Stage 2 output)

### Output

Both gitignored:

- `other/output/ch09_fulltext_cache.rds` - cached full-text extraction,
  reused on reruns
- `other/output/pebble_site_chemistry_page_index.csv` - raw site_id/page
  hits
- `other/output/pebble_site_chemistry_table_pages.csv` - hits filtered to
  genuine data-table pages; this is the file Stage 4 reads

### Running

```bash
Rscript scripts/R/index_pebble_chemistry_pages.R
```

## scripts/R/parse_pebble_chemistry.R

Stage 4: parses chemistry tables on the flagged pages (Stage 3 output) into
tidy long-format records, using `pdftools::pdf_data()` word-position
reconstruction (not `pdf_text()`, because headers wrap across multiple
lines and value rows have ragged missing data). One shared parser function
handles both the stream layout (one site per page block) and the seep
layout (multiple sites stacked per page, split on "Sample"/"Date" header
detection).

Known source-document and parsing issues corrected here (see
`other/AGENTS.md` for full detail): a mislabeled Turbidity (NTU) column on
seep general-chemistry pages that reuses the stream template's second
"Field Water Temperature" header; parent parameter names for merged
Total/Dissolved sub-columns backfilled from the left-neighbor column; and
orphaned header labels (never-sampled parameters with no matching
value-row token) dropped rather than force-assigned to a neighboring
column.

### Input

- `other/input/pebble/ch_09_water_quality_bb.pdf` (gitignored; download
  separately, see above)
- `other/output/pebble_site_chemistry_table_pages.csv` (Stage 3 output)

### Output

`other/output/pebble_chemistry_long.csv` (gitignored) - one row per
site/date/parameter: site_id, date, parameter, unit, value,
label_corrected, source_page.

### Running

```bash
Rscript scripts/R/parse_pebble_chemistry.R
```

## scripts/R/join_pebble_sites_chemistry.R

Stage 5: joins the confirmed site coordinates (Stage 2) to the parsed
chemistry records (Stage 4) and summarizes each site's sampling record
(sample count, parameter count, date range) for use as a map popup. This
is the file `chapters/03_spatial_coverage.qmd` reads to add Pebble baseline
markers to the station map.

### Input

- `other/output/pebble_nushagak_confirmed_sites.csv` (Stage 2 output)
- `other/output/pebble_chemistry_long.csv` (Stage 4 output)

### Output

`other/output/pebble_sites_chemistry_summary.csv` (gitignored) - one row
per confirmed site: coordinates, HUC8, n_samples, n_parameters, n_results,
date_min, date_max. Sites with no matching chemistry records keep NA
summary columns rather than being dropped, so the map still shows the full
confirmed-site set.

### Running

```bash
Rscript scripts/R/join_pebble_sites_chemistry.R
```
