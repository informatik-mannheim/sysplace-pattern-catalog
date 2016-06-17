Function clean
{
	delete-temps
	gci -Recurse -Path output/ -Include *.* | rm 
}

Function delete-temps
{
	gci -Recurse -Include *.aux, *.log, *.dvi, *.synctex.gz, *.4ct, *.4tc, *.tmp, *.lg, *.idv, *.xref, *.bbl, *.lof, *.blg, *.out | rm 
}

Function build
{
	New-Item -Force -ItemType directory -Path output/pdf
	New-Item -Force -ItemType directory -Path output/temp/pdf
	cd patterns
	gci -Exclude template.tex,header.tex *.tex | ForEach-Object {pdflatex -interaction=nonstopmode -output-directory "../output/pdf"  $_.FullName }
	gci ../output/pdf/ -Exclude *.pdf | ForEach-Object {mv -Force $_ ../output/temp/pdf}
	cd ..
}

Function build-web
{
	New-Item -Force -ItemType directory -Path output/html
	New-Item -Force -ItemType directory -Path output/temp/html
	cd patterns
	gci -Exclude template.tex, header.tex *.tex | ForEach-Object {htlatex $_.Name "html, -css, charset=utf-8" " -cunihtf -utf8"}
	gci -Exclude *.html, *.tex, *.png, *.pdf, *.bib | ForEach-Object {mv -Force $_ ../output/temp/html} # move all build-related files to temp for debugging
	mv -Force *.html ../output/html
	cp *.png ../output/html # copy, DON'T move as we need them for every build again.

	cd ../output/html
	New-Item -ItemType file -Force index.html
	echo "<DOCTYPE HTML>" > index.html
	echo "<head></head>" >> index.html
	echo "<body><h1>Alle Pattern</h1>" >> index.html
	gci -Name -Exclude index.html, *.png | ForEach-Object {echo "<a href='$_'>::> $_</a><br />"  >> index.html}
	echo "</body>" >> index.html
	cd ../..
}

Function build-web-single
{
	Param(
		[parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string]
		$file
	)

	cd patterns
	htlatex ($file + ".tex") "html5, charset=utf-8" " -cunihtf -utf8"
	gci -Exclude *.html, *.tex, *.png, *.pdf, *.bib, *.cfg | ForEach-Object {mv -Force $_ ../output/temp/html} # move all build-related files to temp for debugging
	
	#insert menu
	insert-into-file $file
	
	#move to output
	mv -Force ($file + ".html") ../output/html
	
	# move png files to output as well
	cp *.png ../output/html # copy, DON'T move as we need them for every build again.
	
	# rebuild index file
	cd ../output/html
	New-Item -ItemType file -Force index.html
	echo "<DOCTYPE HTML>" > index.html
	echo "<head><link rel=""stylesheet"" href=""style.css""></head>" >> index.html
	echo "<body><h1>Alle Pattern</h1>" >> index.html
	gci -Name -Exclude index.html, *.png | ForEach-Object {echo "<a href='$_'>::> $_</a><br />"  >> index.html}
	echo "</body>" >> index.html
	cd ../..
}

Function deploy
{
	pscp output/html/* web/* webdeploy@141.19.142.50:/var/www/html/sysplace
}

Function insert-into-file
{
	Param(
		[parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string]
		$file
	)
	
	(Get-Content ($file + ".html")) | ForEach-Object {
		if ($_ -match "<div class=""maketitle"">") 
		{
			Get-Content ../web/menu.html
		}
		$_;
	} | Set-Content ($file + ".html")
}
