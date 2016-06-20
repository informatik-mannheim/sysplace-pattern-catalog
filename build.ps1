Function clean
{
	delete-temps
	gci -Recurse -Path output/ -Include *.* | rm 
}

Function delete-temps
{
	gci -Recurse -Include *.aux, *.log, *.dvi, *.synctex.gz, *.4ct, *.4tc, *.tmp, *.lg, *.idv, *.xref, *.bbl, *.lof, *.blg, *.out, *.run.xml, *-blx.bib | rm 
}

Function build-pdf
{
	Write-Host "Creating output/pdf"
	New-Item -Force -ItemType directory -Path output/pdf | Out-Null
	Write-Host "Creating output/temp/pdf"
	New-Item -Force -ItemType directory -Path output/temp/pdf | Out-Null
	Write-Host "Writing all output to output/temp/pdf/build.log"
	New-Item -Force -Path output/temp/pdf -Name "build.log" -ItemType File | Out-Null
	
	cd patterns
	
	# Build all pattern pdfs
	gci -Exclude template.tex,header.tex,all.tex *.tex | ForEach-Object {
		build-single-pdf $_;
	}
	
	# Build the catalog with all patterns
	gci all.tex | Foreach-Object { build-single-pdf $_; }
	
	# Move everything that is not a pdf to output/temp/pdf
	Write-Host "Cleaning up...";
	gci ../output/pdf/ -Exclude *.pdf | ForEach-Object {mv -Force $_ ../output/temp/pdf}
	cd ..
}

Function build-single-pdf
{
		Param(
			[parameter(Mandatory=$true)]
			[System.IO.FileSystemInfo]
			$file
		)
		
		Write-Host ("Building " + $file.FullName + "... ") -NoNewline; 
		pdflatex -interaction=nonstopmode -output-directory "../output/pdf"  $_.FullName *>> ../output/temp/pdf/build.log;
		if($LASTEXITCODE -eq 0)
		{
			Write-Host "Success" -ForegroundColor green
		} else {
			Write-Host "Error" -ForegroundColor red 
		}
}

Function build-web
{
	# Recreate Output Folders
	New-Item -Force -ItemType directory -Path output/html
	New-Item -Force -ItemType directory -Path output/temp/html
	
	cd patterns
	
	# Build HTML
	gci -Exclude template.tex,header.tex,all.tex *.tex | ForEach-Object {htlatex $_.Name "html5, charset=utf-8" " -cunihtf -utf8"} 
	
	# Move all build-related files to output/temp for debugging
	gci -Exclude *.html, *.tex, *.png, *.pdf, *.bib, *.cfg | ForEach-Object {mv -Force $_ ../output/temp/html} 
	
	# Insert menu into generated HTML files
	gci *.html | ForEach-Object {insert-into-file $_} 
	
	# Move / copy all HTML, images and css to output
	mv -Force *.html ../output/html 
	cp *.png ../output/html
	cp ../web/style.css ../output/html

	# Generate an index of all files
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
	insert-into-file ($file + ".html")
	
	#move to output
	mv -Force ($file + ".html") ../output/html
	
	# move png files to output as well
	cp *.png ../output/html # copy, DON'T move as we need them for every build again.
	cp ../web/style.css ../output/html
	
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
	
	(Get-Content $file) | ForEach-Object {
		if ($_ -match "<div class=""maketitle"">") 
		{
			Get-Content ../web/menu.html
		}
		$_;
	} | Set-Content $file
}
