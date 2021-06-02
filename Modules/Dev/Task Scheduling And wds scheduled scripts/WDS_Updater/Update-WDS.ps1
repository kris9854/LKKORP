# Script for running with task scheduler
# Given the functionality to reinitiate a WMI file.
function Rearm-WMI {
    param (
    # Path to boot image
    [Parameter(Mandatory = $false)]
    [string]
    $LocalPath = 'D:\LKKORPDeploymentShare\Sources\Boot.wim',
    # Replace Image Name
    [Parameter(AttributeValues)]
    [ParameterType]
    $ImageName = "Lite Touch Windows PE x64"
    )
    try {
        WDSUTIL /Replace-Image /Image:"$ImageName" /ImageType:Boot /Architecture:"x64" /ReplacementImage /ImageFile:"$LocalPath"
        $return("Success")
    }
    catch {
        Write-Error -Message "Error Running WDSUTIL" 
    }
    
    
}

Choco install {{Pakkenavn}}.nupkg -y