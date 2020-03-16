
function register-dlls-fromFolder
{
    param($folderPath)
    Get-ChildItem $folderPath | Where-Object { $_ -like "*.dll" } | foreach-object {
        Unblock-File -Path $_.FullName;
        Add-Type -path $_.FullName;
       }
}

Export-ModuleMember *