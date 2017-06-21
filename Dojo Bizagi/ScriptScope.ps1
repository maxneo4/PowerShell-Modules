$scriptImplicit = 'A'
$script:explicit = 'B'
$scope = 'parentScope'

function show-vars
{
 write-host $scriptImplicit
 Write-Host $explicit
 Write-Host $script:explicit
 write-host $globalValue
 $scope = 'localScope'
 write-host $scope
}

function modify-varsFail
{
 $scriptImplicit = 'Y'
 $explicit = 'Z'
 $globalValue = 'localFail'
}

function modify-varsSuccess
{
 $script:scriptImplicit = 'Y'
 $script:explicit = 'Z'
 $global:globalValue = 'globalSuccess'
}

modify-varsFail
show-vars
write-host '********************'
modify-varsSuccess
show-vars

