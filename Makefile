TEMPFILES = "*.aux" "*.log" "*.dvi" "*.synctex.gz" "*.4ct" "*.4tc" "*.tmp" "*.lg" "*.idv" "*.xref" "*.bbl" "*.lof" "*.blg" "*.out"

clean: delete-temps
	find output -type f | xargs rm -f	
delete-temps:
	for f in $(TEMPFILES) ; do find . -name $$f  | xargs rm -f ; done
build:
	mkdir -p output/pdf
	mkdir -p output/temp/pdf
	cd patterns
	for file in `find . -name "*.tex" -printf "%f\n"` ; do pdflatex $$file -interaction=nonstopmode ; done
	cd ..

build-web:

