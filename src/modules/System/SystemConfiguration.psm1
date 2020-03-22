function get-userName
{
    return $env:USERNAME
}

function new-shortCutInDesktop
{
    param($shorcutName, $target)
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\$shorcutName.lnk")
    $Shortcut.TargetPath = $target
    $Shortcut.Save()
}

Export-ModuleMember *