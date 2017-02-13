all: GenomicDataCommons.pdf

GenomicDataCommons.pdf: GenomicDataCommons.tex gdcCitations.bib
	rm GenomicDataCommons.b*; xelatex GenomicDataCommons.tex; biber --bblsafecharsset=full GenomicDataCommons; xelatex GenomicDataCommons.tex; xelatex GenomicDataCommons.tex; xelatex GenomicDataCommons.tex


GenomicDataCommons.tex: GenomicDataCommons.Rnw
	Rscript -e 'knitr::knit("GenomicDataCommons.Rnw")'
