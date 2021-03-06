<#Variables exportadas#>
New-Variable -Name module -Value 'neomax' -Scope Global -Force
New-Variable -Name remoteSession -Value $null -Scope Global -Force
New-Variable -Name connSqlServer -Value $null -Scope Global -Force
New-Variable -Name connSqlCeServer -Value $null -Scope Global -Force

[System.Reflection.Assembly]::LoadWithPartialName("system.data.sqlserverce")

function Format-Console
{
	<#
    .SYNOPSIS
      Da mayor legilibilidad a la consola mediante formatos y aumento en el tamaño del buffer.		
	#>
	param($title="Neomax", $foreGroundColor = "green", $backGroundColor="black")
	[console]::Title = $title
	[console]::ForegroundColor = $foreGroundColor
	[Console]::BackgroundColor = $backGroundColor
	[console]::BufferWidth = 120
	[console]::WindowWidth = 120
	[console]::BufferHeight = 3000
	[console]::WindowHeight = 50
}

#region Funciones de ayuda de comandos

function Get-HelpModule
{
	<#
    .SYNOPSIS
      Muestra la lisa de comandos del modulo con información de ayuda acerca de cada
	  uno de estos.
	.DESCRIPTION
	  
    .EXAMPLE
     Get-HelpModule neomax	
	.EXAMPLE
	 Get-HelpModule neomax *Location*
	#>
	param([Parameter(Mandatory=$true)][String]$nameModule,
	[String]$nameCommand = '*')
	$info = Get-Module $nameModule
	$info.ExportedCommands.get_Values() | 
	%{ if($_.name -like $nameCommand)
		{ Get-help $_.name -Examples }
	}
}

function Get-ListModule
{
	<#
    .SYNOPSIS
      Muestra la lisa de comandos del modulo.
	.DESCRIPTION
	  
    .EXAMPLE
     Get-ListModule neomax		
	#>
	param([Parameter(Mandatory=$true)][String]$nameModule)
	$info = Get-Module $nameModule
	$info.ExportedCommands.get_Values() | select CommandType,Name | Sort-Object -Property Name
}

#endregion

#region Funciones relativas a C#

function Get-CsharpLocation
{
	<#
    .SYNOPSIS
      Obtiene el directorio actual de las clases C# el cual es diferente al directorio de PS.			
	#>
	[IO.Directory]::GetCurrentDirectory()
}

function Set-CsharpLocation
{
	<#
    .SYNOPSIS
      Coloca el directorio actual de las clases C# el cual es diferente al directorio de PS.	
	#>
	param([Parameter(Mandatory=$true)][String]$dir)
	[IO.Directory]::SetCurrentDirectory($dir)
}

Function Import-CsFile
{
	<#
    .SYNOPSIS
      Carga el código de una clase C# para utilizarla desde powerShell.
	.DESCRIPTION
	  
    .EXAMPLE
     Import-CsFile ConfigFRT.cs System.Xml.dll		
	#>
	param( [Parameter(Mandatory=$true)]$file, [String[]]$Assemblies)
	process
	{
		$definition = Read-Path $file
		Add-Type -TypeDefinition $definition -Language CSharpVersion3 -ReferencedAssemblies $Asseblies
	}
}

Function Import-Assemblies
{
	<#
    .SYNOPSIS
      Carga las dlls del path indicado.
	.DESCRIPTION
	  
    .EXAMPLE
     Import-Assemblies 'E:\Dropbox\DEVELOPMENT\power_shell\PS'		
	#>
	param([Parameter(Mandatory=$true, ValueFromPipeLine=$true)][String]$path)
	
	Get-ChildItem $path -Filter '*.dll' | 
	%{ 
		[reflection.Assembly]::LoadFrom($_.FullName)
		#Add-Type $_.FullName
	}
	
	Set-CsharpLocation $path
}

