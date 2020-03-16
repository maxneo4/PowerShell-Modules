Import-Module StorageAccess -Force

function Merge-Entity
{
    param($storage, $sharedKey, $table, $partitionKey, $rowKey, $jsonBody)    	
	$uri = "https://$($storage).table.core.windows.net/$table(PartitionKey='$partitionKey', RowKey='$rowKey')"	
	Merge-TableStorage -uri $uri -key $sharedKey -body $jsonBody
}

function Get-Entity
{
	param($storage, $sharedKey, $table, $partitionKey, $rowKey)    	
	$uri = "https://$($storage).table.core.windows.net/$($table)()?`$filter=PartitionKey eq '$partitionKey' and RowKey eq '$rowKey'"	
	Get-TableStorage -uri $uri -key $sharedKey
}

function Get-EntityByPartitionKey
{
	param($storage, $sharedKey, $table, $partitionKey)    	
	$uri = "https://$($storage).table.core.windows.net/$($table)()?`$filter=PartitionKey eq '$partitionKey'"	
	Get-TableStorage -uri $uri -key $sharedKey
}

function Get-EntityByPartitionKeyAndCustomProperty
{
	param($storage, $sharedKey, $table, $partitionKey, $customPropertyName, $customPropertyValue)    	
	$uri = "https://$($storage).table.core.windows.net/$($table)()?`$filter=PartitionKey eq '$partitionKey' and $customPropertyName eq '$customPropertyValue'"	
	Get-TableStorage -uri $uri -key $sharedKey
}

function Remove-Entity
{
	param($storage, $sharedKey, $table, $partitionKey, $rowKey)    	
	$uri = "https://$($storage).table.core.windows.net/$table(PartitionKey='$partitionKey', RowKey='$rowKey')"	
	Remove-TableStorage -uri $uri -key $sharedKey
}