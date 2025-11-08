# Quick Build Script - Just double-click or run this!
# Builds the portable ZIP package

$BuildScript = Join-Path $PSScriptRoot 'Build-Portable.ps1'

if (Test-Path $BuildScript) {
    & $BuildScript -OpenOutput
} else {
    Write-Host "ERROR: Build-Portable.ps1 not found!" -ForegroundColor Red
    Write-Host "Make sure you're running this from the build folder." -ForegroundColor Yellow
    pause
}
