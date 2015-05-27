Function clean
{
	gci -Recurse *.aux | rm 
	gci -Recurse *.log | rm 
	gci -Recurse *.dvi | rm 
	gci -Recurse *.synctex.gz| rm 
	gci -Recurse *.pdf | rm 
	
}

Function build
{
	cd patterns
	gci -Exclude template.tex *.tex | ForEach-Object {pdflatex -output-directory "../output" $_.FullName }
	cd ..
}

