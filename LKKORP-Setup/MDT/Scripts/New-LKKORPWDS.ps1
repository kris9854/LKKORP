function New-LKKORPWDS {
    param (
        # Server Name Defaults to local
        [Parameter(Mandatory = $false)]
        [String]
        $Server = "$env:ComputerName",

        # RemoteInstallPath name
        [Parameter(Mandatory = $false)]
        [String]
        $RemoteInstallPath = 'c:\RemoteInstall',
        
        # DeploymentShare name
        [Parameter(Mandatory = $false)]
        [String]
        $DeploymentShare = 'c:\LKKORPDeploymentShare',

        # SMBShareName
        [Parameter(Mandatory = $false)]
        [String]
        $SMBShareName = $DeploymentShare.split('\')[-1] + '$' 
    )
    # Region Install WDS locally
    Install-WindowsFeature -Name WDS -IncludeManagementTools

    WDSUTIL /Verbose /Progress /Initialize-Server /Server:"$Server" /RemInst:"$ReminstallationPath"

    WDSUTIL /Set-Server /AnswerClients:All
    # Endregion Install WDS locally

    # Region Create local Deployment Share
    New-Item -Path "$DeploymentShare" -ItemType directory
    $SMBShareArguments = @{
        Name         = "$SMBShareName" 
        Path         = "$DeploymentShare" 
        ChangeAccess = 'LKKORP\Share-Access-WDS-RW'

    }
    New-SmbShare @SMBShareArguments 

    $GrantSMBARG = @{
        Name        = "$SMBShareName" 
        AccessRight = "Read" 
        
    }
    Grant-SmbShareAccess @GrantSMBARG -AccountName ‘SA-MDT’
    Grant-SmbShareAccess @GrantSMBARG -AccountName ‘Share-Access-WDS-RW'
    # Endregion Create local Deployment Share
    # Endregion Script For setting up WDS server with currect settings
}
#Call Function
New-LKKORPWDS
