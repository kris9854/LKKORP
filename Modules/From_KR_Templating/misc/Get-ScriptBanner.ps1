#The banner for this script
function Get-ScriptBanner {
    param (
        # Colour of text
        [Parameter(Mandatory = $false)]
        [string]
        $Colour = $Global:BannerColour
    )
    Write-Host -Object "
.-.   .-.   .-..-. .--. .---. .---. 
: :   : :   : :' ;: ,. :: .; :: .; :
: :   : :   :   ' : :: ::   .':  _.'
: :__ : :__ : :.`.: :; :: :.`.: :   
:___.':___.':_;:_;`.__.':_;:_;:_;   
                                    " -ForegroundColor $Colour
}