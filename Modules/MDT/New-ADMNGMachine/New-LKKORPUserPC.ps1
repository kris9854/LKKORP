
function New-LKKORPUserPC {
    [CmdletBinding()]
    param (
        # Name Of the New Computer
        [Parameter(Mandatory = $false)]
        [String]
        $Hostname,

        # Mac Address of the new PC
        [Parameter(Mandatory = $false)]
        [String]
        $MacAddress,

        # GUID
        [Parameter(Mandatory = $false)]
        [string]
        $PC_GUID,

        # If this is a server 
        [Parameter(Mandatory = $false)]
        [Switch]
        $Server,

        # Location
        [Parameter(Mandatory = $false)]
        [string]
        $JoinOUPath = 'OU=Workstations,OU=Computers,OU=LKKorp,DC=LKKORP,DC=local'
    )
        
    begin {
        $BootLocation = "Boot\x64\Images\LiteTouchPE_x64.wim"
        # Cleaning the GUID or MAC to be ready for the WDS CLIENT implementation
        if (-not $MacAddress) {
            if (-not $PC_GUID) {
                Write-Host -Object "Please insert GUID: " -NoNewline -ForegroundColor Green
                $PC_GUID = Read-Host
            }
            
            $DeviceID = $PC_GUID
        }
        else {
            $DeviceID = $MacAddress
        }
        # Replace The regex values in string everyting form start until end where char matches ,:;,-+ or .
        $DeviceID = $DeviceID -replace '^.*=|,|:|;|,|-|\+|\..*$'

        # Creating the Hostname
        if ($Server) { 
            Write-Host "Please provide a Hostname for the New Server" -NoNewline -ForegroundColor Green
            $Hostname = Read-Host
        }
        else {
            #Create Uniq number based on given mac or GUID
            $Length = 5
            $set = "$DeviceID".ToCharArray()
            $result = ""
            for ($x = 0; $x -lt $Length; $x++) {
                $result += $set | Get-Random
            }

            $CreatedHostname = 'PC-' + "$result"
            $Hostname = $CreatedHostname
        }
    }
    
    process {
        New-WdsClient -DeviceID "$DeviceID" -DeviceName "$Hostname" -BootImagePath "$BootLocation" -JoinDomain $true -OU "$JoinOUPath"
    }
    
    end {
        
    }
}