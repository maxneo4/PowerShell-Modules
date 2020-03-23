function get-userName
{
    return $env:USERNAME
}

function new-shortCutInDesktop
{
    param($shorcutName, $target, $iconLocation)
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\$shorcutName.lnk")
    $Shortcut.TargetPath = $target
	if($iconLocation){ $Shortcut.IconLocation = "$iconLocation, 0" }
    $Shortcut.Save()
}

Export-ModuleMember *