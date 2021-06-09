function Init-DiffVM {
    <#
.SYNOPSIS
Just run script to go through the setup

.DESCRIPTION
Script used to do 3 tasks.
1. Change IP
2. Change Computername
3. Join Domain using a Service account named SA-MDT

.EXAMPLE
Init-DiffVM

.NOTES
Dansk: Skrevet til min svendeproeve.
#>

    [CmdletBinding()]
    param ()
    
    begin {
        #Create the variables used in the Script
        #Variables Script
        $TxtColour = 'Green'
        $ConfirmColour = 'Yellow'
        $SuccessColour = 'green'
        #Region Domain Dependence
        $DomainToJoin = 'LKKORP.LOCAL';
        $OuPath = 'OU=VM,OU=Servers,OU=Computers,OU=LKKorp,DC=LKKORP,DC=local';
        #Endregion Domain Dependence

        #Region Credential Creation for Domain Join
        [string]$DomainUserName = "SA-MDT@$DomainToJoin"
        Write-Host "Type in password: " -ForegroundColor "$TxtColour" -NoNewline
        [securestring]$DomainUserPassword = Read-Host -AsSecureString
        [pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($DomainUserName, $DomainUserPassword)


        #LocalCred
        [string]$LocalUserName = 'Administrator'
        [string]$LocalUserPassword = 'Password1'
        # Convert to SecureString
        [securestring]$LocalSecStringPassword = ConvertTo-SecureString $LocalUserPassword -AsPlainText -Force
        [pscredential]$LocalCred = New-Object System.Management.Automation.PSCredential ($LocalUserName, $LocalSecStringPassword)
        #Endregion Credential Creation for Domain Join

        #Region VM NAME
        Write-Host -Object 'VM fullNAM (Eeks DKHER-DHCP0001): ' -ForegroundColor "$TxtColour" -NoNewline;
        $VMName = Read-Host;
        $VmName = "$VMName";
        #Endregion VM NAME 

        #Region Ip address
        Write-Host -Object 'IP address: ' -ForegroundColor "$TxtColour" -NoNewline;
        [System.Net.IPAddress]$IP = Read-Host;
        $DNS = "10.0.4.100" #Standard
        [System.Net.IPAddress]$DefaultGateway = "10.$($IP.ToString().split('.')[1]).$($IP.ToString().split('.')[2]).1";
        $CIDR = '24';
        $NetworkCard = (Get-NetAdapter | Where-Object { $_.Name -eq 'Ethernet' }).InterfaceAlias
        #Endregion Ip address
    }
    
    process {
        Write-Host -Object "*************************************************************************" -ForegroundColor $ConfirmColour
        Write-Host -Object "*   VMNAME: $VMName" -ForegroundColor $ConfirmColour
        Write-Host -Object "*   DOMAIN TO JOIN: $DOMAINTOJOIN" -ForegroundColor $ConfirmColour
        Write-Host -Object "*   Oupath: $OuPath" -ForegroundColor $ConfirmColour
        Write-Host -Object "*   IP: $IP" -ForegroundColor $ConfirmColour
        Write-Host -Object "*   DNS: $DNS" -ForegroundColor $ConfirmColour
        Write-Host -Object "*   CIDR: $CIDR" -ForegroundColor $ConfirmColour
        Write-Host -Object "*   Network Card: $NetworkCard" -ForegroundColor $ConfirmColour
        Write-Host -Object "*************************************************************************" -ForegroundColor $ConfirmColour
        Write-Host -Object "*   Press any key to confirm or ctrl+c to cancel                        *" -ForegroundColor $ConfirmColour
        Write-Host -Object "*************************************************************************" -ForegroundColor $ConfirmColour
        Read-Host 
        #IP
        
        #VM Name
        try {
            if ($VMName -like '*DC*') {
                Write-Host -Object 'Is This a Domain Controller?' -ForegroundColor "$TxtColour";
                Write-Host -Object 'Y/N' -ForegroundColor "$TxtColour" -NoNewline;
                $Answer = Read-Host;
            }
            if (($Answer -eq 'y') -or ($Answer -eq 'Y')) {
                Rename-Computer -NewName "$VMName";
                New-NetIPAddress -IPAddress "$IP" -InterfaceAlias "$NetworkCard" -DefaultGateway "$DefaultGateway" -AddressFamily IPv4 -PrefixLength 24
                Set-DnsClientServerAddress –InterfaceAlias $NetworkCard -ServerAddresses "$DNS";
                Remove-Item -LiteralPath 'c:\Init-VM' -Recurse -Force -Confirm;
     
                Write-Host "Please manually add this pc to the domain.";
                Start-Sleep -Seconds 5
            }
            else {
                New-NetIPAddress -IPAddress "$IP" -InterfaceAlias "$NetworkCard" -DefaultGateway "$DefaultGateway" -AddressFamily IPv4 -PrefixLength 24
                Set-DnsClientServerAddress –InterfaceAlias $NetworkCard -ServerAddresses "$DNS"
                Write-Host -Object "AWAITING NETWORK CHANGE" -ForegroundColor $SuccessColour
                Start-Sleep -Seconds 5
                Rename-Computer -NewName "$VMName"
                Add-Computer -DomainName "$DomainToJoin" -Credential $CredObject -OUPath "$OuPath" -NewName $VMName -LocalCredential $LocalCred
                # Remove-Item -LiteralPath 'c:\Init-VM' -Recurse -Force -Confirm

            } 
        }  
        catch {
            Throw("ERROR in Try, Catch part")
        }     

    }
    
    end {
        Write-Host -Object "*************************************************************************" -ForegroundColor $SuccessColour
        Write-Host -Object "*   VMNAME: $VMName" -ForegroundColor $SuccessColour
        Write-Host -Object "*   DOMAIN TO JOIN: $DOMAINTOJOIN" -ForegroundColor $SuccessColour
        Write-Host -Object "*   Oupath: $OuPath" -ForegroundColor $SuccessColour
        Write-Host -Object "*   IP: $IP" -ForegroundColor $SuccessColour
        Write-Host -Object "*   DNS: $DNS" -ForegroundColor $SuccessColour
        Write-Host -Object "*   CIDR: $CIDR" -ForegroundColor $SuccessColour
        Write-Host -Object "*   Network Card: $NetworkCard" -ForegroundColor $SuccessColour
        Write-Host -Object "*************************************************************************" -ForegroundColor $SuccessColour
        Write-Host -Object "*   Press any key to restart                                            *" -ForegroundColor $SuccessColour
        Write-Host -Object "*************************************************************************" -ForegroundColor $SuccessColour
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        Write-Host -Object "PC will restart in 5 seconds" -ForegroundColor "$SuccessColour";
        Start-Sleep -Seconds 5;
        Restart-Computer -Force;
    }
}


#Global variable
# Moved to public
#Function Call
Init-DiffVipublic

#Function Call
Init-DiffVM