##############################################################
<#                                                           #
This is a Public Env file. Do not write sensitive data here. #
It will be uploaded to your choosen repository               #
#>                                                           #
##############################################################
#
#
#
#Region Colour
$Global:writehostsuccessfullcolour = 'green'
$Global:BannerColour = 'cyan'
$Global:TextColour = 'cyan'
$Global:ErrorTextColour = 'red'
#Endregion Colour

##
#Svendeproeve
[string]$Global:ForegroundColour = 'Cyan'
[string]$Global:TxtColour = 'Cyan';
[string]$Global:ConfirmColour = 'yellow';
[string]$Global:SuccessColour = 'Green';

#Hyper-v Specific
[string]$Global:StandardVMParentDisk = 'D:\Server\Disk\WIN2019\LKKORP-ParentDisk.vhdx'
[int]$Global:StandardVMGen = 2

[int]$Global:StandardMNGVlan = 2
[int]$Global:StandarServerVlan = 4
[int]$Global:StandardClientVlan = 6