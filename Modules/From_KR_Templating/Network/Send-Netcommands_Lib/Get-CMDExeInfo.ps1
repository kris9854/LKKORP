function Get-CMDExeInfo {
    <#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER SwitchArray
Parameter description

.PARAMETER OutFileLocation
Parameter description
Location to where we will write the answer out to. 

.PARAMETER LineCMD
Parameter description
The Command to be sent example Show run int giga 1/0/1
or dis ip int brief

.PARAMETER StringToLookFor
Parameter description
A regex implementation. Just look for a simple match on a string. Will return the holde line example:
Vlan6 returns Vlan6 up up x.x.x.x -- -- if there is a match else nothing


.EXAMPLE
Get-CMDExeInfo -Debug -Verbose
Please Insert the command to send:
dis ip int brief
Please Insert the String to look for:
Vlan6
Returns Vlan2 up up 10.246.16.32 -- --

.NOTES
General notes
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
        $OutFileLocation = "$Log/Get-CommandInfo.txt",

        [Parameter( HelpMessage = 'The Command to Send"',
            Mandatory = $false)]
        [string]$LineCMD,

        [Parameter( HelpMessage = 'The String to look for"',
            Mandatory = $false)]
        [string]$StringToLookFor
    )
    
    Begin {
        ############################
        if (-not $LineCMD) {
            Write-Host -Object 'Please Insert the command to send: ' -ForegroundColor $Global:TextColour;
            [string]$LineCMD = Read-Host 
        }
        if (-not $StringToLookFor) {
            Write-Host -Object 'Please Insert the String to look for: ' -ForegroundColor $Global:TextColour;
            [string]$StringToLookFor = Read-Host 
        }

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
            # #Call The check-switchmodel function to determine the model of the switch.
            Check-SwitchModelTest -SwitchModel "$($Switch.model)"

            switch ($Global:ReturnObj_Model) {
                'HP_Comware' { 
                    [bool]$IsCiscoCatalyst = $false;
                    Break;
                }
                'Cisco_IOS' {
                    [bool]$IsCiscoCatalyst = $true;
                    Break;
                }
                'Cisco_IOSXE' { 
                    [bool]$IsCiscoCatalyst = $true;
                    Break;
                }
                'Cisco_Nexus' { 
                    [bool]$IsCiscoCatalyst = $true;
                    Break;
                }
                Default {
                    [bool]$IsCiscoCatalyst = $null;
                    Break;
                }
            }
            
            if (Test-Connection -TargetName $Switch.fullname -Count '1' -ErrorAction SilentlyContinue) {
                #Debug messages for troubleshooting
                #Switch Controlling commands to be send based on the isciscocatalys variable. Mainly if we want to change it depending on the model
                switch ($IsCiscoCatalyst) {
                    $true { 
                        Write-Debug "Sending $LineCMD"
                        Write-Debug "Sending $StringToLookFor"  
                        $ReturnedValue = Send-SingleSSHCommand -HostAddress "$TempSwitchName" -LineCMD $LineCMD -StringToLookFor $StringToLookFor -IsCiscoCatalyst $IsCiscoCatalyst -Credential $CredObject
                        Write-Debug "Cisco Device"
                        
                        Break;
                    }
                    $false {     
                        Write-Debug "Sending $LineCMD"
                        Write-Debug "Sending $StringToLookFor"         
                        $ReturnedValue = Send-SingleSSHCommand -HostAddress "$TempSwitchName" -LineCMD $LineCMD -StringToLookFor $StringToLookFor -IsCiscoCatalyst $IsCiscoCatalyst -Credential $CredObject
                        Write-Debug "HP Device"
                        Break;
                    }
                    Default {
                        Write-Host -Object 'Not Applicable' -ForegroundColor $Global:ErrorTextColour
                        Break;
                    }
                }
                if ($ReturnedValue) {
                    $ReturnedStringObj += $ReturnedValue
                    Write-Verbose $ReturnedValue
                }
            }
            else {
                Write-Host -Object "Device Not Online" -ForegroundColor $Global:ErrorTextColour
            }
        }
    }

    end {
        #Creates a log file Deleting if it exist
        $Output = $ReturnedStringObj | Out-String
        if ([System.IO.Directory]::Exists("$log")) {
            
            $Output | Out-File -FilePath "$OutFileLocation" -Force
        }
        else {
            Write-Host "PROBLEMS WITH SAVING THE LOG" -ForegroundColor Red
        }
        Write-Host $Output -ForegroundColor $Global:TextColour
        
    }
   
}
