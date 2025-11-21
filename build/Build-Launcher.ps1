<#
.SYNOPSIS
    Builds ntchk.exe launcher from C# source
.DESCRIPTION
    Compiles ntchk-launcher.cs into a standalone Windows executable
    This .exe launcher is policy-friendly (no VBScript) and launches PowerShell hidden
.EXAMPLE
    .\Build-Launcher.ps1
#>

$ErrorActionPreference = 'Stop'

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  ntchk Launcher Builder" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Paths
$BuildFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $BuildFolder
$SourceFile = Join-Path $BuildFolder 'ntchk-launcher.cs'
$OutputExe = Join-Path $ProjectRoot 'ntchk.exe'

# Verify source exists
if (-not (Test-Path $SourceFile)) {
    Write-Host "ERROR: Source file not found: $SourceFile" -ForegroundColor Red
    exit 1
}

Write-Host "[1/3] Loading C# source..." -ForegroundColor Yellow
$sourceCode = Get-Content $SourceFile -Raw
Write-Host "      Source loaded: $($sourceCode.Length) bytes" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Compiling to executable..." -ForegroundColor Yellow

try {
    Add-Type -TypeDefinition $sourceCode `
        -OutputAssembly $OutputExe `
        -OutputType ConsoleApplication `
        -ReferencedAssemblies @('System.dll')
    
    Write-Host "      Compilation successful!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Compilation failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/3] Verifying output..." -ForegroundColor Yellow

if (Test-Path $OutputExe) {
    $exeSize = (Get-Item $OutputExe).Length / 1KB
    Write-Host "      Created: ntchk.exe ($([Math]::Round($exeSize, 2)) KB)" -ForegroundColor Green
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Output: $OutputExe" -ForegroundColor White
    Write-Host ""
    Write-Host "You can now use ntchk.exe as your launcher!" -ForegroundColor White
    Write-Host "- Double-click ntchk.exe to start the app (hidden window)" -ForegroundColor Gray
    Write-Host "- Fallback: Use ntchk.bat if .exe is blocked" -ForegroundColor Gray
    Write-Host "- Direct: Run ntchk.ps1 for troubleshooting" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "ERROR: Output file not created!" -ForegroundColor Red
    exit 1
}
