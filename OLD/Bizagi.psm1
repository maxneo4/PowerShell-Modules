<#Variables exportadas#>

#region cadenas de texto

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

function get-JsonNormal
{
	<#
    .SYNOPSIS
     Recibe un json con formato C# y lo formatea con las comillas normales.
	.DESCRIPTION
	  
    .EXAMPLE
     get-JsonNormal '{\"name\":\"jason\", \"edad\":\"28\"}'		
	#>
	param([Parameter(Mandatory=$true, ValueFromPipeLine=$true)][String]$json) 
	$json -replace '\\"', '"'
}

function get-JsonCharpClipboard
{
	getc | get-JsonCharp | setc
}

function get-JsonNormalClipboard
{
	getc | get-JsonNormal | setc
}

function get-FormattedJson
{
    $input = getc
    $formatted = $input -replace '{', '{{'
    $formatted = $formatted -replace '}','}}'
    setc $formatted
}

function get-Guid
{
<#
    .SYNOPSIS
     Genera un GUID nuevo, lo copia al portapapeles y lo retorna.
	.DESCRIPTION
	 
    .EXAMPLE
     $guid = get-Guid	
	#>
	$guid = [System.GUID]::NewGuid()
	$guid.ToString().toUpper() | setc
	$guid
}

function get-ScriptIdTaskFromGuid($targetTable, $IdTargetTable, $idTaskColumn, $newGUIDColumnName)
{
<#
    .SYNOPSIS
     Genera un Script para regenerar los idTask a partir de una columna nueva GUID
	.DESCRIPTION
	 
    .EXAMPLE    
	get-ScriptIdTaskFromGuid 'WORKITEM' 'idWorkItem' 'idTask' 'guidTask'
	#>

 $template = " --Verifing case
SELECT $IdTargetTable, $idTaskColumn, $newGUIDColumnName FROM $targetTable

--removing column
ALTER TABLE $targetTable 
	DROP column $newGUIDColumnName

--ADDING NEW COLUMN ***********************************************
IF COL_LENGTH('$targetTable','$newGUIDColumnName') IS NULL
 BEGIN
 /*Column does not exist or caller does not have permission to view the object*/
	ALTER TABLE $targetTable 
	ADD $newGUIDColumnName uniqueidentifier null	
 END

 --ADDING DATA IN COLUMN *********************************************
 UPDATE $targetTable 
 SET $targetTable.$newGUIDColumnName = TASK.guidTask
 FROM $targetTable 
 JOIN TASK ON $targetTable.$idTaskColumn = TASK.idTask


 --Setting $idTaskColumn in null
 UPDATE $targetTable 
 SET $idTaskColumn = null

 --UPDATING $idTaskColumn FROM $newGUIDColumnName ************************************
 UPDATE $targetTable 
 SET  $targetTable.$idTaskColumn  = TASK.idTask
 FROM $targetTable 
 JOIN TASK ON $targetTable.$newGUIDColumnName = TASK.guidTask";
 
 setc $template
 $template
}

function ConvertTo-hashTable($properties)
{
    $h=@{}
    foreach($property in $properties)
    {
        $value = $property.Value               
        if($value-is [PSCustomObject])
        { $h."$($property.Name)" = ConvertTo-hashTable $value.Psobject.Properties }
        else
        { $h."$($property.Name)" = $value }
    } 
    return $h
}

function FormatAndOrder-Json([string]$json)
{
    $jsonObject = ConvertFrom-Json $json       
    $hashFormat = ConvertTo-hashTable $jsonObject.psobject.properties 
    return ConvertTo-Json $hashFormat -Depth 10   
}

function Compare-Json($jsonRef, $jsonDiff)
{   
    $jsonOrderedRef = FormatAndOrder-Json $jsonRef
     Write-Output $jsonOrderedRef
    $jsonOrderedDiff = FormatAndOrder-Json $jsonDiff
     Write-Output $jsonOrderedDiff
    Compare-Object ($jsonOrderedRef -split "`n") ($jsonOrderedDiff -split "`n")     
}

function Compare-JsonAutomatic
{    
    $jsonRef=''
    $jsonDiff=''
    setc ''
    $clipboardInitial = getc
    while($jsonRef -eq '' -or $jsonDiff -eq '')
    {
        sleep 1
        Write-Output '.'
        if($jsonRef -ne '')
        {
            $clipboardInitial = getc
            if($clipboardInitial -ne $jsonRef)
            { 
              $jsonDiff = $clipboardInitial  
              Write-Output 'jsonDiff loaded'
            }            
        }else
        {
            $jsonRef = getc
            if($jsonRef -ne $clipboardInitial)
            {  
              Write-Output 'jsonRef loaded'
            }
        }
        
    }
    Compare-Json $jsonRef $jsonDiff | fw -AutoSize
}

#endregion

#region Definición de alias
#Set-Alias getc Get-Clipboard -Scope Global
#Set-Alias setc Set-Clipboard -Scope Global
#endregion

Export-ModuleMember *