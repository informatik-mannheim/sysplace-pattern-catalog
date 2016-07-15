Function clean
{
	delete-temps
	gci -Recurse -Path output/ -Include *.* | rm 
	gci -Path patterns/ -Include *.html,*.css -Recurse | rm
}

Function delete-temps
{
	gci -Recurse -Include *.aux, *.log, *.dvi, *.synctex.gz, *.4ct, *.4tc, *.tmp, *.lg, *.idv, *.xref, *.bbl, *.lof, *.blg, *.out, *.run.xml, *-blx.bib, *.ist, *.glo, *.ps | rm 
}

Function build-pdf
{
	$single_file;
	
	if($args[0]) {
		$single_file = $true;
	}

	$stopwatch = [system.diagnostics.stopwatch]::startNew()

	Write-Host "Creating output/pdf"
	New-Item -Force -ItemType directory -Path output/pdf | Out-Null
	Write-Host "Creating output/temp/pdf"
	New-Item -Force -ItemType directory -Path output/temp/pdf | Out-Null
	Write-Host "Writing all output to output/temp/pdf/build.log"
	New-Item -Force -Path output/temp/pdf -Name "build.log" -ItemType File | Out-Null
	
	cd patterns
	
	if($single_file) {
		# build the specified pattern
		gci -Filter ($args[0] + ".tex") | ForEach-Object {
			build-single-pdf $_;
		};
	}
	else {
		# build all patterns
		gci -Exclude template.tex,header.tex,all.tex,template_desc.tex,template_starter.tex,glossary.tex *.tex | ForEach-Object {
			build-single-pdf $_;
		}
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
		
		# Build pdflatex (step 1/5)
		Write-Host ("Building PDF " + $file.FullName + " ... ") -NoNewline; 
		pdflatex -interaction=nonstopmode -output-directory "../output/pdf"  $_.FullName *>> ../output/temp/pdf/build.log;
		Write-Host "[ pdflatex " -NoNewline
		$success += $LASTEXITCODE;
		
		# Build bibtex (step 2/5)
		cp lit.bib ../output/pdf
		cd ../output/pdf
		bibtex $file.BaseName *>> ../temp/pdf/build.log;
		Write-Host "bibtex " -NoNewline
		$success += $LASTEXITCODE;
		
		# Make glossaries (step 3/5)
		Write-Host "glossaries " -NoNewline
		makeglossaries $_.BaseName *>> ../temp/pdf/build.log
		$success += $LASTEXITCODE;
		
		# Build pdflatex (step 4/5)
		cd ../../patterns
		pdflatex -interaction=nonstopmode -output-directory "../output/pdf"  $_.FullName *>> ../output/temp/pdf/build.log;
		$success += $LASTEXITCODE;
		Write-Host "pdflatex " -NoNewline
		
		# Build pdflatex (step 5/5)
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
	Write-Host "Creating output/html/patterns"
	New-Item -Force -ItemType directory -Path output/html/patterns | Out-Null
	Write-Host "Creating output/temp/html"
	New-Item -Force -ItemType directory -Path output/temp/html | Out-Null
	Write-Host "Writing all output to output/temp/html/build.log"
	New-Item -Force -Path output/temp/html -Name "build.log" -ItemType File | Out-Null
	
	cd patterns
	
	# Build HTML
	cp ../output/temp/pdf/*.bbl .
	cp ../output/temp/pdf/*.gls .
	cp ../output/temp/pdf/*.aux .
	gci -Exclude template.tex,header.tex,all.tex,template_desc.tex,template_starter.tex,glossary.tex *.tex | ForEach-Object {
		Write-Host ("Building Website " + $_.FullName + " ... ") -NoNewline
		htlatex $_.Name "html5, charset=utf-8" " -cunihtf -utf8" *>>  ../output/temp/html/build.log
		PrintSuccessOrError $LASTEXITCODE
	} 
	
	# Move all build-related files to output/temp for debugging
	gci -Exclude *.html, *.tex, *.png, *.pdf, lit.bib, *.cfg | ForEach-Object {mv -Force $_ ../output/temp/html} 
	
	# Insert menu into generated HTML files
	gci *.html | ForEach-Object {insert-into-file $_} 
	
	# Generate search index
	Write-Host "Generating search index [temporarily disabled]"
	#generate-index
	
	# Jekyll Build
	jekyll build -s ../web/ -d ../output/html/
	
	# Move / copy all HTML, images and css to output
	mv -Force *.html ../output/html/patterns
	cp *.png ../output/html/patterns
	#cp -Recurse -Force ../web/_site/* ../output/html  # menu.html shouldn't be copied...
	cd ..
	
	$stopwatch.Stop()
	Write-Host ("It took " + $stopwatch.Elapsed.ToString("mm\:ss") + " to build.")
}

Function deploy
{
	pscp -r output/html/* webdeploy@141.19.142.50:/var/www/html/sysplace
}

Function generate-index
{
	..\composer\vendor\bin\jsindex .
	mv  -Force jssearch.index.js ..\output\html
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
			Get-Content ../web/_includes/menu.html
		}
		$_;
	} | Set-Content $file
}
