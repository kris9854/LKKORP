function Create-LKKORPDHCPScope {
    <#
    .SYNOPSIS
    Used to create DHCP scopes based on a csv file
    
    .DESCRIPTION
        Used to create DHCP scopes based on a csv file
    
    .PARAMETER dhcpserver
    Parameter description
    The DHCP server ip or name defaults to local pc
    
    .PARAMETER CsvImportPath
    Parameter description
    THe path to with the csv file is located defaults to DHCPScopes.csv in same folder.
    csv headers: 
    Scopename;NetworkID
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        # DHCP Server
        [Parameter(Mandatory = $false)]
        [string]
        $dhcpserver = "$env:computername",

        # Csv Import location
        [Parameter(AttributeValues)]
        [ParameterType]
        $CsvImportPath = '.\DHCPScopes.csv'
    )
    
    begin {
        $CsvImport = Import-Csv -Delimiter ';' -Path $CsvImportPath -Encoding default
    }
    
    process {
        foreach ($CSVFile in $CsvImport) {
            # Make $null
            [string]$scopename = $null       #name of the scope
            [string]$ScopeID = $null           #Scope Ip
            # SPlitting Part
            $FirstOctet = $null
            $SecondOctet = $null
            $ThirdOctet = $null
            [string]$ScopeIDSSplit = $null
            # Automating the scopes to follow network standards 
            [string]$Lease = $null
            [string]$startrange = $null
            [string]$endrange = $null
            [string]$subnetmask = $null
            [string]$router = $null



            #Define Variables based on the imported CSV
            [string]$scopename = $CSVFile.Scopename       #name of the scope
            [string]$ScopeID = $CSVFile.NetworkID           #Scope Ip
            # SPlitting Part
            $FirstOctet = $ScopeID.split('.')[0]
            $SecondOctet = $ScopeID.split('.')[1]
            $ThirdOctet = $ScopeID.split('.')[2]
            [string]$ScopeIDSSplit = "$FirstOctet" + '.' + "$SecondOctet" + '.' + "$ThirdOctet" + '.'
            # Automating the scopes to follow network standards 
            [string]$Lease = '1.00:00:00'
            [string]$startrange = $ScopeIDSSplit + '51'
            [string]$endrange = $ScopeIDSSplit + '254'
            [string]$subnetmask = '255.255.255.0'
            [string]$router = $ScopeIDSSplit + '1'
        
            # Creating scope
            Add-DHCPServerv4Scope -EndRange $endrange -Name $scopename -StartRange $startrange -SubnetMask $subnetmask -State Active -LeaseDuration $Lease
            # Adding router
            Set-DHCPServerv4OptionValue -ScopeId $scopeID -Router $router -lease
        }
    }
    
    end {
        
    }
}
