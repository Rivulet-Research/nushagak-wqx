# Pebble Integration: Code Templates for Stage 4

Ready-to-use R code for integrating Pebble stations into `chapters/03_spatial_coverage.qmd`.

---

## Template Option A: Pebble as Separate Layer (Recommended)

Add this code to the setup chunk in `03_spatial_coverage.qmd`, after the WQP data is loaded:

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

Then modify the **map code** (replace the existing `leaflet()` chunk):

```r
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

### Result
- WQP stations appear in **blue**, Pebble stations in **orange**
- Users can toggle each layer on/off independently
- Both datasets cluster when zoomed out
- Popup shows source (WQP vs. Pebble) and relevant fields

---

## Template Option B: Unified Coverage Approach

If you want a single, merged dataset, add this to the setup chunk:

```r
# Prepare WQP data
wqp_summary <- wq_inventory %>%
  filter(!is.na(lon), !is.na(lat)) %>%
  select(
    station_id = MonitoringLocationIdentifier,
    lat, lon, HUC,
    source = OrganizationFormalName
  ) %>%
  mutate(
    data_source = "WQP",
    results_or_description = as.character(resultCount) # Adapt as needed
  )

# Prepare Pebble data
pebble_confirmed_file <- "other/output/pebble_nushagak_confirmed_sites.csv"
if (file.exists(pebble_confirmed_file)) {
  pebble_summary <- read.csv(pebble_confirmed_file) %>%
    select(station_id, lat, lon, HUC = huc8) %>%
    mutate(
      data_source = "Pebble Project EIS",
      source = "Pebble Project EIS",
      results_or_description = "Baseline water quality"
    )
  
  # Merge all stations
  all_stations <- bind_rows(wqp_summary, pebble_summary)
} else {
  all_stations <- wqp_summary %>%
    mutate(results_or_description = as.character(results_or_description))
}

# Convert to spatial
all_sf <- all_stations %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)
```

Then update the map to color-code by data source:

```r
# Define colors by source
source_colors <- c(
  "WQP" = "#0072B2",
  "Pebble Project EIS" = "#FF8C00"
)

leaflet(all_sf) %>%
  addProviderTiles(providers$Esri.WorldTopoMap, group = "Topo") %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
  addCircleMarkers(
    radius = 6,
    color = ~source_colors[data_source],
    weight = 1,
    fillOpacity = 0.7,
    popup = ~paste0(
      "<b>", station_id, "</b><br>",
      "Source: ", data_source, "<br>",
      "HUC8: ", HUC, "<br>",
      "Info: ", results_or_description
    ),
    clusterOptions = markerClusterOptions()
  ) %>%
  addLayersControl(
    baseGroups = c("Topo", "Satellite"),
    options = layersControlOptions(collapsed = FALSE)
  )
```

### Result
- Single unified map with both data sources
- Color indicates source (blue = WQP, orange = Pebble)
- Simpler interface, but less flexible (can't toggle sources separately)

---

## Template Option C: Side-by-Side Summary Stats

Add a callout or section after the existing HUC summary table:

```r
# Pebble coverage by HUC (if available)
pebble_confirmed_file <- "other/output/pebble_nushagak_confirmed_sites.csv"
if (file.exists(pebble_confirmed_file)) {
  pebble_summary <- read.csv(pebble_confirmed_file) %>%
    group_by(huc8) %>%
    summarize(
      Pebble_Stations = n(),
      .groups = "drop"
    ) %>%
    rename(HUC = huc8) %>%
    mutate(
      HUC_Name = case_when(
        HUC == "19030301" ~ "Upper Nushagak",
        HUC == "19030302" ~ "Mulchatna",
        HUC == "19030303" ~ "Lower Nushagak",
        HUC == "19030304" ~ "Wood",
        TRUE ~ HUC
      )
    ) %>%
    select(HUC, HUC_Name, Pebble_Stations)
  
  # Merge with WQP summary
  combined_summary <- huc_summary %>%
    left_join(pebble_summary, by = c("HUC", "HUC_Name")) %>%
    mutate(Pebble_Stations = replace_na(Pebble_Stations, 0))
  
  knitr::kable(combined_summary, caption = "Monitoring Coverage by HUC8 Sub-basin (WQP + Pebble)")
} else {
  # Original WQP-only table
  knitr::kable(huc_summary, caption = "Monitoring Coverage by HUC8 Sub-basin (WQP)")
}
```

### Result
- Shows side-by-side count of WQP vs. Pebble stations per HUC
- Helps identify coverage gaps filled by Pebble data
- More informative for comparative analysis

---

## Step-by-Step Integration (Option A Recommended)

1. **Open** `chapters/03_spatial_coverage.qmd`

2. **In the setup chunk (after line 33)**, add:
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

3. **Replace the entire map chunk (lines 40–62)** with the updated version above

4. **Test render**:
   ```r
   quarto::quarto_render("chapters/03_spatial_coverage.qmd")
   ```

5. **View result** in `docs/chapters/03_spatial_coverage.html`

---

## Data Structure Reference

After running the R filter script, `pebble_nushagak_confirmed_sites.csv` will have:

| Column | Type | Example |
|--------|------|---------|
| `station_id` | string | "MUL-01" |
| `lat` | numeric | 59.452 |
| `lon` | numeric | -156.382 |
| `source_pdf` | string | "pebble-feis_ch3-section-16.pdf" |
| `page` | integer | 42 |
| `notes` | string | "Mulchatna River mainstem" |
| `huc8` | string | "19030302" |
| `huc8_name` | string | "Mulchatna" |

The setup chunk selects `station_id`, `lat`, `lon`, and `huc8` for the map.

---

## Debugging Tips

**Map doesn't show Pebble layer:**
- Check that `other/output/pebble_nushagak_confirmed_sites.csv` exists
- Verify the CSV has valid `lat` and `lon` columns
- Open the browser console (F12) for JavaScript errors

**Coordinates don't match basemap:**
- Double-check that coordinates are in decimal degrees (not DMS)
- Verify sign: latitude south should be negative, longitude west should be negative

**Pebble file is empty or missing:**
- Ensure Stages 1–3 were completed successfully
- Check console output from `filter_pebble_by_huc8.R` for excluded sites

---

## Files to Modify

| File | Action |
|------|--------|
| `chapters/03_spatial_coverage.qmd` | Add Pebble loading + modify map code |
| (No other files need changes for basic integration) | |

Once integrated, the chapter will display Pebble stations alongside WQP data without breaking existing functionality.
