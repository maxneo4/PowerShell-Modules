## Manera de ejecutar las pruebas Initarias##

1. Instalar http://psget.net/ `(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex`
2. Abrir consola de powershell como administrador, luego ejecutar (*Verificar get-executionPolicy sea 'Unrestricted' en caso contrario utilizar Set-ExecutionPolicy Unrestricted*)
3. En la misma consola ejecutar `install-module Pester`
4. Editar archivo RunPesterTests.bat donde se puede cambiar argumentos como -uriProject http://localhost:42715/api/Project u otros mas por los deseados
5. Ejecutar RunPesterTests.bat para correr las pruebas unitarias
***
## Informacion adicional

[https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

[day-48-pesterworking-assertions/](http://www.systemcentercentral.com/day-48-pesterworking-assertions/)

[mock units in powershell](https://www.red-gate.com/simple-talk/sysadmin/powershell/practical-powershell-unit-testing-mock-objects/)

[Pester en github](https://github.com/pester/Pester)

[pester method Should documentation](https://github.com/pester/Pester/wiki/Should)

[powershell-equivalent-of-curl-http-post-for-file-transfer](http://stackoverflow.com/questions/8506533/powershell-equivalent-of-curl-http-post-for-file-transfer)