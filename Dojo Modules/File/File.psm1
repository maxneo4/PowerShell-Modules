New-Variable -Name module -Value 'Utils' -Scope Global -Force

function Get-ContentFromFile
{	
	param([Parameter(Mandatory=$true, ValueFromPipeLine=$true)] [string]$filePath)
	Begin
	{
		$content = ''
	}	
	Process
	{		
		$content+=[IO.File]::ReadAllText(  ( Resolve-Path $filePath) )
	}
	End
	{
		$content
	}		
}

Export-ModuleMember Get-ContentFromFile