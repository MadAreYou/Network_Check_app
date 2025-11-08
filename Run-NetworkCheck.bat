@echo off
REM Network Check Launcher
REM This script launches the Network Check application

echo Starting Network Check...
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0NetworkCheckApp.ps1"

if errorlevel 1 (
    echo.
    echo Error: Failed to start Network Check
    echo.
    echo Try running NetworkCheckApp.ps1 directly:
    echo Right-click NetworkCheckApp.ps1 ^> Run with PowerShell
    echo.
    pause
)
