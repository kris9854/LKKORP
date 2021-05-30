# Holds function for the application to work

function Change-Win10LockScreen {
    param (
        # Main Win10 lockscreenfolder
        [Parameter(Mandatory = $false)]
        [string]
        $Win10LockscreenDir = 'C:\Windows\Web\Screen'
    )
    #Take ownership
    takeown /f C:\Windows\Web\Screen\*.*

    #change permission giing system access to write
    icacls c:\windows\WEB\wallpaper\Windows\*.* /Grant 'System:(F)'

    # Remove originals
    Remove-Item C:\Windows\Web\Screen\*.*

    #Copy our wallpapers
    Copy-Item $PSScriptRoot\*.* C:\Windows\Web\Screen
}

function Change-Wallpaper {
    param ()
    #inspiration link https://ccmexec.com/2015/08/replacing-default-wallpaper-in-windows-10-using-scriptmdtsccm/
    #Take ownership
    takeown /f c:\windows\WEB\wallpaper\Windows\img0.jpg
    takeown /f C:\Windows\Web\4K\Wallpaper\Windows\*.*
    #change permission giing system access to write
    icacls c:\windows\WEB\wallpaper\Windows\img0.jpg /Grant 'System:(F)'
    icacls C:\Windows\Web\4K\Wallpaper\Windows\*.* /Grant 'System:(F)'
    # Remove originals
    Remove-Item c:\windows\WEB\wallpaper\Windows\img0.jpg
    Remove-Item C:\Windows\Web\4K\Wallpaper\Windows\*.*
    #Copy our wallpapers
    Copy-Item $PSScriptRoot\img0.jpg c:\windows\WEB\wallpaper\Windows\img0.jpg
    Copy-Item $PSScriptRoot\4k\*.* C:\Windows\Web\4K\Wallpaper\Windows



}
