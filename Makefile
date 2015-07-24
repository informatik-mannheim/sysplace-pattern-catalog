TEMPFILES = "*.aux" "*.log" "*.dvi" "*.synctex.gz" "*.4ct" "*.4tc" "*.tmp" "*.lg" "*.idv" "*.xref" "*.bbl" "*.lof" "*.blg" "*.out"

clean: delete-temps
	find output -type f | xargs rm -f	
delete-temps:
	for f in $(TEMPFILES) ; do find . -name $$f  | xargs rm -f ; done
build:
	mkdir -p output/pdf
	mkdir -p output/temp/pdf
#	for file in `find . -name "*.tex" ! -name "template.tex" ! -name "header.tex" -printf "%f\n"` ; do pdflatex $$file -interaction=nonstopmode -output-directory=patterns/ ; done
	for file in `find . -name "*.tex" ! -name "template.tex" ! -name "header.tex" -printf "%f\n"` ; do pdflatex -interaction=nonstopmode -output-directory=patterns patterns/$$file ; done
	mv patterns/*.pdf output/pdf/

build-web:

