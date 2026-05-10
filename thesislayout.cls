\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{thesislayout}[2026/05/05 Layout selector for the thesis document]

\newcommand*{\thesis@baseclass}{thesisA4}

\DeclareOption{a4paper}{\renewcommand*{\thesis@baseclass}{thesisA4}}
\DeclareOption{a5paper}{\renewcommand*{\thesis@baseclass}{thesis}}
\DeclareOption{11pt}{}
\DeclareOption{twoside}{}
\DeclareOption*{}
\ProcessOptions\relax

\LoadClass{\thesis@baseclass}