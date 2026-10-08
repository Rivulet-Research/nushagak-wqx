# Project Memory — nushagak-wqx

Working notes for Posit Assistant across sessions. Unlike `other/agent_context/agent_context.qmd`
(user-authored instructions, assistant may not edit), this file is assistant-maintained and can be
updated as work progresses.

## Pebble Project data extraction — in progress (10/7/2026)

**Goal** (from `other/agent_context/agent_context.qmd`, 10/7/2026 entry): build an R pipeline that
(1) scrapes Pebble field site locations/names from PDF into a CSV, (2) retains only sites within the
Nushagak watershed HUC8s, (3) joins retained sites to their surface water quality data, (4) adds
retained sites to the "Spatial Coverage of Monitoring Stations" chapter.

### Findings from document investigation (pdftools, local, no OCR needed)

- `other/input/pebble/pebble-feis_ch3-section-16.pdf` (63 pp) is FEIS Chapter 3.16, "Surface Water
  Hydrology" (streamflow/floodplains) — **not** water chemistry. No mg/L, pH, or metals anywhere in
  it. Chemistry lives in FEIS Section 3.18, "Water and Sediment Quality," a different file not in
  this repo. Decision: do not pursue this file further for chemistry.
- Correct chemistry source, supplied by user: `other/input/pebble/ch_09_water_quality_bb.pdf`
  (2,247 pp, 62.5 MB). Chapter 9.1, "Water Quality–Bristol Bay Drainages," from the same 2004-2008
  Environmental Baseline Document as the field sampling plans appendix. Full-text extraction takes
  ~25s locally; text layer present on all pages (no OCR needed). Uses the same site-ID scheme as the
  field sampling plan (e.g. `SK100B`, `NK100A`, `UT100D`) — confirms the two docs join by site ID.
  Has no coordinate table of its own.
- `other/input/pebble/appx_f_field_sampling_plans.pdf` (1,032 pp, 2004-2008 EBD Appendix F) spans
  many disciplines (fish, aquatic habitat, geochem, wildlife, water quality), each with its own table
  format — no single master site list.
- **Authoritative site-coordinate source found**: pp. 1011-1012 of the field sampling plan contain a
  self-contained 2008 cumulative station table, "Surface Hydrology and Water-quality Stream Station
  Locations" (stream sites, Table 3) plus a companion seep-locations table (Table 4). Clean format:
  Site ID, Longitude/Latitude in both DMM and decimal degrees. Covers the Mine Study Area (NFK, SFK,
  UTC, KC, KR drainages) — a far smaller/cleaner extraction target than scanning the full document.
- Caveat: no equivalent station table found for the Road/Port transportation corridor; coverage there
  is unconfirmed. UTC (Upper Talarik Creek) drains to Iliamna Lake/Kvichak, not Nushagak, so it will
  be correctly excluded by the HUC8 filter regardless.
- Sample chemistry table (`ch_09`, site SK100B, Appendix 9.1B) is a clean wide format: one block per
  site, sample dates as rows, parameters as columns (field pH, temp, DO, conductivity, hardness, TSS,
  nutrients, etc.), with total/dissolved distinguished in column headers. Parseable via
  `pdftools::pdf_data()` word-position reconstruction.

### Approved 5-stage pipeline (not yet built)

1. `extract_pebble_sites.R` — parse the 2008 station tables (Appendix F pp. 1011-1012 only) →
   site_id, lat, lon, type (stream/seep) candidate CSV
2. `filter_pebble_by_huc8.R` (already exists in `scripts/R/`) — spatial filter to the 4 Nushagak
   HUC8s → confirmed sites CSV
3. New script — literal site-ID search over a cached full-text extraction of
   `ch_09_water_quality_bb.pdf` → site_id-to-page-number index (exact match, not keyword guessing;
   entirely local, cache the 2,247-page text extraction to disk once, gitignored, reused on reruns)
4. New script — parse chemistry tables only on flagged pages (dozens, not thousands) into tidy long
   format (site_id, date, parameter, value, unit, total/dissolved form); row-filter each table block
   to confirmed Nushagak sites only, even when a page's table includes other non-Nushagak sites
5. Join tidy chemistry to confirmed sites; add Pebble baseline site markers to the "Spatial Coverage
   of Monitoring Stations" map, **merged into the existing station markers** (not a separate
   toggleable layer) but with the popup noting "Pebble Project 2004-2008 baseline" so the different
   source/era stays identifiable

### User decisions already made (do not re-ask)

- Site extraction scope: water quality / surface water sites only (not fish/wildlife/vegetation plots)
- Pebble markers merge into existing map markers (popup text distinguishes source/era)
- Chemistry table parsing: row-by-row filter to confirmed Nushagak sites, not whole-table-block
  retention

