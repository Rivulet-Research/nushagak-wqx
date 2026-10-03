# Collaborator Onboarding Checklist

**Welcome to the Nushagak River Water Quality project!**

Print this page or keep it open while you get started. It should take about 10 minutes.

------------------------------------------------------------------------

## Step 1: Clone the Repository (2 min)

``` bash
git clone https://github.com/Rivulet-Research/nushagak-wqx.git
cd nushagak-wqx
```

- [ ] Repository cloned successfully
- [ ] You're in the `nushagak-wqx` directory

------------------------------------------------------------------------

## Step 2: Install R Packages (2 min)

Open R or RStudio and run:

``` r
install.packages(c("dataRetrieval", "dplyr", "ggplot2"))
```

Wait for all three to install. This is one-time only.

- [ ] `dataRetrieval` installed
- [ ] `dplyr` installed
- [ ] `ggplot2` installed

------------------------------------------------------------------------

## Step 3: Open RStudio Project (1 min)

**Option A**: Double-click `nushagak-wqx.Rproj` in the repository folder

**Option B**: In RStudio, `File > Open Project` → select `nushagak-wqx.Rproj`

- [ ] RStudio opened with the project
- [ ] Project name shows "nushagak-wqx" in the top-right corner

------------------------------------------------------------------------

## Step 4: Render the Book (2–3 min)

In RStudio console, run:

``` r
quarto render --to html
```

Wait for render to complete. Last line should be: `Output created: _book\index.html`

- [ ] Render completed without errors
- [ ] Output line says "Output created: \_book\index.html"

------------------------------------------------------------------------

## Step 5: View the Rendered Book (1 min)

Open this file in your web browser:

```         
_book/index.html
```

Or: In RStudio File Explorer, navigate to `_book/` → double-click `index.html`

- [ ] Book opens in browser
- [ ] You can see the title: "Nushagak River Watershed Water Quality Baseline"
- [ ] All 11 chapters are visible in the left sidebar

------------------------------------------------------------------------

## Step 6: Explore the Key Chapter (1 min)

Click on **Chapter 3: Spatial Coverage** in the sidebar.

- [ ] Chapter 3 opens
- [ ] You can see an **interactive map** with blue dots (monitoring stations)
- [ ] Map is zoomable and draggable (click and drag to move around)

**What you're seeing**: All 212+ water quality monitoring stations in the Nushagak River watershed.

------------------------------------------------------------------------

## Step 7: Verify the DOCX Download (30 sec)

On the right side of the toolbar (top), look for a cloud download icon with text "Download DOCX".

- [ ] You can see the "Download DOCX" button
- [ ] Click it to download the Word document version

------------------------------------------------------------------------

## Step 8: Read the Quick Start Guide (5 min)

Open and read: **COLLABORATOR_QUICK_START.md**

This file is in the root directory of the repository.

- [ ] File opened
- [ ] You've read at least the first three sections:
  - [ ] 30-Second Setup
  - [ ] Project Structure at a Glance
  - [ ] What This Project Is About

------------------------------------------------------------------------

## Step 9: Understand the Git Workflow (2 min)

For your first contribution:

1.  Create a branch:

    ``` bash
    git checkout -b feature/your-description
    ```

    (Example: `feature/update-chapter-05-temperature`)

2.  Edit chapter files (`.qmd` files) as needed

3.  Test locally:

    ``` bash
    quarto render --to html
    ```

4.  Commit when ready:

    ``` bash
    git add chapters/
    git commit -m "Update Chapter X: describe your change"
    ```

5.  Push:

    ``` bash
    git push origin feature/your-description
    ```

6.  On GitHub, create a pull request (optional for review)

**For this checklist**: Just understand the concept. Don't actually create a branch yet unless you're ready to contribute.

- [ ] You understand the five-step workflow above
- [ ] You know how to create a branch with `git checkout -b`
- [ ] You know how to test with `quarto render --to html`

------------------------------------------------------------------------

## Step 10: Know What NOT to Change (Yet!)

These files should not be edited without discussion:

- [ ] `_quarto.yml` (book configuration)
- [ ] `references.bib` (bibliography)
- [ ] `.github/workflows/` (automation)

You **can safely edit**:

- [ ] Any file in `chapters/` (01_intro.qmd, 02_data_sources.qmd, etc.)
- [ ] `README.md`
- [ ] Content in `images/` and `other/` (with care)

------------------------------------------------------------------------

## Step 11: Bookmark These Resources

- **GitHub Repository**: https://github.com/Rivulet-Research/nushagak-wqx

- **Live Website**: https://rivulet-research.github.io/nushagak-wqx/

- **Quick Start Guide**: COLLABORATOR_QUICK_START.md (in repo root)

- **Pre-Push Checklist**: PRE_PUSH_VERIFICATION.md (in repo root)

- **WQP Data API**: https://www.waterqualitydata.us

- [ ] All bookmarked or noted

------------------------------------------------------------------------

## Step 12: Troubleshooting Test

If something didn't work above, run this:

``` bash
# Check that R packages are installed
Rscript -e "library(dataRetrieval); library(dplyr); library(ggplot2); cat('All packages loaded successfully!')"

# Check that Quarto is installed
quarto --version

# Check that you can see the repo
git remote -v
```

If all three show output without errors, you're good.

- [ ] All three commands returned output (no "not found" errors)

------------------------------------------------------------------------

## You're Done! 🎉

**Summary of what you now have**:

✅ Repository cloned to your computer\
✅ R packages installed\
✅ Book renders locally on your machine\
✅ You've seen the interactive map\
✅ You understand the contribution workflow\
✅ You know which files are safe to edit

**Next steps**:

1.  **Read the chapters** (especially Chapter 1 for context)
2.  **Identify what you'd like to improve** (add content, fix typos, clarify writing, etc.)
3.  **Open an issue on GitHub** to discuss your idea (optional)
4.  **Create a pull request** when you're ready to contribute

------------------------------------------------------------------------

## Questions?

- **Technical setup issues**: See PRE_PUSH_VERIFICATION.md → "Troubleshooting"
- **Project questions**: See COLLABORATOR_QUICK_START.md → "Questions?"
- **Data questions**: Read Chapter 2 (Data Sources) or Chapter 4 (Parameters)
- **Contact**: Benjamin Meyer (rivuletresearch\@gmail.com)

------------------------------------------------------------------------

**Date Completed**: \_\_\_\_\_\_\_\_\_\_\_\_\_\
**Notes / Questions**: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\
\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

------------------------------------------------------------------------

*Welcome to the team!*
