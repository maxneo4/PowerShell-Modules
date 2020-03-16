New-Variable -Name module -Value 'SecureStrings' -Scope Global -Force

function Save-SecureString
{
    param(
            [string]$stringToSecure,
            [string]$pathXml
        )
    $secureString =  $stringToSecure | ConvertTo-SecureString -AsPlainText -Force
    $secureString | Export-Clixml -Path $pathXml
}

function Read-SecureString
{
    param($pathXml)
    $secureString = Import-Clixml -Path $pathXml
    $BSTR =  [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    return $plainPassword
}

Export-ModuleMember *