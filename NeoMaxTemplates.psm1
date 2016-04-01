#get-verb
#Set-ExecutionPolicy Unrestricted

New-Variable -Name module -Value 'neomax-templates' -Scope Global -Force

#region base functions

function Get-FromClipboard
{
  if ($Host.Runspace.ApartmentState -eq 'STA')
    {
        Add-Type -Assembly PresentationCore
        [Windows.Clipboard]::GetText()
    } else {
    Write-Warning ('Run {0} with the -STA parameter to use this function' -f $Host.Name)
  }
}

function Set-ToClipboard
{
param([Parameter(Mandatory=$true, ValueFromPipeLine=$true)]$text)
  if ($Host.Runspace.ApartmentState -eq 'STA') {
        Add-Type -Assembly PresentationCore
        [Windows.Clipboard]::SetText($text)
    } else {
    Write-Warning ('Run {0} with the -STA parameter to use this function' -f $Host.Name)
  }
}

Function Select-FilePath
{
	param($initialFilePath)
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |	Out-Null
	$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$OpenFileDialog.initialDirectory = $initialFilePath
	$OpenFileDialog.filter = "All files (*.*)| *.*"
	$OpenFileDialog.ShowDialog() | Out-Null
	$OpenFileDialog.filename
}

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

function Get-TemplatesFromFile
{
    param($filePath)
    $content = Get-ContentFromFile -filePath $filePath
    $contentParts = $content -split "`r`n--/--`r`n"
    foreach($contentPart in $contentParts)
    {
        $lines = $contentPart -split "`r`n"
        $json = ConvertFrom-Json $lines[0]
        $lines = $lines[1..($lines.Length-1)]
        $json.content = $lines -join "`r`n"
        $json
    }
}

#endregion

#region data

function Get-DataFromClipboard
{
    $clipboardContent = (Get-FromClipboard).split("`r`n")
    $clipboardContent[0] = $clipboardContent[0] -replace ' ', ''
    $script:data = $clipboardContent | ConvertFrom-Csv -Delimiter "`t"
    $properties = $script:data[0] | Get-Member -MemberType NoteProperty
    $script:data | % {  foreach ($property in $_.PsObject.Properties)
    { $property.Value = $property.Value -replace ':"','"'   } $_ }
}

#endregion

###################################################################
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

#Extention

function Convert-FirstCharToLower
{
    param($text)
    $text.substring(0,1).tolower()+$text.substring(1)
}

function Convert-FirstCharToUpper
{
    param($text)
    $text.substring(0,1).toupper()+$text.substring(1)
}

function Format-Date
{
    param($date, $format)
    $date = [datetime]$date
    $date.ToString($format)
}

function Split-Line
{
    param($line, $limit, $separator)
    if($line.length -gt $limit)
    {
        $line = $line.SubString(0, $limit) + $separator + (Split-line -line $line.SubString($limit) -limit $limit -separator $separator )
    }
    $line
}


#$template = '@$Propiedad varchar'
#$template = Get-ContentFromFile $file
#Format-DataAndTemplate $template | Set-ToClipboard
#Expand-dataAndJoin -separator ",`r`n" | Set-ToClipboard
#$file = Select-FilePath
<#
Get-DataFromClipboard
Format-Data -template ( Get-ContentFromFile $file ) | Set-ToClipboard

$file = Select-FilePath
$template = Get-ContentFromFile $file
$formatedTemplate = Format-Template $template

Format-DataFilterExpand -template '$propertyrelational' -filter '$value -eq "3"'
#>

function Get-Help-Templates
{
    Write-Host '

    1. Get-DataFromClipboard
    2. Format-Data (column template requerida)

    1. Get-DataFromClipboard
    2. $file = Select-FilePath
    3. $template = Get-ContentFromFile $file (escribirla en la consola por lo regular fallar por "" y otros caracteres especiales)
    4. Format-Data $template


    '
}

Export-ModuleMember *