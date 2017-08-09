New-Variable -Name module -Value 'LoadScripts' -Scope Global -Force
function Get-ScriptToTestPath
{
    param($Invocation)   
    $root = Split-Path -Parent $Invocation.MyCommand.Path
    $scriptToTest = (Split-Path -Leaf $Invocation.MyCommand.Path).Replace(".Tests.", ".")    
    "$root\$scriptToTest"
}

Export-ModuleMember *