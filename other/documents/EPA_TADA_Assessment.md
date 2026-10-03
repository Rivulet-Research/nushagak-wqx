# EPA TADA Assessment for Nushagak WQX Project

## Summary: What is TADA?

**Tools for Automated Data Analysis (TADA)** is an EPA initiative comprising an R package (`EPATADA`) and Shiny web applications designed to help organizations compile, clean, and analyze water quality data from the Water Quality Portal (WQP). TADA provides three integrated modules:

1. **Module 1 (TADAShiny)**: Data Discovery and Cleaning — Retrieves WQP data, runs quality control screens, flags invalid metadata, handles unit conversions, and manages censored data.
2. **Module 2 (TADAShinyJoinToAU)**: Assessment Unit and Use Integration — Joins WQP monitoring locations with EPA ATTAINS assessment units and designated uses.
3. **Module 3 (TADAShinyAnalyze)**: Criteria and Methodologies Integration — Assigns water quality standards and analyzes data at monitoring location or assessment unit scales.

All tools are open-source and available on GitHub with active community development.

---

## Relevance to Nushagak WQX Project

### **High Relevance — Direct Applicability**

**1. Data Quality & Cleaning (Module 1)**
The current Nushagak project retrieves WQP data via the `dataRetrieval` R package. TADA's Module 1 provides systematic quality control that would complement or replace ad-hoc validation:

- **Automatic flagging of invalid metadata** using EPA WQX domain value validation services
- **Unit harmonization** (e.g., temperature in Fahrenheit vs. Celsius)
- **Detection limit (censored) data handling** — critical for trace metals analysis where many observations are below detection limits
- **Data visualization tools** for reviewing quality issues before final use

**Current workaround**: Manual filtering in code (e.g., `as.numeric()` conversions, explicit NA handling). TADA would standardize this and reduce errors.

---

**2. Data Gap Identification & Assessment Design (Module 2 & 3)**
The Nushagak project's stated goals include:
- Establishing a baseline across five HUC8 sub-basins (19030301–19030305)
- Identifying gaps where new monitoring would be most valuable
- Preparing the 2027 RFP response on continuous monitoring strategy

TADA's Module 2 capabilities could assist in:
- Spatially joining WQP stations to Alaska assessment units (if available in ATTAINS)
- Documenting which designated uses (aquatic life, recreation, subsistence) are assigned to each sub-basin
- Flagging gaps in parameter coverage relative to regulatory requirements

**Current gap**: The project manually identifies gaps via literature review and visual inspection. TADA could formalize this process.

---

### **Potential Limitations & Caveats**

**1. Alaska-Specific Assessment Units**
TADA integrates with EPA's ATTAINS system (Assessment, TMDL Tracking and Implementation System). However:
- Alaska's assessment unit designations and water quality standards are managed through Alaska DEC, which may or may not be fully represented in ATTAINS.
- You would need to verify whether the Nushagak sub-basins have designated uses already mapped in ATTAINS, or whether manual crosswalking is needed.

**2. Non-Repository Data Sources**
TADA is designed for WQP/WQX data. The Nushagak project also relies on:
- Pebble Project EIS environmental baseline data
- EPA Bristol Bay Watershed Assessment
- Tribal monitoring (BBNA, LEO network)
- Cook Inletkeeper stream temperature networks
- Academic literature (UAA AKNHP, NPS SWAN)

TADA cannot directly ingest these sources; they still require manual literature review and data compilation.

---

## Recommended Use Cases for Nushagak Project

### **Implement Now (Quick Wins)**
1. **Use TADA Module 1 (TADAShiny)** to systematically clean and validate WQP data for the five HUC8 sub-basins.
   - Saves time vs. manual column selection and type conversion errors (which you've already encountered in `06_metals_contaminants.qmd`).
   - Generates automated data quality flags and summary visualizations.
   - Outputs a certified data file for downstream analysis.

2. **Integrate EPATADA R package functions** directly into your Quarto chapters.
   - The `EPATADA` R package can be called from within `.qmd` files.
   - This allows you to leverage TADA's validation logic without switching away from your RStudio workflow.

### **Implement Later (If Time/Resources Permit)**
3. **Explore Module 2 (TADAShinyJoinToAU)** after confirming whether Alaska assessment units are represented in ATTAINS.
   - Contact TADA Team ([mywaterway@epa.gov](mailto:mywaterway@epa.gov)) to clarify Alaska coverage.
   - If Alaska uses a separate assessment system, you may need to create a custom crosswalk.

4. **Consider joining the TADA Working Group** for collaboration on Alaska-specific implementations and to share what you learn with other organizations working in similar regions.

---

## Implementation Path

**Option A (Minimal Effort):**
- Continue using `dataRetrieval` for WQP queries (already working).
- Add explicit calls to TADA's `readWQPdata()` wrapper function in relevant chapters to leverage validation.
- This replaces your current manual type conversions and NA handling.

**Option B (Deeper Integration):**
- Use TADAShiny web interface to clean and certify your WQP dataset once.
- Download the validated output and archive it as your "golden dataset."
- Read the cleaned dataset into Quarto chapters (no need to re-query).
- Reduces rendering time and ensures consistent data provenance.

---

## Resources

- **TADA GitHub Organization**: https://github.com/USEPA/EPATADA
- **EPATADA R Package Documentation**: https://usepa.github.io/EPATADA/
- **TADAShiny Application** (web interface): https://rconnect-public.epa.gov/TADAShiny/
- **TADA Working Group**: Contact [mywaterway@epa.gov](mailto:mywaterway@epa.gov) to inquire about membership
- **Related EPA Tool**: Water Quality Portal (WQP) — https://www.waterqualitydata.us/

---

## Next Steps

1. Test TADAShiny by uploading a subset of Nushagak WQP data (e.g., Mulchatna HUC 19030302) to see if data quality flags reveal issues not caught by visual inspection.
2. If useful, integrate EPATADA functions into your Quarto workflow (Modules 1–2).
3. Contact EPA TADA team if you need guidance on Alaska assessment unit coverage.

