Function clean
{
	delete-temps
	gci -Recurse *.pdf, *.css, *.html, *.htm | rm 
	
}

Function delete-temps
{
	gci -Recurse *.aux, *.log, *.dvi, *.synctex.gz, *.4ct, *.4tc, *.tmp, *.lg, *.idv, *.xref | rm 
}

Function build
{
	cd patterns
	gci -Exclude template.tex *.tex | ForEach-Object {pdflatex -output-directory "../output/pdf" $_.FullName }
	gci ../output/pdf/ -Exclude *.pdf | ForEach-Object {mv $_ ../output/temp/pdf}
	cd ..
}

Function build-web
{
	cd patterns
	gci -Exclude template.tex *.tex | ForEach-Object {htlatex $_.FullName "html, -css, charset=utf-8" " -cunihtf -utf8"}
	gci -Exclude *.html, *.tex | ForEach-Object {mv $_ ../output/temp/html}
	mv *.html ../output/html
	cd ..
}