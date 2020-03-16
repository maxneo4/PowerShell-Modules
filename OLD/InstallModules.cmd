cd /d %~dp0
powershell.exe -noexit -STA -noprofile -executionpolicy bypass . '%~dp0InstallModules.ps1' '%~dp0'