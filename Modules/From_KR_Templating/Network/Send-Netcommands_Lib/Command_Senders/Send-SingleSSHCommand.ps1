function Send-SingleSSHCommand {
    <#
.SYNOPSIS
Single command sender 

.DESCRIPTION
Can only be sent to non-systemview and enabled configuration mode. And only if the switch starts there. 

.PARAMETER HostAddress
Parameter description
The Ip or hostname of the corresponding switch

.PARAMETER HostPort
Parameter description
The Port on with to make the SSH connection

.PARAMETER Credential
Parameter description
The credentilas to use default is using the global CredObject

.PARAMETER LineCMD
Parameter description
The Command to be sent example Show run int giga 1/0/1
or dis ip int brief

.PARAMETER StringToLookFor
Parameter description
A regex implementation. Just look for a simple match on a string. Will return the holde line example:
Vlan6 returns Vlan6 up up x.x.x.x -- -- if there is a match else nothing

.PARAMETER SleepTimerMiliSec
Parameter description

.PARAMETER IsCiscoCatalyst
Parameter description
Do a check if it is cisco or not


.EXAMPLE
EXAMPLE

.NOTES
General notes
#>
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Hostname or Ip of the device to witch you wan't to send commands", 
            Mandatory = $true )]
        [String]$HostAddress,

        [Parameter(Mandatory = $false)]
        [Int]$HostPort = 22,

        [Parameter(Mandatory = $false)]
        [PSCredential]$Credential = $Global:CredObject,

        [Parameter( HelpMessage = 'The Command to Send"',
            Mandatory = $true)]
        [string]$LineCMD,

        [Parameter( HelpMessage = 'The String to look for"',
            Mandatory = $true)]
        [string]$StringToLookFor,
    
        # SleepTimerin milisecound
        [Parameter(Mandatory = $false)]
        [int]
        $SleepTimerMiliSec = '300',

        # IsCiscoCatalyst
        [Parameter(Mandatory = $true)]
        [bool]
        $IsCiscoCatalyst
    )
    
    begin {
        #Promp user for input
        if (-not $LineCMD) {
            Write-Host -Object 'Please Insert the command to send: ' -ForegroundColor $Global:TextColour = 'cyan';
            $LineCMD = Read-Host 
        }
        $Regex = '.*' + "$StringToLookFor" + '.*'
        Write-Debug $Regex
        # Removes the SSH Sessions before proceding
        Get-SSHSession | Remove-SSHSession
        $Result = $null
        $sshsession = $null
        $SSHShellStream = $null
        [int]$Counter = 1
        $TotalCMDCount = $CMDTemplate.count
        [array]$SSHRespondArray = @()
    }
    
    process {
        switch ($IsCiscoCatalyst) {
            $true { 
                $CISCOCMD = "terminal length 0{0}$LineCMD" -f [environment]::NewLine
                $sshsession = New-SSHSession -ComputerName "$HostAddress" -Credential $Credential -AcceptKey -ErrorAction silentlyContinue;
                Start-Sleep -Milliseconds "60"
                if ($SSHSession.Connected) {
          
                    #Creates a shell stream for us to feed commands to:
                    $SSHResponse = Invoke-SSHCommand -SSHSession $SSHSession -Command $CISCOCMD -ErrorAction silentlyContinue;
                    $Result = $SSHResponse.Output | Out-String;
                    $SSHSessionRemoveResult = Remove-SSHSession -SSHSession $SSHSession;
                    if (-Not $SSHSessionRemoveResult) {
                        Write-Host -ForegroundColor "$Global:TextColour" -Object "Could not remove SSH Session $($SSHSession.SessionId):$($SSHSession.Host).";
                    }   
                }
                else {
                    Write-Host -ForegroundColor "$Global:TextColour" -Object "Could not connect to SSH host: $($HostAddress):$HostPort.";
                }
                Break;
            }

            $false {
                $sshsession = New-SSHSession -ComputerName "$HostAddress" -Credential $Credential -AcceptKey -ErrorAction silentlyContinue;
                Start-Sleep -Milliseconds "60"
                if ($SSHSession.Connected) {
          
                    #Creates a shell stream for us to feed commands to:
                    $SSHResponse = Invoke-SSHCommand -SSHSession $SSHSession -Command $LineCMD -ErrorAction silentlyContinue;
                    $Result = $SSHResponse.Output | Out-String;
                    $SSHSessionRemoveResult = Remove-SSHSession -SSHSession $SSHSession;
                    if (-Not $SSHSessionRemoveResult) {
                        Write-Host -ForegroundColor "$Global:TextColour" -Object "Could not remove SSH Session $($SSHSession.SessionId):$($SSHSession.Host).";
                    }   
                }
                else {
                    Write-Host -ForegroundColor "$Global:TextColour" -Object "Could not connect to SSH host: $($HostAddress):$HostPort.";
                }
                Break;
            }
            Default {
                $stringObj = 'ERROR'
            }
        }
    
    }
    
    end {
        $ReturnValue = $Result;
        $TMP = $ReturnValue.Trim()
        Write-Debug "TMP: $TMP"
        # The replace part will replace multiple whitespaces with single whitespace
        $StringObj = $(($TMP | Select-String -Pattern "$Regex" -AllMatches).Matches.Value) -replace '\s+', ' ' 
        if ($StringObj) {
            Return("$stringObj")
        }
        else {
            Return("No_Matches_Found")
        }
    }
}