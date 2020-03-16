
$map = @{UseMcRedirectFeature = 'MCRedirect'
    ShowEnviromentErrorsFeature = 'ShowEnviromentErrors'
}

$sandboxes = 'Dev', 'Int'
$featureNames = 'UseCategories', 'ShowEnviromentErrorsFeature', 'UseMcRedirectFeature', 'UpgradeEnvironmentFeature', 'DataCenterLocation',
'AllowUseEnterpriseCategories', 'AllowUseEnvironmentZones', 'AllowEnterpriseCategoriesInPersonalSubscription', 'AllowChangeVersion', 'AllowReturnToPreviousVersion', 
'AllowIISReset', 'UseInfrastructures', 'EnableSubscriptionId', 'AllowSelectReleaseTypeEnterprise', 'AllowIISResetTrial', 'DevelopmentEnvironmentFeature', 'EnableSubscriptionId',
'UseInfrastructures'

#Other features
$featureNames = 'AllowMaintenanceWindow'


$featureLinks = @()

foreach($featureName in $featureNames)
{
    if($map.ContainsKey($featureName))
    {
        $featureName = $map[$featureName]
    }
    foreach($sandbox in $sandboxes)
    {
        $featureLinks += 'https://eus-gatekeeper-prod-webapp.azurewebsites.net/FeatureAccess/Index?featureName=RunCloud-'+$featureName+'-'+$sandbox
    }
}

 foreach($featureLink in $featureLinks)
 {
    [System.Diagnostics.Process]::Start($featureLink)
    Read-Host
 }
