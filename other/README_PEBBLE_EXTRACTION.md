# Pebble Data Extraction & Integration: Complete Guide

**Status**: Ready to begin  
**Last Updated**: October 4, 2026  
**Estimated Time**: 2–3 hours total

---

## 📋 Quick Navigation

### For Different Needs:

| If you want... | Read this |
|---|---|
| **TL;DR walkthrough** | [`QUICK_START_PEBBLE.md`](QUICK_START_PEBBLE.md) — 5 min read, hands-on steps |
| **Copy-paste commands** | [`PEBBLE_COMMAND_REFERENCE.txt`](PEBBLE_COMMAND_REFERENCE.txt) — Handy reference card |
| **Detailed workflow** | [`PEBBLE_WORKFLOW_SUMMARY.md`](PEBBLE_WORKFLOW_SUMMARY.md) — Full overview + decision points |
| **Complete plan** | [`PEBBLE_EXTRACTION_PLAN.md`](PEBBLE_EXTRACTION_PLAN.md) — In-depth with troubleshooting |
| **Code templates** | [`PEBBLE_INTEGRATION_CODE_TEMPLATES.md`](PEBBLE_INTEGRATION_CODE_TEMPLATES.md) — Ready-to-use R code |

---

## 🎯 What You're Building

An interactive map in `chapters/03_spatial_coverage.qmd` that shows:

- **WQP stations** (blue dots) — data from WQP API query
- **Pebble Project stations** (orange dots) — baseline monitoring from EIS PDFs
- **Layer toggle** — users can turn each data source on/off
- **Popups** — click a dot to see station ID, HUC, and source

**Map before**: Only WQP stations  
**Map after**: WQP + Pebble, side-by-side, in a single interactive visualization

---

## 🔄 The 4-Stage Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ Stage 1: Python Scans PDFs (5 min)                          │
│ Locates candidate tables via keyword matching               │
└──────────────────┬──────────────────────────────────────────┘
                   │ You review the flagged tables CSV
┌──────────────────▼──────────────────────────────────────────┐
│ Stage 2: Manual Transcription (1-2 hours)                   │
│ You extract coordinates from PDF station-location tables    │
└──────────────────┬──────────────────────────────────────────┘
                   │ You save coordinates CSV
┌──────────────────▼──────────────────────────────────────────┐
│ Stage 3: R Validates Coordinates (2 min)                    │
│ Tests each coordinate against HUC8 boundaries               │
└──────────────────┬──────────────────────────────────────────┘
                   │ Confirmed sites CSV is ready
┌──────────────────▼──────────────────────────────────────────┐
│ Stage 4: Integrate into Chapter (30 min)                    │
│ Add Pebble layer to the map and update code                │
└─────────────────────────────────────────────────────────────┘
```

**Each stage builds on the previous one.** No backtracking needed if you follow the steps carefully.

---

## 📁 Files You'll Work With

### Already Provided ✓

```
scripts/python/
  └─ extract_pebble_nushagak.py ........... Stage 1 scanner

scripts/R/
  ├─ filter_pebble_by_huc8.R ............. Stage 3 validator
  └─ pebble_site_coordinates_template.csv  Template for Stage 2

other/input/pebble/
  └─ pebble-feis_ch3-section-16.pdf ....... Source data (20 MB)
```

### You Create in Stage 2

```
other/input/pebble/
  └─ pebble_site_coordinates.csv ......... Your coordinate transcriptions
```

**Format** (copy from template):
```
station_id,lat,lon,source_pdf,page,notes
MUL-01,59.452,-156.382,pebble-feis_ch3-section-16.pdf,42,Mulchatna mainstem
```

### Auto-Generated in Stages 1 & 3 (Gitignored)

```
other/output/
  ├─ pebble_nushagak_sites.csv ........... Stage 1 output (review this)
  ├─ pebble_sites_huc8_check.csv ......... Stage 3 output (all sites)
  ├─ pebble_nushagak_confirmed_sites.csv . Stage 3 output (KEY—for map)
  └─ nushagak_huc8_boundary.gpkg ......... Stage 3 cached boundaries
