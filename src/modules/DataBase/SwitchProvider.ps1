function set-provider($providerType)
{
    switch($providerType)
    {
        'oracle' { 
            Import-Module DataBaseConnectorOracle -Force
            set-alias select-query select-queryOracle -Scope Script -Force
            set-alias open-connection Open-OracleConnection -Scope Script -Force
            set-alias close-connection Close-OracleConnection -Scope Script -Force
        }
        'sqlserver' {      
            Import-Module DataBaseConnectorSqlServer -Force
            set-alias select-query select-querySqlServer -Scope Script -Force
            set-alias open-connection Open-SqlServerConnection -Scope Script -Force
            set-alias close-connection Close-SqlServerConnection -Scope Script -Force
        }
    }
}