function Send-BulkCommands {
    <#
.SYNOPSIS
 Send-NetCommands is a multivendor ssh command sender. The logic of the CMD creator is writen here.
 The actually function for sending commands is send-sshcommands

.DESCRIPTION
 This function will send commands to a switch. The commands would be based on a
 txt file placed at a specifc place. The given switch will be a switch object with the corresponding values.
 Value 1. fullname
 Value 2. model
 Value 3. switch_count_in_stack

.PARAMETER SwitchArray
Parameter Array containing the switches we want to execute this on. Default value is our global $Global:CSVImport that is loaded on opening automation program

.PARAMETER OutFileLocation
Parameter OutFileLocation is the location of the log file writen in txt (sadly)

.PARAMETER CheckNetwork
parameter CheckNetwork will run a simple ping function (Ping-Sweep). To test if the network is working 

.PARAMETER Cisco_ConfigLocation
Parameter Cisco_ConfigLocation of the commands we should run on cisco devices 

.PARAMETER HP_ConfigLocation
Parameter HP_ConfigLocation of the commands we should run on Comware devices 

.PARAMETER StackDependent
Parameter StackDependent Should We use stackindependency? Please set your config in Stack-0.txt file.

.EXAMPLE
Send-NetCommands -> sends commands dependent on what you given as information in the corresponding stack-x.txt file
Send-NetCommands -StackDependent $false -> uses the stack-0 file on all devices

.NOTES
Remember to set the csv correctly. 
    #>
    [CmdletBinding()]
    param (
        #A csv file with the devices for upgrade defaults to the get-switchversion outfiled csv file. 
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Insert a switch object"
        )]
        [array]$SwitchArray = $Global:CsvImport,

        # OutFileLocation
        [Parameter(Mandatory = $false)]
        [string]
        $OutFileLocation = "$Log/Send-BulkCommands.txt",

        # Check Network will ping the device networks to check if everything looks good. 
        [Parameter(Mandatory = $false)]
        [bool]$CheckNetwork = $true,

        # StackDependent do we sent commands that depends on knowing how many devices there are in the stack?
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Should We use stackindependency? Please set your config in Stack-0.txt file -> will be sent to all devices in you csv")]
        [bool]$StackDependent = $true
    )
    
    Begin {
        ############################
        #Variables
        $TotalSwitches = $SwitchArray.count
        [int]$Counter = 1
        [array]$ReturnedStringObj = @()

        #ScriptBlocks can be called wth a &  $SCRIPTBLOCK
        [scriptblock]$ResetVariableBlock = {
            #Reset Variable values
            #Script scope is to delete the vairalbe from current function
            Remove-Variable -Name 'IsCiscoCatalyst' -Scope Script -ErrorAction SilentlyContinue;
            Remove-Variable -Name 'ReturnedValue' -Scope Script  -ErrorAction SilentlyContinue;
            Remove-Variable -Name 'TempStackNumber' -Scope Script  -ErrorAction SilentlyContinue;
            Remove-Variable -Name 'UpdateCommands' -Scope Script  -ErrorAction SilentlyContinue;
            Remove-Variable -Name 'SwitchDependentVLAN' -Scope Script  -ErrorAction SilentlyContinue;
        }

        #############################
    }
    
    Process {

        foreach ($Switch in $SwitchArray) {
            $Counter++
            & $ResetVariableBlock #Calls the scriptblock 
            $TempSwitchName = "$($switch.fullname)"
            Write-Debug "$TempSwitchName"
            $Switchname = $switch.fullname.trimEnd("$Global:NetworkDNSExtension")
            if (-not $StackDependent) {
                $TempStackNumber = "$($switch.switch_count_in_stack)"
            }
            else {
                $TempStackNumber = '0'
            }
            
            $SwitchDependentVLAN = $switch.hostname.split('-')[-1].trim()
            #################################################################################################
            # Location to change if you have another template you want to change
            $lookupTable = @{
                '{{SwitchName}}'          = "$Switchname"
                '{{SwitchDependentVLAN}}' = "$SwitchDependentVLAN"
            }
            ,
            ##### CHANGING THE FOLLOWING VALUES WILL DETERMINE WHAT COMMANDS WILL BE SENT TO THE SWITCH
            # Cisco-Config Location Defaults to con removal
            [string]$Cisco_ConfigLocation = "$Templating" + '\Network\Commands\Cisco\' + "Stack-$TempStackNumber.txt"
            # Hp-Config Location Defaults to con removal
            [string]$HP_ConfigLocation = "$Templating" + '\Network\Commands\HP\' + "Stack-$TempStackNumber.txt"
            #################################################################################################

            Write-Debug $OutFileLocation
            ################################################################################################
            #Call The check-switchmodel function to determine the model of the switch.
            Check-SwitchModelTest -SwitchModel "$($Switch.model)"

            switch ($Global:ReturnObj_Model) {
                'HP_Comware' { 
                    [bool]$IsCiscoCatalyst = $false;
                    [array]$UpdateCommands = (Get-Content -Path "$HP_ConfigLocation") | ForEach-Object {
                        $line = $_
                        $lookupTable.GetEnumerator() | ForEach-Object {
                            if ($line -match $_.Key) {
                                $line = $line -replace $_.name, $_.Value
                            }
                        }
                        $line
                    } 
                    Break;
                }
                'Cisco_IOS' {
                    $IsCiscoCatalyst = $true;
                    [array]$UpdateCommands = (Get-Content -Path "$Cisco_ConfigLocation") | ForEach-Object {
                        $line = $_
                        $lookupTable.GetEnumerator() | ForEach-Object {
                            if ($line -match $_.Key) {
                                $line = $line -replace $_.name, $_.Value
                            }
                        }
                        $line
                    } 
                    Break;
                }
                'Cisco_IOSXE' { 
                    $IsCiscoCatalyst = $true;
                    [array]$UpdateCommands = (Get-Content -Path "$Cisco_ConfigLocation") | ForEach-Object {
                        $line = $_
                        $lookupTable.GetEnumerator() | ForEach-Object {
                            if ($line -match $_.Key) {
                                $line = $line -replace $_.name, $_.Value
                            }
                        }
                        $line
                    } 
                    Break;
                }
                'Cisco_Nexus' { 
                    $IsCiscoCatalyst = $true;
                    [array]$UpdateCommands = (Get-Content -Path "$Cisco_ConfigLocation") | ForEach-Object {
                        $line = $_
                        $lookupTable.GetEnumerator() | ForEach-Object {
                            if ($line -match $_.Key) {
                                $line = $line -replace $_.name, $_.Value
                            }
                        }
                        $line
                    } 
                    Break;
                }
                Default {
                    $IsCiscoCatalyst = $null;
                    [string]$UpdateCommands = "";
                    Break;
                }
            }
            if (Test-Connection -TargetName $Switch.fullname -Count '1' -ErrorAction SilentlyContinue) {
                #Debug messages for troubleshooting
                #Switch Controlling commands to be send based on the isciscocatalys variable. Mainly if we want to change it depending on the model
                switch ($IsCiscoCatalyst) {
                    $true { 
                        $ReturnedValue = Send-SSHCommands -HostAddress "$TempSwitchName" -CMDTemplate $UpdateCommands -Credential $CredObject
                        Write-Debug "Cisco Device"
                        Write-Verbose $ReturnedValue
                        Break;
                    }
                    $false {               
                        $ReturnedValue = Send-SSHCommands -HostAddress "$TempSwitchName" -CMDTemplate $UpdateCommands -Credential $CredObject
                        Write-Debug "HP Device"
                        Write-Verbose $ReturnedValue
                        Break;
                    }
                    Default {
                        Write-Host -Object 'Not Applicable' -ForegroundColor $Global:ErrorTextColour
                        Break;
                    }
                }
                $ReturnedStringObj += $ReturnedValue
            }
            else {
                Write-Host -Object "Device Not Online" -ForegroundColor $Global:ErrorTextColour
            }
        }
    }

    End {
        #Creates a log file Deleting if it exist
        if ([System.IO.Directory]::Exists("$log")) {
            $Output = $ReturnedStringObj | Out-String | Out-File -FilePath "$OutFileLocation" -Force
        }
        else {
            Write-Host "PROBLEMS WITH SAVING THE LOG" -ForegroundColor Red
            Write-Host "$ReturnedStringObj"
            Write-Host "PROBLEMS WITH SAVING THE LOG" -ForegroundColor Red
        }
        if ($CheckNetwork) { Ping-Sweep }
        
    }
}
