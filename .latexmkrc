# Latexmk configuration for LuaLaTeX with glossaries and Biber
$pdf_mode = 4;  # Use lualatex
$postscript_mode = $dvi_mode = 0;

# Force Biber as bibliography backend
$bibtex = 'biber %O %S';

# Add custom dependency for glossaries
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
    my ($base_name, $path) = fileparse( $_[0] );
    pushd $path;
    my $return = system "makeglossaries", $base_name;
    popd;
    return $return;
}

# Ensure proper cleanup
$clean_ext = "acn acr alg aux bbl bcf blg fdb_latexmk fls glg glo gls idx ilg ind ist lof log lot out run.xml synctex.gz toc xdv";
