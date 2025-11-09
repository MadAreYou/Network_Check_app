@echo off
REM Network Check Launcher
REM This script launches the Network Check application using VBScript to hide the PowerShell window

REM Create a temporary VBScript to launch PowerShell hidden
echo Set objShell = CreateObject("WScript.Shell") > "%TEMP%\LaunchNetworkCheck.vbs"
echo objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""%~dp0NetworkCheckApp.ps1""", 0, False >> "%TEMP%\LaunchNetworkCheck.vbs"

REM Execute the VBScript
cscript //nologo "%TEMP%\LaunchNetworkCheck.vbs"

REM Clean up the temporary VBScript
del "%TEMP%\LaunchNetworkCheck.vbs"
