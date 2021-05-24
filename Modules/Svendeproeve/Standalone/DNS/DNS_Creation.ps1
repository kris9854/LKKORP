function Helper-DNSEntry {
    [CmdletBinding()]
    param (
        # Subnet
        [Parameter(Mandatory = $true)]
        [string]$Subnet3octets,
        
        # Subnetmask
        [Parameter(Mandatory = $true)]
        [ipaddress]$Subnetmask, 
        
        # DefaultGW
        [Parameter(Mandatory = $true)]
        [ipaddress]$DefaultGW,

        #DNS Server address
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [ipaddress]$DNSServerIP
    )
    
    begin {
        #Variables Script dependent 
        $start = 1;
        $End = 100;
        [int]$IpOnline = 0;
        [int]$LookupCounte = 0;
        [int]$ping = 1; # Number of times to attempt each ping
        $ObjectArray = @()
    }
    
    process {
        #Pinging subnet
        do {
            $Lookup = $null
            $Test = $null
            $obj = $null;
            Remove-Variable -Name 'Test' -ErrorAction SilentlyContinue;
            $IP = "$subnet.$start";
            Write-Debug -Message "$IP";
            $Test = Test-Connection -ComputerName $IP -Count $ping -Quiet #-TimeoutSeconds 1;
            $Lookup = (Resolve-DnsName -Name 'IP' -ErrorAction SilentlyContinue).NameHost
            if ($Test) {
                $IpOnline++
            }
            if ($Lookup) {
                $LookupCounter++
            }
            $start++
            $obj = [PSCustomObject]@{
                'IP'         = "$IP"
                'Online'     = "$Test"
                'DNS Lookup' = "$Lookup"
            }
            $ObjectArray += $obj
            Write-Verbose $obj | Out-String
            Write-Debug "number of online ips is $IpOnline"
            
        } until (($start -ge $end) -or ($IpOnline -ge 50))
    }
    
    end {
        Return($ObjectArray)
    }
}
function Create-DNSEntry {
    [CmdletBinding()]
    param (
        # Subnet
        [Parameter(Mandatory = $false)]
        [ipaddress]$Subnet,

        # Subnetmask
        [Parameter(Mandatory = $false)]
        [ipaddress]$Subnetmask = '255.255.255.0',

        # DefaultGW
        [Parameter(Mandatory = $false)]
        [ipaddress]$DefaultGW
    )
    
    begin {
        #Initiate Variables that are not given.
        if (([string]::IsNullOrEmpty("$subnet"))) {
            Write-Host -Object "Subnet? EKS 10.0.0.0" -ForegroundColor 'cyan'
            $Subnet = Read-Host;
        }
        #Converting subnet to a string and splitting it to create a better looking DefaultGW call
        $subnetStringSplit = $subnet.ToString().Split('.')
        [string]$subnetBase = $subnetStringSplit[0] + '.' + $subnetStringSplit[1] + '.' + $subnetStringSplit[2] + '.'
        [ipaddress]$DefaultGW = $subnetBase + '1'
        
    }
    
    process {
        [array]$Global:ReturnValue = Helper-DNSEntry -Subnet3octets "$subnetBase" -Subnetmask "$Subnetmask" -DefaultGW "$DefaultGW" #-DNSServerIP $DNSServerIP
        $ReturnValue
    }
    
    end {
        
    }
}