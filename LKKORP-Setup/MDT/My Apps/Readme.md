
# Applications

This setup is used for a PoC during my examination.
<br />
Please use this with caution.

install in this order:
<br />
1. Chocolatey.org Chocolatey 0.10.15
<br />
2. Chocolatey chocolatey-core.extension 1.3.5.1
<br />
3. Microsoftt DotNet 4.5.2 4.5.2.20140902
<br />
4. Chocolatey Chocolateygui 0.18.1

## Chocolatey.org Chocolatey 0.10.15

Have changed the default installation path to "c:\Choco"
<br />
powershell.exe -executionpolicy bypass -noninteractive -windows hidden -File ".\tools\chocolateyinstall.ps1"

## Chocolatey chocolatey-core.extension 1.3.5.1

choco install chocolatey-core.extension.1.3.5.1.nupkg -y

## Microsoftt DotNet 4.5.2 4.5.2.20140902

choco install DotNet4.5.2.4.5.2.20140902.nupkg -y

## Chocolatey Chocolateygui 0.18.1

Have removed dependencies from the package but be aware that you need to install chocolatey-core.extension 1.3.5.1 and DotNet 4.5.2 4.5.2.20140902 first
<br />
choco install chocolateygui.0.18.1.nupkg -y