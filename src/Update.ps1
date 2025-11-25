# Update.ps1 - Auto-update functionality for ntchk (Network Toolkit)

function Get-NcCurrentVersion {
    <#
    .SYNOPSIS
    Retrieves the current version of the application
    #>
    param(
        [Parameter(Mandatory)] [string] $AppRoot
    )
    
    # Try to read from Build-Config.json (dev environment)
    try {
        $configPath = Join-Path $AppRoot 'build\Build-Config.json'
        if (Test-Path -LiteralPath $configPath) {
            $buildConfig = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
            return $buildConfig.Version
        }
    } catch {
        # Silent fallback
    }
    
    # Fallback: Return hardcoded version (for portable releases)
    return "1.0.4"
}

function Get-NcLatestRelease {
    <#
    .SYNOPSIS
    Queries GitHub API for the latest release of ntchk
    .OUTPUTS
    Returns object with: Version, DownloadUrl, ReleaseNotes, PublishedDate
    #>
    param(
        [string] $Owner = "MadAreYou",
        [string] $Repo = "Network_Check_app"
    )
    
    try {
        $apiUrl = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
        
        # Set TLS 1.2 for GitHub API (required for GitHub)
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        } catch {
            # If setting TLS fails, try without it (might work on newer systems)
        }
        
        # Query GitHub API
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop -TimeoutSec 10
        
        # Extract version from tag (assumes format: v1.0.1 or 1.0.1)
        $version = $response.tag_name -replace '^v', ''
        
        # Find the portable ZIP asset (ntchk-vX.X.X-Portable.zip or NetworkCheck-vX.X.X-Portable.zip for backward compatibility)
        $zipAsset = $response.assets | Where-Object { $_.name -match '(ntchk|NetworkCheck)-v.*-Portable\.zip$' } | Select-Object -First 1
        
        if (-not $zipAsset) {
            throw "No portable release package found in latest release"
        }
        
        return [pscustomobject]@{
            Version = $version
            DownloadUrl = $zipAsset.browser_download_url
            ReleaseNotes = $response.body
            PublishedDate = $response.published_at
            AssetName = $zipAsset.name
            AssetSize = $zipAsset.size
        }
    }
    catch {
        # Return null - error will be caught by Test-NcUpdateAvailable
        return $null
    }
}

function Compare-NcVersion {
    <#
    .SYNOPSIS
    Compares two version strings (semantic versioning)
    .OUTPUTS
    Returns: 1 if Version1 > Version2, -1 if Version1 < Version2, 0 if equal
    #>
    param(
        [Parameter(Mandatory)] [string] $Version1,
        [Parameter(Mandatory)] [string] $Version2
    )
    
    try {
        # Parse versions (handle v1.0.1 or 1.0.1 format)
        $v1 = [version]($Version1 -replace '^v', '')
        $v2 = [version]($Version2 -replace '^v', '')
        
        if ($v1 -gt $v2) { return 1 }
        elseif ($v1 -lt $v2) { return -1 }
        else { return 0 }
    }
    catch {
        Write-Host "Error comparing versions: $($_.Exception.Message)"
        return 0  # Assume equal on error
    }
}

function Test-NcUpdateAvailable {
    <#
    .SYNOPSIS
    Checks if a newer version is available on GitHub
    .OUTPUTS
    Returns object with: UpdateAvailable (bool), CurrentVersion, LatestVersion, ReleaseInfo
    #>
    param(
        [Parameter(Mandatory)] [string] $AppRoot
    )
    
    $currentVersion = Get-NcCurrentVersion -AppRoot $AppRoot
    $latestRelease = Get-NcLatestRelease
    
    if (-not $latestRelease) {
        return [pscustomobject]@{
            UpdateAvailable = $false
            CurrentVersion = $currentVersion
            LatestVersion = $null
            ReleaseInfo = $null
            Error = "Could not retrieve latest release information"
        }
    }
    
    $comparison = Compare-NcVersion -Version1 $latestRelease.Version -Version2 $currentVersion
    
    return [pscustomobject]@{
        UpdateAvailable = ($comparison -gt 0)
        CurrentVersion = $currentVersion
        LatestVersion = $latestRelease.Version
        ReleaseInfo = $latestRelease
        Error = $null
    }
}

