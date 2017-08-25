

$services = Get-WmiObject win32_service | ?{$_.Name -like '*4063*'} | select Name, DisplayName, State, PathName
$services

#Forma 32bits
& "C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\installutil" /u /name="$($services[0].Name)" "$($services[0].PathName.Split('"')[1])"

#forma 64bits
& "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\installutil.exe" /u /name="$($services[0].Name)" "$($services[0].PathName.Split('"')[1])"
& sc delete BizAgiProjectASchedulerService


#Delete workPortal files
"C:\Bizagi\Enterprise\Projects\BizAgiR110x\Temporary" | Remove-Item -force
Get-ChildItem "C:\Windows\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files" -rec | Remove-Item -rec -force