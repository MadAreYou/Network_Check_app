function Get-NcSettings {
    param(
        [Parameter(Mandatory)] [string] $AppRoot
    )
    $configPath = Join-Path $AppRoot 'config.json'
    $cfg = $null
    if (Test-Path -LiteralPath $configPath) {
        try {
            $cfg = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
        } catch {
            $cfg = $null
        }
    }
    if (-not $cfg) {
        $defaultExport = Join-Path $AppRoot 'exports'
        $ooklaLocal = Join-Path $AppRoot 'speedtest.exe'
        $cliPath = if (Test-Path -LiteralPath $ooklaLocal) { $ooklaLocal } else { '' }
        $cfg = [pscustomobject]@{
            ExportFolder       = $defaultExport
            OoklaCLIPath       = $cliPath
            AutoExportMorningCheck = $false
            OoklaLicenseAccepted = $false
            DarkMode = $false
        }
        if (-not (Test-Path -LiteralPath $defaultExport)) { New-Item -ItemType Directory -Path $defaultExport -Force | Out-Null }
        $cfg | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding UTF8
    }
    else {
        # Backfill new settings when upgrading
        if (-not ($cfg.PSObject.Properties.Name -contains 'AutoExportMorningCheck')) {
            $cfg | Add-Member -NotePropertyName AutoExportMorningCheck -NotePropertyValue $false
        }
        if (-not ($cfg.PSObject.Properties.Name -contains 'OoklaCLIPath')) {
            $cfg | Add-Member -NotePropertyName OoklaCLIPath -NotePropertyValue ''
        }
        
        # Set default export folder if empty
        if ([string]::IsNullOrWhiteSpace($cfg.ExportFolder)) {
            $cfg.ExportFolder = Join-Path $AppRoot 'exports'
        }
        
        # Auto-detect Ookla CLI if path is empty
        $ooklaLocal = Join-Path $AppRoot 'speedtest.exe'
        if ((-not $cfg.OoklaCLIPath) -or [string]::IsNullOrWhiteSpace($cfg.OoklaCLIPath)) {
            if (Test-Path -LiteralPath $ooklaLocal) { $cfg.OoklaCLIPath = $ooklaLocal }
        }
        if (-not ($cfg.PSObject.Properties.Name -contains 'OoklaLicenseAccepted')) {
            $cfg | Add-Member -NotePropertyName OoklaLicenseAccepted -NotePropertyValue $false
        }
        if (-not ($cfg.PSObject.Properties.Name -contains 'DarkMode')) {
            $cfg | Add-Member -NotePropertyName DarkMode -NotePropertyValue $false
        }
        
        # Ensure export folder exists
        if (-not (Test-Path -LiteralPath $cfg.ExportFolder)) { 
            New-Item -ItemType Directory -Path $cfg.ExportFolder -Force | Out-Null 
        }
    }
    return $cfg
}

function Save-NcSettings {
    param(
        [Parameter(Mandatory)] [string] $AppRoot,
        [Parameter(Mandatory)] $Settings
    )
    $configPath = Join-Path $AppRoot 'config.json'
    $Settings | ConvertTo-Json | Set-Content -LiteralPath $configPath -Encoding UTF8
}
