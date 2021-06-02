Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Remove Standard source repo so we only pull from explicit set repositories
choco source remove -n chocolatey -y

# Set the source feed/repositorie to LKKORP-Internal
Choco source add -n 'LKKORP-Internal' -s=http://proget.lkkorp.local/nuget/LKKORP-Internal/ -y


choco install chocolateygui