# Get the TS variables
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$ScriptRoot = $tsenv.Value('ScriptRoot')
$OSDTargetSystemRoot = $tsenv.Value('OSDTargetSystemRoot')
 
# Rename default wallpaper
Rename-Item $OSDTargetSystemRoot\Windows\Web\Screen img1.jpg -Force
 
# Copy new default wallpaper
Copy-Item $ScriptRoot\LKKORP\Windows_Lockscreen\img0.jpg $OSDTargetSystemRoot\Web\Wallpaper\Windows -Force