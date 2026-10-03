# Multi-Format Rendering Setup

This Quarto book is configured to render in three formats: HTML (for GitHub Pages), DOCX, and PDF.

## Formats

- **HTML**: Serves as the primary online documentation on GitHub Pages (via workflow)
- **DOCX**: Word document available for download from the sidebar
- **PDF**: PDF version (requires LaTeX installation locally)

## Local Rendering

To render locally:

```bash
# Render all formats
quarto render

# Render specific format
quarto render --to html
quarto render --to docx
quarto render --to pdf
```

Outputs go to the `_book/` directory.

## GitHub Pages Setup

A GitHub Actions workflow (`.github/workflows/render-and-publish.yml`) automatically:

1. Renders the HTML version when you push to `main`
2. Renders the DOCX version and places it in `_book/` for download
3. Deploys the HTML to GitHub Pages at `https://rivulet-research.github.io/nushagak-wqx/`

### Enable GitHub Pages

1. Go to **Settings** → **Pages**
2. Set **Build and deployment** → **Source** to `Deploy from a branch`
3. Set **Branch** to `gh-pages` (the workflow creates this automatically)

## Sidebar Tools

The left sidebar includes:

- **Download DOCX**: Points to `nushagak-wqx.docx` in the `_book/` directory after rendering
- **GitHub Repository**: Links to the repository at https://github.com/Rivulet-Research/nushagak-wqx

These are configured in `_quarto.yml` under `book.sidebar.tools`.

## Troubleshooting

### Render Error: Column doesn't exist

The error in `05_physical_chemical.qmd` has been fixed. The code was trying to select `MonitoringLocationName` which doesn't exist in the filtered dataset. The selection has been updated to only fetch `ResultMeasureValue`.

### DOCX not appearing in sidebar

After rendering locally, run:
```bash
quarto render --to docx
```

The DOCX will be created in `_book/nushagak-wqx.docx`. When you push to GitHub, the workflow automatically places it there for download.

### GitHub Actions workflow stuck

Check the workflow status under **Actions** in your repository. Common issues:
- R package dependencies not installed (update `.github/workflows/render-and-publish.yml` `install.packages()` if needed)
- GitHub Pages not enabled (see setup above)
- Branch protection rules preventing deployment (temporarily disable if needed)

