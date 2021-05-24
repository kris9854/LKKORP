
function Create-DHCPByForm {
    # DHCPScopeCreation.ps1
    # Script by Tim Buntrock
    # This script will create a DHCP scope based on your input
    # You can verify the config after you add all values, and if you confirm with "y," the scope will be created!
    # You can add values like DNS server, Boot options, and so on to this script, but I set options like this using Server Options.

    [CmdletBinding()]
    param (
        # DHCP Server
        [Parameter(Mandatory = $false)]
        [string]
        $dhcpserver = "$env:computername",

        # ScopeName Server
        [Parameter(Mandatory = $false)]
        [string]
        $scopename = '',

        # ScopeName Server
        [Parameter(Mandatory = $false)]
        [string]
        $scopeID = '10.',

        # ScopeName Server
        [Parameter(Mandatory = $false)]
        [string]
        $startrange = '10.',

        # ScopeName Server
        [Parameter(Mandatory = $false)]
        [string]
        $endrange = '10.',

        # ScopeName Server
        [Parameter(Mandatory = $false)]
        [string]
        $subnetmask = '255.255.255.0',

        # ScopeName Server
        [Parameter(Mandatory = $false)]
        [string]
        $router = '10.',

        # Silent or not
        [Parameter(Mandatory = $false)]
        [switch]
        $Silent = $false
    )
    
    begin {
        [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic');

        if ($silent -eq $false) {
            Write-Host
            Write-Host ----------Preconfigured Settings----------- -ForegroundColor "yellow"
            Write-Host
            Write-Host Server: {} {} {} {} {} {} {} {} $dhcpserver -ForegroundColor "yellow"
            Write-Host Scope Name: {} {} {} {} $scopename -ForegroundColor "yellow"
            Write-Host Scope ID: {} {} {} {} {} {} $scopeID -ForegroundColor "yellow"
            Write-Host IP Range: {} {} {} {} {} {} $startrange - $endrange -ForegroundColor "yellow"
            Write-Host Subnetmask: {} {} {} {} $subnetmask -ForegroundColor "yellow"
            Write-Host Router: {} {} {} {} {} {} {} {} $router -ForegroundColor "yellow"
            Write-Host
            Write-Host ---------/Preconfigured Settings----------- -ForegroundColor "yellow"
            Write-Host
            Write-Host
            Write-Host
            Write-Host Type in y to continue or any key to cancel...
            Write-Host
        }
        $input = [Microsoft.VisualBasic.Interaction]::InputBox("Type in y to continue `n or any key to cancel...", "Create Scope", "")
    }
    
    process {
        
        if (($input) -eq "y" ) {    
            Add-DHCPServerv4Scope -ComputerName $dhcpserver -EndRange $endrange -Name $scopename -StartRange $startrange -SubnetMask $subnetmask -State Active
            Set-DHCPServerv4OptionValue -ComputerName $dhcpserver -ScopeId $scopeID -Router $router
 
            if ($silent -eq $false) {
                Write-Host
                Write-Host
                Write-Host Created Scope $scopename on Server $dhcpserver -ForegroundColor "green"
                Write-Host
                Write-Host ---------------Settings-------------------- -ForegroundColor "green"
                Write-Host ------------------------------------------- -ForegroundColor "green"
                Write-Host
                Write-Host Scope Name: {} {} {} $scopename -ForegroundColor "green"
                Write-Host Scope ID: {} {} {} {} {} $scopeID -ForegroundColor "green"
                Write-Host IP Range: {} {} {} {} {} $startrange - $endrange -ForegroundColor "green"
                Write-Host Subnetmask: {} {} {} $subnetmask -ForegroundColor "green"
                Write-Host Router: {} {} {} {} {} {} {} $router -ForegroundColor "green"
                Write-Host
                Write-Host ------------------------------------------- -ForegroundColor "green"
                Write-Host --------------/Settings-------------------- -ForegroundColor "green"
            }
        }
        else {
            exit
        }
    }
    
    end {
        
    }
}
