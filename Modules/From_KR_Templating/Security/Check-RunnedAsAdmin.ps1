function Check-RunnedAsAdmin {
    #Return true of false on admin
    [bool]$ReturnValue = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
    Return($ReturnValue)
}