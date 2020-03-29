

function Start-ProcessAndWait-Result($fileName, $workingDirectory, $standardInputText, [array]$arguments)
{
	<#
		.EXAMPLE
		$dinamicJson = @{ inputs = @( @{ name='valueA' }, @{ name='dbs'; options = @('z','dhl','Zedge') } ) } | ConvertTo-Json -Depth 10
		$r = Start-ProcessAndWait-Result 'C:\git\Libs-C-\DynamicCommandForm\bin\Debug\DynamicForm.exe'  -standardInputText $dinamicJson -arguments @('--input')
		$r.out
		$r.error
		$r.exit_code
	#>
    $redirectStandardInput = $standardInputText -ne $null
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    if($workingDirectory -ne $null){ $pinfo.WorkingDirectory = $workingDirectory }
    $pinfo.FileName = $fileName
    $pinfo.RedirectStandardInput = $redirectStandardInput
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.CreateNoWindow = $true
    if($arguments -ne $null){ $pinfo.Arguments = $arguments | ForEach-Object { "`"$_`" " } }
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() 
    if($redirectStandardInput){
        $p.StandardInput.Write($standardInputText);
        $p.StandardInput.Close()
    }    
    $p.WaitForExit()    
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.Close()
    return @{
        out = $stdout
        error = $stderr
        exit_code = $p.ExitCode
    }
}

Export-ModuleMember *