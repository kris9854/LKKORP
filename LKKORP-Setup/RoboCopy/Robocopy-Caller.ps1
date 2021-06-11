# caller for the script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
# Set location to script root
Set-Location $scriptPath
# Call another script and Redirect all streams to a file
.\RoboCopy.ps1 *> .\RobocopyScriptLog.txt