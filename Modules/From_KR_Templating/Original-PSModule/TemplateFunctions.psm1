<#
Script received from Kristian Ebdrups github page 
https://github.com/kris9854/KR_Template
#>
#Region self design
# Region Functions for automation
# Credential function
function Create-Credentials {

    # Asking for credentials:
    Write-Host "Insert Username: " -ForegroundColor "$TextColour" -NoNewline
    [string]$userName = Read-Host
    Write-Host "Type in password: " -ForegroundColor "$TextColour" -NoNewline
    [securestring]$userPassword = Read-Host -AsSecureString
    #Create the $CredObject
    [pscredential]$script:credObject = New-Object System.Management.Automation.PSCredential ($userName, $userPassword)

}
Function New-Directory {
    <#
    .SYNOPSIS
    
    .DESCRIPTION
    Creating a directory in the script path. Also creates a varialbe you can use to call i later in the script.
    
    .PARAMETER DirName
    the name of the directory. Will also become the variable name
    
    .EXAMPLE
    New-Directory -DirName Newfolder
    Will create a folder .\Newfolder. Will also create a variable you can call with $Newfolder name.
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    #Function used to create a new directory in the script location
    Param (
        #The Directory Name
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DirName
    )

    begin {
        $VerbosePreference = 'Continue' #Display Verbose
        $SaveLocation = "$ScriptPath\$DirName"
    }

    process {
        If (!(Test-Path -Path "$SaveLocation")) {
            Try {
                New-Item -ItemType Directory -Path "$ScriptPath" -Name $DirName | Out-Null
                #Write-Log -Message "Directory $SaveLocation Created" -Level 'Info'
                New-Variable -Name "$DirName" -Value "$SaveLocation" -Scope global #Creates a variable with the directory name
            }
            catch { Write-Verbose -Message "Error" }
        }
        else {
            New-Variable -Name $DirName -Value "$SaveLocation" -Scope global #Creates a variable with the directory name
            #Write-log -Message "Directory $SaveLocation allready exist" -Level 'Warn'
        }
    }

    end {
        $VerbosePreference = 'SilentlyContinue' #Remove the display Verbose setting
        # Write-Log -Message "Variable created $Dirname" -Level 'Info'
    }
}## End Function New-Directory
Function Write-Log {
    [CmdletBinding()]
    #Function Used to create a log file in the .\log folder
    Param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [Alias("msg")]
        [string]$Message = 'Location',

        [Parameter(Mandatory = $false)]
        [Alias('LogPath')]
        [string]$Path = "$Log\$ScriptName.log",

        [Parameter(Mandatory = $false)]
        [ValidateSet("Error", "Warn", "Info")]
        [string]$Level = "Info"
    )

    Begin {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process {

        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        if (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            New-Item $Path -Force -ItemType File
        }

        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                Write-Error $Message
                $LevelText = 'ERROR:'
            }
            'Warn' {
                Write-Warning $Message
                $LevelText = 'WARNING:'
            }
            'Info' {
                Write-Verbose $Message
                $LevelText = 'INFO:'
            }
        }
        # Write log entry to $Path
        "$FormattedDate $LevelText $Message  : Execution line $($MyInvocation.ScriptLineNumber)" | Out-File -FilePath $Path -Append
    }
    End {
        $VerbosePreference = 'SilentlyContinue' #Remove the display Verbose setting
    }
}## End Function Write-Log
Function Show-Msgbox {
    [CmdletBinding()]
    Param(
        #Message Parameter
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        #Button Parameter with validation set
        [Parameter(Mandatory = $true)]
        [ValidateSet('OkOnly', 'OkCancel', 'AbortRetryIgnore', 'YesNoCancel', 'YesNo', 'RetryCancel')]
        [string]$Button,

        [Parameter(Mandatory = $false)]
        [ValidateSet ('Critical', 'Question', 'Exclamation', 'Information')]
        [string]$Icon,

        #Title Of your Message Box
        [Parameter(Mandatory = $false)]
        [string]$Title
    )

    Begin {
        if ([string]$Title -eq $null) {
            [string]$Title = "Message Box"
        }
        [reflection.assembly]::loadwithpartialname("microsoft.visualbasic") | Out-Null
    }
    process {
        [microsoft.visualbasic.interaction]::Msgbox("$Message", "$Button,$Icon", "$Title")
    }
    end {
    }
}## End Function Show-Msgbox
# Region Working With IP
function Send-KeepAlive {
    <#
    .SYNOPSIS
    Designed to keep a VPN connection up. For x hours
    
    .DESCRIPTION
    If a VPN connection is setup to drop the connection after no data has been sent on the link for 1.1 + hours. It will drop the session. 
    This script has the inteand to send a ping to the DNS server. Therefore keaping the connection alive. 
    
    .PARAMETER KeepAliveAddress
    The Address used to the ping.
    Default: is your DNS
    
    .PARAMETER OptionalLabelUpdate
    If you have a winform where you want to add some information to a label.
    Default: None
    
    .PARAMETER Hours
    The Hours you want this script to run.
    Default: 8 hours is the default value here 
    
    .EXAMPLE
    Send-KeepAlive -Hours 3 
    
    .NOTES
    KEEP THE VPN ALIVE
    #>
    [CmdletBinding()]
    param (
        # Ip of the address to check up to
        [Parameter(Mandatory = $false)]
        [string]
        $KeepAliveAddress,

        # Label to update $x
        [Parameter(Mandatory = $false)]
        $OptionalLabelUpdate,

        # How many hours you want this to run for 
        [Parameter(Mandatory = $false)]
        [int]
        $Hours = 8
    )
    begin {
        $x = 0
        #Check if keepaliveaddress is set if not default would be this dns server
        if (($KeepAliveAddress.Length -eq 0)) {
            $KeepAliveAddress = (
                Get-NetIPConfiguration |
                Where-Object {
                    $_.IPv4DefaultGateway -ne $null -and
                    $_.NetAdapter.Status -ne "Disconnected"
                }
            ).DNSServer.ServerAddresses[0]

        }
    }
    process {
        Start-Job -Name "KeepAlive-Main" -ScriptBlock {
            do {
                Test-Connection -Quiet -Count 2 -ComputerName "$KeepAliveAddress"
                $x++
                Start-Sleep -Seconds 3600
                if ($optionalLabelUpdate -eq $null -or $optionalLabelUpdate -eq '' -or $optionalLabelUpdate -eq ' ' -or $optionalLabelUpdate -ge 1 ) {
                    $script:lbl_increase.Text = 'Kept Alive for ' + "$x" + ' hour'
                }
            } until ($x = $Hours)
        } 

        # Check for Job Done
        do {
            Start-Sleep -Seconds 2;
        } While ((Get-Job -Name "KeepAlive-Main").state -ne 'Completed');
    }
    end {
        Write-Verbose -Message "Ran the function"
    }
}
<#Section Set up in new folder structure 
function Get-Hostip {
    #Return Ip of localhost
    param (
        # Returned Object Name
        [Parameter(Mandatory = $true)]
        [string]
        $ReturnedObjectName
    )
	
    # Getting the first hostip
    $Getting_HostIP = (
        Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4DefaultGateway -ne $null -and
            $_.NetAdapter.Status -ne "Disconnected"
        }
    ).IPv4Address.IPAddress[0]

    # Create a variable and set it equal to the Hostip
    New-Variable -Name $ReturnedObjectName -Value "$Getting_HostIP" -Scope 'global'
    Write-Debug -Message "Created variable $globalparameter with value $Getting_HostIP"
}
function Test-Ipv4Match {
    param (
        # IP
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Ip
    )
    Begin { }
 
    Process {
        if ($Ip -match '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$') {
            return "$true"
        }
        else { return "$false" }
    }
 
    End { }
}
function Test-InTextIpv4Match {
    param (
        # IP
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Ip
    )
    Begin { }
 
    Process {
        if ($Ip -match '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b') {
            return "$true"
        }
        else { return "$false" }
    }
 
    End { }
}
function Test-Ipv6Match {
    param (
        # IP
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Ip
    )
    Begin { }
 
    Process {
        if ($Ip -match '^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$') {
            return "$true"
        }
        else { return "$false" }
    }
 
    End { }
}
function Test-InTextIpv6Match {
    param (
        # IP
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Ip
    )
    Begin { }
 
    Process {
        if ($Ip -match '(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))') {
            return "$true"
        }
        else { return "$false" }
    }
 
    End { }
}#Endregion Test-InTextIpv6Match
# Endregion Working With IP
#>
#Getting the Firewall Rules
function Get-FirewallLog {
    param (
        # Name Of the Hostname 
        [Parameter(Mandatory = $true)]
        [array]
        $Hostname,
        # Savelocation
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^.*(?<!\\)$')]
        [string]
        $Savelocation
    )
    #Init Variables
    $date = Get-Date -Format 'dd-MM'
    
    foreach ($PC in $Hostname) {
        if (Test-Connection -ComputerName "$PC" -Count 1 -Quiet) {
            Write-Debug -Message "$PC is Online"
            if (!(Get-Item -Path "c:\temp\FirewallLogLocation" -ErrorAction SilentlyContinue)) {
                New-Item -ItemType Directory -Path "c:\temp\FirewallLogLocation"
            }
            $SvLoc = "$Savelocation" + "\$PC-Firewall-$date.log"
            Copy-Item -Path "\\$PC\c$\Windows\System32\LogFiles\Firewall\pfirewall.log" -Destination "$SvLoc" 
        }
        else {
            Write-Debug -Message "$PC is not Online"
        }

    }
}#Endregion Get-FirewallLog
function Get-Hypervstatus {
    <#
    .SYNOPSIS

    .DESCRIPTION
    check if hyper-v is installed
    
    .PARAMETER HostName
    The hostname of the PC 
    
    .EXAMPLE
    Get-Hypervstatus -Hostname "N123456"
    Get-Hypervstatus -Hostname "N123456,N999999,N111111"
    .NOTES
    General notes
    #>
    param (
        # Hostname of pc to test
        [Parameter(Mandatory = $true)]
        [string[]]
        $HostName
    )

    foreach ($PC in $HostName) {
        $online = (test-onlineFast -ComputerName "$PC").online
        if ( $online -eq "true") {
            $Session = New-PSSession -ComputerName "$PC"
            $HPVcheck = Invoke-Command -Session $Session -ScriptBlock {
                $hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
                # Check if Hyper-V is enabled
                if ($hyperv.State -eq "Enabled") {
                    $hpvcheck = "has Hyper-V enabled"
                } 
                else {
                    $hpvcheck = "has Hyper-V disabled"
                }  
                return("$HPVcheck")
            }
        }
        else {
            $hpvcheck = "is not online"
        }

        Write-Host "$PC $HPVcheck"
        $Session | Remove-PSSession
  
    }
}#Endregion Get-Hypervstatus
#Endregion self design
function Convert-CIDR {
    # Gotten from reddit shortest script Challenge "https://www.reddit.com/r/PowerShell/comments/81x324/shortest_script_challenge_cidr_to_subnet_mask/"
    param (
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [int]
        $Cidr = 24
        
    )
    for ($i = 0; $i -le 24; $i = $i + 8) { $a = $a + "." + ([convert]::ToInt32(("1" * $Cidr + "0" * (32 - $Cidr)).Substring($i, 8), 2)).ToString() }; $a.Substring(1)
}
function Get-StaticIp {
    [CmdletBinding()]
    param (
        # Subnet
        [Parameter(Mandatory = $true)]
        [ipaddress]
        $Subnet,

        # Needed IP's default is 1
        [Parameter(Mandatory = $false)]
        [int]
        $NeededIPs = 1,

        # ListBoxName name of the listbox to where the ip's should be populated
        [Parameter(Mandatory = $true)]
        [system.Windows.Forms.ListBox]
        $ListBoxName
    )
    
    begin {
        # $script:steps = ([System.Management.Automation.PsParser]::Tokenize((Get-Content "$PSScriptRoot\$($MyInvocation.MyCommand.Name)"), [ref]$null) | Where-Object { $_.Type -eq 'Command' -and $_.Content -eq 'Write-ProgressHelper' }).Count
        $steps = 3 + $NeededIps
        Write-Host $steps
        $stepCounter = 0
        Write-ProgressHelper -Activity "Running Get-StaticIp" -Message "Finding availible Ip's" -StepNumber ($stepCounter++) -Progressbar $Prgbar_Listavail
        $IpAvailArray = @()
        # Static range 10-50 
        $SubnetCalculated = $Subnet.GetAddressBytes()[0].tostring() + '.' + $Subnet.GetAddressBytes()[1].tostring() + '.' + $Subnet.GetAddressBytes()[2].tostring()
        $StaticIpRange = 11..50 | ForEach-Object { "$SubnetCalculated" + '.' + "$_" }
    }
    
    process {
        $ResultArray = Test-OnlineFast -ComputerName $StaticIpRange
        foreach ($Iphost in $ResultArray) {
            Write-ProgressHelper -Activity "Running Get-StaticIp" -Message "Finding availible Ip's" -StepNumber ($stepCounter++) -Progressbar $Prgbar_Listavail
            $CurrentTestIp = $null
            Write-Host "$Iphost"
            if ($Iphost.Online -eq $False) {
                Write-Debug -Message "is False"
                $CurrentTestIp = $Iphost.Address
                $resolving = Resolve-DnsName -Name $CurrentTestIp -ErrorAction silentlycontinue
                if ($resolving -eq $null) {
                    Write-Host -Object "$CurrentTestIp Isn't in use"
                    $IpAvailArray += "$CurrentTestIp"
                }
            }
            if ($IpAvailArray.count -eq $NeededIps) {
                break
            }
        }
    }    
    end {

        Write-ProgressHelper -Activity "Running Get-StaticIp" -Message "Finding availible Ip's" -StepNumber 99 -Progressbar $Prgbar_Listavail 
        # Populate to GUI  
        Update-ListViewHelper -ListBoxName $ListBoxName -PopulatingArray $IpAvailArray
        Write-ProgressHelper -Activity "Running Get-StaticIp" -Message "Finding availible Ip's" -StepNumber 100 -Progressbar $Prgbar_Listavail 
    }
}
##################################
##################################
#Region Helpers
#Endregion Helpers
Function Test-OnlineFast {
    #Function for fast ping - Created https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/final-super-fast-ping-command
    param
    (
        # make parameter pipeline-aware
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $ComputerName,
        $TimeoutMillisec = 1000
    )

    begin {
        # use this to collect computer names that were sent via pipeline
        [Collections.ArrayList]$bucket = @()
        # hash table with error code to text translation
        $StatusCode_ReturnValue =
        @{
            0     = 'Success'
            11001 = 'Buffer Too Small'
            11002 = 'Destination Net Unreachable'
            11003 = 'Destination Host Unreachable'
            11004 = 'Destination Protocol Unreachable'
            11005 = 'Destination Port Unreachable'
            11006 = 'No Resources'
            11007 = 'Bad Option'
            11008 = 'Hardware Error'
            11009 = 'Packet Too Big'
            11010 = 'Request Timed Out'
            11011 = 'Bad Request'
            11012 = 'Bad Route'
            11013 = 'TimeToLive Expired Transit'
            11014 = 'TimeToLive Expired Reassembly'
            11015 = 'Parameter Problem'
            11016 = 'Source Quench'
            11017 = 'Option Too Big'
            11018 = 'Bad Destination'
            11032 = 'Negotiating IPSEC'
            11050 = 'General Failure'
        }

        # hash table with calculated property that translates
        # numeric return value into friendly text

        $statusFriendlyText = @{
            # name of column
            Name       = 'Status'
            # code to calculate content of column
            Expression = {
                # take status code and use it as index into
                # the hash table with friendly names
                # make sure the key is of same data type (int)
                $StatusCode_ReturnValue[([int]$_.StatusCode)]
            }
        }

        # calculated property that returns $true when status -eq 0
        $IsOnline = @{
            Name       = 'Online'
            Expression = { $_.StatusCode -eq 0 }
        }

        # do DNS resolution when system responds to ping
        $DNSName = @{
            Name       = 'DNSName'
            Expression = { if ($_.StatusCode -eq 0) {
                    if ($_.Address -like '*.*.*.*')
                    { [Net.DNS]::GetHostByAddress($_.Address).HostName }
                    else
                    { [Net.DNS]::GetHostByName($_.Address).HostName }
                }
            }
        }
    }
    process {
        # add each computer name to the bucket
        # we either receive a string array via parameter, or
        # the process block runs multiple times when computer
        # names are piped
        $ComputerName | ForEach-Object {
            $null = $bucket.Add($_)
        }
    }
    end {
        # convert list of computers into a WMI query string
        $query = $bucket -join "' or Address='"

        Get-WmiObject -Class Win32_PingStatus -Filter "(Address='$query') and timeout=$TimeoutMillisec" |
        Select-Object -Property Address, $IsOnline, $DNSName, $statusFriendlyText
    }

}## End Function Test-OnlineFast
Function Get-PendingReboot {
    <#
.SYNOPSIS
    Gets the pending reboot status on a local or remote computer.

.DESCRIPTION
    This function will query the registry on a local or remote computer and determine if the
    system is pending a reboot, from Microsoft updates, Configuration Manager Client SDK, Pending Computer
    Rename, Domain Join or Pending File Rename Operations. For Windows 2008+ the function will query the
    CBS registry key as another factor in determining pending reboot state.  "PendingFileRenameOperations"
    and "Auto Update\RebootRequired" are observed as being consistant across Windows Server 2003 & 2008.

    CBServicing = Component Based Servicing (Windows 2008+)
    WindowsUpdate = Windows Update / Auto Update (Windows 2003+)
    CCMClientSDK = SCCM 2012 Clients only (DetermineIfRebootPending method) otherwise $null value
    PendComputerRename = Detects either a computer rename or domain join operation (Windows 2003+)
    PendFileRename = PendingFileRenameOperations (Windows 2003+)
    PendFileRenVal = PendingFilerenameOperations registry value; used to filter if need be, some Anti-
                     Virus leverage this key for def/dat removal, giving a false positive PendingReboot

.PARAMETER ComputerName
    A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME).

