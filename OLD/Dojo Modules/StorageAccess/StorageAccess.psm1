New-Variable -Name module -Value 'StorageAccess' -Scope Global -Force

function Get-BlobStorage
{
    param($uri, $key, $outFile)
	Get-BlobStorageMethod -uri $uri -key $key -method GET -outFile $outFile
}

function Get-BlobStorageMethod
{
	param($uri, $key, $method, $body, $contentType, $outFile)
	
    $date = [System.DateTime]::UtcNow.ToString("R")
    $uriApiObject = Get-ApiObject -uri $uri

    $headers = @{"x-ms-date"=$date
             "x-ms-version"="2016-05-31"            
             }

    $stringToSign = Get-SignedSignatureBlobService -VERB $method `
	-canonicalizedResource $uriApiObject.canonicalizedResource -contentType $contentType -canonicalizedHeaders (Get-canonicalizedHeaders $headers)
   
    $authHeader = Get-AuthorizationHeader -Key $Key -stringToSign $stringToSign -StorageAccount $uriApiObject.StorageAccount
	$headers.Add("Authorization", $authHeader)
    		
    Invoke-WebRequest -Method $method -Uri $uri -Headers $headers -Body $body -UseBasicParsing -OutFile $outFile
}

function Get-SignedSignatureBlobService
{
    param($canonicalizedResource, $VERB, $contentEncoding, $contentLanguage, $contentLength, $date, $contentType, $ContentMD5,
    $IfModifiedSince, $IfMatch, $ifNoneMatch, $ifUnmodifiedSince, $Range, $canonicalizedHeaders)  
    $stringToSign = "$VERB`n$contentEncoding`n$ContentMD5`n$contentLanguage`n$contentLength`n$contentType`n$date`n$IfModifiedSince`n$IfMatch`n"+
    "$ifNoneMatch`n$ifUnmodifiedSince`n$Range`n$canonicalizedHeaders`n$canonicalizedResource"
    return $stringToSign
}

function Get-canonicalizedHeaders
{
    param($headers)
    "x-ms-date:$($headers['x-ms-date'])`nx-ms-version:$($headers['x-ms-version'])"
}

function Get-TableStorage
{
    param($uri, $key)
	Get-TableStorageMethod -uri $uri -key $key -method GET    
}

function Set-TableStorage
{
	param($uri, $key, $body)
	Get-TableStorageMethod -uri $uri -key $key -method POST `
	 -body $body -contentType 'application/json'
}

function Merge-TableStorage
{
	param($uri, $key, $body)
	Get-TableStorageMethod -uri $uri -key $key -method MERGE `
	 -body $body -contentType 'application/json'
}

function Remove-TableStorage
{
	param($uri, $key, $body)
	Get-TableStorageMethod -uri $uri -key $key -method DELETE `
}

function Get-TableStorageMethod
{
	param($uri, $key, $method, $body, $contentType)
	
    $date = [System.DateTime]::UtcNow.ToString("R")
    $uriApiObject = Get-ApiObject -uri $uri
    $stringToSign = Get-SignedSignatureTableService -VERB $method -date $date `
	-canonicalizedResource $uriApiObject.canonicalizedResource -contentType $contentType
    $authHeader = Get-AuthorizationHeader -Key $Key -stringToSign $stringToSign -StorageAccount $uriApiObject.StorageAccount

    $headers = @{"x-ms-date"=$date
             "x-ms-version"="2016-05-31"
             "Authorization"=$authHeader
             "DataServiceVersion"="3.0;NetFx"
             "MaxDataServiceVersion"="3.0;NetFx"
             "Accept"="application/json;odata=nometadata"
             }
	if($body)
	{
		$headers.Add("Content-Length", $body.Length)
		$headers.Add("Content-Type", $contentType)
	}
	if($method -eq 'PUT' -or $method -eq 'DELETE')
	{
		$headers.Add("If-Match", "*")
	}	
	if($method -eq 'GET'){ Invoke-RestMethod -Method $method -Uri $uri -Headers $headers -Body $body -UseBasicParsing }
	else{ Invoke-WebRequest -Method $method -Uri $uri -Headers $headers -Body $body -UseBasicParsing }
}


function Get-SignedSignatureTableService
{
    param($canonicalizedResource, $VERB, $date, $contentType, $ContentMD5)  
    $stringToSign = "$VERB`n$ContentMD5`n$contentType`n$date`n$canonicalizedResource"
    return $stringToSign
}

function Get-AuthorizationHeader
{
    param($key, $StorageAccount, $stringToSign)

    $sharedKey = [System.Convert]::FromBase64String($Key)
    $hasher = New-Object System.Security.Cryptography.HMACSHA256
    $hasher.Key = $sharedKey

    $signedSignature = [System.Convert]::ToBase64String($hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($stringToSign)))
    $authHeader = "SharedKey ${StorageAccount}:$signedSignature"
    return $authHeader
}


function Get-ApiObject
{
	Param($uri)

	$uriObj = New-Object -TypeName System.Uri -ArgumentList $uri
	$storageAccount = $uriObj.Host.Substring(0, $uriObj.Host.IndexOf('.'))
    $resource = $uriObj.PathAndQuery.Substring(1, $uriObj.PathAndQuery.Length - $uriObj.Query.Length -1) #-replace '\(\)',''
	
	#contruir parametros para blobStorage,  para tableStorage solo se requiere ?comp=metadata [Revisar documentacion de authenticacion]
    <#$queryDictionary = [System.Web.HttpUtility]::ParseQueryString($uriObj.Query)
    $orderedDictionary = $queryDictionary | Sort-Object 
    $canonilazedParameters="`n"
    $orderedDictionary | foreach{ $canonilazedParameters+="$($_):$($queryDictionary[$_])`n" }#>

	$apiParts = @{		
		StorageAccount = $storageAccount		
		resource = $resource
        canonicalizedResource = "/$StorageAccount/$resource$canonilazedParameters"
	}
	$apiObject = New-Object PSObject -Property $apiParts	
	return $apiObject
}

Export-ModuleMember Get-TableStorage, Set-TableStorage, Merge-TableStorage, Get-BlobStorage, Remove-TableStorage