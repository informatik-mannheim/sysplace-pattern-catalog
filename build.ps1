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
	New-Item -Force -ItemType directory -Path output/pdf
	New-Item -Force -ItemType directory -Path output/temp/pdf
	cd patterns
	gci -Exclude template.tex *.tex | ForEach-Object {pdflatex -output-directory "../output/pdf" $_.FullName }
	gci ../output/pdf/ -Exclude *.pdf | ForEach-Object {mv -Force $_ ../output/temp/pdf}
	cd ..
}

Function build-web
{
	New-Item -Force -ItemType directory -Path output/html
	New-Item -Force -ItemType directory -Path output/temp/html
	cd patterns
	gci -Exclude template.tex *.tex | ForEach-Object {htlatex $_.FullName "html, -css, charset=utf-8" " -cunihtf -utf8"}
	gci -Exclude *.html, *.tex | ForEach-Object {mv -Force $_ ../output/temp/html}
	mv -Force *.html ../output/html
	cd ..
}