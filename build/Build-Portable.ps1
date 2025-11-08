<#
.SYNOPSIS
    Automated build script for Network Check portable application
.DESCRIPTION
    This script packages the Network Check app into a portable ZIP distribution
    Run this script from the project root or build folder
.EXAMPLE
    .\Build-Portable.ps1
#>

param(
    [switch]$SkipClean,
    [switch]$OpenOutput
)

# Set error handling
$ErrorActionPreference = 'Stop'

# Get script and project paths
$BuildFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $BuildFolder
$ReleasesFolder = Join-Path $ProjectRoot 'releases'

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Network Check - Portable Build Script" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Load build configuration
$ConfigPath = Join-Path $BuildFolder 'Build-Config.json'
if (-not (Test-Path $ConfigPath)) {
    throw "Build configuration not found: $ConfigPath"
}

Write-Host "[1/6] Loading build configuration..." -ForegroundColor Yellow
$Config = Get-Content $ConfigPath | ConvertFrom-Json
Write-Host "      App: $($Config.AppName) v$($Config.Version)" -ForegroundColor Green
Write-Host "      Author: $($Config.Author)" -ForegroundColor Green
Write-Host ""

# Create releases folder
if (-not (Test-Path $ReleasesFolder)) {
    New-Item -ItemType Directory -Path $ReleasesFolder -Force | Out-Null
}

# Define output paths
$OutputName = "$($Config.AppName.Replace(' ', ''))-v$($Config.Version)-Portable"
$TempBuildFolder = Join-Path $BuildFolder "temp_$([Guid]::NewGuid().ToString('N').Substring(0,8))"
$ZipPath = Join-Path $ReleasesFolder "$OutputName.zip"

Write-Host "[2/6] Creating temporary build folder..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $TempBuildFolder -Force | Out-Null
Write-Host "      Location: $TempBuildFolder" -ForegroundColor Green
Write-Host ""

Write-Host "[3/6] Copying application files..." -ForegroundColor Yellow

# Copy main script
Copy-Item (Join-Path $ProjectRoot $Config.MainScript) -Destination $TempBuildFolder
Write-Host "      + $($Config.MainScript)" -ForegroundColor Gray

# Copy speedtest.exe if exists
$SpeedTestPath = Join-Path $ProjectRoot 'speedtest.exe'
if (Test-Path $SpeedTestPath) {
    Copy-Item $SpeedTestPath -Destination $TempBuildFolder
    Write-Host "      + speedtest.exe" -ForegroundColor Gray
}

# Copy config.json
$ConfigJsonPath = Join-Path $ProjectRoot 'config.json'
if (Test-Path $ConfigJsonPath) {
    Copy-Item $ConfigJsonPath -Destination $TempBuildFolder
    Write-Host "      + config.json" -ForegroundColor Gray
}

# Copy src folder
$SrcPath = Join-Path $ProjectRoot 'src'
if (Test-Path $SrcPath) {
    Copy-Item $SrcPath -Destination $TempBuildFolder -Recurse
    Write-Host "      + src\ (PowerShell modules)" -ForegroundColor Gray
}

# Copy ui folder
$UiPath = Join-Path $ProjectRoot 'ui'
if (Test-Path $UiPath) {
    Copy-Item $UiPath -Destination $TempBuildFolder -Recurse
    Write-Host "      + ui\ (XAML files)" -ForegroundColor Gray
}

# Copy assets folder
$AssetsPath = Join-Path $ProjectRoot 'assets'
if (Test-Path $AssetsPath) {
    Copy-Item $AssetsPath -Destination $TempBuildFolder -Recurse
    Write-Host "      + assets\ (icons, images)" -ForegroundColor Gray
}

# Create empty exports folder
$ExportsFolder = Join-Path $TempBuildFolder 'exports'
New-Item -ItemType Directory -Path $ExportsFolder -Force | Out-Null
Write-Host "      + exports\ (placeholder)" -ForegroundColor Gray

Write-Host ""

# Create README
Write-Host "[4/6] Generating README.txt..." -ForegroundColor Yellow
$ReadmePath = Join-Path $TempBuildFolder 'README.txt'
$ReadmeContent = @"
=====================================
  $($Config.AppName) v$($Config.Version)
=====================================

$($Config.Description)

Author: $($Config.Author)
$($Config.Copyright)

=====================================
QUICK START
=====================================

