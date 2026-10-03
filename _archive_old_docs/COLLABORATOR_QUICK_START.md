---

editor: 
  markdown: 
    wrap: 72
---

# Collaborator Quick Start Guide

Welcome to the Nushagak River Watershed Water Quality project!

------------------------------------------------------------------------

## 30-Second Setup

1.  **Clone the repo**:

    ``` bash
    git clone https://github.com/Rivulet-Research/nushagak-wqx.git
    cd nushagak-wqx
    ```

2.  **Open in RStudio**:

    - Double-click `nushagak-wqx.Rproj`
    - Or: `File > Open Project` → select `.Rproj` file

3.  **Install one-time dependencies**:

    ``` r
    install.packages(c("dataRetrieval", "dplyr", "ggplot2"))
    ```

4.  **Render the book**:

    ``` r
    quarto render --to html
    ```

    Open `_book/index.html` in your browser to view the rendered book.

------------------------------------------------------------------------

## Project Structure at a Glance

```         
nushagak-wqx/
├── chapters/           # 11 content chapters (01_intro through 11_data_management)
├── images/            # Maps, diagrams, watershed photo
├── _quarto.yml        # Book configuration (parts, chapters, formats)
├── index.qmd          # Title page and overview
├── references.bib     # BibTeX citations
├── README.md          # Full project overview
└── _book/             # Rendered HTML (auto-generated)
```

------------------------------------------------------------------------

## What This Project Is About

**Goal**: Synthesize existing water quality data for the Nushagak River watershed (southwest Alaska) to support collaborative monitoring efforts for three Native Village councils: Ekwok, New Koliganek, New Stuyahok.

**Key Stats**: - **Watershed**: 13,400 square miles, one of the world's largest wild salmon fisheries - **Data**: 212+ stations, 5,000+ observations from EPA Water Quality Portal (WQP) and USGS - **Current scope**: Four HUC8 sub-basins draining to Nushagak River (Togiak excluded—separate drainage) - **Output**: Interactive HTML book for web + downloadable DOCX for stakeholders

------------------------------------------------------------------------

## Chapter Overview

### Part I: Context & Baseline (Chapters 1–4)

- **01_intro**: Watershed and salmon ecology background
- **02_data_sources**: How to access WQP, NWIS, EPA, and gray literature
- **03_spatial_coverage**: Interactive map of all monitoring stations
- **04_parameters_summary**: What water quality parameters have been measured

### Part II: Water Quality Synthesis (Chapters 5–8)

- **05_physical_chemical**: Temperature, pH, dissolved oxygen, conductivity baseline
- **06_metals_contaminants**: Copper (and form distinction), zinc, molybdenum levels
- **07_nutrients_salmon**: Nitrogen, phosphorus, biological indicators
- **08_gaps_and_needs**: Where monitoring data are sparse; top priorities for new work

### Part III: RFP Context & Strategy (Chapters 9–11)

- **09_community_focus**: Geographic and thematic priorities for Ekwok, Koliganek, Stuyahok
- **10_monitoring_design**: Quality Assurance Project Plan (QAPP) structure, sampling methods
- **11_data_management**: Database design (WQX standards), visualization tools, governance

------------------------------------------------------------------------

## Key Facts for Contributors

### Data Sources

- **All data are public**: EPA WQP, USGS NWIS, published literature only
- **No proprietary data**: No tribal or private datasets included without permission
- **Current through**: March 2024 (WQP/NWIS cutoff)
- **Data queries are reproducible**: All code is in `.qmd` files; anyone can re-run queries

### Geographic Scope: Four HUC8s

| HUC8     | Name           | Notes                             |
|----------|----------------|-----------------------------------|
| 19030301 | Upper Nushagak | 20 stations, 1,324 observations   |
| 19030302 | Mulchatna      | Tributary basin                   |
| 19030303 | Main Nushagak  | Confluence and mainstem           |
| 19030304 | Wood River     | Tributary basin (sparse coverage) |

**Excluded**: HUC 19030305 (Togiak River) drains separately into Bristol Bay; not part of Nushagak drainage.

### Key Finding: Metal Form Distinction

