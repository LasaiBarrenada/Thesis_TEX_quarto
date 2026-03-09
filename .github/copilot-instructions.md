# AI Coding Agent Instructions - PhD Thesis (LaTeX)

## Project Overview
This is a KU Leuven PhD thesis written in LaTeX. The project uses a minimal structure with TinyTeX distribution for compilation.

## Project Structure
- **[main.tex](../main.tex)**: Primary thesis document using a KU Leuven thesis template
- **main.pdf**: Compiled output
- **thesis.cls**: Custom KU Leuven thesis document class
- **acronyms.tex**: Acronym definitions for glossaries package
- **references.bib**: Bibliography database file
- **Chapters/**: Directory containing all thesis chapter files
  - acknowledgments.tex, abstract.tex, introduction.tex, objectives.tex
  - results1.tex, discussion.tex
  - additional_statements.tex, ai_use_statement.tex
  - CV.tex, Publications.tex
- **figures/**: Main directory for thesis figures and images
- **images/**: Additional images directory
- **logos/**: Directory for institutional and project logos
- **title_page/**: Directory containing pre-compiled title page PDF
- **Cover/**: Directory for cover design files
- **copyrights/**: Directory for copyright information
- **articles/**: Directory for included article files (if applicable)
- **main.aux, main.bbl, main.log, main.fls, main-blx.bib, *.aux**: LaTeX compilation artifacts (auto-generated, do not edit)

## Build System
**LaTeX Distribution**: TinyTeX (lightweight TeX Live distribution)
**Compiler**: XeLaTeX (specified by `% !TeX program = xelatex` directive in main.tex)

### Building the Document
To compile the thesis, use:
```powershell
latexmk -xelatex main.tex
```

For continuous compilation with latexmk:
```powershell
latexmk -xelatex -pvc main.tex
```

## Current State
The thesis is in active development with:
- Complete template-based setup using KU Leuven thesis class
- Structured chapter organization in Chapters/ directory
- Acronyms management with glossaries package
- Bibliography system configured (references.bib)
- Pre-compiled title page integration
- Multiple chapters: introduction, objectives, results, discussion
- Supporting sections: acknowledgments, abstract, CV, publications

## LaTeX-Specific Guidelines

### Document Structure
- Main entry point is always `main.tex`
- Uses KU Leuven thesis template class
- Mathematical equations use standard LaTeX `equation` environment

### When Adding Content
1. **New sections/chapters**: Add using appropriate commands in `main.tex`
2. **Chapter files**: Store chapter `.tex` files in `Chapters/` directory, include with `\include{chapters/filename}` (note lowercase in path)
3. **Figures**: Place image files in `figures/` or `images/` directory, reference with `\includegraphics{figures/filename}` or `\includegraphics{images/filename}`
4. **Logos**: Place institutional logos in `logos/` directory
5. **Articles**: Store separate article `.tex` files in `articles/` directory if needed
6. **Bibliography**: Add entries to `references.bib` file using BibTeX/BibLaTeX format
7. **Acronyms**: Add new acronyms to `acronyms.tex` file
8. **Custom packages**: If adding packages, ensure they're available in TinyTeX or install via `tlmgr`

### Common Workflows
- **Quick compile**: Run `latexmk -xelatex main.tex` for compilation
- **Full compile with continuous preview**: Run `latexmk -xelatex -pvc main.tex` for automatic recompilation on changes
- **Clean build**: Run `latexmk -c` to remove auxiliary files
- **View output**: Open `main.pdf` after compilation

### Package Management
TinyTeX is located at: `c:/Users/u0158158/AppData/Roaming/TinyTeX/`

To install missing packages:
```powershell
tlmgr install <package-name>
```

## Tips
- **Directory structure**: Use `figures/` and `images/` for figures, `logos/` for institutional graphics, `Chapters/` for chapter files, `articles/` for modular content
- **Template-based**: Using KU Leuven thesis class - follow template conventions for structure
- **Compilation artifacts**: Safe to delete `.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.synctex.gz`, `.bbl`, `.blg` - they regenerate on next compile
- **Path conventions**: Note that `\include{chapters/...}` uses lowercase in LaTeX commands while the actual folder is capitalized as `Chapters/`

## Best Practices
- Store chapter content as separate files in `Chapters/` directory for modularity
- Use consistent naming conventions for files (e.g., `introduction.tex`, `objectives.tex`)
- Place figures in `figures/` or `images/` subdirectories before referencing
- Keep logos separate in `logos/` for easy template integration
- Maintain bibliography in `references.bib` using BibTeX/BibLaTeX format
- Add acronyms to `acronyms.tex` file for consistent glossary management
- Use XeLaTeX for compilation (already configured in main.tex)
- Utilize latexmk for efficient builds with automatic dependency handling
