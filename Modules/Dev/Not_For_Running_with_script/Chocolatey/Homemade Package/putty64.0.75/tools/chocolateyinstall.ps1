
$ErrorActionPreference = 'Stop';
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'putty-64bit-0.75-installer.msi'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'msi'
  #url            = $url
  #url64bit       = $url64
  file           = $fileLocation
  softwareName   = 'Putty64*'
  # Checksums are now required as of 0.10.0.
  # To determine checksums, you can get that from the original site if provided. 
  # You can also use checksum.exe (choco install checksum) and use it 
  # e.g. checksum -t sha256 -f path\to\file
  checksum       = '6E4D8550C75ABBB110BD3CD2F25B22D030A27A377A31B48CD619B623E61CCC8C'
  checksumType   = 'sha256'
  #checksum64     = '6E4D8550C75ABBB110BD3CD2F25B22D030A27A377A31B48CD619B623E61CCC8C'
  #checksumType64 = 'sha256'
  # MSI
  silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" # ALLUSERS=1 DISABLEDESKTOPSHORTCUT=1 ADDDESKTOPICON=0 ADDSTARTMENU=0
  validExitCodes = @(0, 3010, 1641)
}

#Install-ChocolateyPackage @packageArgs
# as admin
Install-ChocolateyInstallPackage @packageArgs

