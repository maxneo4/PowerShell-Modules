
Import-Module Pester

. "$PSScriptRoot\Tool\Modules\InstallModules.ps1"

Invoke-Pester -OutputFile report.xml -outputformat nunitxml #-Path $tests #-EnableExit