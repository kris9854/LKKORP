rem  This Is a helper for any exe files we want to run
echo off
Z:\Applications\{{PATHTOEXE}} /silent
:loop
timeout /t 10 /nobreak
Tasklist /fi "imagename eq {{INSTALLER.exe}}" |find ":" > nul
if errorlevel 1 goto loop
exit