.PARAMETER ErrorLog
    A single path to send error data to a log file.

.EXAMPLE
    PS C:\> Get-PendingReboot -ComputerName (Get-Content C:\ServerList.txt) | Format-Table -AutoSize

    Computer CBServicing WindowsUpdate CCMClientSDK PendFileRename PendFileRenVal RebootPending
    -------- ----------- ------------- ------------ -------------- -------------- -------------
    DC01           False         False                       False                        False
    DC02           False         False                       False                        False
    FS01           False         False                       False                        False

    This example will capture the contents of C:\ServerList.txt and query the pending reboot
    information from the systems contained in the file and display the output in a table. The
    null values are by design, since these systems do not have the SCCM 2012 client installed,
    nor was the PendingFileRenameOperations value populated.

.EXAMPLE
    PS C:\> Get-PendingReboot

    Computer           : WKS01
    CBServicing        : False
    WindowsUpdate      : True
    CCMClient          : False
    PendComputerRename : False
    PendFileRename     : False
    PendFileRenVal     :
    RebootPending      : True

    This example will query the local machine for pending reboot information.

.EXAMPLE
    PS C:\> $Servers = Get-Content C:\Servers.txt
    PS C:\> Get-PendingReboot -Computer $Servers | Export-Csv C:\PendingRebootReport.csv -NoTypeInformation

    This example will create a report that contains pending reboot information.

