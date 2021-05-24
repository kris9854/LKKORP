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