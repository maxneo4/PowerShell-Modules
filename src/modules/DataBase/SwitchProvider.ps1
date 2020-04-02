$rootSwitchProvider = $PSScriptRoot

function set-provider($connectionString)
{
    $providerType = if($connectionString.Contains("Initial Catalog")){ 'sqlserver'} else { 'oracle' }
    switch($providerType)
    {
        'oracle' { 
            Import-Module "$rootSwitchProvider/DataBaseConnectorOracle" -Force
            set-alias select-query select-queryOracle -Scope Script -Force
            set-alias open-connection Open-OracleConnection -Scope Script -Force
            set-alias close-connection Close-OracleConnection -Scope Script -Force
        }
        'sqlserver' {      
            Import-Module "$rootSwitchProvider/DataBaseConnectorSqlServer" -Force
            set-alias select-query select-querySqlServer -Scope Script -Force
            set-alias open-connection Open-SqlServerConnection -Scope Script -Force
            set-alias close-connection Close-SqlServerConnection -Scope Script -Force
        }
    }
}