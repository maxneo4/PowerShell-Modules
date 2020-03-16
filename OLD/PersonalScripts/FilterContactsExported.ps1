$content = Get-Clipboard
$contactsExcel = $content | ConvertFrom-Csv -Delimiter "`t"

$contacts = $contactsExcel | where { $_.mobile1 -ne '' }


$contacts = $contacts | select 'Full name', mobile1, mobile2, office1, office2 -Unique

$contactsP = @()
$lastFullName =''
foreach($contact in $contacts)
{
    if($contact."Full name" -ne $lastFullName)
    {
        $contactsP += $contact
        $lastFullName = $contact."Full name"
    }
}


$contactsP | Convertto-csv -delimiter "`t" | Set-Clipboard 