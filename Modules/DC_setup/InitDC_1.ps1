# https://docs.microsoft.com/en-us/windows/deployment/deploy-windows-mdt/create-a-windows-10-reference-image
# For initializing the DC env
function InitDC {
    param (
        # Location of the OU file
        [Parameter(Mandatory = $false)]
        [string]$OUlistLocation = "$Modules\Svendeproeve\DC_Setup\oulist.txt"
    )
    
    $oulist = Import-Csv -Path "$OUlistLocation"
    ForEach ($entry in $oulist) {
        $ouname = $entry.ouname
        $oupath = $entry.oupath
        New-ADOrganizationalUnit -Name $ouname -Path $oupath
        Write-Host -ForegroundColor Green "OU $ouname is created in the location $oupath"
    }


    #Init The MDT User
    New-ADUser -Name 'SA-MDT' -UserPrincipalName 'SA-MDT' -Path "OU=Service Accounts,OU=Accounts,OU=LKKORP,DC=LKKORP,DC=LOCAL" -Description "Service ACCount for MDT Build Account" -AccountPassword (ConvertTo-SecureString "Asdf1234" -AsPlainText -Force) -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Enabled $true
}
