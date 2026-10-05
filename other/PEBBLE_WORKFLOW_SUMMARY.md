# Pebble Data Extraction Workflow: Complete Summary

---

## The Goal

Extract water quality monitoring sites from Pebble Project EIS PDFs that fall within the Nushagak River drainage (HUC8 19030301–19030304), and display them alongside WQP stations on the spatial coverage map in `chapters/03_spatial_coverage.qmd`.

---

## Why This Multi-Stage Approach?

| Challenge | Why Not Single-Step | Solution |
|-----------|-------------------|----------|
| **PDFs are large** (20 MB each) | Can't send full text to AI—too costly/slow | Local Python script scans text layer for keywords |
| **Tables require manual review** | Keyword matches can be false positives (e.g., regional comparison table that mentions "Nushagak" but isn't in the Nushagak drainage) | Human review of flagged pages; then spatial validation |
| **Coordinates must be verified** | Keyword + human review still can't guarantee spatial accuracy | R script tests lat/lon against official HUC8 polygons |
| **Integration is minimal code** | Cleaner workflow if all validation is upstream | Load pre-validated CSV into chapter; simple R merge |

**Result**: Transparent, reproducible, and doesn't eat your token budget.

---

## The 4-Stage Workflow

```
PDF Files
   ↓
[Stage 1: Python Scan] → Locate candidate tables via keywords
   ↓ (review CSV, open PDFs)
[Stage 2: Manual Transcription] → Extract station coordinates by hand
   ↓ (save CSV)
[Stage 3: R Spatial Filter] → Validate coordinates against HUC8 boundaries
   ↓ (confirmed sites CSV)
[Stage 4: R Integration] → Load into chapter 03 and display on map
   ↓
Final Map: WQP (blue) + Pebble (orange) on interactive leaflet
```

---

## Stage 1: PDF Scan (Automated)

**Script**: `scripts/python/extract_pebble_nushagak.py`

**Input**:
- Source PDFs in `other/input/pebble/` (e.g., `pebble-feis_ch3-section-16.pdf`)

**Process**:
1. Reads text layer from each PDF using `pdfplumber`
2. Searches for keywords: `nushagak`, `mulchatna`, `koktuli`, `tikchik`, `wood`, `igushik`, `bristol bay`, `dillingham`
3. Flags tables containing matches

**Output**: `other/output/pebble_nushagak_sites.csv`
- One row per flagged table
- Columns: PDF name, page number, table index, text preview

**Time**: 5 minutes  
**Required action**: Manually review the CSV and open the flagged PDF pages to identify which ones contain actual station-location data (not just discussion mentions).

---

## Stage 2: Manual Transcription (Human-Intensive)

**Your task**: Extract coordinates from the source PDFs

**Input**:
- `other/output/pebble_nushagak_sites.csv` (from Stage 1)
- Actual Pebble EIS PDF files

**Process**:
1. For each flagged page in the CSV:
   - Open the PDF to that page
   - Find the station-location table (usually a separate section from results)
   - Identify rows relevant to Nushagak drainage
   - Transcribe station ID, latitude, longitude, source PDF, page number

2. Create `other/input/pebble/pebble_site_coordinates.csv` (you create this file):
   ```
   station_id,lat,lon,source_pdf,page,notes
   MUL-01,59.452,-156.382,pebble-feis_ch3-section-16.pdf,42,Mulchatna mainstem
   MUL-02,59.461,-156.395,pebble-feis_ch3-section-16.pdf,42,Mulchatna tributary
   KOK-05,59.823,-156.110,pebble-feis_ch3-section-16.pdf,45,Koktuli headwaters
   ```

**Time**: 1–2 hours (depends on how many flagged tables have actual station coordinates)  
**Output**: A single CSV file with your transcribed coordinates  
**Notes**:
- Decimal degrees only (negative for South/West)
- Order doesn't matter
- Missing coordinates? Use `NA` or leave blank
- The next stage will validate; don't worry about perfect accuracy

---

## Stage 3: Spatial Validation (Automated)

**Script**: `scripts/R/filter_pebble_by_huc8.R`

**Input**: `other/input/pebble/pebble_site_coordinates.csv` (created in Stage 2)

**Process**:
1. Reads your coordinates CSV
2. Fetches HUC8 polygons from USGS Watershed Boundary Dataset (cached locally)
3. Uses spatial containment test (`sf::st_within()`) to check each coordinate
4. Writes outputs with HUC8 assignment

**Output**:
- `other/output/pebble_sites_huc8_check.csv` — all sites with HUC8 assignment (or `NA`)
- `other/output/pebble_nushagak_confirmed_sites.csv` — **only sites inside the four HUC8s** ✓

**Time**: 2 minutes  
**Required action**: Review console output for:
- How many sites were confirmed (should be > 0)
- Which sites were excluded (outside the HUCs)
- Any errors or missing coordinates

**The "confirmed" file** is what Stage 4 will read—it's authoritative for what appears on the map.

---

## Stage 4: Integration into Chapter 03 (Code Edits)

**File**: `chapters/03_spatial_coverage.qmd`

**Change 1: Add Pebble loader to setup chunk** (after line 33)

```r
# Load confirmed Pebble sites (only if file exists)
pebble_confirmed_file <- "other/output/pebble_nushagak_confirmed_sites.csv"
if (file.exists(pebble_confirmed_file)) {
  pebble_sites <- read.csv(pebble_confirmed_file) %>%
    select(station_id, lat, lon, huc8)
  pebble_sf <- pebble_sites %>%
    st_as_sf(coords = c("lon", "lat"), crs = 4326)
} else {
  pebble_sf <- NULL
  message("Pebble sites file not found; skipping Pebble layer")
}
```

**Change 2: Replace entire map chunk** (lines 40–62)

```r
#| eval: !expr knitr::is_html_output()
# Create the base map
map <- leaflet(wq_sf) %>%
  addProviderTiles(providers$Esri.WorldTopoMap, group = "Topo") %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
  # WQP stations in blue
  addCircleMarkers(
    radius = 6,
    color = "#0072B2",
    weight = 1,
    fillOpacity = 0.7,
    popup = ~paste0(
      "<b>", MonitoringLocationName, "</b><br>",
      "ID: ", MonitoringLocationIdentifier, "<br>",
      "Org: ", OrganizationFormalName, "<br>",
      "Results: ", resultCount
    ),
    clusterOptions = markerClusterOptions(),
    group = "WQP Stations"
  )

# Add Pebble sites if available (in orange)
if (!is.null(pebble_sf)) {
  map <- map %>%
    addCircleMarkers(
      data = pebble_sf,
      radius = 6,
      color = "#FF8C00",
      weight = 1,
      fillOpacity = 0.7,
      popup = ~paste0(
        "<b>Pebble: ", station_id, "</b><br>",
        "HUC8: ", huc8, "<br>",
        "Source: Pebble Project EIS"
      ),
      clusterOptions = markerClusterOptions(),
      group = "Pebble Project Sites"
    )
}

# Add layer controls
map %>%
  addLayersControl(
    baseGroups = c("Topo", "Satellite"),
    overlayGroups = if (!is.null(pebble_sf)) {
      c("WQP Stations", "Pebble Project Sites")
    } else {
      c("WQP Stations")
    },
    options = layersControlOptions(collapsed = FALSE)
  )
```

**Time**: 30 minutes (mostly copy-paste)  
**Test**: 
```r
quarto::quarto_render("chapters/03_spatial_coverage.qmd")
```
Open `docs/chapters/03_spatial_coverage.html` in browser—you should see blue dots (WQP) and orange dots (Pebble).

---

## Data Flow Diagram

```
┌─────────────────────────────────────┐
│ Pebble EIS PDFs (gitignored)        │ ← You already have:
│ other/input/pebble/                 │   pebble-feis_ch3-section-16.pdf
│ └─ pebble-feis_ch3-section-16.pdf   │
└─────────────────────┬───────────────┘
                      │
         [Stage 1: Python Scan]
         extract_pebble_nushagak.py
                      │
                      ↓
┌─────────────────────────────────────┐
│ Flagged tables (gitignored)         │
│ other/output/pebble_nushagak_sites.│ ← You review this CSV
│ csv                                 │
└─────────────────────┬───────────────┘
                      │ (Manual Review)
         [Stage 2: Human Transcription]
         Extract coordinates from PDFs
                      │
                      ↓
┌─────────────────────────────────────┐
│ Site coordinates (gitignored)       │
│ other/input/pebble/                 │ ← You create:
│ pebble_site_coordinates.csv         │   station_id, lat, lon, ...
└─────────────────────┬───────────────┘
                      │
         [Stage 3: R Spatial Filter]
         filter_pebble_by_huc8.R
                      │
                      ↓
┌─────────────────────────────────────┐
│ Validated sites (gitignored)        │
│ other/output/                       │ ← Script creates:
│ pebble_nushagak_confirmed_sites.csv │   Only sites in Nushagak HUC8s
└─────────────────────┬───────────────┘
                      │
         [Stage 4: R Integration]
         chapters/03_spatial_coverage.qmd
                      │
                      ↓
┌─────────────────────────────────────┐
│ Interactive Map (HTML)              │ ← Final output:
│ WQP stations (blue)                 │   03_spatial_coverage.html
│ Pebble stations (orange)            │   Shows both data sources
│ Toggle layers, cluster, zoom        │
└─────────────────────────────────────┘
```

---

## Key Decision Points

| Question | Answer | Why |
|----------|--------|-----|
| Why not just OCR all PDFs automatically? | Token cost + speed + accuracy risk | 20 MB PDFs × multiple users = expensive. Local scan + human review is cheaper & transparent. |
| Why manual transcription instead of full table parsing? | Focus on what matters + human validation | Station-location tables are sparse; parsing "nice-to-have." Coordinates are essential; humans catch errors better. |
| Why use HUC8 boundaries instead of just keywords? | Ground truth | Place names can mislead (e.g., "Nushagak" mentioned in regional comparison table for a site that doesn't drain there). Coordinates + polygon test removes ambiguity. |
| Why add Pebble as a separate layer, not merge with WQP? | Flexibility + data integrity | Pebble and WQP have different metadata structures. Layer toggle lets users choose. Easy to merge later if needed. |
| Why is the confirmed file gitignored? | It's derived from local PDFs | Anyone can regenerate it by running Stages 1–3. No point checking it in. |

---

## Success Criteria

After all 4 stages:

✓ `chapters/03_spatial_coverage.qmd` renders without errors  
✓ The interactive map shows **both blue (WQP) and orange (Pebble) dots**  
✓ Clicking an orange dot shows popup: `Pebble: [ID] | HUC8: [code] | Source: Pebble Project EIS`  
✓ Layer toggle allows turning Pebble sites on/off independently  
✓ Console output from Stage 3 shows N confirmed sites (N > 0)  

---

## File Inventory

### Provided (You don't create these)

| File | Role |
|------|------|
| `scripts/python/extract_pebble_nushagak.py` | Stage 1 scanner |
| `scripts/R/filter_pebble_by_huc8.R` | Stage 3 filter |
| `scripts/R/pebble_site_coordinates_template.csv` | Template for Stage 2 |
| `scripts/python/requirements.txt` | Python dependencies |
| `other/input/pebble/pebble-feis_ch3-section-16.pdf` | Source data (already downloaded) |

### You Create

| File | Stage | Action |
|------|-------|--------|
| `other/input/pebble/pebble_site_coordinates.csv` | 2 | Copy template, fill in coordinates |
| `chapters/03_spatial_coverage.qmd` | 4 | Add Pebble loader + update map code |

### Auto-Generated (Gitignored)

| File | Stage | Regenerate |
|------|-------|-----------|
| `other/output/pebble_nushagak_sites.csv` | 1 | `python extract_pebble_nushagak.py` |
| `other/output/pebble_sites_huc8_check.csv` | 3 | `Rscript filter_pebble_by_huc8.R` |
| `other/output/pebble_nushagak_confirmed_sites.csv` | 3 | `Rscript filter_pebble_by_huc8.R` |
| `other/output/nushagak_huc8_boundary.gpkg` | 3 | Cached (auto-refreshes if deleted) |

---

## Estimated Time

| Stage | Component | Time |
|-------|-----------|------|
| 1 | Setup (one-time) | 5 min |
| 1 | Run scan | 5 min |
| 2 | Review flagged tables | 10 min |
| 2 | Manual transcription | 60–120 min |
| 3 | Run filter | 2 min |
| 4 | Code edits + test | 30 min |
| | **TOTAL** | **2–2.5 hours** |

**Blocking assumption**: You have the source PDFs and they have readable text layers (no OCR needed).

---

## Next Steps

1. **Read** `other/QUICK_START_PEBBLE.md` for hands-on walkthrough
2. **Start Stage 1** when ready: `python scripts/python/extract_pebble_nushagak.py ...`
3. **Share results** if stuck (e.g., "Can't find the station-location table in the PDF")

---

## Related Documentation

- `other/PEBBLE_EXTRACTION_PLAN.md` — Detailed plan with troubleshooting
- `other/PEBBLE_INTEGRATION_CODE_TEMPLATES.md` — Alternative integration approaches
- `other/QUICK_START_PEBBLE.md` — Quick walkthrough of each stage
- `scripts/README.md` — Technical documentation of scripts
- `chapters/02_data_sources.qmd` — Context on Pebble data availability
- `chapters/03_spatial_coverage.qmd` — Integration point

---

## Questions?

See the troubleshooting section in `other/PEBBLE_EXTRACTION_PLAN.md`.
