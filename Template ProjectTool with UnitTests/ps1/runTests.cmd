cd /d %~dp0
powershell.exe -noexit -STA -noprofile -executionpolicy bypass . '%~dp0RunTests.ps1'