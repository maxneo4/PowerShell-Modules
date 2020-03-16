
function Convertto-hash
{
    param([object]$object)
    $result = @{}
    foreach($prop in $object.PSObject.properties)
    {
        $result[$prop.Name] = $object."$($prop.Name)"
    }
    return $result
}

Export-ModuleMember Convertto-hash