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
\renewcommand{\familydefault}{\sfdefault}

% Packages
\RequirePackage{graphicx}
\RequirePackage{subcaption}
\captionsetup{font=small, labelfont=bf}
\captionsetup[subfigure]{font=scriptsize}
\RequirePackage{textpos}
\RequirePackage{xcolor}
\RequirePackage{pdfpages}
\RequirePackage{bm}
\RequirePackage{listings}
% Define a listings style for R code with readable colors and formatting
\lstdefinelanguage{R}{%
  morekeywords={function,if,else,for,while,repeat,break,next,return,TRUE,FALSE,NULL,NA},%
  morekeywords=[2]{library,require,package,install.packages,data.frame,rnorm,rbinom,plogis,nb_varsel,all_subset_plot,VIF_plot},%
  morekeywords=[3]{c,df,result,harms,n,outcome_var,costs,mode,folds,permutations,allow_parallel},%
  alsoletter={._$},%
  morecomment=[l]{#}
}
\lstdefinestyle{Rstyle}{
  language=R,
  basicstyle=\ttfamily\small,
  keywordstyle=\color{dibs_main}\bfseries,
  keywordstyle=[2]\color{blue!70!black}\bfseries,
  keywordstyle=[3]\color{teal!60!black},
  commentstyle=\color{gray}\itshape,
  stringstyle=\color{red!60!black},
  showstringspaces=false,
  breaklines=true,
  columns=flexible,
  keepspaces=true,
  tabsize=2,
  xleftmargin=2pt,
  xrightmargin=2pt
}
\RequirePackage{tcolorbox}
\tcbuselibrary{listings,breakable}
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
% Bibliography: suppress unwanted fields
\AtEveryBibitem{
    \clearfield{url}
    \clearfield{issn}
    % Suppress "visited on <date>"
    \clearfield{urlyear}
    \clearfield{urlmonth}
    \clearfield{urlday}
}
\addbibresource{references.bib}

% Make quote environment use smaller font
\AtBeginEnvironment{quote}{\small}

% Code box for examples (Box 1 style)
\newtcblisting{codebox}[1][]{
  enhanced,
  breakable,
  colback=white,
  colframe=black,
  left=4pt,
  right=4pt,
  top=6pt,
  bottom=6pt,
  boxrule=0.8pt,
  arc=0pt,
  auto outer arc,
  fonttitle=\bfseries,
  title=#1,
  listing engine=listings,
  listing only,
  listing options={style=Rstyle}
}

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

% Copyright page command
\newcommand{\makecopyrightpage}[2]{%
  % #1 = author name, #2 = address
  \clearpage
  \thispagestyle{empty}
  \vspace*{\fill}
  \noindent
  \reflectbox{\textcopyright}~\the\year{} KU Leuven -- Faculty of Medicine\\[0.5em]
  Self-published, #1, #2\\[1em]
  {\small
 Copyleft: All rights reversed. This publication may be reproduced in any form by print, photoprint, microfilm, electronic or any other means, provided that appropriate credit is given and this exact freedom is passed on to all subsequent users.}\\[1.5em]
 *Cover art exception*: "La Clairvoyance" (1936) and "Le Retour" (1940) by Ren\'e Magritte are used with permission from the artist's estate {\copyright} Succession Ren\'e Magritte, SABAM Belgium 2026. The CC license does not apply to these images.\\[1.5em]
  \clearpage
}

% Blank page command
\newcommand{\blankpage}{\clearpage \thispagestyle{empty} \null \clearpage}

% Front & back cover commands
\newcommand{\makefrontcover}{\blankpage}
\newcommand{\makebackcover}{\blankpage}
