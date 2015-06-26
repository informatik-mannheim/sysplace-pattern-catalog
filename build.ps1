Function clean
{
	delete-temps
	gci -Recurse -Include *.pdf, *.css, *.html, *.htm | rm 
	
}

Function delete-temps
{
	gci -Recurse -Include *.aux, *.log, *.dvi, *.synctex.gz, *.4ct, *.4tc, *.tmp, *.lg, *.idv, *.xref | rm 
}

Function build
{
	New-Item -Force -ItemType directory -Path output/pdf
	New-Item -Force -ItemType directory -Path output/temp/pdf
	cd patterns
	gci -Exclude template.tex *.tex | ForEach-Object {pdflatex -interaction=nonstopmode -output-directory "../output/pdf" $_.FullName }
	gci ../output/pdf/ -Exclude *.pdf | ForEach-Object {mv -Force $_ ../output/temp/pdf}
	cd ..
}

Function build-web
{
	New-Item -Force -ItemType directory -Path output/html
	New-Item -Force -ItemType directory -Path output/temp/html
	cd patterns
	gci -Exclude template.tex *.tex | ForEach-Object {htlatex $_.FullName "html, -css, charset=utf-8" "-cunihtf -utf8"}
	gci -Exclude *.html, *.tex, *.png | ForEach-Object {mv -Force $_ ../output/temp/html}
	mv -Force *.html ../output/html
	cp *.png ../output/html

	cd ../output/html
	New-Item -ItemType file -Force index.html
	echo "<DOCTYPE HTML>" > index.html
	echo "<head></head>" >> index.html
	echo "<body><h1>Alle Pattern</h1>" >> index.html
	gci -Name -Exclude index.html |ForEach-Object {echo "<a href='$_'>$_</a><br />"  >> index.html}
	echo "</body>" >> index.html
	cd ../..
}

