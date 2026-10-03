# Existing Agency Protocols & SOPs Reference Guide
## Nushagak River Collaborative Monitoring & Data Management Project

---

## 1. Document Purpose & Project Context

This reference document synthesizes established agency Standard Operating Procedures (SOPs), field protocols, and quality assurance frameworks for direct ingestion into **Posit Assistant** and **RStudio**. It provides the foundational knowledge required for Posit Assistant to draft Quality Assurance Project Plans (QAPPs), build Survey123 mobile schemas, and write data validation scripts in R [cite: 3, 4, 6].

### Project Scope & Collaborative Framework
* **Participating Tribal Entities**: Native Village of Ekwok, New Koliganek Village Council, and New Stuyahok Village Council [cite: 3, 5].
* **Study Area**: Nushagak River Watershed (HUC6: 190303), spanning 280+ miles in Southwestern Alaska across HUC8 sub-basins 19030301 (Upper Nushagak), 19030302 (Mulchatna), 19030303 (Nuyakuk), 19030304 (Wood), and 19030305 (Lower Nushagak / Snake) [cite: 3].
* **Core Monitoring Objectives**:
  * **Goal 1**: Deploy continuous monitoring sondes/loggers, establish standardized field methods, author an EPA-approved Tier 2 QAPP, train Tribal Water Technicians, and collect a 3-year baseline water quality dataset [cite: 3, 4, 6].
  * **Goal 2**: Implement offline mobile field collection using Esri Survey123, establish centralized database storage, configure automated multi-Tribe data entry standardization, and deploy GIS visualization services [cite: 3, 4, 6].

### Schedule & Regulatory Milestones
* **Draft QAPP Submission to EPA Region 10**: Targeted for December 1, 2026 [cite: 4].
* **Final EPA QAPP Approval**: Targeted for March 1, 2027 [cite: 4].
* **Equipment Selection & Technician Training Completion**: Targeted for June 30, 2027 [cite: 4].
* **Project Term**: Execution through September 30, 2029 [cite: 4].

---

## 2. Agency Protocol & SOP Inventory

### A. U.S. Environmental Protection Agency (EPA) — Region 10
1. **EPA Region 10 Tribal QAPP Guidance (Tier 2 / CWA Section 106 & 319)**
   * *Application*: Structural blueprint for baseline ambient monitoring programs [cite: 4, 6].
   * *Core Elements*: Defines Data Quality Objectives (DQOs) for Precision, Accuracy, Representativeness, Completeness, Comparability, and Sensitivity (PARCCS).
2. **EPA Field Monitoring Protocols for Multi-Parameter Sondes**
   * *Application*: Continuous and discrete deployment of sondes (YSI EXO, Hydrolab) measuring pH, dissolved oxygen (DO), water temperature, specific conductance, and turbidity.
   * *Calibration Requirements*: 2-point pH buffer calibration (pH 7.0 and 10.0), 100% air-saturation DO calibration, and turbidity standard checks.
3. **EPA Water Quality Exchange (WQX) Data Standards**
   * *Application*: Database schema alignment [cite: 3, 4].
   * *Key Attributes*: Standardized naming conventions for monitoring location IDs, activity types, characteristic names, measurement units, and analytical methods.

### B. U.S. Geological Survey (USGS)
1. **USGS National Field Manual for the Collection of Water-Quality Data (NFM Book 9)**
   * *Chapter A4 (Collection of Water Samples)*: Cross-sectional Equal-Width-Increment (EWI) and Equal-Discharge-Increment (EDI) depth-integrated sampling protocols across wide channel rivers (Nushagak and Mulchatna mainstems) [cite: 3].
   * *Chapter A6 (Field Measurements)*: Parameter stabilization criteria prior to recording discrete values (e.g., temperature ±0.2°C, pH ±0.1 units, DO ±0.2 mg/L).
2. **USGS Continuous Water-Quality Monitoring (Techniques and Methods 1-D3 / 1-D5)**
   * *Application*: Deployment, calibration, and data auditing for continuous loggers.
   * *SOP Highlights*: Sensor fouling corrections, calibration drift adjustments, in-stream mounting structure guidelines, and cross-sectional thermal homogeneity checks.

### C. Alaska Department of Environmental Conservation (ADEC)
1. **ADEC Division of Water Generic QAPP Template**
   * *Application*: EPA Region 10-approved state template tailored to Alaska sub-arctic logistics, covering all 24 required EPA QAPP elements [cite: 4].
2. **ADEC Ambient Water Quality Monitoring System (AWQMS) SOPs**
   * *Application*: Laboratory sample hold-time limits, sample preservation techniques, chain-of-custody tracking, and statewide database formatting.

### D. National Park Service (NPS) — Southwest Alaska Network (SWAN)
1. **SWAN Freshwater Monitoring Protocols**
   * *Application*: Baseline water chemistry and stream flow monitoring protocols developed specifically for salmon rivers in Bristol Bay / Southwest Alaska [cite: 3].
2. **SWAN Continuous River Logger Installation Protocols**
   * *Application*: Specialized installation techniques for securing temperature and water level loggers against spring ice-scour, high-velocity flooding, and bedload sediment movement [cite: 3].

### E. Regional Alaska Interagency Standards
1. **Stream Temperature Data Collection Standards and Protocol for Alaska**
   * *Sponsors*: Cook Inletkeeper, Alaska Natural Heritage Program (AKNHP), and agency partners.
   * *Calibration SOP*: Pre- and post-deployment accuracy verification using a 0.0°C ice-water bath and room-temperature water bath against a NIST-certified thermometer (±0.2°C tolerance).
   * *Logging Protocol*: Hourly continuous temperature recording.
2. **Esri Survey123 Mobile Collection Schema**
   * *Application*: Design standards for offline mobile forms operating on tablets in remote areas without cellular service [cite: 6]. Connects field observations, calibration logs, site photos, and chain-of-custody metadata directly into ArcGIS Online [cite: 3, 6].

---

## 3. How Posit Assistant Should Use This Information

When loaded into Posit Assistant within RStudio, this document enables the assistant to execute the following tasks:

1. **QAPP Generation**: Synthesize QAPP draft sections (specifically Section B: Data Generation and Acquisition) following EPA Region 10 Tier 2 standards and ADEC templates [cite: 4, 6].
2. **Data Schema & Survey123 Design**: Generate Esri Survey123 XLSForm column structures aligned with EPA WQX naming conventions and USGS field measurement parameters [cite: 3, 4, 6].
3. **QA/QC R Code Development**: Write R scripts to process raw continuous logger data, auto-flag sensor drift/fouling using USGS TM 1-D3 thresholds, and convert raw field data into WQX-compliant formats [cite: 3, 4].
