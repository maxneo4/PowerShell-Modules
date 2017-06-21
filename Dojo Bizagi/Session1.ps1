#https://ss64.com/ps/

#interpolation

$jsonString = '{"jsonProperty":"jsonValue"}'
$interpolateExample = "The jsonstring is $jsonString"
$interpolateExample

$jsonString = '{"jsonProperty":"jsonValue"}'
$interpolateExample = 'The jsonstring is $jsonString'
$interpolateExample


$process = (Get-Process)[0]
$interpolateExample = "The process name is $process.Name"
$interpolateExample

$process = (Get-Process)[0]
$interpolateExample = "The process name is $($process.Name)"
$interpolateExample

#dynamic language

$storedExpression = 'if($number -gt 2){ write-host $number+1 }else{ write-host $number-1 }'
$number = 3
Invoke-Expression $storedExpression
$number = 1
Invoke-Expression $storedExpression

$command = { if($number -gt 2){ write-host ($number+1) }else{ write-host ($number-1) } }
$number = 3
$command.Invoke()

$command = { param($number) if($number -gt 2){ write-host ($number+1) }else{ write-host ($number-1) } }
$command.Invoke(2)

$method = 'Invoke'
$command."$method"(9)

#Pipeline

$items = 5,9,3,4
$items | Where-Object { $_ % 3 -eq 0 } | %{ $_ + 1 }


function get-JsonCharp
{
	<#
    .SYNOPSIS
     Recibe un json y lo formatea para reemplazar comillas por las especiales.
	.DESCRIPTION
	  
    .EXAMPLE
     get-JsonCharp '{"name":"jason", "edad":"28"}'		
	#>
	param([Parameter(Mandatory=$true, ValueFromPipeLine=$true)][String]$json) 
	$json -replace '"', '\"'
}


function get-JsonCharpClipboard
{
	getc | get-JsonCharp | setc
}

#Ccharp compatibility

[Guid]::NewGuid()

$contentFile = [IO.File]::ReadAllText($filepath)

$ConfigFRTClassContent = [IO.File]::ReadAllText('ConfigFRT.cs')
Add-Type -TypeDefinition $ConfigFRTClassContent -Language CSharpVersion3 -ReferencedAssemblies System.Xml.dll

[reflection.Assembly]::LoadFrom($fullNameDll)

[Reflection.Assembly]::LoadWithPartialName("system.data.sqlserverce")

Function Get-FilePath
{   	
	 param($initialDirectory)
	 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
	 Out-Null
	 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	 $OpenFileDialog.initialDirectory = $initialDirectory
	 $OpenFileDialog.filter = "All files (*.*)| *.*"
	 $OpenFileDialog.ShowDialog() | Out-Null
	 $OpenFileDialog.filename
}

#comparison operators

$list = 'pan', 'panaderia', 'zapato', 'Panadero', 'tienda'


$list | Where-Object { $_ -like 'pan*'}


$list | Where-Object { $_ -clike 'pan*'}


#Clipboard demo
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
  }
}

$excelContent = Get-Clipboard
$objectsPs = $excelContent | ConvertFrom-Csv -Delimiter "`t" 
$ownerList = $objectsPs | where { $_.rol -eq 'owner'}
$ownerList | ConvertTo-Html - | Out-File 'C:\report.html'
Invoke-Item 'C:\report.html'