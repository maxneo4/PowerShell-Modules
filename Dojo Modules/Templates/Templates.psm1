function Get-ContentFromFile
{
	param([Parameter(Mandatory=$true, ValueFromPipeLine=$true)] [string]$filePath)
	Begin
	{	$content = ''	}
	Process
	{	$content+=[IO.File]::ReadAllText(  ( Resolve-Path $filePath) )	}
	End
	{	$content	}
}

function Format-Template
{
    param([string]$textTemplate)
    $templateContent = $textTemplate -replace '"', '`"'
     '"'+ ( Create-Vars ) + $templateContent + '"'
}

function Create-Vars
{
    $properties = $data[0] | Get-Member -MemberType NoteProperty
    $result = '$_ = if($_){$_}else{$data[0]}'+"`r`n"
    $properties | %{ $result += "`$$($_.Name) = Get-VarValue `$$($_.Name) `$_.$($_.Name)`r`n" }
    '$(' + "$result )"
}

function Get-VarValue
{
    param($currentValue, $newvalue)
    if($newvalue){ $newvalue } else {$currentValue}
}

function Format-Data
{
    param($template=$data[0].template)
    $formatedTemplate = Format-Template $template
    Invoke-Expression $formatedTemplate
}

function Format-DataExpand
{
    param($template=$data[0].template, $separator = "`r`n")
    $formatedTemplate = Format-Template $template
    $result = $data | %{ Invoke-Expression $formatedTemplate }
    [string]::Join($separator, $result)
}

function Create-VarsFilter
{
    $properties = $data[0] | Get-Member -MemberType NoteProperty
    $result = ''
    $properties | %{ $result += "`$$($_.Name) = `$_.$($_.Name)`r`n" }
    $result
}

function Format-DataFilterExpand
{
    param($template=$data[0].template, $separator = "`r`n", $filter = '$true')
    $formatedTemplate = Format-Template $template

    $result = Create-VarsFilter
    Invoke-Expression "function Eval(`$row){ $result $filter }"
    $result = $data | where{ Eval($_) } |%{ Invoke-Expression $formatedTemplate }
    [string]::Join($separator, $result)
}
