Function ConvertTo-Objects
{
	<#
	.SYNOPSIS
	Recibe un Resultado de una consulta y la convierte a un array de objetos el cual es
	mas legible de comprender
	.EXAMPLE
	$rdr = Select-SqlCeServer 'SELECT * FROM TABLE1' 'Data Source=C:\Users\cdbody05\Downloads\VisorImagenesNacional\VisorImagenesNacional\DIVIPOL.sdf;'		
	$rdr | ConvertTo-Objects 
	#>
	param([Parameter(ValueFromPipeline=$true, Mandatory=$true)][Object[]]$rdr)
	BEGIN
	{
		$arr = [System.Collections.ArrayList]@()	
		$count = 0
	}
	
	PROCESS
	{
	
		if($rdr)
		{			
		#Cargamos el resultado al objeto				
			foreach ($item in $rdr)	
			{
				$count++
				$obj = @{ N = $count}				
				for($i = 0; $i -lt $item.FieldCount; $i++)	
				{	
					$obj.Add($item.GetName($i), $item[$i])
				}	

				$psobj = New-Object PSCustomObject -Property $obj
				$arr.Add($psobj) | Out-Null
			}
		}	
	}
	END
	{
		return $arr
	}
}

function Get-InsertScript($object, $table)
{
    $columns = [System.Collections.ArrayList]@()
    $values = [System.Collections.ArrayList]@()
    for($i = 0; $i -lt $object.dataRow.FieldCount; $i++){
      $colunmName = $object.dataRow.GetName($i) 
      $value = $object.$colunmName
      $columns.Add($colunmName) | Out-Null
      $values.Add("'$value'") | Out-Null
     } 
    
   
    $columns = $columns -join ', '
    $values = $values -join ', '
    "Insert into $table ($columns) values ($values)"
}

Export-ModuleMember *