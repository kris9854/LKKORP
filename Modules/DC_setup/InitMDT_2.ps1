# https://docs.microsoft.com/en-us/windows/deployment/deploy-windows-mdt/create-a-windows-10-reference-image
#Init the MDT Server
function InitMDT {
    param ()
    Write-Host "Have you installed Windows ADK? If Not exit this"
    Read-Host

}
# Region Script For setting up WDS server with currect settings

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
        ReadAccess   = 'LKKORP\SA-MDT, LKKORP\Share-Access-WDS-RW' 
        FullAccess   = 'LKKORP\Share-Access-WDS-RW' -

    }
    New-SmbShare @SMBShareArguments
    # Endregion Create local Deployment Share
    # Endregion Script For setting up WDS server with currect settings
}
New-LKKORPWDS