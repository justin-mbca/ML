# Clinical Trial Data Flow: From Raw to Reusable Abstractions

This guide explains how clinical trial data moves from raw or SDTM-like sources into reusable abstractions that power monitoring, review, and exploratory analysis in Shiny apps. The focus is practical—labs, adverse events, subject-level data, and handling edge cases and baseline logic.

---

## 1. Data Sources
- **Raw Data:** Direct exports from EDC, lab systems, or CSVs. Often messy, inconsistent, and not standardized.
- **SDTM-like Data:** Structured datasets (e.g., DM, LB, AE) following CDISC conventions. More reliable, but still needs abstraction for app reuse.

## 2. Abstraction Process
- **Labs (LB):**
  - Extract core variables: subject ID, test name, value, units, visit, reference ranges.
  - Standardize test names and units.
  - Abstract into a reusable table or module for longitudinal tracking, flagging abnormal values, and baseline comparisons.

- **Adverse Events (AE):**
  - Extract subject ID, event term, severity, start/end dates, outcome.
  - Standardize event coding (e.g., MedDRA).
  - Abstract into a module for event timeline visualization, severity filtering, and cross-study comparison.

- **Subject-Level Data (DM/ADSL):**
  - Extract demographics, treatment arm, randomization, baseline characteristics.
  - Abstract into a subject table for cohort selection, stratification, and drill-down analysis.

## 3. Edge Cases & Baseline Logic
- **Edge Cases:**
  - Missing values, duplicate records, inconsistent units, out-of-range dates.
  - Abstractions include logic to flag, filter, or impute these cases for reliable monitoring.

- **Baseline Logic:**
  - Define baseline for labs (e.g., first pre-dose value), adverse events (pre-existing vs emergent), and subject characteristics.
  - Abstractions parameterize baseline definitions so modules can adapt to different study protocols.

## 4. Reusable Abstractions in Shiny
- Each abstraction (labs, AE, subject-level) is implemented as a module or function.
- Modules are study-agnostic: parameterized to accept different datasets, variable names, and baseline rules.
- Outputs support monitoring dashboards, review tables, and exploratory plots.

---

**Summary:**
Clinical trial data flows from raw or SDTM-like sources into reusable abstractions for labs, adverse events, and subject-level data. Edge cases and baseline logic are handled in the abstraction layer, enabling robust monitoring and flexible analysis in Shiny apps. This approach keeps code maintainable, scalable, and ready for cross-study reuse.
