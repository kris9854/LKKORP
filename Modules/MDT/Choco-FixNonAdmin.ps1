# Used to fix the chocolately installation 

# Set properties
############################################
$AllItems = (Get-ChildItem -Recurse -Path $env:ChocolateyInstall).FullName
foreach ($NewPath in $AllItems) {
$NewAcl = Get-Acl -Path "$NewPath"
$identity = "LKKORP\Domain Users"
$fileSystemRights = "FullControl"
$type = "Allow"
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path "$NewPath" -AclObject $NewAcl
}
Write-Verbose "Exit code was $exitCode"
$validExitCodes = @(0, 1605, 1614, 1641, 3010)
if ($validExitCodes -contains $exitCode) {
  Exit 0
}

Exit $exitCode