.LINK
    Component-Based Servicing:
    http://technet.microsoft.com/en-us/library/cc756291(v=WS.10).aspx

    PendingFileRename/Auto Update:
    http://support.microsoft.com/kb/2723674
    http://technet.microsoft.com/en-us/library/cc960241.aspx
    http://blogs.msdn.com/b/hansr/archive/2006/02/17/patchreboot.aspx

    SCCM 2012/CCM_ClientSDK:
    http://msdn.microsoft.com/en-us/library/jj902723.aspx

.NOTES
    Author:  Brian Wilhite
    Email:   bcwilhite (at) live.com
    Date:    29AUG2012
    PSVer:   2.0/3.0/4.0/5.0
    Updated: 27JUL2015
    UpdNote: Added Domain Join detection to PendComputerRename, does not detect Workgroup Join/Change
             Fixed Bug where a computer rename was not detected in 2008 R2 and above if a domain join occurred at the same time.
             Fixed Bug where the CBServicing wasn't detected on Windows 10 and/or Windows Server Technical Preview (2016)
             Added CCMClient property - Used with SCCM 2012 Clients only
             Added ValueFromPipelineByPropertyName=$true to the ComputerName Parameter
             Removed $Data variable from the PSObject - it is not needed
             Bug with the way CCMClientSDK returned null value if it was false
             Removed unneeded variables
             Added PendFileRenVal - Contents of the PendingFileRenameOperations Reg Entry
             Removed .Net Registry connection, replaced with WMI StdRegProv
             Added ComputerPendingRename
