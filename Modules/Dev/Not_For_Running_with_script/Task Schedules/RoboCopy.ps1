#Robocopy Script
#variables
[string]$SourcePath = ''
[string]$DestinationPath = ''
[string]$LogFileLocation = ''
#Call Robocopy with parameters 

Robocopy.exe $SourcePath $DestinationPath /E /ZB /DCOPY:DAT /COPYALL /R:5 /W:10 /LOG:$LogFileLocation

<#
Attributes justification:
/E = takes all files and subfolders from the source to destination
/ZB = retry to copy the files
/DCOPY:DAT = insures that attributes, ntfs permissions, timestaps +more
/COPYALL = Copies all file info, attributes, ntfs permissions, timestaps +more
/R:5 = retrie 5 times
/W:10 = Wait 10 sec before restart
/LOG:$LogFileLocation = logfile location
#>