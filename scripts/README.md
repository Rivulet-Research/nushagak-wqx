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
