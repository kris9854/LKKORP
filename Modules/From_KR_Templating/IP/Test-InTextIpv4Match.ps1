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