1. Extract this ZIP to any folder
2. Run: NetworkCheckApp.ps1
   - Right-click → Run with PowerShell
   - OR double-click if .ps1 files are associated

3. First-time setup:
   - The app will auto-configure paths
   - Go to Settings → Create Desktop Shortcut (optional)

=====================================
REQUIREMENTS
=====================================

- Windows 10/11 (PowerShell 5.1+)
- Internet connection for speed tests
- Administrator rights (for some diagnostics)

=====================================
FEATURES
=====================================

✓ Speed Test (powered by Ookla)
  - Download/Upload speeds
  - Ping and latency
  - ISP and server info
  - Export results to JSON

✓ Network Information
  - Network name (WiFi/Ethernet)
  - IP address (public & local)
  - Gateway and DNS servers
  - Connection type and status
  - Auto-refresh with timestamp

✓ Diagnostics
  - Traceroute to custom hosts
  - DNS flush
  - IP release/renew
  - Winsock reset
  - ARP cache clear

✓ Settings
  - Light/Dark mode themes
  - Export folder configuration
  - Auto-export after speed test
  - Desktop shortcut management

=====================================
PORTABLE MODE
=====================================

This app is fully portable:
- No installation required
- No registry changes
- All settings in config.json
- Can run from USB drive
- Move folder anywhere

=====================================
CONTACT & SUPPORT
=====================================

Email: juraj@madzo.eu
LinkedIn: linkedin.com/in/juraj-madzunkov-457389104

If you like this app, consider buying me a coffee!
Revolut: @jurajcy93

=====================================
TROUBLESHOOTING
=====================================

If the app doesn't start:
1. Right-click NetworkCheckApp.ps1
2. Select "Run with PowerShell"
3. If blocked by security:
   - Right-click → Properties
   - Check "Unblock" → OK

For execution policy errors:
  powershell.exe -ExecutionPolicy Bypass -File NetworkCheckApp.ps1

=====================================
"@

Set-Content -Path $ReadmePath -Value $ReadmeContent -Encoding UTF8
Write-Host "      README.txt created" -ForegroundColor Green
Write-Host ""

# Create launcher BAT file
Write-Host "[5/6] Creating launcher script..." -ForegroundColor Yellow
$LauncherPath = Join-Path $TempBuildFolder 'Run-NetworkCheck.bat'
$LauncherContent = @"
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
"@

Set-Content -Path $LauncherPath -Value $LauncherContent -Encoding ASCII
Write-Host "      Run-NetworkCheck.bat created" -ForegroundColor Green
Write-Host ""

# Create ZIP package
Write-Host "[6/6] Creating ZIP package..." -ForegroundColor Yellow

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
    Write-Host "      Removed existing ZIP" -ForegroundColor Gray
}

# Use .NET compression (PowerShell 5.1 compatible)
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($TempBuildFolder, $ZipPath, 'Optimal', $false)

$ZipSize = (Get-Item $ZipPath).Length / 1MB
Write-Host "      ZIP created: $([Math]::Round($ZipSize, 2)) MB" -ForegroundColor Green
Write-Host ""

# Cleanup
if (-not $SkipClean) {
    Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
    Remove-Item $TempBuildFolder -Recurse -Force
    Write-Host "      Temporary folder deleted" -ForegroundColor Green
    Write-Host ""
}

# Summary
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  BUILD COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Output Location:" -ForegroundColor Yellow
Write-Host "  $ZipPath" -ForegroundColor White
Write-Host ""
Write-Host "Package Contents:" -ForegroundColor Yellow
Write-Host "  - NetworkCheckApp.ps1 (main application)" -ForegroundColor White
Write-Host "  - Run-NetworkCheck.bat (launcher)" -ForegroundColor White
Write-Host "  - speedtest.exe (Ookla CLI)" -ForegroundColor White
Write-Host "  - src\ (PowerShell modules)" -ForegroundColor White
Write-Host "  - ui\ (XAML interface)" -ForegroundColor White
Write-Host "  - assets\ (icons, images)" -ForegroundColor White
Write-Host "  - config.json (settings)" -ForegroundColor White
Write-Host "  - README.txt (documentation)" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Test the ZIP by extracting and running" -ForegroundColor White
Write-Host "  2. Distribute to users" -ForegroundColor White
Write-Host "  3. Upload to your platform of choice" -ForegroundColor White
Write-Host ""

# Open output folder
if ($OpenOutput) {
    Start-Process explorer.exe -ArgumentList "/select,`"$ZipPath`""
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
