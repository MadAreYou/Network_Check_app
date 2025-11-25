# Update.ps1 - Auto-update functionality for ntchk (Network Toolkit)

function Get-NcCurrentVersion {
    <#
    .SYNOPSIS
    Retrieves the current version of the application
    #>
    param(
        [Parameter(Mandatory)] [string] $AppRoot
    )
    
    # Priority 1: Read from version.txt (portable releases)
    try {
        $versionFile = Join-Path $AppRoot 'version.txt'
        if (Test-Path -LiteralPath $versionFile) {
            $version = (Get-Content -LiteralPath $versionFile -Raw).Trim()
            if ($version -match '^\d+\.\d+\.\d+$') {
                return $version
            }
        }
    } catch {
        # Silent fallback
    }
    
    # Priority 2: Read from Build-Config.json (dev environment)
    try {
        $configPath = Join-Path $AppRoot 'build\Build-Config.json'
        if (Test-Path -LiteralPath $configPath) {
            $buildConfig = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
            return $buildConfig.Version
        }
    } catch {
        # Silent fallback
    }
    
    # Fallback: Return default version (should never reach here)
    return "1.0.0"
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
    Downloads and installs the latest version of ntchk in-place (portable mode)
    .DESCRIPTION
    Downloads the portable ZIP, extracts to "extracted" folder in the app directory,
    then copies files to the main folder (preserving config.json and exports).
    The app must be closed during file copy to avoid file locks.
    #>
    param(
        [Parameter(Mandatory)] [string] $AppRoot,
        [Parameter(Mandatory)] [string] $DownloadUrl,
        [Parameter(Mandatory)] [string] $Version
    )
    
    # Debug log in app folder
    $debugLog = Join-Path $AppRoot "upgrade-debug.log"
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path $debugLog -Value "`n=== [$timestamp] Install-NcUpdate Started ===" -Force
    Add-Content -Path $debugLog -Value "AppRoot: $AppRoot" -Force
    Add-Content -Path $debugLog -Value "DownloadUrl: $DownloadUrl" -Force
    Add-Content -Path $debugLog -Value "Version: $Version" -Force
    
    try {
        # Create "extracted" folder in app directory (portable approach)
        $extractedFolder = Join-Path $AppRoot "extracted"
        Add-Content -Path $debugLog -Value "Creating extracted folder: $extractedFolder" -Force
        
        # Clean up old extracted folder if exists
        if (Test-Path $extractedFolder) {
            Remove-Item -Path $extractedFolder -Recurse -Force -ErrorAction SilentlyContinue
            Add-Content -Path $debugLog -Value "Removed old extracted folder" -Force
        }
        
        New-Item -ItemType Directory -Path $extractedFolder -Force | Out-Null
        Add-Content -Path $debugLog -Value "Extracted folder created" -Force
        
        # Download ZIP file to extracted folder
        $zipPath = Join-Path $extractedFolder "ntchk-v$Version-Portable.zip"
        Add-Content -Path $debugLog -Value "Downloading to: $zipPath" -Force
        
        # Set TLS 1.2 for GitHub downloads
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Download
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($DownloadUrl, $zipPath)
        $webClient.Dispose()
        
        Add-Content -Path $debugLog -Value "Download completed" -Force
        
        if (-not (Test-Path $zipPath)) {
            throw "Download failed - ZIP file not found"
        }
        
        $zipSize = (Get-Item $zipPath).Length
        Add-Content -Path $debugLog -Value "ZIP exists, size: $zipSize bytes" -Force
        
        # Extract ZIP directly to extracted folder
        Add-Content -Path $debugLog -Value "Extracting ZIP..." -Force
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractedFolder)
        
        Add-Content -Path $debugLog -Value "Extraction complete" -Force
        
        # Delete the ZIP file (no longer needed)
        Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
        Add-Content -Path $debugLog -Value "ZIP file deleted" -Force
        
        # CRITICAL FIX: GitHub ZIP contains nested folder (ntchk-v1.0.5-Portable/)
        # We need to flatten it so files are directly in extracted/ folder
        $nestedFolder = Get-ChildItem $extractedFolder -Directory | Where-Object { $_.Name -match '^ntchk-v.*-Portable$' } | Select-Object -First 1
        if ($nestedFolder) {
            Add-Content -Path $debugLog -Value "Detected nested folder: $($nestedFolder.Name) - flattening structure..." -Force
            
            # Move all files from nested folder to extracted root
            $nestedPath = $nestedFolder.FullName
            Get-ChildItem $nestedPath -Recurse | ForEach-Object {
                $relativePath = $_.FullName.Substring($nestedPath.Length + 1)
                $targetPath = Join-Path $extractedFolder $relativePath
                
                if ($_.PSIsContainer) {
                    if (-not (Test-Path $targetPath)) {
                        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                    }
                } else {
                    $targetDir = Split-Path $targetPath -Parent
                    if (-not (Test-Path $targetDir)) {
                        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                    }
                    Move-Item -LiteralPath $_.FullName -Destination $targetPath -Force
                }
            }
            
            # Remove now-empty nested folder
            Remove-Item -Path $nestedPath -Recurse -Force -ErrorAction SilentlyContinue
            Add-Content -Path $debugLog -Value "Flattening complete - nested folder removed" -Force
        } else {
            Add-Content -Path $debugLog -Value "No nested folder detected - structure is correct" -Force
        }
        
        # Verify extraction
        $extractedFiles = Get-ChildItem $extractedFolder -Recurse -File
        Add-Content -Path $debugLog -Value "Extracted file count: $($extractedFiles.Count)" -Force
        
        # Backup current config.json (preserve user settings)
        Add-Content -Path $debugLog -Value "Backing up config..." -Force
        $currentConfig = Join-Path $AppRoot 'config.json'
        $backupConfig = Join-Path $extractedFolder 'config_backup.json'
        if (Test-Path $currentConfig) {
            Copy-Item -LiteralPath $currentConfig -Destination $backupConfig -Force
            Add-Content -Path $debugLog -Value "Config backed up" -Force
        }
        
        # Create updater script that runs AFTER app closes
        Add-Content -Path $debugLog -Value "Creating updater script..." -Force
        $updaterScript = Join-Path $AppRoot 'updater.ps1'
        
        $updaterCode = @"
# ntchk Auto-Updater Script (Portable Mode)
# Copies files from 'extracted' folder to app root after app closes

`$ErrorActionPreference = 'Continue'
`$logFile = Join-Path '$AppRoot' 'update.log'

function Write-Log {
    param([string]`$Message)
    `$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path `$logFile -Value "[`$timestamp] `$Message" -Force
}

try {
    Write-Log '=== ntchk Auto-Update Started ==='
    Write-Log 'Waiting 3 seconds for app to close...'
    Start-Sleep -Seconds 3
    
    `$extractedFolder = Join-Path '$AppRoot' 'extracted'
    `$backupConfig = Join-Path `$extractedFolder 'config_backup.json'
    
    Write-Log "Extracted folder: `$extractedFolder"
    
    if (-not (Test-Path `$extractedFolder)) {
        throw "Extracted folder not found"
    }
    
    `$allFiles = Get-ChildItem `$extractedFolder -Recurse -File | Where-Object { `$_.Name -ne 'config_backup.json' }
    Write-Log "Files to copy: `$(`$allFiles.Count)"
    
    `$copiedCount = 0
    `$skippedCount = 0
    
    foreach (`$file in `$allFiles) {
        `$relativePath = `$file.FullName.Substring(`$extractedFolder.Length + 1)
        `$targetPath = Join-Path '$AppRoot' `$relativePath
        
        try {
            if (`$relativePath -eq 'config.json' -or `$relativePath -like 'exports\\*' -or `$relativePath -like 'exports/*') {
                `$skippedCount++
                continue
            }
            
            `$parentDir = Split-Path `$targetPath -Parent
            if (-not (Test-Path `$parentDir)) {
                New-Item -ItemType Directory -Path `$parentDir -Force | Out-Null
            }
            
            Copy-Item -LiteralPath `$file.FullName -Destination `$targetPath -Force
            `$copiedCount++
        }
        catch {
            Write-Log "ERROR: `$relativePath - `$(`$_.Exception.Message)"
        }
    }
    
    Write-Log "Copied: `$copiedCount, Skipped: `$skippedCount"
    
    if (Test-Path `$backupConfig) {
        Copy-Item -LiteralPath `$backupConfig -Destination (Join-Path '$AppRoot' 'config.json') -Force
        Write-Log 'Restored config.json'
    }
    
    Write-Log 'Cleaning up extracted folder...'
    Remove-Item -Path `$extractedFolder -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Log 'Restarting app...'
    `$exeLauncher = Join-Path '$AppRoot' 'ntchk.exe'
    if (Test-Path `$exeLauncher) {
        Start-Process -FilePath `$exeLauncher
    }
    
    Write-Log '=== Update completed successfully ==='
}
catch {
    Write-Log "CRITICAL ERROR: `$(`$_.Exception.Message)"
}

Write-Log 'Deleting updater script...'
Start-Sleep -Seconds 2
Remove-Item -LiteralPath `$MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
"@
        
        Set-Content -Path $updaterScript -Value $updaterCode -Encoding UTF8
        Add-Content -Path $debugLog -Value "Updater script created at: $updaterScript" -Force
        
        Add-Content -Path $debugLog -Value "=== Install-NcUpdate completed successfully ===" -Force
        
        return [pscustomobject]@{
            Success = $true
            Message = "Update to v$Version ready to install!"
            Error = $null
            UpdaterScript = $updaterScript
        }
    }
    catch {
        # Log error to app folder
        $debugLog = Join-Path $AppRoot "upgrade-debug.log"
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        
        try {
            Add-Content -Path $debugLog -Value "`n=== [$timestamp] Install-NcUpdate FAILED ===" -Force -ErrorAction Stop
            Add-Content -Path $debugLog -Value "Error: $($_.Exception.Message)" -Force -ErrorAction Stop
            Add-Content -Path $debugLog -Value "Error Type: $($_.Exception.GetType().FullName)" -Force -ErrorAction Stop
            Add-Content -Path $debugLog -Value "Stack Trace: $($_.ScriptStackTrace)" -Force -ErrorAction Stop
        }
        catch {
            [System.Windows.MessageBox]::Show("Critical error: $($_.Exception.Message)", 'Debug Error', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
        }
        
        # Cleanup extracted folder on error
        $extractedFolder = Join-Path $AppRoot "extracted"
        if (Test-Path $extractedFolder) {
            Add-Content -Path $debugLog -Value "Cleaning up extracted folder..." -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $extractedFolder -Recurse -Force -ErrorAction SilentlyContinue
            Add-Content -Path $debugLog -Value "Extracted folder deleted" -Force -ErrorAction SilentlyContinue
        }
        
        return [pscustomobject]@{
            Success = $false
            Message = "Update failed: $($_.Exception.Message)"
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