Function get-Assemblies
{
<#
    .SYNOPSIS
      Muestra los tipos de las dlls que coincidan con el patron.
	.DESCRIPTION
	  
    .EXAMPLE
     get-Assemblies 'Everest'		
	#>
	param($pattern)
	[appdomain]::currentdomain.GetAssemblies() | 
	where { ($_.Location -like "*$($pattern)*")   } | 
	% {$_.gettypes()} | format-table -groupby Assembly -property NameSpace,Name -Wrap
}

#endregion

#region Funciones de entrada y salida

function Read-Path
{
	<#
    .SYNOPSIS
      Lee un archivo plano y retorna su contenido utilizando el método ReadAllText.
	  Si recibe varios elementos de la pipeline unira el contenido de todos.
	  Es necesario dado que el comand get-Content trae las lineas como un array
	.DESCRIPTION
	  
    .EXAMPLE
     Read-Path 'C:\log.txt'
	.EXAMPLE
	 "file.cs" | Read-Path	 
	.EXAMPLE
	@('hola.txt','saludo.txt') | Read-Path
	#>
	param([Parameter(Mandatory=$true, ValueFromPipeLine=$true)] [string]$path)
	Begin
	{
		$result = ''
	}	
	Process
	{		
		$result+=[IO.File]::ReadAllText(  ( Resolve-Path $path) )
	}
	End
	{
		$result
	}		
}

Function Get-ProcessLocation
{
	<#
	.SYNOPSIS
	Obtiene la ruta del ejcutable en caso que este se encuentre embebido dentro de un .exe.
	Más especificamente encuentra la ruta fisica del proceso que 
	#>
	$p = Get-Process -Id $PID 
	$path =  Split-Path -Parent $p.Path
}

function Merge-Folder()
{
	<#
	.SYNOPSIS
	Verifica si un folder existe... de no ser asi se creara.
	#>
	param($folder)
	if(!(Test-Path -Path $folder )){
		New-Item -ItemType directory -Path $folder
	}
}

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

Function Get-FilePath
{   
	<#
	.SYNOPSIS
	Abre una interface de usuario para seleccionar la ubicación de un archivo en el sistema.
	#>
	 param($initialDirectory)
	 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
	 Out-Null
	 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	 $OpenFileDialog.initialDirectory = $initialDirectory
	 $OpenFileDialog.filter = "All files (*.*)| *.*"
	 $OpenFileDialog.ShowDialog() | Out-Null
	 $OpenFileDialog.filename
}

Function Remove-ChildrenFolders
{
<#
	.SYNOPSIS
	Remueve las carpetas que contenga el folderpath.
	#>
    param($folderPath)
    
    $files = Get-ChildItem $folderPath -Recurse |  where{ $_.Attributes -ne 'Directory' }
    $files | %{ Set-ItemProperty $_.FullName -name IsReadOnly -value $false }
    Remove-Item $folderPath -Recurse
}

#endregion

#region Funciones de diagnostico

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

function Measure-Performance
{
	<#
    .SYNOPSIS
      Mide el tiempo que le toma a una rutina completarse n veces.
	.DESCRIPTION
	  
    .EXAMPLE
	 $codeps = { Read-EventLog | out-null }
     Measure-Performance $codeps 200		
	#>
 param([scriptblock]$code, [int]$iteraciones)
	$dateBegin = Get-Date	
	for($i=0; $i -le $iteraciones; $i++)
	{
		& $code
	}
	$dateEnd = Get-Date	
	$time = $dateEnd - $dateBegin
	New-Object PsObject -Property  @{  TotalTime=$time.ToString(); BeginTime = $dateBegin; EndTime = $dateEnd } | Format-Table -Property BeginTime,EndTime,TotalTime
}

Function Write-Log
{	
	<#
    .SYNOPSIS
      Escribe un texto en un log de texto plano. Retorna la ruta del archivo donde a colocado el texto
	.DESCRIPTION
	  
    .EXAMPLE
	 Write-Log 'Hello World'
	 Write-Log 'Hello World' -source 'user' -pathLog 'C:'
	#>
	param($text, $source='' ,$pathLog)
	if($pathLog -eq $null)
		{ $pathLog = Get-Location }
	$nameLog = get-date -f 'dd-MMM-yyyy'
	if($source -eq $null) #Si se especifica la fuente se 
	{ $nameLog = "$source $nameLog" }
	
	$dateLog = get-date -f 'HH:mm ss'	
	$target = "$pathLog\log-$nameLog.txt"
	"$dateLog - $text" | Add-Content $target
	$target
} 

