---

editor: 
  markdown: 
    wrap: 72
---

# GitHub Pages Deployment

The current setup is correct. The book renders to `_book/` folder, and GitHub Actions automatically publishes it to GitHub Pages.

## How It Works

1.  You push to `main` branch
2.  GitHub Actions runs (automatically triggered)
3.  Quarto renders to `_book/` folder
4.  GitHub Actions uploads `_book/` as the artifact
5.  GitHub Pages serves the site from that artifact

The workflow is in `.github/workflows/render-and-publish.yml`

## What Gets Published

Everything in `_book/` folder: - `index.html` (entry point) - All chapter HTML files - CSS, JavaScript resources - Generated DOCX file

## View the Published Site

https://rivulet-research.github.io/nushagak-wqx/

Updates within 2-3 minutes of push to main.

## Directory Structure Note

**No separate `docs/` folder needed.** GitHub Pages can be configured to publish from `_book/` (which is what we're doing via the Actions workflow).

The `docs/` folder in this repo contains project documentation (like `AGENTS.md`), not the rendered book. This is separate and correct.

If you ever wanted to serve GitHub Pages from a `docs/` folder instead, you'd: 1. Change `_quarto.yml` `output-dir: docs` 2. Commit the `docs/` folder to git 3. Enable GitHub Pages to publish from `docs/` folder in repo settings

But the current approach (publish from Actions artifact) is cleaner and avoids committing generated files to git.