#>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("CN", "Computer")]
        [String[]]$ComputerName = "$env:COMPUTERNAME",
        [String]$ErrorLog
    )

    Begin { }## End Begin Script Block
    Process {
        Foreach ($Computer in $ComputerName) {
            Try {
                ## Setting pending values to false to cut down on the number of else statements
                $CompPendRen, $PendFileRename, $Pending, $SCCM = $false, $false, $false, $false

                ## Setting CBSRebootPend to null since not all versions of Windows has this value
                $CBSRebootPend = $null

                ## Querying WMI for build version
                $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -ErrorAction Stop

                ## Making registry connection to the local/remote computer
                $HKLM = [UInt32] "0x80000002"
                $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"

                ## If Vista/2008 & Above query the CBS Reg Key
                If ([Int32]$WMI_OS.BuildNumber -ge 6001) {
                    $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
                    $CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"
                }

                ## Query WUAU from the registry
                $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
                $WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired"

                ## Query PendingFileRenameOperations from the registry
                $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\Session Manager\", "PendingFileRenameOperations")
                $RegValuePFRO = $RegSubKeySM.sValue

                ## Query JoinDomain key from the registry - These keys are present if pending a reboot from a domain join operation
                $Netlogon = $WMI_Reg.EnumKey($HKLM, "SYSTEM\CurrentControlSet\Services\Netlogon").sNames
                $PendDomJoin = ($Netlogon -contains 'JoinDomain') -or ($Netlogon -contains 'AvoidSpnSet')

                ## Query ComputerName and ActiveComputerName from the registry
                $ActCompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\", "ComputerName")
                $CompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\", "ComputerName")

                If (($ActCompNm -ne $CompNm) -or $PendDomJoin) {
                    $CompPendRen = $true
                }

                ## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
                If ($RegValuePFRO) {
                    $PendFileRename = $true
                }

                ## Determine SCCM 2012 Client Reboot Pending Status
                ## To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0
                $CCMClientSDK = $null
                $CCMSplat = @{
                    NameSpace    = 'ROOT\ccm\ClientSDK'
                    Class        = 'CCM_ClientUtilities'
                    Name         = 'DetermineIfRebootPending'
                    ComputerName = $Computer
                    ErrorAction  = 'Stop'
                }
                ## Try CCMClientSDK
                Try {
                    $CCMClientSDK = Invoke-WmiMethod @CCMSplat
                }
                Catch [System.UnauthorizedAccessException] {
                    $CcmStatus = Get-Service -Name CcmExec -ComputerName $Computer -ErrorAction SilentlyContinue
                    If ($CcmStatus.Status -ne 'Running') {
                        Write-Warning "$Computer`: Error - CcmExec service is not running."
                        $CCMClientSDK = $null
                    }
                }
                Catch {
                    $CCMClientSDK = $null
                }

                If ($CCMClientSDK) {
                    If ($CCMClientSDK.ReturnValue -ne 0) {
                        Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"
                    }
                    If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) {
                        $SCCM = $true
                    }
                }

                Else {
                    $SCCM = $null
                }

                ## Creating Custom PSObject and Select-Object Splat
                $SelectSplat = @{
                    Property = (
                        'Computer',
                        'CBServicing',
                        'WindowsUpdate',
                        'CCMClientSDK',
                        'PendComputerRename',
                        'PendFileRename',
                        'PendFileRenVal',
                        'RebootPending'
                    )
                }
                New-Object -TypeName PSObject -Property @{
                    Computer           = $WMI_OS.CSName
                    CBServicing        = $CBSRebootPend
                    WindowsUpdate      = $WUAURebootReq
                    CCMClientSDK       = $SCCM
                    PendComputerRename = $CompPendRen
                    PendFileRename     = $PendFileRename
                    PendFileRenVal     = $RegValuePFRO
                    RebootPending      = ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename)
                } | Select-Object @SelectSplat

            }
            Catch {
                Write-Warning "$Computer`: $_"
                ## If $ErrorLog, log the file to a user specified location/path
                If ($ErrorLog) {
                    Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append
                }
            }
        }## End Foreach ($Computer in $ComputerName)
    }## End Process

    End { }## End End

}## End Function Get-PendingReboot
#####################

