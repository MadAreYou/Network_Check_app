@echo off
REM ntchk - Network Toolkit Launcher
REM Launches the PowerShell application with hidden window (no VBScript)

REM Launch PowerShell hidden and exit immediately
start /min "" powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0ntchk.ps1"
exit
