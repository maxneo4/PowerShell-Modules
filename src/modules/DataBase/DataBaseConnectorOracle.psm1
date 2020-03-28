$root = $PSScriptRoot

Add-Type -path "$root\Oracle.ManagedDataAccess.dll"
Import-Module "$root/DataBaseCommon" -Force

function Open-OracleConnection
{	
	param($connectionString)	
	$script:connectionOracle = new-object Oracle.ManagedDataAccess.Client.OracleConnection($connectionString) -ErrorAction Stop
	$script:connectionOracle.Open()
	if(-not $script:connectionOracle.State -eq 'Open')
	{
		throw "The connection can not be stablished with $connectionString"
	}
}


function Close-OracleConnection
{	
	$script:connectionOracle.Close()
	$script:connectionOracle.Dispose()
	$script:connectionOracle = $null
}


function Select-QueryOracle
{	
	param($query, $connectionString, [switch]$asResultDataReader, [switch]$ManageConnection)
	
	if($ManageConnection -and $asResultDataReader){
		Write-Error "Cannot use manageConnection and asResultDataReader at same"
	}

	$query = Convertto-OracleQueryFromSqlServerQuery $query
	if($ManageConnection) { Open-OracleConnection $connectionString }
	$query = new-object Oracle.ManagedDataAccess.Client.OracleCommand($query, $script:connectionOracle)	
	$resultDataReader = $query.ExecuteReader()
	$result = $null
	if($asResultDataReader)
		{ $result = $resultDataReader } 
	else 
		{
			 $result = $resultDataReader | ConvertTo-Objects 
			 $resultDataReader.Close()
		}	
	if($ManageConnection) { Close-OracleConnection }
	return $result
}

function Invoke-CommandOracle
{	
	param($command, $connectionString, [switch]$ManageConnection)
	$command = Convertto-OracleQueryFromSqlServerQuery $command
	if($ManageConnection) { Open-OracleConnection $connectionString	 }
	$oraclecommand = new-object Oracle.ManagedDataAccess.Client.OracleCommand($command, $script:connectionOracle)
	$oraclecommand.ExecuteNonquery()
	if($ManageConnection) { Close-OracleConnection }
}

function Invoke-StoreProcedureOracle
{	
	param($command, $connectionString, [switch]$ManageConnection, [hashtable]$parameters)
	$command = Convertto-OracleQueryFromSqlServerQuery $command
	if($ManageConnection) { Open-OracleConnection $connectionString	 }
	$oraclecommand = new-object Oracle.ManagedDataAccess.Client.OracleCommand($command, $script:connectionOracle)
	$oraclecommand.CommandType = [System.Data.CommandType]::StoredProcedure
	foreach($key in $parameters.Keys)
	{
		[Oracle.ManagedDataAccess.Client.OracleParameter]$parameter = New-Object Oracle.ManagedDataAccess.Client.OracleParameter
		$parameter.Value = $parameters[$key]
		$parameter.ParameterName = $key
		$oraclecommand.Parameters.Add($parameter)
	}
	
	$oraclecommand.ExecuteNonquery()
	if($ManageConnection) { Close-OracleConnection }
}


function Convertto-OracleQueryFromSqlServerQuery
{
	param($query)
	return $query -replace 'dbo.', ''
}

Export-ModuleMember *