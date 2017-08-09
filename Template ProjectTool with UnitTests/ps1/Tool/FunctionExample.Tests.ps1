Import-Module Pester
Import-Module LoadScripts -Force
. (Get-ScriptToTestPath $MyInvocation)

write-host 'running---'

Describe "Add" {
    
    It "adds positive numbers" {
        $sum = Add 3 5
        $sum | Should Be 8
    }
 
    It "adds negative numbers" {
        $sum = Add (-3) (-5)
        $sum | Should Be (-8)
    }
}
 
Describe "EdgeCases" {
    
    It "adds positive and negative numbers" {
        $sum = Add 3 (-5)
        $sum | Should Be (-2)
    }
}