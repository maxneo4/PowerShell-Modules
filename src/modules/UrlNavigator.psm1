
function open-url
{
    param([string]$url)
    [System.Diagnostics.Process]::Start($url)
}

Export-ModuleMember *