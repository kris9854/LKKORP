function Ping-Sweep {
    param (
        #a csv file with the devices for upgrade defaults to the get-switchversion outfiled csv file. 
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Insert a switch object"
        )]
        $SwitchArray = $Global:CsvImport
    )
    #Variable Initiatization
    [int]$ProgressBarInt = 0
    $Totalsubnet = $SwitchArray.count
    $Counter = 1


    #Main function
    foreach ($Switch in $SwitchArray) {
        Write-Progress -Activity "Pinging $($Switch.hostname)'s subnet " -Status "$Counter subnet checked out of $Totalsubnet" -PercentComplete ($ProgressBarInt / $Totalsubnet * 100)
        $ProgressBarInt++
        $Counter++
        $ReturnedValue = Ping-Subnet -HostName $Switch.hostname
        if ($ReturnedValue -Match "online") {
            Write-Host $ReturnedValue -ForegroundColor $Global:writehostsuccessfullcolour
        }
        else {
            Write-Host $ReturnedValue -ForegroundColor $Global:ErrorTextColour
        }
    }
 
} 