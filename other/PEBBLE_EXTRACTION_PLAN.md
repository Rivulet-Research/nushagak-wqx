---

editor: 
  markdown: 
    wrap: 72
---

# Pebble Data Extraction & Integration Plan

**Last Updated:** October 4, 2026\
**Status:** Ready to Begin

------------------------------------------------------------------------

## Overview

The goal is to extract water quality monitoring data from Pebble Project EIS PDFs that fall within the Nushagak River drainage (HUC8 19030301-19030304) and integrate those stations into the spatial coverage map and summary tables in `chapters/03_spatial_coverage.qmd`.

The workflow is **three-stage**: 1. **Python scan** → Locate candidate tables in PDFs via keyword matching 2. **Manual transcription** → Extract coordinates from station-location tables 3. **Spatial filter + R integration** → Validate coordinates against HUC8 boundaries, then add to visualization

------------------------------------------------------------------------

## Current State

- **Source PDFs**: `other/input/pebble/pebble-feis_ch3-section-16.pdf` (20 MB) ✓ Downloaded
- **Python script**: `scripts/python/extract_pebble_nushagak.py` ✓ Ready
- **R filter script**: `scripts/R/filter_pebble_by_huc8.R` ✓ Ready
- **R coordinate template**: `scripts/R/pebble_site_coordinates_template.csv` ✓ Ready
- **Integration point**: `chapters/03_spatial_coverage.qmd` — currently queries WQP only

------------------------------------------------------------------------

## Step 1: Python Scan (Stage 1)

**Time estimate**: 5–10 minutes\
**Output**: `other/output/pebble_nushagak_sites.csv`

### Prerequisite Setup (one-time, if not already done)

``` bash
cd C:\Users\Benjamin\OneDrive\Documents\GitHub_Local\rivulet\nushagak-wqx
python -m venv scripts/python/.venv
scripts\python\.venv\Scripts\activate
pip install -r scripts/python/requirements.txt
```

### Run the Scan

``` bash
python scripts/python/extract_pebble_nushagak.py \
    --pdf_dir other/input/pebble \
    --output other/output/pebble_nushagak_sites.csv
```

### What This Does

- Extracts text from each PDF using `pdfplumber`
- Searches for keyword matches: `nushagak`, `mulchatna`, `koktuli`, `tikchik`, `wood`, `igushik`, `bristol bay`, `dillingham`
- Writes flagged table locations to a CSV with:
  - Source PDF name
  - Page number
  - Table index
  - Text preview (first 3 rows)

### Next Action

Open `other/output/pebble_nushagak_sites.csv` and identify which rows contain actual station coordinates (not just mentions of place names in discussion text). Note the page numbers.

------------------------------------------------------------------------

## Step 2: Manual Transcription (Stage 2)

**Time estimate**: 30 minutes – 2 hours (depending on number of flagged tables)\
**Output**: `other/input/pebble/pebble_site_coordinates.csv`

### Process

For each flagged table: 1. Open the indicated PDF page 2. Locate the **station-location table** (usually on a separate page from the results table—check appendices or earlier in the chapter) 3. For each station that drains into the Nushagak drainage, transcribe: - `station_id` (e.g., "MUL-01", "KOK-05") - `lat` (decimal degrees, negative for south) - `lon` (decimal degrees, negative for west) - `source_pdf` (PDF filename) - `page` (page number of station-location table) - `notes` (any relevant info, e.g., "Mulchatna mainstem" or "tributary, no coords found")

### CSV Format

Use the template at `scripts/R/pebble_site_coordinates_template.csv`:

```         
station_id,lat,lon,source_pdf,page,notes
MUL-01,59.452,-156.382,pebble-feis_ch3-section-16.pdf,42,Mulchatna River mainstem
MUL-02,59.461,-156.395,pebble-feis_ch3-section-16.pdf,42,Mulchatna tributary
KOK-05,59.823,-156.110,pebble-feis_ch3-section-16.pdf,45,Koktuli River headwaters
```

### Save the File

```         
other/input/pebble/pebble_site_coordinates.csv
```

