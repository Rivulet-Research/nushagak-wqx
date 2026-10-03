# Chapter Review & Spot-Check Summary
**October 3, 2026**

---

## I. Monitoring Program Design Chapter (10) — SOPs Guide Alignment

### Review Scope
Compared Chapter 10 prose and structure against the comprehensive SOPs guide (`existing_protocols_and_sops_guide.md`) to verify accurate integration of agency protocols, calibration standards, and field methods.

### Findings: **STRONG ALIGNMENT**

#### EPA Protocols ✓
- **Tier 2 tribal QAPP structure** cited correctly [@EPARegion10_TribalQAPP]
- **PARCC/PARCCS framework** (precision, accuracy, representativeness, completeness, comparability) detailed in "Quality Objectives" section
- **WQX data standards** referenced in "Electronic Data Collection" section
- Multi-parameter sonde calibration (2-point pH 7.0/10.0 buffer, 100% air-saturation DO calibration) accurately stated

#### USGS Protocols ✓
- **National Field Manual Book 9** cited with Chapter A4 (Equal-Width-Increment/Equal-Discharge-Increment cross-sectional sampling) and Chapter A6 (field measurement stabilization)
- Stabilization criteria correct: temperature ±0.2°C, pH ±0.1 units, DO ±0.2 mg/L
- Continuous monitoring techniques referenced appropriately

#### Alaska Regional Protocols ✓
- **Cook Inletkeeper + AKNHP Stream Temperature Protocol** cited with specific pre/post-deployment accuracy checks (0°C ice-water bath + room-temp bath against NIST ±0.2°C thermometer)
- **Alaska DEC QAPP template** cited as EPA Region 10-approved state baseline
- **AWQMS SOPs** (sample hold time, preservation, chain-of-custody) integrated into data management chapter narrative

#### Esri Survey123 Integration ✓
- Offline tablet capability emphasized (critical for remote Nushagak drainage areas without cellular service)
- WQX schema alignment requirement clearly stated for field-to-WQP workflow
- ArcGIS Online integration workflow described

#### Design Philosophy ✓
- Chapter correctly **defers to DQO process (Chapter 8)** rather than prescribing exact station counts or sampling frequencies
- Parameters listed as "Typical Monitoring Approach" with "whether to include each...is a DQO-process decision"
- Avoids false specificity; acknowledges that numeric acceptance criteria for PARCC are program-specific

### Minor Gaps (Acceptable at this project stage)
- NPS SWAN protocols not mentioned in Chapter 10 (specialized; appropriate to exclude from introductory QAPP chapter)
- USGS TM 1-D3 sensor fouling/drift correction details not in prose (appropriate—belongs in full QAPP implementation)
- Esri Survey123 XLSForm code examples not included (appropriate—level of detail for QAPP itself, not overview chapter)

### Conclusion
**Chapter 10 is well-integrated with SOPs guide.** All major protocol frameworks are present, cited, and positioned appropriately for an overview chapter destined for tribal RFP response.

---

## II. Stale HUC8 Reference Audit

### Scope
Searched all chapters for references to "five HUCs" or "five sub-basins" that reflect the original (pre-Togiak-exclusion) configuration.

### Issues Found & Fixed

#### Issue 1: Comment in Chapter 04 — FIXED
- **File**: `chapters/04_parameters_summary.qmd`, line 13
- **Original**: `# Fetch parameter data for all five HUCs`
- **Fixed**: `# Fetch parameter data for all four Nushagak HUCs`
- **Root cause**: Comment not updated when vector definition was corrected in prior session

#### Issue 2: Prose in Chapter 06 — FIXED
- **File**: `chapters/06_metals_contaminants.qmd`, line 110
- **Original**: "across the five HUC8 sub-basins"
- **Fixed**: "across the four Nushagak HUC8 sub-basins"
- **Root cause**: Prose update incomplete in prior session (vector was corrected; prose was missed)

### Final Audit Results

All four data-access chapters verified to use correct four-HUC vector:
```
chapters/03_spatial_coverage.qmd:     nushagak_hucs <- c("19030301", "19030302", "19030303", "19030304") ✓
chapters/04_parameters_summary.qmd:   nushagak_hucs <- c("19030301", "19030302", "19030303", "19030304") ✓
chapters/05_physical_chemical.qmd:    nushagak_hucs <- c("19030301", "19030302", "19030303", "19030304") ✓
chapters/06_metals_contaminants.qmd:  nushagak_hucs <- c("19030301", "19030302", "19030303", "19030304") ✓
```

No remaining stale "five" or "five sub-basin" references found in any chapter.

### Togiak Exclusion Verification

Chapter 03 spatial coverage contains proper explanatory note:
> "HUC8 19030305, which comprises the Togiak River system, is excluded from this analysis as it drains separately into Bristol Bay rather than the Nushagak River."

This note is accurate and well-placed.

---

## III. Summary of Changes

| File | Change | Type | Status |
|------|--------|------|--------|
| `chapters/04_parameters_summary.qmd` | Comment: "all five HUCs" → "all four Nushagak HUCs" | Line 13 | ✓ Fixed |
| `chapters/06_metals_contaminants.qmd` | Prose: "five HUC8 sub-basins" → "four Nushagak HUC8 sub-basins" | Line 110 | ✓ Fixed |

---

## IV. Key Lesson: Code vs. Prose Updates

Both fixes highlight an important pattern observed in this session:
- **Code vectors** (e.g., `nushagak_hucs <- c(...)`) are the actual source of truth for queries and analysis
- **Prose descriptions** must be manually updated separately; they don't auto-update when code changes
- When Togiak (HUC 19030305) was removed from the vector in the prior session, the **vector definition was corrected** but **prose comments and sentences were incompletely updated**

**Going forward**: When code vectors are updated, treat prose updates as a separate QA step. Use grep searches for numeric references ("five", "five sub-basins") and HUC codes to verify consistency.

---

## V. Book State After This Review

✓ All chapters free of stale HUC8 references  
✓ Chapter 10 properly integrated with SOPs guide  
✓ Code vectors and prose in sync  
✓ Togiak exclusion documented and consistent  
✓ Ready for next content review iteration