```

### You Edit in Stage 4

```
chapters/03_spatial_coverage.qmd ......... Add Pebble loader + update map code
```

---

## 🚀 Getting Started: Choose Your Path

### Path A: Just Start (Recommended)

1. Open [`QUICK_START_PEBBLE.md`](QUICK_START_PEBBLE.md)
2. Follow steps 1–4 in order
3. Refer to [`PEBBLE_COMMAND_REFERENCE.txt`](PEBBLE_COMMAND_REFERENCE.txt) for exact commands

**Time**: ~2 hours with this path.

### Path B: Understand First

1. Read [`PEBBLE_WORKFLOW_SUMMARY.md`](PEBBLE_WORKFLOW_SUMMARY.md) for context
2. Follow [`QUICK_START_PEBBLE.md`](QUICK_START_PEBBLE.md) for execution
3. Consult [`PEBBLE_EXTRACTION_PLAN.md`](PEBBLE_EXTRACTION_PLAN.md) for troubleshooting

**Time**: ~2.5 hours with this path (more reading up front).

### Path C: Deep Dive

1. Start with [`PEBBLE_EXTRACTION_PLAN.md`](PEBBLE_EXTRACTION_PLAN.md) for complete context
2. Use [`PEBBLE_WORKFLOW_SUMMARY.md`](PEBBLE_WORKFLOW_SUMMARY.md) as reference
3. Consult [`PEBBLE_INTEGRATION_CODE_TEMPLATES.md`](PEBBLE_INTEGRATION_CODE_TEMPLATES.md) for alternatives

**Time**: ~3 hours (thorough understanding).

---

## ⚡ The Essentials

### What You Must Do (Can't Skip)

1. **Create `other/input/pebble/pebble_site_coordinates.csv`** (Stage 2)
   - Copy the template from `scripts/R/pebble_site_coordinates_template.csv`
   - Fill in coordinates from the PDF (one row per site)
   - This is the bottleneck step (1–2 hours of manual work)

2. **Edit `chapters/03_spatial_coverage.qmd`** (Stage 4)
   - Add 8-line Pebble loader to setup chunk
   - Replace the leaflet map code (copy-paste from template)
   - Test render to verify it works

### What the Scripts Do Automatically

- **Stage 1**: Python scans PDFs and flags candidate tables
- **Stage 3**: R validates coordinates against HUC8 boundaries

You don't need to modify these scripts unless you want to change keywords or analysis logic.

---

## 🎓 Key Concepts

### Why This Approach?

**Problem**: Pebble EIS PDFs are thousands of pages. Can't send all text to AI.

**Solution**: Three-layer filtering
1. **Keyword scan** (Python) — Focus on relevant pages only
2. **Manual review** (Human) — Confirm which tables have coordinates
3. **Spatial validation** (R) — Ground-truth test against HUC8 boundaries

**Result**: Fast, transparent, reproducible. Token budget stays reasonable.

### Coordinate Format

Alaska coordinates are in **decimal degrees, both negative** (south & west):
- **Latitude**: 59.452°N = `59.452` (positive)
- **Longitude**: 156.382°W = `-156.382` (negative)
- **Example**: Mulchatna mouth ≈ `59.45, -156.38`

### HUC8 Boundaries

These four HUC8 codes define the Nushagak River drainage:
- `19030301` — Upper Nushagak
- `19030302` — Mulchatna
- `19030303` — Lower Nushagak (+ Nuyakuk)
- `19030304` — Wood River

The R script in Stage 3 tests whether each coordinate falls inside **all four** of these boundaries.

---

## ✅ Success Checklist

### Before You Start
- [ ] Read this file and choose a path above
- [ ] Verify PDF is in `other/input/pebble/` (it's already there)
- [ ] Understand the 4-stage workflow

### During Stages
- [ ] Stage 1: Python scan runs, CSV is created ✓
- [ ] Stage 2: You create coordinate CSV (manual work)
- [ ] Stage 3: R script runs, confirmed sites CSV created ✓
- [ ] Stage 4: You edit chapter 03, map displays both layers ✓

### Final Success Criteria
- [ ] `chapters/03_spatial_coverage.qmd` renders without errors
- [ ] Interactive map shows **both blue (WQP) and orange (Pebble) dots**
- [ ] Orange dots have working popups (click → "Pebble: [ID] | HUC8: ...")
- [ ] Layer toggle in top-right control shows both "WQP Stations" and "Pebble Project Sites"
- [ ] Stage 3 console output shows **N > 0** confirmed sites

---

## 🆘 Help & Troubleshooting

### Quick Issues

| Problem | Fix |
|---------|-----|
| Python script won't run | Activate venv: `scripts\python\.venv\Scripts\activate` |
| Can't find station coordinates in PDF | Check Table of Contents & Appendices for "Station Locations" table |
| No sites confirmed in Stage 3 | Verify CSV format: `station_id,lat,lon,...` (numeric lat/lon, not text) |
| Map doesn't show Pebble layer | Verify `pebble_nushagak_confirmed_sites.csv` exists and has data |

### Full Troubleshooting

See **Troubleshooting** sections in:
- [`PEBBLE_EXTRACTION_PLAN.md`](PEBBLE_EXTRACTION_PLAN.md) — Detailed Q&A
- [`PEBBLE_COMMAND_REFERENCE.txt`](PEBBLE_COMMAND_REFERENCE.txt) — Common errors + fixes

---

## 📚 Complete Documentation Map

```
README_PEBBLE_EXTRACTION.md (this file)
│
├─→ QUICK_START_PEBBLE.md ..................... 5-min TL;DR
├─→ PEBBLE_COMMAND_REFERENCE.txt .............. Commands only
├─→ PEBBLE_WORKFLOW_SUMMARY.md ............... Overview + diagrams
├─→ PEBBLE_EXTRACTION_PLAN.md ................ Detailed plan + troubleshooting
├─→ PEBBLE_INTEGRATION_CODE_TEMPLATES.md ..... Ready-to-use code
│
├─→ scripts/README.md ......................... Technical script docs
├─→ chapters/02_data_sources.qmd ............. Data source context
├─→ chapters/03_spatial_coverage.qmd ......... Integration point
│
└─→ scripts/python/extract_pebble_nushagak.py .. Stage 1 script
    scripts/R/filter_pebble_by_huc8.R ........ Stage 3 script
