function Ping-Subnet {
    param (
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^access-\d{1,5}')]
        [String]$HostName
    )
    $SwitchNumber = ($HostName.split('-')[-1].trim()) -replace "\D+" # .net regular expression to delete everything else that the number
    if ([int]$SwitchNumber -gt 255) { Return("SwitchNumber IS Greater Than 255") }
    $Subnet = "10.0.$SwitchNumber";
    [System.Net.IPAddress]$SubnetFull = "10.0.$SwitchNumber.0";
    $start = 1;
    $End = 254;
    [int]$IpOnline = 0;
    [int]$ping = 1; # Number of times to attempt each ping
 
    # Path and filename for results file
    # $OutPath = "$output\SubnetPing.csv"
    do {
        Remove-Variable -Name 'Test' -ErrorAction SilentlyContinue;
        $IP = "$subnet.$start";
        $Test = Test-Connection -ComputerName $IP -Count $ping -Quiet -TimeoutSeconds 1;
        if ($Test) {
            $IpOnline++
        }
        Write-Verbose "$IP,$Test";
        Write-Debug "number of online ips is $IpOnline"

  
        #Add-Content -LiteralPath $OutPath -Value "$IP,$Test"
        $start++
    } until (($start -ge $end) -or ($IpOnline -ge 2))

    if ($IpOnline -ge 2) {
        Return("$SubnetFull is Online");
        Break;
    }
    else {
        Return("$SubnetFull is Offline");
        Break;
    }
}