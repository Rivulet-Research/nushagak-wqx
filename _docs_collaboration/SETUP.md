# Setup Instructions

Clone the repository:

``` bash
git clone https://github.com/Rivulet-Research/nushagak-wqx.git
cd nushagak-wqx
```

Install R packages:

``` r
install.packages(c("dataRetrieval", "dplyr", "ggplot2"))
```

Open RStudio project: Double-click `nushagak-wqx.Rproj` or use `File > Open Project`.

Render the book:

``` r
quarto render --to html
```

View output: Open `_book/index.html` in a web browser.

------------------------------------------------------------------------

## Project Structure

- `chapters/` — 11 content chapters (01_intro through 11_data_management)
- `images/` — Maps and figures
- `_quarto.yml` — Book configuration
- `index.qmd` — Title page
- `references.bib` — Bibliography

## Data

All data from EPA Water Quality Portal (WQP) and USGS NWIS. Public sources only.

Spatial coverage: Four HUC8 sub-basins draining to Nushagak River (19030301, 19030302, 19030303, 19030304). HUC 19030305 (Togiak River) excluded as separate drainage.

Stations: 212+\
Observations: \~5,000\
Data current through: March 2024

## Workflow

1.  Create a branch: `git checkout -b feature/description`
2.  Edit chapter files as needed
3.  Test locally: `quarto render --to html`
4.  Commit: `git commit -m "Update Chapter X: description"`
5.  Push: `git push origin feature/description`

GitHub Actions will automatically render and deploy on push to main.

------------------------------------------------------------------------

## Files Not to Edit

- `_quarto.yml`
- `.github/workflows/`
- `references.bib` (without proper source management)

Safe to edit: - All files in `chapters/` - `README.md` - Content files

------------------------------------------------------------------------

## Common Issues

**Missing packages**: `install.packages("dataRetrieval")`

**Map not showing**: Open `_book/index.html` in web browser, not RStudio Viewer

**Render fails**: Check R console for error output; verify all packages installed

**DOCX download not working**: Run `quarto render --to docx`

------------------------------------------------------------------------

## Contact

Benjamin Meyer (rivuletresearch\@gmail.com)\
Repository: https://github.com/Rivulet-Research/nushagak-wqx