### Pipeline status (10/7/2026 session) — Stages 1-4 complete, Stage 5 not started

**Stage 1** (`scripts/R/extract_pebble_sites.R`): parses pp. 1011-1012 of the field sampling plan →
`other/output/pebble_candidate_sites.csv`, 67 candidate sites (39 stream + 28 seep).

**Stage 2** (`scripts/R/filter_pebble_by_huc8.R`, modified to read Stage 1's output): spatial-filters
to the Nushagak HUC8s → `other/output/pebble_nushagak_confirmed_sites.csv`, **37 of 67 sites
confirmed** (21 stream + 16 seep), all in HUC8 19030302 (Mulchatna River). Full check (including
excluded sites) in `other/output/pebble_sites_huc8_check.csv`.

**Stage 3** (`scripts/R/index_pebble_chemistry_pages.R`): indexes `ch_09_water_quality_bb.pdf`
page-by-site, then narrows raw hits to genuine data-table pages via a validated heuristic (site ID
immediately followed by "Sample Date" on the next line). Outputs
`other/output/pebble_site_chemistry_page_index.csv` (raw hits) and
`other/output/pebble_site_chemistry_table_pages.csv` (filtered table pages — the one Stage 4 uses).
**All 37/37 confirmed sites resolved** to 119-121 data-table pages (streams: 3 pages/site; seeps: 4
pages/site, shared across co-located sites). Full-text extraction cached at
`other/output/ch09_fulltext_cache.rds` (gitignored).

Found during Stage 3: two confirmed sites, **SK136A and SK136B, were renamed SK100H and SK100I**
respectively in the chemistry chapter — stated explicitly in the source PDF ("SK100I and SK100H were
previously known as SK136B and SK136A respectively"). The script hard-codes this rename map
(`site_renames`) to resolve their chemistry pages, then Stage 4 maps the ch_09 ID back to the
original field-plan ID for output, so downstream joins to the Stage 2 confirmed-sites table still use
SK136A/SK136B.

**Stage 4** (`scripts/R/parse_pebble_chemistry.R`): word-position table parser using
`pdftools::pdf_data()` (not `pdf_text()`, due to wrapped multi-line headers and ragged missing-value
rows). Handles both stream (one site/page-block) and seep (multiple sites stacked per page, split via
"Sample"+"Date" header detection) layouts with one shared parser function. Output:
`other/output/pebble_chemistry_long.csv` — **71,037 rows, 78 distinct parameters, all 37/37 confirmed
sites**, columns `site_id, date, parameter, unit, value, label_corrected, source_page`.

Three real parsing bugs found and fixed while validating at scale (all about header-to-column
assignment, not the underlying data values):
1. **Source-document defect** (not a parser bug): every seep table's general-chemistry page reuses
   the stream template's second "Field Water Temperature" header for what is actually a Turbidity
   (NTU) column — temperature is never reported in NTU. Confirmed systematic across multiple seep
   sites (SP112, SP41, ...). Fix: relabel to "Turbidity" when label contains "Temperature" but unit
   is NTU; flag the correction in `label_corrected` for auditability.
2. **Merged Total/Dissolved sub-columns**: a parent label (e.g. a metal name) visually spans both its
   Total/Dissolved sub-columns, but nearest-point x-assignment only attributes it to one, leaving the
   other a bare "Total"/"Dissolved" with no parent name. Fix: backfill the parent name from the
   immediate left-neighbor column when a column's label is exactly "Total" or "Dissolved".
3. **Orphaned header labels**: a parameter never sampled at a given site can still print a header
   label with no matching unit-row token (no column of its own), which bled into a neighboring
   column's label (e.g. "Field Oxidation Field Reduction Turbidity Potential"). Fix: drop header
   words further than `max_label_dist` (25px) from every column center instead of force-assigning.

Also canonicalized minor cross-page OCR/line-wrap text-variant duplicates post-parse: "Field
Turbidity" → "Turbidity"; "Nitrate + Nitrite" / "Nitrate+ Nitrite" / "Nitrate/ Nitrite" → "Nitrate +
Nitrite" (same combined determination, confirmed same unit mg/L).

### Next step — Stage 5 (not started)

Join `other/output/pebble_chemistry_long.csv` to `other/output/pebble_nushagak_confirmed_sites.csv`
(by `site_id`/`station_id`) and integrate into `chapters/03_spatial_coverage.qmd`'s map: merge into
the existing station markers (not a separate toggleable layer), with popup text noting "Pebble
Project 2004-2008 baseline" to keep the source/era distinguishable. Also update
`chapters/02_data_sources.qmd` (already references `ch_09_water_quality_bb.pdf`) to document the new
pipeline outputs.