#endregion

#region Funciones para acceso remoto

Function Enable-WinRM
{
	<#
	.SYNOPSIS
	Habilita el servicio de WinRM para acceder a comandos remotos.
	#>
	Enable-PSRemoting -Force
	Set-Item wsman:\localhost\client\trustedhosts *
	Restart-Service WinRM
}

Function Get-NewPsSession
{
	<#
		.SYNOPSIS
		Crea una Sesion donde la contraseña es solicitada y no abre ventana emergente
	#>
	param([Parameter(Mandatory=$true)]$computerName, [Parameter(Mandatory=$true)]$UserName)	

	$Password = Read-Host -AsSecureString "Enter Your Password:" 

	$credencial = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $Password 

	New-PSSession -ComputerName $computerName `
	  -Credential $credencial
}

Function Set-CurrentSession
{
	<#
		.SYNOPSIS
		Coloca la sesión remota de trabajo.
	#>
	param($session)
	$global:remoteSession = $session
}

Function Send-Command
{
	<#
		.SYNOPSIS
		Corre un script en la sesión remota de trabajo
	#>
	param([Scriptblock]$script)	
	Invoke-Command -Session $global:remoteSession -ScriptBlock $script
}

Function Enable-Scritps
{	
	<#
		.SYNOPSIS
		Habilita el uso de scritps en la sesión remota de trabajo
	#>
	Send-Command -script 
	{
	    #Set executionpolicy to bypass warnings IN THIS SESSION ONLY
	    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
	}
}

function Register-Script 
{
	<#
		.SYNOPSIS
		Registra un script para su uso en la sesión remota de trabajo
	#>
	param([Parameter(Mandatory=$true)][string]$path)
 	Invoke-Command -Session $global:remoteSession -FilePath $path	
}

#endregion

#region Funciones relativas a cadenas de texto

Function Format-Text
{
	<#
	.SYNOPSIS
	Recibe un hash el cual se utiliza para formatear un texto con valores del estilo #NAME donde en el hash deberia estar presente la key NAME con cierto valor que sera el que tomara su posción dentro del texto.
	#>
	param([String]$text, [HashTable]$pivots)
	
	foreach($comodin in $pivots.GetEnumerator())
	{		
		$text = $text -replace "#$($comodin.key)", $pivots[$comodin.key]
	}
	$text
}

Function Get-FileName
{
	<#
	.SYNOPSIS
	Invoka el método [System.IO.Path]::GetFileName
	#>
	param([string]$fullName)
	
	[System.IO.Path]::GetFileName($fullName)
}

#endregion

#region Funciones para manejo de datos en memoria

Function Expand-ArrayObject
{
	<#
	.SYNOPSIS
	Recibe un arreglo de objetos y realiza una expansion sobre datos separados por cierto separador
	.EXAMPLE
	$arr | Expand-ArrayObject fieldX 
	#>
	param ( [Parameter(ValueFromPipeline=$true, Mandatory=$true)][PSObject[]] $array
	,[Parameter(Mandatory=$true)][string]$field, [char] $delimiter = ';' )
	
	process
	{	
		[PSObject[]] $array_result = @()			
			foreach($item in $array)
			{
				$item."$field" -split $delimiter | 
				%{ $newItem = $item.PSObject.Copy(); $newItem."$field" = $_; $array_result += $newItem }
			}	
		$array_result	
	}
}

Function ConvertTo-Objects
{
	<#
	.SYNOPSIS
	Recibe un Resultado de una consulta y la convierte a un array de objetos el cual es
	mas legible de comprender
	.EXAMPLE
	$rdr = Select-SqlCeServer 'SELECT * FROM TABLE1' 'Data Source=C:\Users\cdbody05\Downloads\VisorImagenesNacional\VisorImagenesNacional\DIVIPOL.sdf;'		
	$rdr | ConvertTo-Objects 
	#>
	param([Parameter(ValueFromPipeline=$true, Mandatory=$true)][Object[]]$rdr)
	BEGIN
	{
		$arr = @()	
		$count = 0
	}
	
	PROCESS
	{
	
		if($rdr)
		{			
		#Cargamos el resultado al objeto				
			foreach ($item in $rdr)	
			{
				$count++
				$obj = new-Object PSObject
				#Listara todos los campos que vienen en la consulta			
				$obj | Add-Member Noteproperty N $count
				for($i = 0; $i -lt $item.FieldCount; $i++)	
				{	$obj | Add-Member Noteproperty $item.GetName($i) $item[$i]	}			
				$arr += $obj
			}
		}	
	}
	END
	{
		$arr
	}
}

#endregion

#region Funciones relativas a HTML

Function Set-AlternatingRows {
	<#
	.SYNOPSIS
		Simple function to alternate the row colors in an HTML table
	.DESCRIPTION
		This function accepts pipeline input from ConvertTo-HTML or any
		string with HTML in it.  It will then search for <tr> and replace 
		it with <tr class=(something)>.  With the combination of CSS it
		can set alternating colors on table rows.
		
		CSS requirements:
		.odd  { background-color:#ffffff; }
		.even { background-color:#dddddd; }
		
		Classnames can be anything and are configurable when executing the
		function.  Colors can, of course, be set to your preference.
		
		This function does not add CSS to your report, so you must provide
		the style sheet, typically part of the ConvertTo-HTML cmdlet using
		the -Head parameter.
	.PARAMETER Line
		String containing the HTML line, typically piped in through the
		pipeline.
	.PARAMETER CSSEvenClass
		Define which CSS class is your "even" row and color.
	.PARAMETER CSSOddClass
		Define which CSS class is your "odd" row and color.
	.EXAMPLE $Report | ConvertTo-HTML -Head $Header | Set-AlternateRows -CSSEvenClass even -CSSOddClass odd | Out-File HTMLReport.html
	
		$Header can be defined with a here-string as:
		$Header = @"
		<style>
		TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
		TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
		TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
		.odd  { background-color:#ffffff; }
		.even { background-color:#dddddd; }
		</style>
		"@
		
		This will produce a table with alternating white and grey rows.  Custom CSS
		is defined in the $Header string and included with the table thanks to the -Head
		parameter in ConvertTo-HTML.
	.NOTES
		Author:         Martin Pugh
		Twitter:        @thesurlyadm1n
		Spiceworks:     Martin9700
		Blog:           www.thesurlyadmin.com
		
		Changelog:
			1.0         Initial function release
	.LINK
		http://community.spiceworks.com/scripts/show/1745-set-alternatingrows-function-modify-your-html-table-to-have-alternating-row-colors
	#>
    [CmdletBinding()]
   	Param(
       	[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [string]$Line,
       
   	    [Parameter(Mandatory=$True)]
       	[string]$CSSEvenClass,
       
        [Parameter(Mandatory=$True)]
   	    [string]$CSSOddClass
   	)
	Begin {
		$ClassName = $CSSEvenClass
	}
	Process {
		If ($Line.Contains("<tr>"))
		{	$Line = $Line.Replace("<tr>","<tr class=""$ClassName"">")
			If ($ClassName -eq $CSSEvenClass)
			{	$ClassName = $CSSOddClass
			}
			Else
			{	$ClassName = $CSSEvenClass
			}
		}
		Return $Line
	}
}

#endregion

#region Funciones de bases de datos

function Open-SqlServer
{
	<#
	.SYNOPSIS
	Abre la conexion a SQL Server y la guarda en la variable $global:connSqlServer 
	#>
	param($stringConnection)
	$global:connSqlServer = new-object system.data.SqlClient.SQLConnection
	$global:connSqlServer.ConnectionString = $stringConnection
	$global:connSqlServer.Open()
}

function Select-SqlServer
{	
	<#
	.SYNOPSIS
	Ejecuta una consulta SqlServer retornando el ResultDataReader
	#>
	param($query, $stringConnection)
	
	Open-SqlServer $stringConnection
	$cmd = new-object system.data.sqlclient.sqlcommand
	$cmd.Connection = $global:connSqlServer	
	$cmd.CommandText = $query
	$rdr=$cmd.ExecuteReader()
	$rdr
	Close-SqlServer
}

function Invoke-SqlServer
{
	<#
	.SYNOPSIS
	Ejecuta un comando SqlServer	
	#>
	param($query, $stringConnection)
	
	Open-SqlServer $stringConnection	
	$cmd = new-object system.data.sqlclient.sqlcommand
	$cmd.Connection = $global:connSqlServer	
	$cmd.CommandText = $query	
	$cmd.ExecuteNonQuery()
	Close-SqlServer	
}

function Close-SqlServer
{
	<#
	.SYNOPSIS
	Cierra la conexion relativa a SqlServer $global:connSqlServer
	#>
	$global:connSqlServer.Close()
	$global:connSqlServer.Dispose()
}

function Open-SqlCeServer
{
	<#
	.SYNOPSIS
	Abre la conexion a SQL Server y la guarda en la variable $global:connSqlServer
	.EXAMPLE
	Open-SqlCeServer 'Data Source=C:\Users\cdbody05\Downloads\VisorImagenesNacional\VisorImagenesNacional\DIVIPOL.sdf;'
	#>
	param($stringConnection)
	$global:connSqlCeServer = new-object System.Data.SqlServerCe.SqlCeConnection
	$global:connSqlCeServer.ConnectionString = $stringConnection
	$global:connSqlCeServer.Open()
}

function Select-SqlCeServer
{	
	<#
	.SYNOPSIS
	Ejecuta una consulta SqlServer retornando el ResultDataReader
	.EXAMPLE
	Select-SqlCeServer 'SELECT * FROM TABLE1' 'Data Source=C:\Users\cdbody05\Downloads\VisorImagenesNacional\VisorImagenesNacional\DIVIPOL.sdf;'	
	#>
	param($query, $stringConnection)
	
	Open-SqlCeServer $stringConnection
	$cmd = new-object System.Data.SqlServerCe.SqlCeCommand
	$cmd.Connection = $global:connSqlCeServer	
	$cmd.CommandText = $query
	$rdr=$cmd.ExecuteReader()
	$rdr
	Close-SqlCeServer
}

function Invoke-SqlCeServer
{
	<#
	.SYNOPSIS
	Ejecuta un comando SqlServer	
	#>
	param($query, $stringConnection)
	
	Open-SqlServer $stringConnection	
	$cmd = new-object System.Data.SqlServerCe.SqlCeCommand
	$cmd.Connection = $global:connSqlCeServer	
	$cmd.CommandText = $query	
	$cmd.ExecuteNonQuery()
	Close-SqlCeServer	
}

function Close-SqlCeServer
{
	<#
	.SYNOPSIS
	Cierra la conexion relativa a SqlServer $global:connSqlServer
	#>
	$global:connSqlCeServer.Close()
	$global:connSqlCeServer.Dispose()
}

#endregion

#region Funciones para crear scripts SQL

function Get-TemplateInsert($csv, $nombreTabla, $OnlyInsert = $False)
{
<#
	.SYNOPSIS
	 Genera el script para insertar data y/o crear la tabla
	.EXAMPLE
	Get-TemplateInsert 'TABLE' $true
	Get-TemplateInsert 'TABLE'
	#>
	$rowExtract = $csv[0]
	$properties = $rowExtract | Get-Member -MemberType NoteProperty
	$createTable = "CREATE TABLE $nombreTabla("
	$template = "`r`nINSERT INTO $nombreTabla("
	$values = 'SELECT '
	$count = 0	   
	foreach($property in $properties)
	{
		$propertiCap = $property.Name.ToUpper()		
		$measure = $csv | select -ExpandProperty $propertiCap | %{ $_.length } | measure -Maximum	
		$size = $measure.maximum * 2
		if(!$size)
		{ $size = 1 }
		if($count -gt 0){ $template += ",`r`n"; $values += ', '; $createTable += ",`r`n" }
		$createTable+= "$propertiCap VARCHAR($size)"
		$template+=  "[$propertiCap]"
		$values+= "'{#$propertiCap}'" 
		$count++
	}
	$template += ")`r`n"
	$createTable += ")`r`n"
	if(-not $OnlyInsert)
	{ $template = $createTable + $template }
	
	@($template, $values) #Retorna el encabezado y los valores	
}

function Get-InsertDataScript($nombreTabla, $OnlyInsert = $False)
{
	$data = getc
	$csv = $data | ConvertFrom-Csv -Delimiter "`t"
	#temp
	#$csv = $csv | expand-arrayObject -field folio -delimiter ';'
	
	$insert = Get-TemplateInsert $csv $nombreTabla $OnlyInsert
	
	$resultScript = $insert[0]
	$count = 0
	foreach($row in $csv)
	{
		$properties = $row | Get-Member -MemberType NoteProperty
		$scriptRow = $insert[1]
		
		foreach($property in $properties)
		{
			$propertiCap = $property.Name.ToUpper()
			$scriptRow = $scriptRow -replace "{#$propertiCap}" ,$row."$propertiCap"	
		}
		if($count -gt 0){ $scriptRow = "`r`nUNION ALL`r`n " + $scriptRow }		
		$resultScript += $scriptRow
		$count++
	}	
	$resultScript = $resultScript -replace "'NULL'", "NULL"
	$resultScript | Out-File 'out.txt'
	
	if($OnlyInsert)
	{	setc $resultScript }
	else { ii 'out.txt' }
}

