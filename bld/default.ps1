$base = (Get-Item ..).FullName
$tmp = Join-Path $base 'tmp'
$out = Join-Path $base 'out'
$tls = Join-Path $base 'tls'

Task Default -depends Create-VsixArchives

Task Create-VsixArchives -depends Copy-VsixContent { 
  # Generate zip archive for each template
  Get-ChildItem -Path ..\tmp -Recurse -Include *.vstemplate | ForEach {
    $files = Get-ChildItem -Path $_.Directory.FullName
		
	Push-Location $_.Directory.FullName
	& $tls\7zip\7za.exe a -tzip -mx9 Template.zip *
	Pop-Location
	
	#Remove all files
	$files | ForEach {
	  Remove-Item -Recurse $_.FullName
	}
  }
  
  #Create VSIX files
  Get-ChildItem -Path ..\tmp | ForEach {
    Push-Location ..\tmp\$_
	& $tls\7zip\7za.exe a -tzip -mx9 $out\$_.vsix *
	Pop-Location
  }
}

Task Copy-VsixContent -depends Initialize-Directories {
  Get-ChildItem -Path ..\src -Recurse -Include *.vsixmanifest | ForEach {
	$name = $_.Directory.Name
	Copy-Item $_.Directory.FullName -Destination $tmp\$name -Recurse
  }
}

Task Initialize-Directories {
  if(Test-Path $tmp) {
    Remove-Item -Recurse -Force $tmp
    New-Item $tmp -Type directory
  }
  else {
	New-Item $tmp -Type directory
  }
  
  if(Test-Path $out) {
    Remove-Item -Recurse -Force $out
    New-Item $out -Type directory
  }
  else {
	New-Item $out -Type directory
  }
}