TEMPFILES = "*.aux" "*.log" "*.dvi" "*.synctex.gz" "*.4ct" "*.4tc" "*.tmp" "*.lg" "*.idv" "*.xref" "*.bbl" "*.lof" "*.blg" "*.out"


clean: delete-temps
	find output -type f -delete 

delete-temps:
	for f in $(TEMPFILES) ; do find . -name $$f -delete ; done

build:
	@# create output dirs (if not existing)
	mkdir -p output/pdf
	mkdir -p output/temp/pdf
	@# run all .tex files through pdflatex, except for the template and header ones
	@for file in `find . -name "*.tex" ! -name "template.tex" ! -name "header.tex" -printf "%f\n"`; do \
		(cd patterns && echo "building $$file" && pdflatex -interaction=nonstopmode $$file > /dev/null); \
	done
	@# move pdf files to output
	@echo "moving pdf and temp files to output/pdf/"
	@mv patterns/*.pdf output/pdf/
	@# move all temp files to output
	@for f in $(TEMPFILES) ; do find patterns -name $$f -exec mv {} -t output/temp/pdf \; ; done

build-web:
	mkdir -p output/html
	mkdir -p output/temp/html
	@for file in `find . -name "*.tex" ! -name "template.tex" ! -name "header.tex" -printf "%f\n"`; do \
		(cd patterns && echo "building $$file" && htlatex $$file "html, -css, charset=utf-8" " -cunithf -utf8" > /dev/null); \
	done
	find patterns/ -name "*.*" ! -name "*.html" ! -name "*.tex" ! -name "*.png" ! -name "*.orig" ! -name "*.bib" -exec mv {} output/temp/html \;
	mv patterns/*.html output/html
	cp patterns/*.png output/html
	
