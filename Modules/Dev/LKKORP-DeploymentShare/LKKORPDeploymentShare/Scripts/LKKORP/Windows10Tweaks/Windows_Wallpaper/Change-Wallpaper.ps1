# Get the TS variables
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$ScriptRoot = $tsenv.Value('ScriptRoot')
$OSDTargetSystemRoot =  $tsenv.Value('OSDTargetSystemRoot')
 
# Rename default wallpaper
Rename-Item $OSDTargetSystemRoot\Web\Wallpaper\Windows\img0.jpg img1.jpg -Force
 
# Copy new default wallpaper
Copy-Item $ScriptRoot\LKKORP\Windows_Wallpaper\img0.jpg $OSDTargetSystemRoot\Web\Wallpaper\Windows -Force