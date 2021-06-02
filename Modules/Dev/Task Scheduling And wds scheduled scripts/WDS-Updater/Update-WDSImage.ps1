# Script for running with task scheduler
# Given the functionality to reinitiate a WMI file.
function Update-WDSImage {
    param (
        # Path to boot image
        [Parameter(Mandatory = $false)]
        [string]
        $LocalPath = 'D:\LKKORPDeploymentShare\Boot\LiteTouchPE_x64.wim',
        # Replace Image Name
        [Parameter(Mandatory = $false)]
        [String]
        $ImageName = "Lite Touch Windows PE (x64)"
    )
    Write-Warning "WARNING: Starting Script"
    Set-Location "$PSScriptRoot"
    try {
        WDSUTIL /Replace-Image /Image:"$ImageName" /ImageType:Boot /Architecture:"x64" /ReplacementImage /ImageFile:"$LocalPath"
        Write-Output "Success"
    }
    catch {
        Write-Output "Error Running WDSUTIL" 
    }

    
}
Update-WDSImage