$url = "http://mirror.internode.on.net/pub/test/10meg.test"
$output = "$PSScriptRoot\10meg.test"
$start_time = Get-Date

Invoke-WebRequest -Uri $url -OutFile $output

----
$url = "http://mirror.internode.on.net/pub/test/10meg.test"
$output = "$PSScriptRoot\10meg.test"
$start_time = Get-Date

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
#OR
(New-Object System.Net.WebClient).DownloadFile($url, $output)

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"  
---

$pathModules = "$Env:ProgramFiles\WindowsPowerShell\Modules"

Get-ChildItem $PSScriptRoot -Filter '*.psm1' | 
%{ $folder = [System.IO.Path]::GetFileNameWithoutExtension($_.FullName)	
	$folder =[System.IO.Path]::Combine($pathModules,$folder)
	[System.IO.Directory]::CreateDirectory($folder)
    Copy-Item $_.FullName -Destination $folder }