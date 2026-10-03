# Nushagak River Watershed Water Quality Baseline

A Quarto book synthesizing existing water quality data for the Nushagak River watershed (HUC6: 190303) in southwestern Alaska. This analysis supports a bid proposal for a new collaborative water quality monitoring program.

## Project Structure

```         
nushagak-wqx/
├── _quarto.yml                 # Book configuration (parts, chapters, format)
├── index.qmd                   # Title and overview
├── 01_intro.qmd                # Watershed context and communities
├── 02_data_sources.qmd         # Data repositories and access methods
├── 03_spatial_coverage.qmd     # Interactive map of monitoring stations
├── 04_parameters_summary.qmd   # Parameter inventory and gaps
├── 05_physical_chemical.qmd    # Temperature, pH, DO, conductivity baseline
├── 06_metals_contaminants.qmd  # Copper, zinc, and trace element summary
├── 07_nutrients_salmon.qmd     # Nutrients and biological indicators
├── 08_gaps_and_needs.qmd       # Data gaps and monitoring priorities
├── 09_community_focus.qmd      # Ekwok, Koliganek, Stuyahok priorities
├── 10_monitoring_design.qmd    # QAPP fundamentals and station selection
├── 11_data_management.qmd      # Database and visualization systems
├── references.qmd              # Bibliography and resources
├── references.bib              # BibTeX citations
├── README.md                   # This file
└── _book/                      # Rendered HTML output (auto-generated)
```

## Quick Start

### Render the Book

From the project root:

``` r
quarto render --to html
```

Or preview in RStudio:

``` r
quarto preview
```

### Viewing the Output

Once rendered, open `_book/index.html` in a browser to view the compiled book.

------------------------------------------------------------------------

## Outline at a Glance

### Part I: Watershed Context & Existing Baseline

1.  **Intro**: Watershed overview, salmon ecology, community context
2.  **Data Sources**: Public repositories and data access methods
3.  **Spatial Coverage**: Interactive map of monitoring stations across five HUC8s
4.  **Parameters**: What water quality parameters have been measured; where gaps exist

### Part II: Baseline Water Quality Synthesis

5.  **Physical/Chemical**: Temperature, pH, dissolved oxygen, conductivity patterns
6.  **Metals & Contaminants**: Copper, zinc, molybdenum baseline levels
7.  **Nutrients & Salmon**: Nitrogen, phosphorus, biological indicators
8.  **Gaps & Needs**: Where new monitoring efforts should focus

### Part III: RFP Context & Strategy

9.  **Community Focus**: Ekwok, Koliganek, Stuyahok geographic and possible thematic priorities
10. **Monitoring Design**: QAPP fundamentals, parameter selection, station locations
11. **Data Management**: Database architecture, visualization, QA/QC, governance

------------------------------------------------------------------------

## Data Sources

All data are drawn from publicly available repositories:

- **Water Quality Portal (WQP)**: EPA WQX and USGS NWIS data aggregated
- **USGS NWIS**: Streamflow and long-term water chemistry records
- **Alaska DEC**: State-level water quality monitoring reports
- **Grey literature**: EPA Bristol Bay Assessment, Pebble EIS baseline data, academic publications

Data are current through **March 2024** (WQP/NWIS cutoff).

------------------------------------------------------------------------

## Key Findings

- **Upper Nushagak (HUC 19030301)**: 20 stations, 1,324 water quality observations
- **Lower Nushagak/Snake (HUC 19030305)**: 34 stations, 896 observations
- **Gaps**: Nutrients (N, P) are poorly characterized; metal data are sparse; biological sampling is limited; tributary coverage (Nuyakuk, Wood) is minimal

------------------------------------------------------------------------

## Usage Notes

- All data queries and visualizations are reproducible R code within `.qmd` files
- Chapters render independently; modify code chunks as needed for focused analysis

------------------------------------------------------------------------

## Author & License

See `LICENSE` file for terms.
