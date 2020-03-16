New-Variable -Name module -Value 'SqlServerConnector' -Scope Global -Force

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
				$obj | Add-Member Noteproperty dataRow $item
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

function Get-InsertScript($object, $table)
{
    $columns = @()
    $values = @()
    for($i = 0; $i -lt $object.dataRow.FieldCount; $i++){
      $colunmName = $object.dataRow.GetName($i) 
      $value = $object.$colunmName
      $columns += $colunmName
      $values += "'$value'"
     } 
    
   
    $columns = $columns -join ', '
    $values = $values -join ', '
    "Insert into $table ($columns) values ($values)"
}

Export-ModuleMember *