#endregion

#region Funciones para generar codigo repetitivo

<#
	.SYNOPSIS
	 Genera varias lineas de codigo de acuerdo a los datos csv copiados en el portapapeles, 
    los encabezados son requerdidos. La salida quedara en el mismo portapapeles
	.EXAMPLE
    Para esto los encabezados de los datos deberian ser idWorkingTimeSchema, weekDay, isWorking ... etc
    Se puede usar <NameUser> para diferenciarlo de #Name, ya que podria reemplazar el fragmento #Name de User por el valor de Name
	Get-GenerateCode 'new object[]{ #idWorkingTimeSchema, #weekDay, #isWorking, #fromDate, #toDate, #fromTime1, #toTime1, #fromTime2, #toTime2, #fromTime3, #toTime3, #fromTime4, #toTime4, #fromTime5, #toTime5 }'
	#>
function Get-GenerateCode($template)
{
    $data = getc 
    $csv = ConvertFrom-Csv $data -Delimiter "`t"
    $resultCode = ''
    $properties = $csv[0] | Get-Member -MemberType NoteProperty   
    foreach($row in $csv)
	{		
        $formatedText = $template
        foreach($property in $properties)
		{            
            $propertyName = $property.Name
            $value = $row."$propertyName"
            $formatedText = $formatedText -replace "<$($propertyName)>" , $value
			$formatedText = $formatedText -replace "#$propertyName" , $value	
        }        
        $resultCode += "`t" + $formatedText + "`r`n"
    }
    setc $resultCode
}

function Get-GeneratHeaders()
{
    $data = getc 
    
    $resultCode = $data -replace "`t", '", "'
    $resultCode = $resultCode -replace  "`r`n", ""
    $resultCode = '"'+ $resultCode + '"'
    setc $resultCode
}

#endregion

#region Definición de alias
Set-Alias getc Get-Clipboard -Scope Global
Set-Alias setc Set-Clipboard -Scope Global
#endregion

Export-ModuleMember *