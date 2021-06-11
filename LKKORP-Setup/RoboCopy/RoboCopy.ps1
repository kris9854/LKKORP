#Robocopy Script
[int]$startMs = (Get-Date).Millisecond
#Description used to sync files accross the network
#variables
[string]$SourcePath = 'd:\LKKORPDeploymentShare'
[string]$DestinationPath = '\\DKVIB-WDSV0001\d$\LKKORPDeploymentShare'
[string]$LogFileLocation = 'C:\Projects\RoboCopy\RobocopyLog.txt'
#Call Robocopy with parameters 

Robocopy.exe $SourcePath $DestinationPath /E /TEE /xd DfsrPrivate /ZB /MIR /COPY:DAT /COPYALL /R:5 /W:10 /LOG:$LogFileLocation

<#
Attributes justification:
/E = takes all files and subfolders from the source to destination
/TEE = writes what would be sent to $LogFileLocation in console window
/ZB = retry to copy the files
/DCOPY:DAT = insures that attributes, ntfs permissions, timestaps +more
/COPYALL = Copies all file info, attributes, ntfs permissions, timestaps +more
/R:5 = retrie 5 times
/W:10 = Wait 10 sec before restart
/LOG:$LogFileLocation = logfile location
#>
[int]$endMs = (Get-Date).Millisecond
$Total = "$($startMs - $endMs)"
Write-Output $Total