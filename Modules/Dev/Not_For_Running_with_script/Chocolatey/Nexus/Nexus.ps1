<#
Chocolatey rate limit 5 packages per address
This setup is setup in steps
https://www.youtube.com/watch?v=UehkG1VHtz0&t=604s
#>

#Step 1
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))


#Step 2
choco install nexus-repository


#Step 3
#login to the website
# Create the following:
# 1 x Choco-proxy for proxying Request
# 1 x Choco-Hosted for self created software
# 1 x group to point at

#Step 4. 
#Change chocolatey sources on the machines
$ChocoRepoURL = 'http://localhost:8081/repository/Choco-Group/'
choco.exe 