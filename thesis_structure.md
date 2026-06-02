# Thesis Structure

**Evaluating and Improving Clinical Prediction Models for Ovarian Cancer Diagnosis**

Author: Lasai Barreñada

---

## Overview

This file summarises the project's organisation and the main files and directories contained in the repository. It is kept in sync with the workspace layout.

---

## Top-level files

- [main.tex](main.tex) — thesis main document
- [thesis.cls](thesis.cls) — custom class
- [references.bib](references.bib) — bibliography
- [README.md](README.md)
- [thesis_structure.md](thesis_structure.md) — this file

---

## Key directories

- `Chapters/` — chapter source files (one .tex per chapter)
  - 00a_acknowledgments.tex
  - 00b_abstract.tex
  - 00c_abstract_dutch.tex
  - 00d_acronyms.tex
  - 00e_terms.tex
  - 01_introduction.tex
  - 02_objectives.tex
  - 03_ADNEXSR.tex
  - 04_ADNEXvsRMI.tex
  - 05_ADNEX2.tex
  - 06_RFOverfitting.tex
  - 07_ClusteredCalibration.tex
  - 08_FundamentalProblem.tex
  - 09_varselection.tex
  - 10_discussion.tex
  - 11a_additional_statements.tex
  - 11b_ai_use_statement.tex
  - 11c_CV.tex
  - 11d_Publications.tex

- `figures/` — figure directories by chapter
  - ADNEX2/
  - ADNEXSR/
  - ADNEXvsRMI/
  - ClusteredCalibration/
  - FundamentalProblem/
  - Introduction/
  - RFOverfitting/
  - varselection/

- `R codes/` — R scripts used to generate introduction figures and simulations

- `title_page/`, `Cover/`, `logos/`, `copyrights/` — supporting assets

---

## Build and compilation

Recommended quick build (XeLaTeX):

```powershell
latexmk -xelatex main.tex
```

Or use the project's preferred recipe configured in your editor/LaTeX extension (see repository notes).

---

## Thesis contents (logical outline)

- Front matter: abstract, samenvatting (Dutch), TOC, lists
- Introduction and objectives (background, model performance, calibration, clustering, meta-analysis, reporting)
- Results — Applied: ADNEX systematic reviews and comparisons
- Results — Methodological: RF overfitting, clustered calibration, fundamental problem
- Ongoing work: variable selection for net benefit, ADNEX2 update
- Discussion: summary, calibration, limitations, future directions
- Back matter: acknowledgments, AI use statement, CV, publications, bibliography

---

If you want additional details (e.g., per-chapter figure lists, build recipes for Continuous Preview, or a mapping of numeric citations to BibTeX keys), tell me which section you'd like expanded.
