
# PhD Thesis — Lasai Barreñada

LaTeX source for a PhD thesis compiled as a collection of published papers. The main entry point is `main.tex`. The project uses a small wrapper class (`thesislayout.cls`) to select between the custom classes `thesis.cls` (book-like layout) and `thesisA4.cls` (A4 variant). The document is compiled with LuaLaTeX and uses `biblatex`/`biber` for references and the `glossaries` package for acronyms.

## Quick overview

- Main file: `main.tex`
- Document classes: `thesislayout.cls`, `thesis.cls`, `thesisA4.cls`
- Bibliography: `references.bib` (biblatex + biber)
- Chapters: stored in `Chapters/` (each chapter is a separate `.tex` file)
- Figures: organized under `figures/` by chapter
- Supporting directories: `Cover/`, `title_page/`, `logos/`, `copyrights/`, `images/`

Several chapters are published or in preparation as stand-alone papers (see `Chapters/` for current status and author notes).

## Build (recommended)

Preferred explicit sequence (use this when debugging build problems):

```powershell
lualatex -interaction=nonstopmode main.tex
makeglossaries main
biber main
lualatex -interaction=nonstopmode main.tex
lualatex -interaction=nonstopmode main.tex
```

A convenient one-line continuous-preview command (uses `latexmk` and LuaLaTeX):

```powershell
latexmk -pvc -pdf -pdflatex="lualatex %O %S" main.tex
```

Clean auxiliary files produced by `latexmk` with:

```powershell
latexmk -c
```

Notes:
- If packages are missing, install them with your TeX distribution (TinyTeX users can run `tlmgr install <package>`).
- The build sequence intentionally runs LuaLaTeX multiple times to ensure cross-references, glossary entries, and bibliography are fully resolved.

## Common tasks

- Compile once (fast check): run the explicit sequence above.
- Continuous compile while editing: use the `latexmk` command above.
- Regenerate glossaries: `makeglossaries main` (run after the first LaTeX pass and before the final LaTeX pass).

## Reproducibility and code

Supporting R code and supplementary materials are available in project-specific OSF repositories linked from chapter front-matter. See individual chapters for exact OSF links and data availability notes.

## Troubleshooting

- If compilation fails, open `main.log` and look for the first error. Most common issues are missing packages, unescaped special characters in chapter text, or mismatched braces.
- For bibliography errors, ensure `biber` is in PATH and run `biber main` after the first LaTeX pass.

