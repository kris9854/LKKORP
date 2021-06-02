Option Explicit

Dim oShell, oEnv

Set oShell = CreateObject("WScript.Shell")
Set oEnv = oShell.Environment("PROCESS")

If oEnv("STAGE") = "ISO" then

    Dim sCmd, rc

    sCmd = "WDSUTIL /Replace-Image /Image:""Lite Touch Windows PE (" & oEnv("PLATFORM") & ")"" /ImageType:Boot /Architecture:" & oEnv("PLATFORM") & " /ReplacementImage /ImageFile:""" & oEnv("CONTENT") & "\Sources\Boot.wim"""
    WScript.Echo "About to run command: " & sCmd

    rc = oShell.Run(sCmd, 0, true)
    WScript.Echo "WDSUTIL rc = " & CStr(rc)

    WScript.Quit 1

End if