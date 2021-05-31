function Create-ServerEnv {
    [CmdletBinding()]
    param (
        # Path
        [Parameter(Mandatory = $false)]
        [string]
        $VMPath = "C:",

        # Name Of the Switch needed for the VM (should be a trunked virtual interface)
        [Parameter(Mandatory = $false)]
        [string]
        $SwitchName = 'VintTrunk01'
    )
    
    begin {
        # Variable Read
        $VirtualHardDiskPath = (Get-VMHost).VirtualHardDiskPath
        $VirtualMachinePath = (Get-VMHost).VirtualMachinePath
        $VmNetworkAdapter = (Get-VMSwitch -Name "$SwitchName").Name

        if ((-not [bool](Get-Item -Path "$VMPath\Server" -ErrorAction SilentlyContinue)) -or
            (-not [bool](Get-Item -Path "$VMPath\Server\Disk" -ErrorAction SilentlyContinue)) -or
            (-not [bool](Get-Item -Path "$VMPath\Server\VM" -ErrorAction SilentlyContinue))) {
                
            New-Item -Path $Path -Name 'Server' -ItemType Directory
            $VMPath = $VMPath + '\server'
            New-Item -Path $VMPath -Name 'Disk' -ItemType Directory
            $VMDiskPath = $VMPath + '\Disk'
            New-Item -Path $VMPath -Name 'VM' -ItemType Directory
            $VMPath = $VMPath + '\VM'
        }  
    }
    
    process {
        # Set Default values for hyper-v 
        if (($VirtualHardDiskPath -ne $VMDiskPath) -or 
            ($VirtualMachinePath -ne $VMPath)) {

            Set-VMHost -VirtualHardDiskPath "$VMDiskPath" -VirtualMachinePath "$VMPath"
        }
    }
    
    end {
        
    }
}
function Create-LKKORPVM {
    <#
   .SYNOPSIS
   Easy way to create VM's based on a diff disk
   
   .DESCRIPTION
   Easy way to create VM's based on a diff disk.
   Svendeproeve function
   
   .PARAMETER VMName
   Parameter description
   Name of the VM
   
   .PARAMETER CSVHeader
   Parameter description
   If you want to import from a csv give the header here
   
   .PARAMETER BaseMemory
   Parameter description
   Default basememory is 2GB - input should be in either MB or GB exs 2GB or 2048MB
   
   .PARAMETER SwitchName
   Parameter description
   The switch to be attached to the VM

   .PARAMETER ProcCount
   Parameter description
   The proces count to be added to the new vm

   .EXAMPLE
   Create-CustomVM -VMName 'DKVIB-SERV0001' -SwtchName 'VLanINT01'
   - Creates a Vm with the name DKVIB-SERV0001 and attach the switch named VLANINT01. It will be based on the parent win2019 disk
    
   Create-CustomVM -SwtchName 'VLanINT01'
   - Creates multiple VM name based on the CSV file in same location of script called "Servers.csv" switch named VLANINT01. 
     It will be based on the parent win2019 disk
   
   .NOTES
   Dansk: Lavet til min svendeproeve
   #>
    [CmdletBinding()]
    param (
        # The Name of the new  $VM
        [Parameter(Mandatory = $false)]
        [string]
        $VMName,

        # Csvheader Containing the hostnames
        [Parameter(Mandatory = $false)]
        [string]
        $CSVHeader = 'ServerName',

        # Base memory for the VM
        [Parameter(Mandatory = $false)]
        [string]
        [int64]$BaseMemory = 2GB,

        # Name Of the Switch needed for the VM (should be a trunked virtual interface)
        [Parameter(Mandatory = $false)]
        [string]
        $SwitchName = 'VintTrunk01',

        # ProcCount
        [Parameter(Mandatory = $false)]
        [int]
        $ProcCount = 2
    )
    
    begin {
        # Set-VMNetworkAdapterVlan -Trunk -AllowedVlanIdList "200,300" -VMName "VmName" -VMNetworkAdapterName "TrunkNic" -NativeVlanId 1 
        # Variable location

        # Variable Read count
        [string]$VMParentDisk = [string]$Global:StandardVMParentDisk
        [int]$VMGen = [int]$Global:StandardVMGen
        [int]$ServerVlan = [int]$Global:StandarServerVlan
        [int]$ClientVlan = [int]$Global:StandardClientVlan

        if (-not $VMName) {
            Write-Host -Object 'Please provide a name for the new machine, IF you want to create multiple press ANY button: ' -ForegroundColor "$Global:TextColour" -NoNewline
            $VMName = Read-Host -ErrorAction SilentlyContinue
            $CsvImport = "$VMName"
            if (($VMName -eq $CSV) -or ([string]::IsNullOrEmpty($vmName))) {
                $CsvImport = (Import-Csv -Path '.\servers.csv' -Encoding Default -Delimiter ';').$CSVHeader
            } 
        }
        else {
            # To reduce code later i will set the csvimport name equal to the VMNAME
            $CsvImport = "$VMName"
        }
    }
    
    process {
        # Device Creation process
        foreach ($VM in $CsvImport) {
            # Sets the name of the vm 
            # Variable
            $VMDiskPath = (Split-Path "$VMParentDisk") + '\' + "$vm" + '.vhdx'
            #Write what will be done
            Write-Host -Object '#############################################################################' -ForegroundColor "$global:ConfirmColour"
            Write-Host -Object "##      VM Name: $VM                            " -ForegroundColor "$global:ConfirmColour"
            Write-Host -Object "##      VM Parent Disk: $VMParentDisk           " -ForegroundColor "$global:ConfirmColour"
            Write-Host -Object "##      VM Generation: $VMGen                   " -ForegroundColor "$global:ConfirmColour"
            Write-Host -Object "##      Server Vlan: $ServerVlan                " -ForegroundColor "$global:ConfirmColour"
            Write-Host -Object "##      Client Vlan: $ClientVlan                " -ForegroundColor "$global:ConfirmColour"
            Write-Host -Object '##############################################################################' -ForegroundColor "$global:ConfirmColour"
            Write-Host -Object "# Press any key to confirm or ctrl+c to cancel  " -ForegroundColor $global:ConfirmColour
            Write-Host -Object "##############################################################################" -ForegroundColor "$global:ConfirmColour"
            Read-Host 
            # Creating the Machine with Differencing Disk. 
            $Disk = New-VHD -ParentPath "$VMParentDisk" -Path "$VMDiskPath" -Differencing
            New-VM -Name "$VM" -Generation "$VMGen" -MemoryStartupBytes $BaseMemory -SwitchName "$SwitchName" -VHDPath $VMDiskPath
            Set-VM -Name "$VM" -StaticMemory -ProcessorCount $ProcCount -AutomaticCheckpointsEnabled 0 
            Set-VMNetworkAdapterVlan -VMName "$VM" -Access -VlanId $ServerVlan 
            Get-VM -Name "$VM" | Start-VM
            # Output to PS CLI
            Write-Host -Object '#############################################################################' -ForegroundColor "$Global:writehostsuccessfullcolour"
            Write-Host -Object "##      VM Name: $VM                            " -ForegroundColor "$Global:writehostsuccessfullcolour"
            Write-Host -Object "##      VM Parent Disk: $VMParentDisk           " -ForegroundColor "$Global:writehostsuccessfullcolour"
            Write-Host -Object "##      VM Generation: $VMGen                   " -ForegroundColor "$Global:writehostsuccessfullcolour"
            Write-Host -Object "##      Server Vlan: $ServerVlan                " -ForegroundColor "$Global:writehostsuccessfullcolour"
            Write-Host -Object "##      Client Vlan: $ClientVlan                " -ForegroundColor "$Global:writehostsuccessfullcolour"
            Write-Host -Object '#############################################################################' -ForegroundColor "$Global:writehostsuccessfullcolour"
           
        }
    }
    
    end { }
}
function GLobalVars {
    [string]$Global:ForegroundColour = 'cyan'
    [string]$Global:StandardVMParentDisk = 'D:\Server\Disk\WIN2019\VM-Parent01.vhdx'
    [int]$Global:StandardVMGen = 2
    [int]$Global:StandarServerVlan = 4
    [int]$Global:StandardClientVlan = 6
    [string]$Global:writehostsuccessfullcolour = 'green'
    [string]$Global:BannerColour = 'cyan'
    [string]$Global:TextColour = 'cyan'
    [string]$Global:ErrorTextColour = 'red'
    [string]$Global:ForegroundColour = 'cyan'
    [string]$global:TxtColour = 'Cyan';
    [string]$global:ConfirmColour = 'yellow';
    [string]$global:SuccessColour = 'Green';
}
GLobalVars