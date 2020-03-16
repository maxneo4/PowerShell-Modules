$url = "https://dl.dropboxusercontent.com/u/24769953/PowerShell/NeoMaxTemplates.psm1"

$pathModules = @($env:PSModulePath -split ';')[0]
$folderName = [System.IO.Path]::GetFileNameWithoutExtension($url)	
$folder =[System.IO.Path]::Combine($pathModules,$folderName)
[System.IO.Directory]::CreateDirectory($folder)
$fileName = [System.IO.Path]::GetFileName($url)
$output = [System.IO.Path]::Combine($folder, $fileName)
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)