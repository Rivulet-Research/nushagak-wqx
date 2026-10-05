# Quick Start: Extract & Display Pebble Data
**Time**: ~2-3 hours total | **Difficulty**: Moderate (mostly manual transcription)

---

## TL;DR

**4-step workflow to get Pebble stations on the spatial coverage map:**

1. **Python scan** (5 min): Locate candidate tables in PDFs
2. **Manual transcription** (1-2 hrs): Extract coordinates from flagged tables into CSV
3. **R validation** (2 min): Filter coordinates to Nushagak HUC8 boundaries
4. **Integration** (30 min): Add Pebble layer to map in chapter 03

---

## Stage 1: Scan PDFs for Tables (5 minutes)

```bash
# From project root: C:\Users\Benjamin\OneDrive\Documents\GitHub_Local\rivulet\nushagak-wqx

# ONE-TIME SETUP (if not already done)
python -m venv scripts/python/.venv
scripts\python\.venv\Scripts\activate
pip install -r scripts/python/requirements.txt

# RUN THE SCAN
python scripts/python/extract_pebble_nushagak.py \
    --pdf_dir other/input/pebble \
    --output other/output/pebble_nushagak_sites.csv
```

**Output**: `other/output/pebble_nushagak_sites.csv`  
This CSV shows which PDF pages contain tables mentioning Nushagak-related keywords.

**Next step**: Open the CSV and the corresponding PDF pages to find the actual station-location tables (not just mentions in text).

---

## Stage 2: Transcribe Coordinates (1-2 hours)

**By hand, directly into this CSV:**

```
other/input/pebble/pebble_site_coordinates.csv
```

**Format** (comma-separated):

```
station_id,lat,lon,source_pdf,page,notes
MUL-01,59.452,-156.382,pebble-feis_ch3-section-16.pdf,42,Mulchatna River mainstem
MUL-02,59.461,-156.395,pebble-feis_ch3-section-16.pdf,42,Mulchatna tributary
KOK-05,59.823,-156.110,pebble-feis_ch3-section-16.pdf,45,Koktuli River headwaters
```

**How to find coordinates in the PDF:**
- Open the PDF to the page number flagged by the Python script
- Look for a **station-location table** (usually earlier in the chapter or in an appendix)
- Table typically has columns like: Station ID | Location Name | Latitude | Longitude
- Transcribe each row that appears to be in the Nushagak drainage

**Latitude/Longitude format:**
- Decimal degrees only (e.g., 59.452, not 59°27'7.2")
- Negative for South and West (Alaska is negative both ways)
- Example: Mulchatna mouth is approximately **59.45°N, 156.38°W** = `59.45, -156.38`

**Don't worry about perfect accuracy at this stage**—Stage 3 will validate that your coordinates actually fall within the Nushagak boundaries.

**Stuck finding coordinates?** Post the URL and I can help locate the station table.

---

## Stage 3: Validate Coordinates (2 minutes)

```bash
# From project root
Rscript scripts/R/filter_pebble_by_huc8.R
```

This script:
1. Reads your coordinates CSV
2. Fetches HUC8 boundaries from USGS (downloaded once, cached)
3. Tests each coordinate with spatial containment
4. Writes two output CSVs:
   - `other/output/pebble_sites_huc8_check.csv` — all sites with HUC8 assignment
   - `other/output/pebble_nushagak_confirmed_sites.csv` — only confirmed sites ✓

**Check console output** for:
- Count of confirmed sites (should be > 0 if Step 2 worked)
- Any excluded sites (fell outside the four HUCs)
- Any errors or missing coordinates

**If a site was excluded**: Either its coordinates are wrong (transcription error) or the site truly doesn't drain into the Nushagak (e.g., a regional comparison table). Check the source PDF.

---

## Stage 4: Add to Chapter 03 (30 minutes)

**Open**: `chapters/03_spatial_coverage.qmd`

**After line 33** (end of the first `{r setup}` chunk), add:

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

**Replace the entire map chunk** (lines 40–62) with:

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

**Test it**:

```r
# In RStudio console
quarto::quarto_render("chapters/03_spatial_coverage.qmd")
```

Open `docs/chapters/03_spatial_coverage.html` in your browser. You should see:
- **Blue dots** = WQP stations
- **Orange dots** = Pebble Project stations
- Toggle buttons to show/hide each layer

**Done!** The map now displays both data sources.

---

## What to Expect: Results

After completing all 4 stages, `chapters/03_spatial_coverage.qmd` will show:

- **Interactive map** with WQP stations (blue) and Pebble stations (orange)
- **Layer toggle** to show/hide each data source
- **Clusters** that expand as you zoom in
- **Popups** showing station ID, HUC, and source when clicked
- **Summary tables** (existing WQP tables; can extend to include Pebble counts)

Example popup when clicking a Pebble marker:
```
Pebble: MUL-01
HUC8: 19030302
Source: Pebble Project EIS
```

---

## Timeline

| Stage | Task | Time | Status |
|-------|------|------|--------|
| 1 | Run Python PDF scan | 5 min | 🔵 Ready |
| 2 | Transcribe coordinates manually | 1-2 hrs | 🟡 Next |
| 3 | Run R filter script | 2 min | ⚪ Blocked on Stage 2 |
| 4 | Integrate into chapter 03 | 30 min | ⚪ Blocked on Stage 3 |

**Start with Stage 1** whenever you're ready.

---

## Files Reference

| File | What it is | You create? |
|------|-----------|-----------|
| `scripts/python/extract_pebble_nushagak.py` | PDF keyword scanner | No (provided) |
| `other/input/pebble/pebble-feis_ch3-section-16.pdf` | Source data | No (already downloaded) |
| `other/output/pebble_nushagak_sites.csv` | Stage 1 output | No (auto-generated) |
| `other/input/pebble/pebble_site_coordinates.csv` | Stage 2 input | **Yes—by hand** |
| `scripts/R/filter_pebble_by_huc8.R` | Coordinate validator | No (provided) |
| `other/output/pebble_nushagak_confirmed_sites.csv` | Stage 3 output | No (auto-generated) |
| `chapters/03_spatial_coverage.qmd` | Integration point | **Yes—code edits** |

---

## Questions?

- **Coordinate format not clear?** See the template CSV in `scripts/R/pebble_site_coordinates_template.csv`
- **Can't find station-location table?** Check the PDF's **Table of Contents** and **Appendices** sections
- **R script fails?** Check that you saved your coordinates CSV with the correct path and column names
- **Map doesn't show Pebble layer?** Verify `pebble_nushagak_confirmed_sites.csv` exists and isn't empty

See **`other/PEBBLE_EXTRACTION_PLAN.md`** for detailed troubleshooting and advanced options.
