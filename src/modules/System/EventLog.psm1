function Read-EventLog
{
	<#
    .SYNOPSIS
      Obtiene los últimos registros del log de eventos de acuerdo a una fuente y tipo de entrada.
	  Adicionalmente cuenta con un párametro opcional para filtrar los que ocurrieron luego de cierta fecha. 
	.DESCRIPTION
	  
    .EXAMPLE
     Read-EventLog	#Esto traera los 100 eventos mas recientes
	.EXAMPLE 
	 Read-EventLog 20 Msi #En los ultimos 20 buscara traera los que la fuente coincidan por ejemplo con MsiInstaller
	.EXAMPLE
	 Read-EventLog 20 Msi Error #Trae solo aquellos de tipo error
	 Read-EventLog 20 Msi Information #Trae solo aquellos de tipo information
	.EXAMPLE
	 Read-EventLog 20 Msi -after "27/04/14 16:06"
	#>
	param([int]$last=100, [string]$sourceFilter, [string]$EntryType, [string]$after)
	
	if ($after -ne $null -and $after -ne '')		
	 {	 	
		$afterdt = [datetime]::ParseExact($after, "dd/MM/yy HH:mm", $null)		
		$global:list = get-eventlog application -newest $last -after $afterdt | where{ $_.Source -like "*$sourceFilter*" } | where{ $_.EntryType -like "*$EntryType*"}
	 }	
	else { 
		$global:list = get-eventlog application -newest $last | where{ $_.Source -like "*$sourceFilter*" } | where{ $_.EntryType -like "*$EntryType*"}
		}		
	$list
}

Export-ModuleMember *