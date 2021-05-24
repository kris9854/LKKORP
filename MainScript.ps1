<#
This script consist of 2 funtinalities
First: ScriptTemplate
Secound "Insert Script name"

Functionalities of "Insert Script name"
    .
    .
Version 1.0.0

This Script has 1 "ScriptTemplate"
    .Holds Basic stript paths for every script designed by Kristian
    .Varible creation based on created path
    .Function created
Version Table For ScriptTemplate
    .Version 1.0.0 - First major release of ScriptTemplate
    .Version 1.0.1 - Basic Script front
    .Version 1.0.2 - Added try and catch
    .Version 1.0.3 - Added Test and folder creation
    .Version 1.0.4 - Added Variable Test in New-Directory function
    .Version 1.0.5 - Advanced Function to New-Directory Function, Also added the PresentationFramework DLL
    .Version 1.0.6 - Added better log feature.
        .Logging feature called Write-Log -Message * -Level Warn, Info or Error
    .Version 1.0.7 - Added out-null to new-directory to remove standard output from command execution
    .Version 1.0.8 - Added "Script Specific variables"
    .Version 1.0.9 - Created New varoables
    .Version 1.1.0 - added time execution Check
    .Version 2.0.0 - new template major version
    .Version 3.0.0 -
        .New template major version
        .Created a Powershell Module to hold the functions

Shortcut help: https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf

#>
#using module "$PSScriptRoot\anothermodule.psm1"
#Region DLL's and System Objects
Add-Type -AssemblyName System.Windows.Forms     #Can be created with windows form tools like saphiere or postgree
#Add-Type -AssemblyName PresentationFramework    #https://trumpexcel.com/vba-msgbox/
Clear-Host                          #Clears the powershell windows messages
#Endregion DLL's and System Objects
#Region Script Specific variables.
[string]$ScriptName = 'KR_Template'      #Name of your script
$VersionTemplate = '3.0.1'          #Template Script Version
$VersionScript = '1.0.0'            #Script Version
[string]$ScriptAuthor = 'Kristian'   #Script Author
#Endregion Script Specific variables.
$host.ui.RawUI.WindowTitle = "$ScriptName"
#Region variables and Global Values
$global:ScriptPath = Split-Path $script:MyInvocation.MyCommand.Path
[datetime]$Date = Get-Date -Format "dd-MM-yy-HHmm"
[datetime]$startDTM = (Get-Date) # Get Start Time
#Endregion variables and Global Values


#Region Import Modules
#Import-Module -Name 'Posh-SSH'
#Import-Module -Name 'powershell-yaml'
Import-Module "$ScriptPath\Modules\Original-PSModule\TemplateFunctions.psm1" -Verbose
#Endregion Import Modules

#Region Call functions from TemplateFunctions
New-Directory -DirName 'Log' -ErrorAction SilentlyContinue
New-Directory -DirName 'Modules' -ErrorAction SilentlyContinue
New-Directory -DirName 'Templates' -ErrorAction SilentlyContinue #Used for templating for different powershell structures. Example task Scheduling
New-Directory -DirName 'Output' -ErrorAction SilentlyContinue
#Endregion call function
#Region call Modules in Modules path
#Get The Modules in modules location excluding the Dev folder
$script:ModulesPathScriptList = (Get-ChildItem -Path "$Modules" -Filter '*.ps1' -Recurse).FullName | Where-Object { $_ -notlike "$Modules\Dev\*" }
foreach ($Powershellcustommodule in $script:ModulesPathScriptList) {
    try {
        $message = "Importing: " + (Split-Path $Powershellcustommodule -Leaf)
        Write-Host -Object "$message" -ForegroundColor "green"
        . $Powershellcustommodule 
        $ImportWasSuccessfull = "Imported all modules successfully"
    }
    catch {
        $ImportError = "Error on module import - $Powershellcustommodule"
    }
}

if (-not $ImportError) {
    Write-Host -Object "$ImportWasSuccessfull" -ForegroundColor $Global:writehostsuccessfullcolour
}
else {
    Write-Host -Object "$ImportError" -ForegroundColor 'Red'
}
#Endregion call Modules in Modules path
#############################################################################################################################
#Region Script Execution Start
#Region Main 
# Used to call functions from imported modules
Get-ScriptBanner

#Endregion Main