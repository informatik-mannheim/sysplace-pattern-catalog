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
	$stopwatch = [system.diagnostics.stopwatch]::startNew()

	Write-Host "Creating output/pdf"
	New-Item -Force -ItemType directory -Path output/pdf | Out-Null
	Write-Host "Creating output/temp/pdf"
	New-Item -Force -ItemType directory -Path output/temp/pdf | Out-Null
	Write-Host "Writing all output to output/temp/pdf/build.log"
	New-Item -Force -Path output/temp/pdf -Name "build.log" -ItemType File | Out-Null
	
	cd patterns
	
	# Build all pattern pdfs
	gci -Exclude template.tex,header.tex,all.tex,template_desc.tex,template_starter.tex *.tex | ForEach-Object {
		build-single-pdf $_;
	}
	
	# Move everything that is not a pdf to output/temp/pdf
	Write-Host "Cleaning up...";
	gci ../output/pdf/ -Exclude *.pdf | ForEach-Object {mv -Force $_ ../output/temp/pdf}
	cd ..
	
	$stopwatch.Stop()
	Write-Host ("It took " + $stopwatch.Elapsed.ToString("mm\:ss") + " to build.")
}

Function build-single-pdf
{
		Param(
			[parameter(Mandatory=$true)]
			[System.IO.FileSystemInfo]
			$file
		)
		
		# Reset success flag
		$success = 0;
		
		# Build pdflatex (step 1/4)
		Write-Host ("Building PDF " + $file.FullName + " ... ") -NoNewline; 
		pdflatex -interaction=nonstopmode -output-directory "../output/pdf"  $_.FullName *>> ../output/temp/pdf/build.log;
		Write-Host "[ pdflatex " -NoNewline
		$success += $LASTEXITCODE;
		
		# Build bibtex (step 2/4)
		cp lit.bib ../output/pdf
		cd ../output/pdf
		bibtex $file.BaseName *>> ../temp/pdf/build.log;
		Write-Host "bibtex " -NoNewline
		$success += $LASTEXITCODE;
		
		# Build pdflatex (step 3/4)
		cd ../../patterns
		pdflatex -interaction=nonstopmode -output-directory "../output/pdf"  $_.FullName *>> ../output/temp/pdf/build.log;
		$success += $LASTEXITCODE;
		Write-Host "pdflatex " -NoNewline
		
		# Build pdflatex (step 4/4)
		pdflatex -interaction=nonstopmode -output-directory "../output/pdf"  $_.FullName *>> ../output/temp/pdf/build.log;
		$success += $LASTEXITCODE;
		Write-Host "pdflatex ] " -NoNewline
		
		# Success if all 4 steps returned error code 0, Error otherwise
		PrintSuccessOrError $success
}

Function build-web
{
	#start timer
	$stopwatch = [system.diagnostics.stopwatch]::startNew()

	# Recreate Output Folders
	Write-Host "Creating output/html"
	New-Item -Force -ItemType directory -Path output/html | Out-Null
	Write-Host "Creating output/temp/html"
	New-Item -Force -ItemType directory -Path output/temp/html | Out-Null
	Write-Host "Writing all output to output/temp/html/build.log"
	New-Item -Force -Path output/temp/html -Name "build.log" -ItemType File | Out-Null
	
	cd patterns
	
	# Build HTML
	cp ../output/temp/pdf/*.bbl .
	gci -Exclude template.tex,header.tex,all.tex,template_desc.tex,template_starter.tex *.tex | ForEach-Object {
		Write-Host ("Building Website " + $_.FullName + " ... ") -NoNewline
		htlatex $_.Name "html5, charset=utf-8" " -cunihtf -utf8" *>>  ../output/temp/html/build.log
		PrintSuccessOrError $LASTEXITCODE
	} 
	
	# Move all build-related files to output/temp for debugging
	gci -Exclude *.html, *.tex, *.png, *.pdf, lit.bib, *.cfg | ForEach-Object {mv -Force $_ ../output/temp/html} 
	
	# Insert menu into generated HTML files
	gci *.html | ForEach-Object {insert-into-file $_} 
	
	# Move / copy all HTML, images and css to output
	mv -Force *.html ../output/html 
	cp *.png ../output/html
	cp ../web/style.css ../output/html

	# Generate an index of all files
	Write-Host "Generating index"
	cd ../output/html
	New-Item -ItemType file -Force index.html | Out-Null
	echo "<DOCTYPE HTML>" > index.html
	echo "<head></head>" >> index.html
	echo "<body><h1>Alle Pattern</h1>" >> index.html
	gci -Name -Exclude index.html, *.png | ForEach-Object {echo "<a href='$_'>::> $_</a><br />"  >> index.html}
	echo "</body>" >> index.html
	cd ../..
	
	$stopwatch.Stop()
	Write-Host ("It took " + $stopwatch.Elapsed.ToString("mm\:ss") + " to build.")
}

Function build-catalog
{
	# code to compose one pdf with all patterns
	# Something like:
	#gci all.tex | Foreach-Object { build-single-pdf $_; } 
}


Function PrintSuccessOrError
{
	Param(
		[parameter(Mandatory=$true)]
		[int]
		$code
	)

	if($code -eq 0)
	{
		Write-Host "Success" -ForegroundColor green
	} else {
		Write-Host "Error" -ForegroundColor red 
	}
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

