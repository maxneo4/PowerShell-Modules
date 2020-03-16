Import-Module Converter
function Initialize-Preferences
{
    param([string]$application)

    $folder = $env:ProgramData
    if($null -eq $folder){  $folder = 'C:' }
    $fullFolder = "$folder\${application}Data\preferences"
    if(-not (Test-Path $fullFolder))
    {
        New-Item -ItemType Directory -Path $fullFolder
    }
    return $fullFolder
}

function Get-ContentPreferences
{
    param([string]$application, [string]$module)

    $fullFolder = Initialize-Preferences $application
    if(Test-Path "$fullFolder\${module}.json")
    {
        $content = Get-Content "$fullFolder\${module}.json"
    }else {
        $content = '{}'
    }
    return $content
}

function Get-Preferences
{
    param([string]$application, [string]$module, [object]$defaultOptions)

    $content = Get-ContentPreferences $application $module
    $preferences = $content | ConvertFrom-Json
    #Convert to dict
    $preferences = Convertto-hash $preferences 
    Merge-Preferences -userPreferences $preferences $defaultOptions
    return $preferences
}

function Set-ContentPreferences{
    param([string]$application, [string]$module, [string]$jsonPreferences)

    $fullFolder = Initialize-Preferences $application
    $jsonPreferences | out-file -FilePath "$fullFolder\${module}.json" 
    return $jsonPreferences | ConvertFrom-Json
}

function Set-Preferences{
    param([string]$application, [string]$module, [object]$preferences)

    $storedPreferences = Get-Preferences $application $module

    foreach($prop in $preferences.PsObject.Properties)
    {
        Set-Preference $storedPreferences $prop.Name $preferences."$($prop.Name)"
    }

    $jsonPreferences = $storedPreferences | ConvertTo-Json
    Set-ContentPreferences $application $module $jsonPreferences
}

function Set-Preference
{
    param([hashtable]$preferences, [string]$preferenceKey, [object]$preference)    
    
    $storedPreference = $preferences."$preferenceKey"
    if($null -eq $storedPreference)
    {
        $storedPreference = @{}       
    }
    else
    {
        $storedPreference = convertTo-Hash $storedPreference
    }
    foreach($prop in $preference.PsObject.Properties)
    {        
        $storedPreference[$prop.Name] = $preference."$($prop.Name)"
    } 
    $preferences["$preferenceKey"] = $storedPreference       
}

function Merge-Preferences
{
    param([hashtable]$userPreferences, [object]$defaultOptions)
    foreach($prop in $defaultOptions.PsObject.Properties)
    {
        $propName = $prop.Name
        if($null -eq $userPreferences[$propName])
        {
            $userPreferences[$propName] = $defaultOptions."$propName"
        }
        else
        {
            $userPreferences[$propName] = convertto-hash $userPreferences[$propName]
            foreach($subProp in $defaultOptions."$propName".PsObject.Properties)
            {
                $subpropName = $subProp.Name
                if($null -eq $userPreferences[$propName][$subPropName])
                {
                    $userPreferences[$propName][$subPropName] = $defaultOptions."$propName"."$subPropName"
                }
            }
        }
    }
}

Export-ModuleMember Get-ContentPreferences, Get-Preferences, Set-ContetPreferences, Set-Preferences