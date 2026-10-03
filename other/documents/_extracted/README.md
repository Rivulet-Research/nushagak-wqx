# Nushagak River Watershed Water Quality Analysis - RStudio Project

## Project Background & Context

This project synthesizes existing water quality data for the **Nushagak River Watershed** (HUC6: 190303), located in Southwestern Alaska. 

### Watershed HUC8 Sub-basins Included:
* **19030301** – Upper Nushagak River
* **19030302** – Mulchatna River
* **19030303** – Nuyakuk River
* **19030304** – Wood River
* **19030305** – Snake River / Lower Nushagak

### Goals of the Project:
1. **Consolidate Data Sources**: Aggregate data from major archived public repositories (EPA CDX/WQP, USGS NWIS, DEC) alongside key non-repository data sources (EPA Bristol Bay Watershed Assessment, Pebble EIS Environmental Baseline Document, tribal monitoring networks, and academic literature).
2. **Spatial Mapping & Baseline Summary**: Inventory all sampling locations across the HUC8 sub-basins and map them interactively to evaluate geographical and historical coverage.
3. **RStudio & Posit Assistant Migration**: Provide a structured R environment where you can interactively pull raw water quality parameter datasets (e.g., pH, metals, nutrients, dissolved oxygen) and perform customized analytical workflows.

---

## Package Contents

* **`nushagak_wq_summary.qmd`**: A executable Quarto document that queries the Water Quality Portal REST API using `dataRetrieval`, maps all monitoring stations interactively with `leaflet`, and generates summary tables with `DT`.
* **`data_sources_catalog.md`**: A detailed, curated reference list of both archived public repositories and grey/regulatory literature relevant to the watershed.
* **`README.md`**: Project overview, goals, and step-by-step instructions.

---

## Quickstart Guide

1. **Unzip** this archive on your machine.
2. Open **RStudio** and go to `File > New Project... > Existing Directory`.
3. Select the folder where you extracted these files.
4. Open `nushagak_wq_summary.qmd` and click **Render** (or press `Ctrl+Shift+K` / `Cmd+Shift+K`) to generate the complete HTML report with the interactive map.

---

## Working with Posit Assistant in RStudio

Once loaded into RStudio, you can collaborate with **Posit Assistant** by using prompts such as:

* *"Execute Chunk 4 in `nushagak_wq_summary.qmd` to download raw water quality data for HUC 19030302 (Mulchatna River) and filter for dissolved copper and pH."*
* *"Create a ggplot2 time-series chart showing seasonal variations in stream temperature across USGS and DEC monitoring sites."*
* *"Cross-reference sample site locations from `data_sources_catalog.md` with the WQP sites mapped in the Quarto report."*
