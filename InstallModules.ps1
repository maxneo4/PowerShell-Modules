$pathModules = "$Env:ProgramFiles\WindowsPowerShell\Modules"

Get-ChildItem $PSScriptRoot -Filter '*.psm1' | 
%{ $folder = [System.IO.Path]::GetFileNameWithoutExtension($_.FullName)	
	$folder =[System.IO.Path]::Combine($pathModules,$folder)
	[System.IO.Directory]::CreateDirectory($folder)
    Copy-Item $_.FullName -Destination $folder }