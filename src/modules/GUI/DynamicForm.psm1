$dynamicFormRoot = $PsscriptRoot
$parent = Split-Path $dynamicFormRoot -Parent

import-module "$parent/System/Process"

function show-uiFromJson
{
    <#
    .EXAMPLE
    Import-Module "C:\git\PowerShell-Modules\src\modules\GUI\DynamicForm.psm1" -Force

    $simpleResult = show-ui @{ inputs = @( @{ name='valueA' }, @{ name='dbs'; options = @('z','dhl','Zedge') } ) }
    $simpleResult

    $multiCommandResult = show-ui @{ commandValue = 'do_two'; commands=@{ 
        do_one = @( @{ name='valueA' }, @{ name='dbs'; options = @('z','dhl','Zedge') } ) 
        do_two = @( @{ name='valueZ' }, @{ name='servers'; options = @('uio','localhost','remote') } )     
     }}

    $multiCommandResult
    #>
    param([string]$guiDefinitionJson)
    $result = Start-ProcessAndWait-Result -fileName "$dynamicFormRoot/DynamicForm.exe" -standardInputText $guiDefinitionJson -arguments @('--input')
    if($result.error)
    {
        Write-Error $result.error
    }
    return $result.out
}

function show-ui
{
    param([object]$guiDefinition)
    $jsonValue = $guiDefinition | ConvertTo-Json -Depth 10
    return show-uiFromJson $jsonValue
}

Export-ModuleMember *