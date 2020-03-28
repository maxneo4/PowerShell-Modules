$root = $PSScriptRoot
Import-Module "$root/DataBaseCommon" -Force

function Open-SqlServerConnection
{	
	param($connectionString)
	$script:connectionSqlServer = new-object system.data.SqlClient.SQLConnection
	$script:connectionSqlServer.ConnectionString = $connectionString
	$script:connectionSqlServer.Open()
	if(-not $script:connectionSqlServer.State -eq 'Open')
	{
		throw "The connection can not be stablished with $connectionString"
	}
}

function Close-SqlServerConnection
{	
	$script:connectionSqlServer.Close()
	$script:connectionSqlServer.Dispose()
	$script:connectionSqlServer = $null
}

function Select-QuerySqlServer
{	
	
	param($query, $connectionString, [switch]$asResultDataReader, [switch]$ManageConnection)
	
	if($ManageConnection -and $asResultDataReader){
		Write-Error "Cannot use manageConnection and asResultDataReader at same"
	}

	if($ManageConnection) { Open-SqlServerConnection $connectionString }
	$command = new-object system.data.sqlclient.sqlcommand
	$command.Connection = $script:connectionSqlServer	
	$command.CommandText = $query
	$resultDataReader=$command.ExecuteReader()	
	$result = $null
	if($asResultDataReader)
		{ $result = $resultDataReader } 
	else 
		{ 
			$result = $resultDataReader | ConvertTo-Objects
			$resultDataReader.Close()
		}
	if($ManageConnection) { Close-SqlServerConnection }
	return $result
}

function Invoke-CommandSqlServer
{	
	param($command, $connectionString, [switch]$ManageConnection)
	
	if($ManageConnection) { Open-SqlServerConnection $connectionString	}
	$command = new-object system.data.sqlclient.sqlcommand
	$command.Connection = $script:connectionSqlServer	
	$command.CommandText = $command	
	$command.ExecuteNonQuery()
	if($ManageConnection) { Close-SqlServerConnection }
}

Export-ModuleMember *