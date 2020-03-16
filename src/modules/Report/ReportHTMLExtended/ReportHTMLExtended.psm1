$root = $PSScriptRoot

$reportHtmlModule = get-module ReportHTML -ListAvailable | where-object{ $_.Version -eq '1.4.0.3' }

if(-not $reportHtmlModule)
{
    Install-Module -Name ReportHTML -RequiredVersion 1.4.0.3 -Force
}

Import-Module ReportHTML

if(-not $global:htmlOpenPage)
{
    $pathOpenPageProcessed = "$root\openPageProcesed.html"
    if(-not (Test-Path $pathOpenPageProcessed) )
    {
        $global:htmlOpenPage = Get-htmlOpenPage -TitleText '{TITLE}' -leftLogoString '{LEFT_LOGO}'
        $global:htmlOpenPage | Out-File $pathOpenPageProcessed
    }
    else
    {
        $global:htmlOpenPage = Get-Content -Raw -Path $pathOpenPageProcessed   
    }    
}

function Get-HTMLOpenPageExtended
{   
    param($title = "Report")
    $result  =  $global:htmlOpenPage -replace '{REPORT_CREATED}', "Report created on  $( Get-Date -Format 'MMM dd, yyyy hh:mm tt' )"   
    $result  =  $result -replace '{TITLE}', $title
    return $result 
}