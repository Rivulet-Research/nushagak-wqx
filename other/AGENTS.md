# Nushagak WQX Project Memory

## Project Overview

A Quarto book project synthesizing existing water quality data in the Nushagak River watershed (HUC6: 190303) to support a bid submission for the Native Village of Ekwok collaborative monitoring program (RFP).

**Location**: `C:/Users/Benjamin/OneDrive/Documents/GitHub_Local/rivulet/nushagak-wqx/`

**Purpose**: Exploratory analysis demonstrating professional, thorough baseline water quality assessment without AI bloat. This is a bid support document.

---

## Watershed Context

**Three participating communities:**
- Native Village of Ekwok
- New Koliganek Village Council
- New Stuyahok Village Council

**Five HUC8 sub-basins (Nushagak drainage, HUC6: 190303), names per the official USGS Watershed Boundary Dataset (confirmed via `nhdplusTools::get_huc()`):**
- 19030301 — Upper Nushagak River (20 stations, 1,324 WQP results)
- 19030302 — Mulchatna River
- 19030303 — Lower Nushagak River (includes the Nuyakuk River tributary; not to be confused with the Nuyakuk itself)
- 19030304 — Wood River
- 19030305 — Togiak (excluded from the four-HUC Nushagak drainage analysis; drains separately into Bristol Bay)

**RFP Goal 1**: Establish continuous monitoring efforts (QAPP development, equipment, field training, 3-year baseline dataset)

**RFP Goal 2**: Enhance data collection and management (GIS visualization, electronic field data entry, centralized database, data sharing systems)

---

## Book Structure (3 Parts, ~10 chapters)

### Part I: Watershed Context & Existing Baseline
1. **Intro**: Watershed overview, salmon ecology, community context
2. **Data Inventory**: Sources, methods, and what's queryable via API
3. **Spatial Coverage**: Interactive map of all monitoring stations (five HUC8s)
4. **Temporal & Parameter Summary**: What parameters exist, data gaps, frequency

### Part II: Baseline Water Quality Synthesis
5. **Physical/Chemical**: pH, temperature, DO, conductivity patterns
6. **Metals & Contaminants**: Copper, zinc, molybdenum, acid-generating potential
7. **Nutrients & Salmon Indicators**: Nitrogen, phosphorus, dissolved oxygen for fishery context
8. **Data Gaps & Monitoring Needs**: What's missing, where new effort should focus

### Part III: RFP Context & Strategy
9. **Ekwok/Koliganek/Stuyahok Focus**: Geographic and thematic water quality priorities
10. **Monitoring Design Fundamentals**: QAPP elements, parameter selection, frequency rationale
11. **Data Management Workflow**: Electronic entry, centralized storage, visualization architecture

---

## Data Sources — Priority & Accessibility

### Priority 1: Directly Queryable via R API (implement first)
- **WQP (EPA WQX, USGS NWIS)**: `dataRetrieval::readWQPdata()` and `whatWQPdata()`
- **USGS NWIS**: `dataRetrieval::readNWISdata()` for streamflow, continuous temperature
- **Note**: WQP data current through March 2024; adequate for baseline assessment

### Priority 2: Manual Portal Query (secondary)
- **Alaska DEC Water Quality Portal**: Browse web portal, export CSVs as needed
- **Cook Inletkeeper Stream Temperature Network**: Temperature logger data; may have downloadable export

### Priority 3: Grey Literature (reference, not primary data)
- **EPA Bristol Bay Watershed Assessment (BBWA)**: Summary tables, narrative synthesis
- **Pebble Project EIS/Environmental Baseline Document**: Mulchatna/Koktuli drainage data; tables in PDFs (OCR or manual extraction possible)
- **Academic literature**: Supplementary datasets, reference context
- **Tribal monitoring (BBNA, LEO network)**: Data held privately; note as partnership opportunity, not core analysis

---

## Writing Style Notes

- Minimize AI tropes: no excessive em-dashes, avoid flowery transitions
- Use data and R code to drive narrative; let numbers speak
- All financial/technical calculations in R; use `knitr::kable()` for static tables, `ggplot2` for charts
- Estimated/placeholder values clearly marked with warning callouts
- Professional tone: informative, not promotional; emphasize rigor and data transparency
- Target audience: Grant reviewers and tribal leadership (technical competence + community respect)

---

## RFP Key Dates & Milestones
- Draft QAPP submission to Ekwok and EPA: December 1, 2026
- EPA final QAPP approval: March 1, 2027
- Project end date: September 30, 2029
- (This Quarto book is exploratory baseline work to support bid proposal, not part of formal deliverables)

---

## Current Status

✓ WQP API access confirmed (20–34 stations per HUC, 800–1,300+ results each)
⧖ Book skeleton to be scaffolded
⧖ Data exploration and synthesis chapters to be written (iterative with user review)