Function Get-MACVendor {
    <#
    .SYNOPSIS
    Function Get-MACVendor returns the vendor for a given MAC-Address.
    .DESCRIPTION
    This script uses the API of https://macvendors.co. With Invoke-WebRequest (hence Version 3.0 is needed) it generates an output as xml.
    .PARAMETER MAC
    This is the only but mandatory parameter. Please enter a valid MAC-Address.
    It works both with colons or hyphens - you decide.
    .EXAMPLE
    Execute Get-MACVendor.ps1 directly from shell with dot sourcing
    . .\Get-MACVendor.ps1
    Get-MACVendor -MAC Value
    .NOTES
    Author: Oliver Jäkel | oj@jaekel-edv.de | @JaekelEDV
    with special support of @St_Meissner - thanks!
    #>
    #requires -Version 3.0
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Mandatory = $true, Helpmessage = 'Enter a valid MAC-Address')]
        [string] $MAC
    )
    Try {
        if ($PSCmdlet.ShouldProcess($MAC)) {
  
            [string]$url = 'https://macvendors.co/api'           #The site provides an api... 
            $request = Invoke-WebRequest -Uri "$url/$MAC/xml" #...and an output as xml - great!!!
            [xml]$vendor = $request.content                       #Converts data to xml; "vendor" (company) is in the 'content'-section
            if ($vendor.InnerXml.Contains('no result') -ne $True) {
                $vendor.DocumentElement.company
            }
            else {
                Write-Output -InputObject "No vendor found for $mac"
            }
        }
    }
    Catch {
        Write-Output -InputObject $_.Exception.Message
    }
}



#Endregion no self design