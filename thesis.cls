\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{thesis}[2025/11/26 PhD Thesis Template]

% Base class
\LoadClass[11pt,twoside]{book}

% Page geometry
\RequirePackage[a5paper]{geometry}
\geometry{
    paperwidth=16cm,
    paperheight=24cm,
    inner=2.4cm,
    outer=1.5cm,
    top=2cm,
    bottom=2cm
}

% Fonts
\RequirePackage{fontspec}
\setmainfont{Times New Roman}

% Packages
\RequirePackage{graphicx}
\RequirePackage{textpos}
\RequirePackage{xcolor}
\RequirePackage{pdfpages}
\RequirePackage{bm}
\RequirePackage{listings}
\RequirePackage{makecell}
\RequirePackage{rotating}
\RequirePackage{xr-hyper}
\RequirePackage{amsmath,amssymb}
\RequirePackage[hyphens]{url}
\RequirePackage[colorlinks=false]{hyperref}
\RequirePackage{cleveref}
\RequirePackage{booktabs}
\RequirePackage{nicefrac}
\RequirePackage{microtype}
\RequirePackage{siunitx}
\RequirePackage{enumitem}
\RequirePackage{extpfeil}
\RequirePackage{tabularx,longtable,multirow,array}
\RequirePackage{caption}
\RequirePackage[table]{xcolor}
\RequirePackage{fancyhdr}
\RequirePackage{etoolbox}
\RequirePackage{titlesec}
\RequirePackage[acronym,nonumberlist,nopostdot]{glossaries}
\RequirePackage[backend=biber, style=numeric, sorting=none, citestyle=numeric-comp, giveninits=true]{biblatex}
% Suppress "visited on <date>" in bibliography entries
\AtEveryBibitem{\clearfield{urldate}}

% Bibliography
\AtEveryBibitem{
    \clearfield{url}
    \clearfield{issn}
}
\addbibresource{references.bib}

% Colors
\definecolor{strong}{HTML}{C6EFCE}
\definecolor{moderate}{HTML}{FFEB9C}
\definecolor{weak}{HTML}{FFC7CE}
\definecolor{dibs_main}{RGB}{21,67,121}

% Table & column types
\newcolumntype{M}[1]{>{\centering\arraybackslash}m{#1}}
\newcolumntype{C}[1]{>{\centering\arraybackslash}p{#1}}
\newcommand{\ra}[1]{\renewcommand{\arraystretch}{#1}}

% Float adjustments
\renewcommand{\topfraction}{0.9}
\renewcommand{\bottomfraction}{0.8}
\renewcommand{\textfraction}{0.05}
\renewcommand{\floatpagefraction}{0.8}

% Fancy headers
\fancyhf{}
\renewcommand{\headrulewidth}{0.4pt}
\renewcommand{\footrulewidth}{0pt}
\renewcommand{\chaptermark}[1]{\markboth{\MakeUppercase{#1}}{}}
\renewcommand{\sectionmark}[1]{\markright{\MakeUppercase{#1}}}
\fancyhead[RE]{\small\leftmark}
\fancyhead[LO]{\small\rightmark}
\fancyhead[LE,RO]{\small\thepage}
\pagestyle{fancy}

% Footnotes
\makeatletter
\patchcmd{\@footnotetext} {\reset@font\footnotesize} {\reset@font\small\itshape} {}{}
\makeatother

% Chapter formatting
\titleformat{\chapter}[display]
  {\normalfont\huge\bfseries}
  {Chapter \thechapter}
  {1em}
  {\Huge}

% Glossaries
\makeglossaries

% Front & back cover commands
\newcommand{\makefrontcover}{
  \clearpage \thispagestyle{empty} \null \clearpage
}
\newcommand{\makebackcover}{
  \clearpage \thispagestyle{empty} \null \clearpage
}
