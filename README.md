
# PhD Thesis — Lasai Barreñada

LaTeX source for a PhD thesis compiled as a collection of published papers. Uses a small wrapper class (`thesislayout.cls`) to switch between `thesis.cls` and `thesisA4.cls`, and requires **LuaLaTeX**.

## Project Structure

```
├── main.tex                  # Main document (includes all chapters)
├── thesislayout.cls          # Wrapper class that selects thesis.cls or thesisA4.cls
├── thesis.cls                # Custom document class (based on book)
├── thesisA4.cls              # A4 variant of the custom document class
├── references.bib            # Bibliography (biblatex + biber)
├── acronyms.tex              # Glossary / list of acronyms
├── terms.tex                 # Glossary terms (non-acronyms)
│
├── Chapters/
│   ├── 01_acknowledgments.tex
│   ├── 02_abstract.tex
│   ├── 03_introduction.tex          # Not yet included
│   ├── 04_objectives.tex            # Not yet included
│   ├── 05.01_ADNEXSR.tex            # BMJ Medicine 2024
│   ├── 05.02_ADNEXvsRMI.tex         # BMJ Open 2025
│   ├── 05.03_RFOverfitting.tex      # DPR 2024
│   ├── 05.04_ClusteredCalibration.tex  # RSM 2025
│   ├── 05.05_FundamentalProblem.tex # npj Digital Medicine (submitted)
│   ├── 06_discussion.tex            # Not yet included
│   ├── 07_additional_statements.tex
│   ├── 08_ai_use_statement.tex
│   ├── 09_CV.tex
│   └── 10_Publications.tex
│
├── figures/                  # Figures organized by chapter
│   ├── ADNEXSR/
│   ├── ADNEXvsRMI/
│   ├── RFOverfitting/
│   ├── ClusteredCalibration/
│   └── FundamentalProblem/
│
├── Cover/                    # Thesis cover (PDF + source)
├── title_page/               # Title page (PDF + source)
├── logos/                    # Journal logos
├── copyrights/               # Copyright information
└── images/                   # General images
```

## Building

Requires the full build sequence (LuaLaTeX + glossaries + biber):

```bash
lualatex -interaction=nonstopmode main.tex
makeglossaries main
biber main
lualatex -interaction=nonstopmode main.tex
lualatex -interaction=nonstopmode main.tex
```

