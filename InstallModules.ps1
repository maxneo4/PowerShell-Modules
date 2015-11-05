#sacamos el path de los modulos
$pathModules = $Env:PSModulePath -split ';'

#Tomamos los elementos de modulos existentes en la carpeta y los copiamos
Get-ChildItem $args[0] -Filter '*.psm1' | 
%{ $folder = [System.IO.Path]::GetFileNameWithoutExtension($_.FullName)	
	$folder = "$($pathModules[0])\$folder"
	[System.IO.Directory]::CreateDirectory($folder)
Copy-Item $_.FullName -Destination $folder }