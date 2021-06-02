# Source Adder
# Written by Kristian Ebdrup

# Remove Standard source repo so we only pull from explicit set repositories
choco source remove -n chocolatey -y

# Set the source feed/repositorie to LKKORP-Internal
Choco source add -n 'LKKORP-Internal' -s=http://proget.lkkorp.local/nuget/LKKORP-Internal/ -y

# Used to fix the chocolately installation 

# Set properties
############################################
$myPath = "$env:ChocolateyInstall"
# get actual Acl entry
$myAcl = Get-Acl "$myPath"
$myAclEntry = "LKKORP\Domain Users","FullControl","ContainerInherit,ObjectInherit","None","Allow"
$myAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($myAclEntry)
# prepare new Acl
$myAcl.SetAccessRule($myAccessRule)
$myAcl | Set-Acl "$MyPath"
# check if added entry present
Get-Acl "$myPath" | fl
# Source Adder
# Written by Kristian Ebdrup

# Remove Standard source repo so we only pull from explicit set repositories
choco source remove -n chocolatey -y

# Set the source feed/repositorie to LKKORP-Internal
Choco source add -n 'LKKORP-Internal' -s=http://proget.lkkorp.local/nuget/LKKORP-Internal/ -y

# Used to fix the chocolately installation 

# Set properties
############################################
$myPath = "$env:ChocolateyInstall"
# get actual Acl entry
$myAcl = Get-Acl "$myPath"
$myAclEntry = "LKKORP\Domain Users","FullControl","ContainerInherit,ObjectInherit","None","Allow"
$myAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($myAclEntry)
# prepare new Acl
$myAcl.SetAccessRule($myAccessRule)
$myAcl | Set-Acl "$MyPath"
# check if added entry present
Get-Acl "$myPath" | fl