```

---

## 🎯 Next Steps

1. **Pick your reading path** (A, B, or C above)
2. **Start with Stage 1** — Run the Python scan (10 min)
3. **Review the flagged tables CSV** — Identify candidate sites
4. **Complete Stage 2** — Transcribe coordinates (1–2 hours)
5. **Run Stage 3** — Validate with R script (2 min)
6. **Complete Stage 4** — Integrate into chapter 03 (30 min)
7. **Verify** — Render and check the map

**Estimated total time: 2–3 hours**, mostly spent on manual transcription in Stage 2.

---

## 💡 Pro Tips

- **Before Stage 2**: Open the PDF in a PDF viewer and use "Find" (Ctrl+F) to search for station-location tables
- **During Stage 2**: Keep a text editor + PDF viewer side-by-side; copy-paste coordinates when possible
- **After Stage 3**: Before Stage 4, open `pebble_nushagak_confirmed_sites.csv` in RStudio to verify your sites
- **During Stage 4**: Test incrementally—run the map chunk in isolation after each edit to catch errors early

---

## Questions?

This documentation covers all major steps and common issues. If you get stuck:

1. **Check the troubleshooting section** in [`PEBBLE_EXTRACTION_PLAN.md`](PEBBLE_EXTRACTION_PLAN.md)
2. **Review the relevant stage** in [`QUICK_START_PEBBLE.md`](QUICK_START_PEBBLE.md)
3. **Examine the command reference** in [`PEBBLE_COMMAND_REFERENCE.txt`](PEBBLE_COMMAND_REFERENCE.txt)

Each document is cross-referenced for easy navigation.

---

## 🎓 Understanding the Full Context

If you want to understand **why** this workflow exists and **how** it fits into the larger project:

- **Data source context**: See `chapters/02_data_sources.qmd` (Pebble section)
- **Spatial analysis**: See `chapters/03_spatial_coverage.qmd` (integration point)
- **Design decisions**: See `PEBBLE_WORKFLOW_SUMMARY.md` → "Why This Multi-Stage Approach"

---

## 🚀 Ready?

👉 **Start here**: [`QUICK_START_PEBBLE.md`](QUICK_START_PEBBLE.md)

(Or [`PEBBLE_WORKFLOW_SUMMARY.md`](PEBBLE_WORKFLOW_SUMMARY.md) if you want more context first.)

Good luck! 🎯
