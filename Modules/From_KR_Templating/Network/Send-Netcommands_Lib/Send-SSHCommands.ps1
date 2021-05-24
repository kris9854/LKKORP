function Send-SSHCommands {
    <#
    .SYNOPSIS
    This function is a helper function to Send-Netcommands function. It extends the functionality of that.
    
    .DESCRIPTION
    Long description
    
    .PARAMETER HostAddress
    Parameter description
    
    .PARAMETER HostPort
    Parameter description
    
    .PARAMETER Credential
    Parameter description
    
    .PARAMETER CMDTemplate
    Parameter description
    
    .PARAMETER SleepTimerMiliSec
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    # Can be used to send multiple commands to a HP Switch.
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Hostname or Ip of the device to witch you wan't to send commands", 
            Mandatory = $true )]
        [String]$HostAddress,

        [Parameter(Mandatory = $false)]
        [Int]$HostPort = 22,

        [Parameter(Mandatory = $false)]
        [PSCredential]$Credential = $credObject,

        [Parameter( HelpMessage = 'save an "$objectForScript = Get-Content -path INSERT LOCATION OF file -Raw"',
            Mandatory = $true)]
        [array]$CMDTemplate,

        # SleepTimerin milisecound
        [Parameter(Mandatory = $false)]
        [int]
        $SleepTimerMiliSec = '500'
    )
    
    begin {
        # Removes the SSH Sessions before proceding
        Get-SSHSession | Remove-SSHSession
        $sshsession = $null
        $SSHShellStream = $null
        [int]$Counter = 1
        $TotalCMDCount = $CMDTemplate.count
        [array]$SSHRespondArray = @()
        [int]$ProgressBarInt = 0
        [int]$BigSleepTimer = $SleepTimerMiliSec + 150
    }
    
    process {
        $sshsession = New-SSHSession -ComputerName "$HostAddress" -Credential $Credential -AcceptKey -ErrorAction silentlyContinue;
        Start-Sleep -Milliseconds "60"
        if ($SSHSession.Connected) {
  
            #Creates a shell stream for us to feed commands to:
            $SSHShellStream = New-SSHShellStream -Session $sshsession;
            Start-Sleep -Milliseconds "60"
            if ($SSHShellStream.Session.IsConnected) {
                [void]$SSHShellStream.Read()
                foreach ($LineCMD in $CMDTemplate) {
                    Write-Progress -Activity "Sending CMD" -Status "$Counter Cmd's Send to $HostAddress" -PercentComplete ($ProgressBarInt / $TotalCMDCount * 100)
                    $ProgressBarInt++
                    $SSHShellStream.WriteLine("$LineCMD")
                    Write-Debug "$Counter Of $TotalCMDCount CMD's run"
                    Write-Debug "cmd: $LineCMD" 

                    switch -Wildcard ($LineCMD) {
                        '*ACL*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer;
                            Break; 
                        }
                        '*Save Force*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        '*undo dhcp snooping information remote-id*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        '*undo dhcp snooping binding record*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        '*traffic classifier*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        '*traffic behavior*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        '*access-list*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer;
                            Break; 
                        }
                        '*write*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        '*class*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        '*policy*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        'no*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        'undo*' { 
                            Start-Sleep -Milliseconds $BigSleepTimer; 
                            Break; 
                        }
                        Default {
                            Start-Sleep -Milliseconds "$SleepTimerMiliSec"
                        }
                    }
                    [array]$SSHRespondArray += $SSHShellStream.Read()
                    # Create a check for if it is change or not (maybe create a call for display acl all -> check returned only contain one entry)
                    $counter++
                    # 
                }
                
            }             
            
            $SSHSessionRemoveResult = Remove-SSHSession -SSHSession $SSHSession;
            if (-Not $SSHSessionRemoveResult) {
                Write-Host -ForegroundColor "$Global:TextColour" -Object "Could not remove SSH Session $($SSHSession.SessionId):$($SSHSession.Host).";
            }   
        }
        else {
            Write-Host -ForegroundColor "$Global:TextColour" -Object "Could not connect to SSH host: $($HostAddress):$HostPort.";
        }
    
    }
    
    end {
        $ReturnValue = $SSHRespondArray.Trim() | Out-String;
        Return($ReturnValue);
    }
}