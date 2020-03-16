$root = $PSScriptRoot
$pathModules = "$Env:ProgramFiles\WindowsPowerShell\Modules"

Get-ChildItem $root | Where-Object { $_.PSIsContainer } | #Filter only directories
ForEach-Object{ 	
	Copy-Item $_.FullName -Destination $pathModules -Recurse -Container -Force
}