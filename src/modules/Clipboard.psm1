function Get-Clipboard 
{
	<#
	.SYNOPSIS
	Toma el contendio del portapapeles.
	#>
  if ($Host.Runspace.ApartmentState -eq 'STA') {
        Add-Type -Assembly PresentationCore
        [Windows.Clipboard]::GetText()
    } else {
    Write-Warning ('Run {0} with the -STA parameter to use this function' -f $Host.Name)
    return 'Run {0} with the -STA parameter to use this function' -f $Host.Name
  }
}

function Set-Clipboard 
{
	<#
	.SYNOPSIS
	Coloca contenido en el portapapeles.
	#>
    param([Parameter(Mandatory=$true, ValueFromPipeLine=$true)]$text)	
    if ($Host.Runspace.ApartmentState -eq 'STA') {
            Add-Type -Assembly PresentationCore
            [Windows.Clipboard]::SetText($text)
        } else {
        Write-Warning ('Run {0} with the -STA parameter to use this function' -f $Host.Name)
        return 'Run {0} with the -STA parameter to use this function' -f $Host.Name
    }
}

Export-ModuleMember *