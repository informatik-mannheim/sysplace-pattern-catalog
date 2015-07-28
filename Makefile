TEMPFILES = "*.aux" "*.log" "*.dvi" "*.synctex.gz" "*.4ct" "*.4tc" "*.tmp" "*.lg" "*.idv" "*.xref" "*.bbl" "*.lof" "*.blg" "*.out" "*.fls" "*.fdb_latexmk"


clean: delete-temps
	find output -type f -delete 
	#remove this as soon as it is fixed!
	find patterns -name "*0x*" -delete

delete-temps:
	for f in $(TEMPFILES) ; do find . -name $$f -delete ; done

build:
	mkdir -p output/pdf
	mkdir -p output/temp/pdf
	
	@for file in `find . -name "*.tex" ! -name "template.tex" ! -name "header.tex"`; do \
		(echo "building $$file" && latexmk $$file -pdf -bibtex -interaction=nonstopmode -output-directory=patterns/); \
	done
	
	@echo "moving pdf and temp files to output/pdf/"
	@mv patterns/*.pdf output/pdf/
	
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

deploy:
	rm -rf /var/www/html/sysplace/html
	rm -rf /var/www/html/sysplace/pdf
	cp -r output/html /var/www/html/sysplace	
	cp -r output/pdf /var/www/html/sysplace	