Chapter 06 distinguishes copper by form (dissolved vs. suspended vs. total vs. recoverable): - **Dissolved** (41 obs.): Mean 2.02 µg/L — most bioavailable, immediately toxic to fish - **Suspended** (13 obs.): Mean 5.69 µg/L — less bioavailable, sediment-associated - **Total** (8 obs.): Mean 1.93 µg/L — mass-balance assessment - **Recoverable** (3 obs.): Mean 16.67 µg/L — highest values, sediment source

This distinction is **critical for interpreting contamination risk**.

------------------------------------------------------------------------

## Common Editing Tasks

### Add or Update a Chapter Section

1.  Open the relevant `.qmd` file in RStudio (e.g., `chapters/07_nutrients_salmon.qmd`)
2.  Edit as needed (markdown text + R code chunks)
3.  Save the file
4.  Test locally: `quarto render --to html`
5.  Open `_book/index.html` to verify the change appears

### Query New WQP Data

Use the `dataRetrieval` package in any code chunk:

``` r
library(dataRetrieval)

# Query a specific site
new_data <- readWQPdata(siteid = "USGS-15303500", 
                        siteType = "Stream", 
                        startDate = "2024-01-01")

# Or query by HUC
new_huc_data <- readWQPdata(huc = "19030302", 
                            startDate = "2024-01-01")
```

All data from WQP includes metadata (parameter names, units, site info, dates).

### Update a Table or Summary

Most parameter summaries (temperature, pH, copper, etc.) are generated dynamically:

``` r
# Example: Re-compute temperature summary
temp_stats <- temp_data |>
  summarise(
    N = n(),
    Mean = mean(value, na.rm = TRUE),
    Median = median(value, na.rm = TRUE),
    Min = min(value, na.rm = TRUE),
    Max = max(value, na.rm = TRUE),
    SD = sd(value, na.rm = TRUE)
  )

knitr::kable(temp_stats, caption = "Temperature Summary")
```

**No manual copy-paste tables**—all are code-generated and reproducible.

------------------------------------------------------------------------

## Collaboration Norms

### Branching

- Create a new branch for each improvement: `git checkout -b feature/description`
- Example: `feature/update-copper-analysis`, `feature/add-wood-river-section`
- Keep commits focused and descriptive

### Pull Requests

- Describe what you changed and why
- Reference relevant chapters or data sources
- Request review before merging to `main`

### Commit Messages

```         
Concise one-liner (50 chars)

Optional: Longer explanation if the change is non-obvious.
Mention HUC/chapter/parameter if relevant.
```

### Code Style

- Use base R pipe `|>` (not magrittr `%>%`)
- Keep code comments brief; explain **why**, not **what**
- Use `knitr::kable()` for tables (not `print()` or `cat()`)

------------------------------------------------------------------------

## Troubleshooting

### "dataRetrieval not found"

``` r
install.packages("dataRetrieval")
library(dataRetrieval)
```

### Render fails with "output-dir: \_book does not exist"

``` r
dir.create("_book")  # Create the directory if missing
quarto render --to html
```

### Interactive map (Chapter 03) not showing in HTML

- Maps require a web browser to view
- If using RStudio Viewer, click the "Show in new window" button
- DOCX output will skip the map (expected—Leaflet doesn't work in Word)

### Data queries return different results than expected

- WQP data are updated quarterly; you may see new observations
- Verify HUC codes are correct: `c("19030301", "19030302", "19030303", "19030304")`
- Check date range in queries (default is no date filter; may return very old data)

------------------------------------------------------------------------

## Questions?

- **General project questions**: See `README.md`
- **Data questions**: See Chapter 02 (Data Sources) or Chapter 04 (Parameters)
- **WQP API questions**: https://www.waterqualitydata.us
- **Quarto documentation**: https://quarto.org
- **Contact**: Benjamin Meyer (rivuletresearch\@gmail.com)

------------------------------------------------------------------------

## Next Steps

1.  ✅ Clone repo and render locally
2.  ✅ Read this guide and `README.md`
3.  ✅ Review Chapter 01 (intro) and Chapter 03 (map) to understand the watershed
4.  ✅ Suggest improvements or open an issue in GitHub
5.  ✅ Create a pull request when ready to contribute

**Welcome aboard!**