**Note**: This file is gitignored (you're working locally). Once validated, you can check it in if you want to make the extraction reproducible.

------------------------------------------------------------------------

## Step 3: Spatial Filter & Validation (Stage 3)

**Time estimate**: 2 minutes\
**Output**: - `other/output/pebble_sites_huc8_check.csv` (all sites with HUC8 assignment) - `other/output/pebble_nushagak_confirmed_sites.csv` (only confirmed sites)

### Run the Filter Script

``` bash
Rscript scripts/R/filter_pebble_by_huc8.R
```

### What This Does

- Reads your coordinates CSV
- Fetches the four Nushagak HUC8 polygon boundaries from USGS (cached for reuse)
- Uses `sf::st_within()` to test each coordinate against all four boundaries
- Writes two CSVs:
  - **check file**: every site + HUC8 assignment (`NA` if outside all four)
  - **confirmed file**: only sites inside the four HUC8s

### Review the Output

Check the console output for: - How many of your sites were confirmed (fell inside the HUCs) - Which sites were excluded (fell outside) - Any sites with missing coordinates

The **confirmed file** is the one you'll use in the next step.

------------------------------------------------------------------------

## Step 4: Integration into Chapter 03 (Stage 4)

**Time estimate**: 15–30 minutes\
**Location**: `chapters/03_spatial_coverage.qmd`

### Current Structure

`03_spatial_coverage.qmd` currently: 1. Queries WQP for all four Nushagak HUC8s 2. Creates a map with WQP stations only 3. Shows summary tables by HUC and data provider

### Integration Options

**Option A: Add Pebble stations as a separate layer in the map**

``` r
# In the setup chunk, after creating wq_sf:

pebble_confirmed <- read.csv("other/output/pebble_nushagak_confirmed_sites.csv")
pebble_sf <- pebble_confirmed %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# In the map code, add a second addCircleMarkers() with a different color
# for Pebble sites (e.g., orange), or use a layer group so they can toggle on/off
```

**Option B: Merge Pebble into the WQP data for unified coverage**

Create a common structure with `station_id`, `lat`, `lon`, `HUC`, `source` (WQP or Pebble):

``` r
wqp_for_merge <- wq_inventory %>%
  select(MonitoringLocationIdentifier, lat, lon, HUC, OrganizationFormalName) %>%
  rename(station_id = MonitoringLocationIdentifier, source = OrganizationFormalName) %>%
  mutate(data_source = "WQP")

pebble_for_merge <- pebble_confirmed %>%
  mutate(data_source = "Pebble Project EIS",
         source = "Pebble Project EIS") %>%
  select(station_id, lat, lon, HUC = huc8, source, data_source)

all_stations <- bind_rows(wqp_for_merge, pebble_for_merge)
```

**Option C: Show coverage comparatively**

Add a note or callout box showing: - WQP stations: X locations, Y total observations - Pebble stations: Z confirmed locations (with data type: chemistry, temperature, etc.)

### Recommended Approach

**Start with Option A** (separate layer) because: - Preserves the WQP data structure without disrupting existing analysis - Makes the Pebble contribution visually distinct - Allows toggling Pebble on/off via `addLayersControl()` - Can be evolved to Option B later if needed

------------------------------------------------------------------------

## Step 5: Transcribe Water Quality Data (Optional, Future)

**Status**: Out of scope for initial integration

Once confirmed sites are in the map, you'll eventually want to extract the actual water quality results (not just station locations). This is a separate workflow:

1.  For each confirmed Pebble site, find the results tables in the source PDF
2.  Identify parameters measured (e.g., conductivity, pH, dissolved metals, temperature)
3.  Transcribe results into a long-format CSV: `station_id`, `date`, `parameter`, `value`, `unit`
4.  Load and merge into the WQP results for cross-source analysis

This can be automated with `pdfplumber` once you've identified the table structure, or done manually if tables are few.

------------------------------------------------------------------------

## Checklist

### Before Starting

- [ ] Read this plan and the referenced scripts
- [ ] Verify source PDF is in `other/input/pebble/`
- [ ] Verify Python virtual environment setup (run once)

### Stage 1: Python Scan

- [ ] Run `extract_pebble_nushagak.py`
- [ ] Review `other/output/pebble_nushagak_sites.csv`
- [ ] Note which rows contain actual station coordinates

### Stage 2: Manual Transcription

- [ ] Open flagged PDFs and locate station-location tables
- [ ] Transcribe coordinates into `other/input/pebble/pebble_site_coordinates.csv`
- [ ] Save and verify CSV format

### Stage 3: Spatial Validation

- [ ] Run `filter_pebble_by_huc8.R`
- [ ] Review console output for confirmation count
- [ ] Check `other/output/pebble_nushagak_confirmed_sites.csv`

### Stage 4: Integration

- [ ] Choose integration approach (Option A recommended)
- [ ] Modify `chapters/03_spatial_coverage.qmd`
- [ ] Test that map renders correctly
- [ ] Update summary tables if needed
- [ ] Render the book and verify

### Stage 5 (Future)

- [ ] Extract water quality results tables (when ready)
- [ ] Merge with WQP results in downstream analysis

------------------------------------------------------------------------

## Files Involved

| File | Role | Status |
|----------------------|----------------------|-----------------------------|
| `scripts/python/extract_pebble_nushagak.py` | PDF keyword scan | ✓ Ready |
| `scripts/R/filter_pebble_by_huc8.R` | Spatial validation | ✓ Ready |
| `scripts/R/pebble_site_coordinates_template.csv` | Template for manual entry | ✓ Ready |
| `other/input/pebble/` | Source PDFs (gitignored) | ✓ Downloaded |
| `other/input/pebble/pebble_site_coordinates.csv` | You create this | ⏳ Pending |
| `other/output/pebble_nushagak_sites.csv` | Script output (gitignored) | ⏳ Pending |
| `other/output/pebble_nushagak_confirmed_sites.csv` | Validated sites (gitignored) | ⏳ Pending |
| `chapters/03_spatial_coverage.qmd` | Integration point | ⏳ To be modified |

------------------------------------------------------------------------

## Questions & Troubleshooting

**Q: What if the PDF has no text layer?**\
A: The script will skip it. If needed, convert the scanned PDF to a text-searchable one using `ocrmypdf` (see `scripts/README.md`).

**Q: What if a station's coordinates put it outside all four HUCs?**\
A: The script will flag it in the console output and exclude it from the confirmed file. Check the coordinates in the source PDF—they may be correct (the site is outside the Nushagak drainage) or there may be a transcription error.

**Q: Can I manually verify the Pebble sites visually on a map before finalizing?**\
A: Yes. Before running the R script, you can plot your coordinates CSV on a map (e.g., `leaflet` or `mapview`) to spot-check against a basemap. Add this to your R console after loading the CSV:

``` r
library(leaflet)
pebble_coords <- read.csv("other/input/pebble/pebble_site_coordinates.csv")
pebble_sf <- st_as_sf(pebble_coords, coords = c("lon", "lat"), crs = 4326)
leaflet(pebble_sf) %>%
  addProviderTiles(providers$Esri.WorldTopoMap) %>%
  addCircleMarkers()
```

**Q: How do I add more Pebble PDFs?**\
A: Place additional PDFs in `other/input/pebble/`, then re-run the Python script (it will scan all PDFs in the directory). After reviewing the new flagged tables, add new rows to `pebble_site_coordinates.csv` and re-run the R filter script.

------------------------------------------------------------------------

## References

- **Python script documentation**: `scripts/python/extract_pebble_nushagak.py` (header comments)
- **R script documentation**: `scripts/R/filter_pebble_by_huc8.R` (header comments)
- **Scripts README**: `scripts/README.md` (full setup and troubleshooting)
- **Book chapter**: `chapters/02_data_sources.qmd` (Pebble section context)
- **Integration point**: `chapters/03_spatial_coverage.qmd` (where data will be displayed)

------------------------------------------------------------------------

## Next Actions (Priority Order)

1.  **Stage 1 (Python scan)**: Run `extract_pebble_nushagak.py` — \~10 min
2.  **Stage 2 (Transcription)**: Manually extract coordinates from flagged pages — \~1-2 hrs
3.  **Stage 3 (Validation)**: Run `filter_pebble_by_huc8.R` — \~2 min
4.  **Stage 4 (Integration)**: Modify `03_spatial_coverage.qmd` to display Pebble sites — \~30 min
5.  **Future**: Extract water quality results tables (lower priority for now)
