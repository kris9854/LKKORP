#Function Call
Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        [ValidateSet("INFO", "WARN", "ERROR", "FATAL", "DEBUG")]
        [String]
        $Level = "INFO",

        [Parameter(Mandatory = $True)]
        [string]
        $Message,

        [Parameter(Mandatory = $False)]
        [string]
        $logfile
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If ($logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}

#Robocopy Script
[int]$startMs = (Get-Date).Millisecond
#Description used to sync files accross the network
#variables
[string]$SourcePath = 'd:\LKKORPDeploymentShare'
[string]$DestinationPath = '\\DKHER-WDSV0001\LKKORPDeploymentShare$'
[string]$LogFileLocation = 'C:\Projects\RoboCopy\Log\RoboCopy.log'
#Call Robocopy with parameters 

Robocopy.exe $SourcePath $DestinationPath /E /TEE /ZB /MIR /DCOPY:DAT /COPYALL /R:5 /W:10 /LOG:$LogFileLocation

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
[int]$endMs = (Get-Date).Millisecond
Write-Host $($startMs - $endMs)
Write-Log -Level INFO -Message "$($startMs - $endMs)" -logfile "$LogFileLocation"