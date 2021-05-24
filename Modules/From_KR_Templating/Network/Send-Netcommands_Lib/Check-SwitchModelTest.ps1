function Check-SwitchModelTest {
    [CmdletBinding()]
    param (
        #Switch Name
        [Parameter(
            Mandatory = $true, 
            HelpMessage = "Insert model to check"
        )]
        [string]
        $SwitchModel
    )
    
    begin { 
        if (Get-Variable -Name 'ReturnObj_Model' -Scope 'global' -ErrorAction 'SilentlyContinue' ) {
            Remove-Variable -Name 'ReturnObj_Model' -Scope 'global'  -ErrorAction 'SilentlyContinue'
        }
        [Scriptblock]$nullvaluesSwitchblock = {             
            $Global:ReturnObj_Model = 'NO_MODEL'
        }   
        
        [Scriptblock]$HPSwitchblock = {     
            $Global:ReturnObj_Model = 'HP_Comware'
        }

    
        [Scriptblock]$CiscoIOSSwitchblock = {     
            $Global:ReturnObj_Model = 'Cisco_IOS'
        }
        
        [Scriptblock]$CiscoIOSXESwitchblock = {        
            $Global:ReturnObj_Model = 'Cisco_IOSXE'
        }
       
        [Scriptblock]$CiscoNexusModelSwitchblock = {        
            $Global:ReturnObj_Model = 'Cisco_Nexus'
        }
    }
    
    process {
        #Change from if else to switch 
        switch ($SwitchModel) {
            #Region HP
            #HPE 5510
            'HPE 5510 48G PoE+ 4SFP+ HI' {
                & $HPSwitchblock;
                Break;
            }
            #HPE 5130
            'HPE 5130 48G PoE+ 2SFP+ 2XGT' {
                & $HPSwitchblock;
                Break;
            }
            'HPE 5130 24G PoE+ 2SFP+ 2XGT' {
                & $HPSwitchblock;
                Break;
            }
            #HPE 5700
            'HPE FF 5700-32XGT-8XG-2QSFP+' {
                & $HPSwitchblock;
                Break;
            }
            'HPE FF 5710 24SFP+6QSFP+' {
                & $HPSwitchblock;
                Break;
            }
            #Endregion HP
            #Region Cisco
            #Region Cisco_IOS
            'WS-C2940-8TT-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2950-24' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2950G-24-EI' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2960-24TC-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2960-24TT-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2960-48TT-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2960-8TC-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2960CPD-8TT-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2960G-24TC-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2960G-8TC-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2960PD-8TT-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2960XR-24PD-I' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C2970G-24TS-E' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3550-24-EMI' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3550-24-SMI' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3550-48-SMI' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560-24PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560-24TS' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560-24TS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560-48PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560CG-8PC-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560CX-8PC-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560G-24PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560G-24TS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560G-48PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3560G-48TS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3650-48FS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750-24P' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750-24PS-E' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750-24PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750-24TS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750-48PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750E-48TD-E' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750G-12S-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750G-24PS-E' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750G-24PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750G-24T-E' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750G-24T-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750G-48PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750V2-24PS' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750V2-24PS-E' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750V2-24PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750V2-24TS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750V2-48PS-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750X-12S-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750X-24P-E' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750X-24P-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750X-24P-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750X-48PF-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750X-48PF-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750X-48P-L' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            'WS-C3750X-48P-S' {
                & $CiscoIOSSwitchblock;
                Break;
            }
            #Endregion Cisco_IOS
            #Region Cisco_IOSXE
            'WS-C3850-12S-S' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C3850-24P' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C3850-24P-S' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C3850-48P' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C3850-48P-S' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C3850-48PW-S' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C3850-48T-S' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C4500X-16SFP+' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C4500X-32SFP+' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C4500X-40X-ES' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C4500X-F-32SFP+' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C4507R+E' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C4510RE-S7+96V+' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
            'WS-C4510RE-S8+96V+' {
                & $CiscoIOSXESwitchblock;
                Break;
            }
                    
            #Endregion Cisco_IOSXE
            #Region Cisco_Nexus
            'N5K-C5596UP-BUN' {
                & $CiscoNexusModelSwitchblock;
                Break;
            }
            'N5K-C5596UP-FA' {
                & $CiscoNexusModelSwitchblock;
                Break;
            }
            'N5K-C5596UP' {
                & $CiscoNexusModelSwitchblock;
                Break;
            }
            #Endregion Cisco_Nexus
            #Endregion Cisco
            Default {
                & $nullvaluesSwitchblock
                Break;
            }
        }
    }
    end {
        Write-Debug "The returnedvalue is: $Global:ReturnObj_Model"
    }
}