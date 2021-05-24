
# Maybe rewrite to use internally saved repo?
#Could be: Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('http://NugetRepo.LKKORP.local:8081/repository/Choco-Hosted//ChocolateyInstall.ps1'))
# Or save the script inside a MDT Wrapper??
#https://rdr-it.com/en/mdt-running-powershell-script-during-deployment/
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco source disable -n Chocolatey
Choco source add -n LKKORP_Hosted -s=http://NugetRepo.LKKORP.local:8081/repository/Choco-Hosted/
#choco source add -n Community -s http://chocoserver/nuget/Community/ --priority=10
choco feature enable -n allowGlobalConfirmation
choco feature enable -n allowEmptyChecksums