function Install-NcUpdate {
    <#
    .SYNOPSIS
    Downloads and installs the latest version of ntchk
    .DESCRIPTION
    Downloads the portable ZIP from GitHub, extracts it to a temp location,
    then creates a self-destructing updater script that will:
    1. Wait for the app to close
    2. Overwrite files (without file locks)
    3. Restart the app
    4. Delete itself
    #>
    param(
        [Parameter(Mandatory)] [string] $AppRoot,
        [Parameter(Mandatory)] [string] $DownloadUrl,
        [Parameter(Mandatory)] [string] $Version
    )
    
    try {
        # Create temp directory for download
        $tempDir = Join-Path $env:TEMP "NetworkCheck_Update_$([guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        # Download ZIP file
        $zipPath = Join-Path $tempDir "ntchk-v$Version-Portable.zip"
        Write-Host "Downloading update from: $DownloadUrl"
        
        # Set TLS 1.2 for download
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Download with progress (if possible)
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($DownloadUrl, $zipPath)
        $webClient.Dispose()
        
        if (-not (Test-Path $zipPath)) {
            throw "Download failed - ZIP file not found"
        }
        
        Write-Host "Download complete. Extracting..."
        
        # Extract to temp location
        $extractPath = Join-Path $tempDir "extracted"
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractPath)
        
        # Backup current config.json (preserve user settings)
        $currentConfig = Join-Path $AppRoot 'config.json'
        $backupConfigPath = Join-Path $tempDir 'config_backup.json'
        if (Test-Path $currentConfig) {
            Copy-Item -LiteralPath $currentConfig -Destination $backupConfigPath -Force
            Write-Host "Backed up user settings"
        }
        
        # Create updater script that runs AFTER app closes
        $updaterScript = Join-Path $tempDir 'updater.ps1'
        
        $updaterCode = @"
# ntchk Auto-Updater Script
# This script runs after the app closes to avoid file locking issues

`$ErrorActionPreference = 'Stop'

# Wait for parent process to exit (max 10 seconds)
Start-Sleep -Seconds 2

Write-Host 'Installing update...'

# Source and destination paths
`$extractPath = '$extractPath'
`$appRoot = '$AppRoot'
`$backupConfig = '$backupConfigPath'

try {
    # Copy new files to app root (overwrite existing)
    `$newFiles = Get-ChildItem -Path `$extractPath -Recurse
    
    foreach (`$file in `$newFiles) {
        `$relativePath = `$file.FullName.Substring(`$extractPath.Length + 1)
        `$targetPath = Join-Path `$appRoot `$relativePath
        
        # Skip exports folder and user config during copy
        if (`$relativePath -like 'exports\*') { continue }
        if (`$relativePath -eq 'config.json') { continue }
        
        if (`$file.PSIsContainer) {
            # Create directory if it doesn't exist
            if (-not (Test-Path `$targetPath)) {
                New-Item -ItemType Directory -Path `$targetPath -Force | Out-Null
            }
        }
        else {
            # Copy file (overwrite) - files are now unlocked
            Copy-Item -LiteralPath `$file.FullName -Destination `$targetPath -Force
            Write-Host "  Updated: `$relativePath"
        }
    }
    
    # Restore user config
    if (Test-Path `$backupConfig) {
        `$userConfig = Join-Path `$appRoot 'config.json'
        Copy-Item -LiteralPath `$backupConfig -Destination `$userConfig -Force
        Write-Host 'Restored user settings'
    }
    
    Write-Host 'Update complete! Restarting app...'
    
    # Restart the application using policy-friendly launcher
    `$exeLauncher = Join-Path `$appRoot 'ntchk.exe'
    if (Test-Path -LiteralPath `$exeLauncher) {
        Start-Process -FilePath `$exeLauncher
    }
    else {
        # Fallback to BAT launcher
        `$batLauncher = Join-Path `$appRoot 'ntchk.bat'
        if (Test-Path -LiteralPath `$batLauncher) {
            Start-Process -FilePath `$batLauncher
        }
        else {
            # Last resort: direct PowerShell launch
            Start-Process -FilePath 'powershell.exe' -ArgumentList "-ExecutionPolicy Bypass -File ```"`$appRoot\ntchk.ps1```""
        }
    }
    
    # Cleanup temp files after a delay (allow restart to complete)
    Start-Sleep -Seconds 2
    Remove-Item -Path '$tempDir' -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host 'Update process completed successfully!'
}
catch {
    Write-Host "Update failed: `$(`$_.Exception.Message)"
    [System.Windows.MessageBox]::Show("Update failed: `$(`$_.Exception.Message)", 'Update Error', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
    Read-Host 'Press Enter to exit'
}
"@
        
        Set-Content -Path $updaterScript -Value $updaterCode -Encoding UTF8
        Write-Host "Created updater script"
        
        return [pscustomobject]@{
            Success = $true
            Message = "Update to v$Version ready to install!"
            Error = $null
            UpdaterScript = $updaterScript
        }
    }
    catch {
        # Cleanup on error
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        return [pscustomobject]@{
            Success = $false
            Message = "Update failed"
            Error = $_.Exception.Message
            UpdaterScript = $null
        }
    }
}

function Show-NcUpdateNotification {
    <#
    .SYNOPSIS
    Shows a simple Windows notification about available update (non-blocking)
    #>
    param(
        [Parameter(Mandatory)] [string] $CurrentVersion,
        [Parameter(Mandatory)] [string] $LatestVersion
    )
    
    try {
        # This would show a Windows toast notification
        # For now, we'll use a message box (will be replaced with WPF popup)
        $message = "A new version of Network Check is available!`n`nInstalled: v$CurrentVersion`nAvailable: v$LatestVersion`n`nWould you like to update now?"
        $result = [System.Windows.MessageBox]::Show(
            $message, 
            'Update Available', 
            [System.Windows.MessageBoxButton]::YesNo, 
            [System.Windows.MessageBoxImage]::Information
        )
        
        return ($result -eq [System.Windows.MessageBoxResult]::Yes)
    }
    catch {
        Write-Host "Error showing update notification: $($_.Exception.Message)"
        return $false
    }
}

