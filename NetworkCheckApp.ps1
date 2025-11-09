#requires -Version 5.1
# Ensure STA for WPF
try {
    if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne [System.Threading.ApartmentState]::STA) {
        $args = @('-STA','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
        Start-Process -FilePath powershell.exe -ArgumentList $args | Out-Null
        exit
    }
} catch {}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Load WPF
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$Script:AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:AllowClose = $false
$Script:KeepAliveUntil = [DateTime]::UtcNow.AddMinutes(3)

# Dot-source modules
. "$Script:AppRoot\src\Settings.ps1"
. "$Script:AppRoot\src\Export.ps1"
. "$Script:AppRoot\src\NetworkInfo.ps1"
. "$Script:AppRoot\src\Diagnostics.ps1"
. "$Script:AppRoot\src\SpeedTest.ps1"
. "$Script:AppRoot\src\Update.ps1"

# Ensure export folder exists per settings
$Script:Settings = Get-NcSettings -AppRoot $Script:AppRoot
if (-not (Test-Path -LiteralPath $Script:Settings.ExportFolder)) {
    New-Item -ItemType Directory -Path $Script:Settings.ExportFolder -Force | Out-Null
}

# Load XAML
[xml]$xaml = Get-Content -LiteralPath "$Script:AppRoot\ui\MainWindow.xaml" -Raw
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Global exception handlers so UI errors don't silently close the app
try {
    $logPath = Join-Path $Script:AppRoot 'ui-error.log'
    $engineLog = Join-Path $Script:AppRoot 'engine.log'
    [System.AppDomain]::CurrentDomain.add_UnhandledException({ param($s,$e)
        try { Add-Content -LiteralPath $logPath -Value ("[AppDomain] " + (Get-Date).ToString('o') + " " + ($e.ExceptionObject | Out-String)) } catch {}
    })
    [System.AppDomain]::CurrentDomain.add_ProcessExit({ param($s,$e)
        try { Add-Content -LiteralPath $engineLog -Value ('[' + (Get-Date).ToString('o') + '] ProcessExit: host shutting down') } catch {}
    })
    $handler = [System.Windows.Threading.DispatcherUnhandledExceptionEventHandler]{ param($s,$e)
        try {
            Add-Content -LiteralPath $logPath -Value ("[Dispatcher] " + (Get-Date).ToString('o') + " " + ($e.Exception | Out-String))
        } catch {}
        try { [System.Windows.MessageBox]::Show("Unexpected error: " + $e.Exception.Message, 'Network Check', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null } catch {}
        $e.Handled = $true
    }
    $window.Dispatcher.add_UnhandledException($handler)
} catch {}

function Get-Control($name) {
    return $window.FindName($name)
}

# Cache controls (Speed Test)
$btnRunSpeed         = Get-Control 'btnRunSpeed'
$btnStopSpeed        = Get-Control 'btnStopSpeed'
$btnExportSpeed      = Get-Control 'btnExportSpeed'
$btnCopySpeed        = Get-Control 'btnCopySpeed'
$lblPing             = Get-Control 'lblPing'
$lblDownload         = Get-Control 'lblDownload'
$lblUpload           = Get-Control 'lblUpload'
$lblDownloadSpinner  = Get-Control 'lblDownloadSpinner'
$lblUploadSpinner    = Get-Control 'lblUploadSpinner'
$lblDownloadStatus   = Get-Control 'lblDownloadStatus'
$lblUploadStatus     = Get-Control 'lblUploadStatus'
$lblDownloadLatency  = Get-Control 'lblDownloadLatency'
$lblUploadLatency    = Get-Control 'lblUploadLatency'
$lblIsp              = Get-Control 'lblIsp'
$lblServer           = Get-Control 'lblServer'
$lblPacketLoss       = Get-Control 'lblPacketLoss'
$rotateDownload      = Get-Control 'rotateDownload'
$rotateUpload        = Get-Control 'rotateUpload'
$lblEngine           = Get-Control 'lblEngine'
$txtSpeedLog         = Get-Control 'txtSpeedLog'

# Cache controls (Network Info)
$btnRefreshInfo   = Get-Control 'btnRefreshInfo'
$btnCopyInfo      = Get-Control 'btnCopyInfo'
$btnExportInfo    = Get-Control 'btnExportInfo'
$spinnerNetworkInfo = Get-Control 'spinnerNetworkInfo'
$rotateNetworkInfo  = Get-Control 'rotateNetworkInfo'
$lblNetworkInfoStatus = Get-Control 'lblNetworkInfoStatus'
$lblLastRefreshed = Get-Control 'lblLastRefreshed'
$txtSSID          = Get-Control 'txtSSID'
$txtLanIP         = Get-Control 'txtLanIP'
$txtGateway       = Get-Control 'txtGateway'
$txtDHCP          = Get-Control 'txtDHCP'
$txtDNS           = Get-Control 'txtDNS'
$txtMAC           = Get-Control 'txtMAC'
$txtHostname      = Get-Control 'txtHostname'
$txtPublicIP      = Get-Control 'txtPublicIP'
$txtISP           = Get-Control 'txtISP'

# Cache controls (Diagnostics)
$txtPingTarget    = Get-Control 'txtPingTarget'
$btnRunPing       = Get-Control 'btnRunPing'
$btnCancelPing    = Get-Control 'btnCancelPing'
$spinnerPing      = Get-Control 'spinnerPing'
$lblPingStatus    = Get-Control 'lblPingStatus'
$rotatePing       = Get-Control 'rotatePing'
$txtLookupTarget  = Get-Control 'txtLookupTarget'
$btnRunLookup     = Get-Control 'btnRunLookup'
$btnCancelLookup  = Get-Control 'btnCancelLookup'
$spinnerLookup    = Get-Control 'spinnerLookup'
$lblLookupStatus  = Get-Control 'lblLookupStatus'
$rotateLookup     = Get-Control 'rotateLookup'
$txtTraceTarget   = Get-Control 'txtTraceTarget'
$btnRunTrace      = Get-Control 'btnRunTrace'
$btnCancelTrace   = Get-Control 'btnCancelTrace'
$spinnerTrace     = Get-Control 'spinnerTrace'
$lblTraceStatus   = Get-Control 'lblTraceStatus'
$rotateTrace      = Get-Control 'rotateTrace'
$btnFlushDNS      = Get-Control 'btnFlushDNS'
$btnReleaseRenew  = Get-Control 'btnReleaseRenew'
$btnWinsockReset  = Get-Control 'btnWinsockReset'
$btnClearARP      = Get-Control 'btnClearARP'
$txtDiagOutput    = Get-Control 'txtDiagOutput'
$btnCopyDiag      = Get-Control 'btnCopyDiag'
$btnExportDiag    = Get-Control 'btnExportDiag'

# Cache controls (Settings)
$txtExportFolder  = Get-Control 'txtExportFolder'
$btnBrowseExport  = Get-Control 'btnBrowseExport'
$txtCliPath       = Get-Control 'txtCliPath'
$btnBrowseCli     = Get-Control 'btnBrowseCli'
$btnSaveSettings  = Get-Control 'btnSaveSettings'
$chkAutoExport    = Get-Control 'chkAutoExport'
$chkCheckUpdates  = Get-Control 'chkCheckUpdates'
$rbLightMode      = Get-Control 'rbLightMode'
$rbDarkMode       = Get-Control 'rbDarkMode'
$btnCreateShortcut = Get-Control 'btnCreateShortcut'
$btnRemoveShortcut = Get-Control 'btnRemoveShortcut'
$btnCheckUpdates   = Get-Control 'btnCheckUpdates'
$lblCurrentVersion = Get-Control 'lblCurrentVersion'

# Cache controls (Footer & Contact)
$lnkContact       = Get-Control 'lnkContact'
$contactOverlay   = Get-Control 'contactOverlay'
$btnCloseContact  = Get-Control 'btnCloseContact'
$lnkEmail         = Get-Control 'lnkEmail'
$lnkLinkedIn      = Get-Control 'lnkLinkedIn'
$imgQRCode        = Get-Control 'imgQRCode'
$txtRevolutTag    = Get-Control 'txtRevolutTag'

# Cache controls (Update Popup)
$updateOverlay      = Get-Control 'updateOverlay'
$btnCloseUpdate     = Get-Control 'btnCloseUpdate'
$lblInstalledVersion = Get-Control 'lblInstalledVersion'
$lblNewVersion      = Get-Control 'lblNewVersion'
$lblUpdateStatus    = Get-Control 'lblUpdateStatus'
$btnUpgrade         = Get-Control 'btnUpgrade'
$btnLater           = Get-Control 'btnLater'

# Load QR code image if it exists
$qrCodePath = Join-Path $Script:AppRoot 'assets\revolut_qr.png'
if (Test-Path $qrCodePath) {
    $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
    $bitmap.BeginInit()
    $bitmap.UriSource = New-Object System.Uri($qrCodePath, [System.UriKind]::Absolute)
    $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $bitmap.EndInit()
    $imgQRCode.Source = $bitmap
}

# Initialize settings into UI
$txtExportFolder.Text = $Script:Settings.ExportFolder
$txtCliPath.Text      = $Script:Settings.OoklaCLIPath
$chkAutoExport.IsChecked = [bool]$Script:Settings.AutoExportMorningCheck
$chkCheckUpdates.IsChecked = [bool]$Script:Settings.CheckUpdatesOnStartup

# Display current version
$currentVersion = Get-NcCurrentVersion -AppRoot $Script:AppRoot
$lblCurrentVersion.Text = "Current version: v$currentVersion"

# Load theme preference
if ($Script:Settings.PSObject.Properties['DarkMode']) {
    if ($Script:Settings.DarkMode) {
        $rbDarkMode.IsChecked = $true
    } else {
        $rbLightMode.IsChecked = $true
    }
}

# Helper: show which engine will be used (simplified - always shows "Powered by Ookla Speedtest")
function Set-EngineLabel {
    $ooklaLocal = Join-Path $Script:AppRoot 'speedtest.exe'
    $cliPath = $Script:Settings.OoklaCLIPath
    
    # Check if Ookla CLI is available
    $hasOokla = (Test-Path -LiteralPath $ooklaLocal) -or 
                (-not [string]::IsNullOrWhiteSpace($cliPath) -and (Test-Path -LiteralPath $cliPath))
    
    if (-not $hasOokla) {
        try {
            $ok = Get-Command speedtest -ErrorAction SilentlyContinue
            $hasOokla = $null -ne $ok
        } catch {}
    }
    
    if ($hasOokla) {
        $lblEngine.Text = 'Powered by Ookla Speedtest'
        $lblEngine.Foreground = [System.Windows.Media.Brushes]::DarkGreen
    } else {
        $lblEngine.Text = 'Ookla Speedtest CLI not found'
        $lblEngine.Foreground = [System.Windows.Media.Brushes]::DarkRed
    }
}
Set-EngineLabel

# Helper: set status labels
function Reset-SpeedUi {
    $lblPing.Text = 'Ping: -- ms'
    $lblDownload.Text = '-- Mbps'
    $lblUpload.Text = '-- Mbps'
    $lblDownloadLatency.Text = '--'
    $lblUploadLatency.Text = '--'
    $lblIsp.Text = '--'
    $lblServer.Text = '--'
    $lblPacketLoss.Text = '--'
    $lblDownloadSpinner.Visibility = 'Collapsed'
    $lblUploadSpinner.Visibility = 'Collapsed'
    $lblDownloadStatus.Visibility = 'Collapsed'
    $lblUploadStatus.Visibility = 'Collapsed'
    if ($txtSpeedLog) { $txtSpeedLog.Text = 'Speed test log will appear here.' }
}

Reset-SpeedUi

# Dark Mode Theme Switcher
function Set-Theme {
    param([bool]$IsDark)
    
    if ($IsDark) {
        # Dark Mode Colors
        $window.Resources['WindowBackground'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(30, 30, 30))
        $window.Resources['ContentBackground'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(45, 45, 45))
        $window.Resources['TextPrimary'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(230, 230, 230))
        $window.Resources['TextSecondary'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(170, 170, 170))
        $window.Resources['BorderBrush'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(70, 70, 70))
        $window.Resources['TabBackground'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(45, 45, 45))
        $window.Resources['FooterBackground'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(35, 35, 35))
    } else {
        # Light Mode Colors
        $window.Resources['WindowBackground'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(245, 245, 245))
        $window.Resources['ContentBackground'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(255, 255, 255))
        $window.Resources['TextPrimary'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(33, 33, 33))
        $window.Resources['TextSecondary'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(117, 117, 117))
        $window.Resources['BorderBrush'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(224, 224, 224))
        $window.Resources['TabBackground'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(255, 255, 255))
        $window.Resources['FooterBackground'] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(238, 238, 238))
    }
}

# Apply saved theme on startup
if ($Script:Settings.PSObject.Properties['DarkMode'] -and $Script:Settings.DarkMode) {
    Set-Theme -IsDark $true
}

# Wire theme toggle events
$rbLightMode.Add_Checked({ Set-Theme -IsDark $false })
$rbDarkMode.Add_Checked({ Set-Theme -IsDark $true })

# Contact popup handlers
$lnkContact.Add_Click({
    $contactOverlay.Visibility = 'Visible'
})

$btnCloseContact.Add_Click({
    $contactOverlay.Visibility = 'Collapsed'
})

# Close popup when clicking outside (on overlay)
$contactOverlay.Add_MouseDown({
    param($sender, $e)
    if ($e.OriginalSource -eq $contactOverlay) {
        $contactOverlay.Visibility = 'Collapsed'
    }
})

# Handle hyperlink navigation (email and LinkedIn)
$lnkEmail.Add_Click({
    try {
        Start-Process "mailto:juraj@madzo.eu"
    } catch {}
})

$lnkLinkedIn.Add_Click({
    try {
        Start-Process "https://linkedin.com/in/juraj-madzunkov-457389104"
    } catch {}
})

# Wire Speed Test events
$Script:SpeedJob = $null

# Spinner animation timer (smooth rotation)
$spinnerTimer = New-Object System.Windows.Threading.DispatcherTimer
$spinnerTimer.Interval = [TimeSpan]::FromMilliseconds(30)  # Faster = smoother
$Script:SpinnerAngle = 0
$spinnerTimer.add_Tick({
    $Script:SpinnerAngle += 12  # 12 degrees per tick = 360° in ~1 second
    if ($Script:SpinnerAngle -ge 360) { $Script:SpinnerAngle = 0 }
    $rotateDownload.Angle = $Script:SpinnerAngle
    $rotateUpload.Angle = $Script:SpinnerAngle
})

# Diagnostics spinner timer (same rotation for all diagnostics spinners)
$diagSpinnerTimer = New-Object System.Windows.Threading.DispatcherTimer
$diagSpinnerTimer.Interval = [TimeSpan]::FromMilliseconds(30)
$Script:DiagSpinnerAngle = 0
$diagSpinnerTimer.add_Tick({
    $Script:DiagSpinnerAngle += 12
    if ($Script:DiagSpinnerAngle -ge 360) { $Script:DiagSpinnerAngle = 0 }
    $rotatePing.Angle = $Script:DiagSpinnerAngle
    $rotateLookup.Angle = $Script:DiagSpinnerAngle
    $rotateTrace.Angle = $Script:DiagSpinnerAngle
})

# Network Info spinner timer
$netInfoSpinnerTimer = New-Object System.Windows.Threading.DispatcherTimer
$netInfoSpinnerTimer.Interval = [TimeSpan]::FromMilliseconds(30)
$Script:NetInfoSpinnerAngle = 0
$netInfoSpinnerTimer.add_Tick({
    $Script:NetInfoSpinnerAngle += 12
    if ($Script:NetInfoSpinnerAngle -ge 360) { $Script:NetInfoSpinnerAngle = 0 }
    $rotateNetworkInfo.Angle = $Script:NetInfoSpinnerAngle
})

# Load initial Network Info
$Script:IsRefreshingNetInfo = $false
$Script:NetInfoRunspace = $null

function Refresh-NetworkInfoUi {
    try {
        # If already refreshing, don't start another refresh
        if ($Script:IsRefreshingNetInfo) {
            return
        }
        
        $Script:IsRefreshingNetInfo = $true
        
        # Show spinner and status
        $spinnerNetworkInfo.Visibility = 'Visible'
        $lblNetworkInfoStatus.Visibility = 'Visible'
        $lblNetworkInfoStatus.Text = 'Refreshing...'
        $btnRefreshInfo.IsEnabled = $false
        $netInfoSpinnerTimer.Start()
        
        # Create a runspace for true async execution
        $runspace = [runspacefactory]::CreateRunspace()
        $runspace.ApartmentState = "STA"
        $runspace.ThreadOptions = "ReuseThread"
        $runspace.Open()
        
        # Create PowerShell instance
        $ps = [powershell]::Create()
        $ps.Runspace = $runspace
        
        # Pass the script root path to the runspace
        $scriptPath = Join-Path $PSScriptRoot "src\NetworkInfo.ps1"
        
        # Add script to run
        $ps.AddScript({
            param($networkInfoPath)
            
            # Source NetworkInfo functions
            . $networkInfoPath
            
            # Get network snapshot
            return Get-NcNetworkSnapshot
        }) | Out-Null
        
        $ps.AddArgument($scriptPath) | Out-Null
        
        # Store runspace reference
        $Script:NetInfoRunspace = @{
            PowerShell = $ps
            Runspace = $runspace
            Handle = $ps.BeginInvoke()
        }
        
        # Set up polling timer to check when runspace completes
        $pollTimer = New-Object System.Windows.Threading.DispatcherTimer
        $pollTimer.Interval = [TimeSpan]::FromMilliseconds(100)
        $pollTimer.Add_Tick({
            param($timerSender, $timerArgs)
            
            if ($Script:NetInfoRunspace.Handle.IsCompleted) {
                $timerSender.Stop()
                
                try {
                    # Get results from runspace
                    $results = $Script:NetInfoRunspace.PowerShell.EndInvoke($Script:NetInfoRunspace.Handle)
                    
                    # Check for errors in the runspace
                    if ($Script:NetInfoRunspace.PowerShell.Streams.Error.Count -gt 0) {
                        Write-Host "Runspace errors:"
                        $Script:NetInfoRunspace.PowerShell.Streams.Error | ForEach-Object {
                            Write-Host "  $_"
                        }
                    }
                    
                    # Cleanup runspace
                    $Script:NetInfoRunspace.PowerShell.Dispose()
                    $Script:NetInfoRunspace.Runspace.Dispose()
                    $Script:NetInfoRunspace = $null
                    
                    # Get the first result (should be the network snapshot object)
                    $info = if ($results -is [array]) { $results[0] } else { $results }
                    
                    # Update UI with results (if we got valid data and it has the expected properties)
                    if ($info -and $info.PSObject.Properties['SSID']) {
                        $txtSSID.Text = if ($info.SSID) { $info.SSID } else { '' }
                        $txtLanIP.Text = if ($info.LANIP) { $info.LANIP } else { '' }
                        $txtGateway.Text = if ($info.PSObject.Properties['Gateway']) { $info.Gateway } else { '' }
                        $txtDHCP.Text = if ($info.DHCP) { $info.DHCP } else { '' }
                        $txtDNS.Text = if ($info.DNS) { ($info.DNS -join ", ") } else { '' }
                        $txtMAC.Text = if ($info.MAC) { $info.MAC } else { '' }
                        $txtHostname.Text = if ($info.Hostname) { $info.Hostname } else { '' }
                        $txtPublicIP.Text = if ($info.PublicIP) { $info.PublicIP } else { '' }
                        $txtISP.Text = if ($info.ISP) { $info.ISP } else { '' }
                        $window.Tag = $info
                        
                        # Update last refreshed time
                        $refreshTime = Get-Date -Format "HH:mm:ss"
                        $lblLastRefreshed.Text = "Last refreshed: $refreshTime"
                    } else {
                        Write-Host "Network info: No valid data returned from runspace"
                        Write-Host "Results type: $($results.GetType().FullName)"
                        Write-Host "Results count: $($results.Count)"
                        if ($info) {
                            Write-Host "Info properties: $($info.PSObject.Properties.Name -join ', ')"
                        }
                    }
                }
                catch {
                    Write-Host "Network info error: $($_.Exception.Message)"
                    Write-Host "Stack trace: $($_.ScriptStackTrace)"
                }
                finally {
                    # Hide spinner and status
                    $spinnerNetworkInfo.Visibility = 'Collapsed'
                    $lblNetworkInfoStatus.Visibility = 'Collapsed'
                    $btnRefreshInfo.IsEnabled = $true
                    $netInfoSpinnerTimer.Stop()
                    $Script:IsRefreshingNetInfo = $false
                }
            }
        })
        $pollTimer.Start()
    }
    catch {
        $spinnerNetworkInfo.Visibility = 'Collapsed'
        $lblNetworkInfoStatus.Visibility = 'Collapsed'
        $btnRefreshInfo.IsEnabled = $true
        $netInfoSpinnerTimer.Stop()
        $Script:IsRefreshingNetInfo = $false
        [System.Windows.MessageBox]::Show("Failed to start network info refresh: $($_.Exception.Message)", 'Network Check', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
    }
}

Refresh-NetworkInfoUi

# Check for updates on startup (if enabled)
if ($Script:Settings.CheckUpdatesOnStartup) {
    # Run update check asynchronously to not block UI
    $updateCheckJob = Start-Job -ScriptBlock {
        param($appRoot)
        # Source the Update module
        . "$appRoot\src\Update.ps1"
        # Check for updates
        return Test-NcUpdateAvailable -AppRoot $appRoot
    } -ArgumentList $Script:AppRoot
    
    # Poll for update check completion
    $updateCheckTimer = New-Object System.Windows.Threading.DispatcherTimer
    $updateCheckTimer.Interval = [TimeSpan]::FromMilliseconds(500)
    $updateCheckTimer.Add_Tick({
        param($timerSender, $timerArgs)
        
        if ($updateCheckJob.State -eq 'Completed') {
            $timerSender.Stop()
            
            try {
                $updateInfo = Receive-Job -Job $updateCheckJob
                Remove-Job -Job $updateCheckJob -Force
                
                if ($updateInfo -and $updateInfo.UpdateAvailable) {
                    # Show update popup
                    $lblInstalledVersion.Text = "v$($updateInfo.CurrentVersion)"
                    $lblNewVersion.Text = "v$($updateInfo.LatestVersion)"
                    $lblUpdateStatus.Text = ""
                    
                    # Store release info for later use
                    $window.Resources['UpdateInfo'] = $updateInfo
                    
                    # Show popup
                    $updateOverlay.Visibility = 'Visible'
                }
                
                # Update last check time
                $Script:Settings.LastUpdateCheck = (Get-Date).ToString('o')
                Save-NcSettings -AppRoot $Script:AppRoot -Settings $Script:Settings
            }
            catch {
                Write-Host "Update check error: $($_.Exception.Message)"
            }
        }
        elseif ($updateCheckJob.State -eq 'Failed') {
            $timerSender.Stop()
            Remove-Job -Job $updateCheckJob -Force -ErrorAction SilentlyContinue
        }
    })
    $updateCheckTimer.Start()
}

# Job monitor timer
$jobMonitor = New-Object System.Windows.Threading.DispatcherTimer
$jobMonitor.Interval = [TimeSpan]::FromMilliseconds(250)
$jobMonitor.add_Tick({
    if ($null -eq $Script:SpeedJob) { $jobMonitor.Stop(); return }

    # Check for job failure
    if ($Script:SpeedJob.State -eq 'Failed') {
        $jobMonitor.Stop()
        # Read the actual error from the job's error stream
        $errorMsg = "The speed test job failed unexpectedly."
        if ($Script:SpeedJob.Error.Count -gt 0) {
            # Access the exception from the ErrorRecord
            $errorRecord = $Script:SpeedJob.Error[0]
            $errorMsg += " Reason: $($errorRecord.Exception.Message)"
        }
        $txtSpeedLog.AppendText("`r`nJOB FAILED: $errorMsg`r`n")
        $txtSpeedLog.ScrollToEnd()
        [System.Windows.MessageBox]::Show($errorMsg, "Job Error", 'OK', 'Error') | Out-Null
        $btnRunSpeed.IsEnabled = $true
        Remove-Job -Job $Script:SpeedJob -Force
        $Script:SpeedJob = $null
        return
    }

    $results = Receive-Job -Job $Script:SpeedJob -Keep
    foreach ($r in $results) {
        switch ($r.Type) {
            'log' {
                if ($txtSpeedLog -and $r.Data) {
                    # Only show start and finish messages
                    if ($r.Data -match '^Running|^Test finished|failed|Error|ERROR') {
                        $txtSpeedLog.AppendText("$($r.Data)`r`n")
                        $txtSpeedLog.ScrollToEnd()
                    }
                }
            }
            'progress' {
                $stage = $r.Data.Stage
                switch ($stage) {
                    'download' { 
                        if ($lblDownloadSpinner.Visibility -eq 'Collapsed') {
                            $lblDownloadSpinner.Visibility = 'Visible'
                            $lblDownloadStatus.Visibility = 'Visible'
                            $txtSpeedLog.AppendText("Test ongoing...`r`n")
                            $txtSpeedLog.ScrollToEnd()
                        }
                    }
                    'upload' { 
                        $lblDownloadSpinner.Visibility = 'Collapsed'
                        $lblDownloadStatus.Visibility = 'Collapsed'
                        $lblUploadSpinner.Visibility = 'Visible'
                        $lblUploadStatus.Visibility = 'Visible'
                    }
                }
            }
            'complete' {
                # Hide spinners
                $lblDownloadSpinner.Visibility = 'Collapsed'
                $lblDownloadStatus.Visibility = 'Collapsed'
                $lblUploadSpinner.Visibility = 'Collapsed'
                $lblUploadStatus.Visibility = 'Collapsed'
                
                # Calculate duration and show completion message
                $endTime = Get-Date
                $startTime = $window.Resources['TestStartTime']
                if ($startTime) {
                    $duration = ($endTime - $startTime).TotalSeconds
                    $endTimeStr = $endTime.ToString("HH:mm:ss")
                    $txtSpeedLog.AppendText("Test finished at $endTimeStr (duration: $([math]::Round($duration,1))s)`r`n")
                    $txtSpeedLog.ScrollToEnd()
                }
                
                # Final update with REAL values
                $result = $r.Data
                if ($null -ne $result) {
                    if ($result.PingMs)    { $lblPing.Text = "Ping: $([math]::Round($result.PingMs,2)) ms" }
                    if ($result.DownloadMbpsAvg) { $lblDownload.Text = "$([math]::Round($result.DownloadMbpsAvg,2)) Mbps" }
                    if ($result.UploadMbpsAvg)   { $lblUpload.Text = "$([math]::Round($result.UploadMbpsAvg,2)) Mbps" }
                    
                    # New fields - real values from Ookla JSON
                    if ($result.DownloadLatencyIqm) { $lblDownloadLatency.Text = "$([math]::Round($result.DownloadLatencyIqm,2)) ms" }
                    if ($result.UploadLatencyIqm)   { $lblUploadLatency.Text = "$([math]::Round($result.UploadLatencyIqm,2)) ms" }
                    if ($result.Isp)                { $lblIsp.Text = $result.Isp }
                    if ($result.Server)             { $lblServer.Text = $result.Server }
                    if ($result.PacketLoss -ne $null) { $lblPacketLoss.Text = "$($result.PacketLoss)%" }
                    
                    $window.Resources['LastSpeedResult'] = $result
                } else {
                    # Handle null result (test failed)
                    $txtSpeedLog.AppendText("`r`n[ERROR] Speed test completed but returned no valid result. Check engine.log for details.`r`n")
                    $txtSpeedLog.ScrollToEnd()
                    [System.Windows.MessageBox]::Show("Speed test failed to produce valid results. The speedtest.exe may have encountered an error. Check the log for details.", 'Speed Test Error', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
                }
                
                # Re-enable buttons and clean up (always do this, even on failure)
                $btnRunSpeed.IsEnabled = $true
                $jobMonitor.Stop()
                $spinnerTimer.Stop()
                Remove-Job -Job $Script:SpeedJob -Force
                $Script:SpeedJob = $null
            }
        }
    }
})

$btnRunSpeed.Add_Click({
    try {
        Add-Content -LiteralPath (Join-Path $Script:AppRoot 'engine.log') -Value ('[' + (Get-Date).ToString('o') + '] UI: Run Speed clicked')
        Reset-SpeedUi
        $Script:Settings = Get-NcSettings -AppRoot $Script:AppRoot
        Set-EngineLabel
        
        if ($Script:SpeedJob) { Stop-NcSpeedTest -Job $Script:SpeedJob; $Script:SpeedJob = $null }
        if (-not $Script:Settings.OoklaLicenseAccepted) {
            $resp = [System.Windows.MessageBox]::Show('To run Ookla Speedtest, we need to accept the license and GDPR on your behalf. Proceed?','Ookla License',[System.Windows.MessageBoxButton]::YesNo,[System.Windows.MessageBoxImage]::Information)
            if ($resp -ne [System.Windows.MessageBoxResult]::Yes) { return }
            $r = Accept-NcOoklaLicense -AppRoot $Script:AppRoot -Settings $Script:Settings
            if (-not $r.Success) {
                [System.Windows.MessageBox]::Show("License acceptance failed: $($r.Error)", 'Ookla License', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
                return
            }
            $Script:Settings.OoklaLicenseAccepted = $true
            Save-NcSettings -AppRoot $Script:AppRoot -Settings $Script:Settings
        }
        
        $btnRunSpeed.IsEnabled = $false
        $window.Resources['IsMorningCheck'] = $false
        $window.Resources['TestStartTime'] = Get-Date
        Reset-SpeedUi
        $startTime = Get-Date -Format "HH:mm:ss"
        $txtSpeedLog.Text = "Speedtest started at $startTime`r`n"

        $Script:SpeedJob = Start-NcSpeedTest -AppRoot $Script:AppRoot -Settings $Script:Settings
        $jobMonitor.Start()
        $spinnerTimer.Start()
    }
    catch {
        $btnRunSpeed.IsEnabled = $true
        $btnMorningCheck.IsEnabled = $true
        [System.Windows.MessageBox]::Show("Failed to start speed test: $($_.Exception.Message)", 'Speed Test', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
    }
})

$btnStopSpeed.Add_Click({
    try { 
        if ($Script:SpeedJob) {
            Stop-NcSpeedTest -Job $Script:SpeedJob 
            $Script:SpeedJob = $null
            $jobMonitor.Stop()
            $btnRunSpeed.IsEnabled = $true
            $btnMorningCheck.IsEnabled = $true
            Add-Content -LiteralPath (Join-Path $Script:AppRoot 'engine.log') -Value ('[' + (Get-Date).ToString('o') + '] UI: Test stopped by user.')
        }
    } catch {}
})

$btnExportSpeed.Add_Click({
    try {
        $speed = $window.Resources['LastSpeedResult']
        if (-not $speed) { [System.Windows.MessageBox]::Show('No speed test result to export yet.', 'Export', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null; return }
        $pathJson = Export-NcJson -Object $speed -ExportFolder $Script:Settings.ExportFolder -BaseName "speedtest_$(Get-Date -Format yyyyMMdd_HHmmss)"
        [System.Windows.MessageBox]::Show("Exported: $pathJson", 'Export', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
    }
    catch {
        [System.Windows.MessageBox]::Show("Export failed: $($_.Exception.Message)", 'Export', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
    }
})

# Morning Check button removed - using Run button only

$btnCopySpeed.Add_Click({
    try {
        $speed = $window.Resources['LastSpeedResult']
        if (-not $speed) { [System.Windows.MessageBox]::Show('No speed test result to copy yet.', 'Copy', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null; return }
        Copy-NcText ( ($speed | ConvertTo-Json -Depth 5) )
    }
    catch {}
})

## Removed Run in Console button per request

# Wire Network Info events
$btnRefreshInfo.Add_Click({ 
    Refresh-NetworkInfoUi
})
$btnCopyInfo.Add_Click({
    try {
        $info = $window.Tag
        if ($null -eq $info) { return }
        Copy-NcText ($info | ConvertTo-Json -Depth 5)
    } catch {}
})
$btnExportInfo.Add_Click({
    try {
        $info = $window.Tag
        if ($null -eq $info) { return }
        $path = Export-NcJson -Object $info -ExportFolder $Script:Settings.ExportFolder -BaseName "network_$(Get-Date -Format yyyyMMdd_HHmmss)"
        [System.Windows.MessageBox]::Show("Exported: $path", 'Export', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
    } catch {}
})

# Diagnostics job tracking
$Script:DiagJob = $null
$Script:DiagType = $null

# Diagnostics job monitor
$diagJobMonitor = New-Object System.Windows.Threading.DispatcherTimer
$diagJobMonitor.Interval = [TimeSpan]::FromMilliseconds(250)
$diagJobMonitor.add_Tick({
    if ($null -eq $Script:DiagJob) { $diagJobMonitor.Stop(); return }
    
    try {
        $jobState = $Script:DiagJob.State
        
        if ($jobState -eq 'Completed') {
            $result = Receive-Job -Job $Script:DiagJob
            $txtDiagOutput.Text = $result
            Remove-Job -Job $Script:DiagJob -Force
            $Script:DiagJob = $null
            
            # Hide spinners and enable buttons based on type
            switch ($Script:DiagType) {
                'ping' {
                    $btnRunPing.IsEnabled = $true
                    $spinnerPing.Visibility = 'Collapsed'
                    $lblPingStatus.Visibility = 'Collapsed'
                    $btnCancelPing.Visibility = 'Collapsed'
                }
                'lookup' {
                    $btnRunLookup.IsEnabled = $true
                    $spinnerLookup.Visibility = 'Collapsed'
                    $lblLookupStatus.Visibility = 'Collapsed'
                    $btnCancelLookup.Visibility = 'Collapsed'
                }
                'trace' {
                    $btnRunTrace.IsEnabled = $true
                    $spinnerTrace.Visibility = 'Collapsed'
                    $lblTraceStatus.Visibility = 'Collapsed'
                    $btnCancelTrace.Visibility = 'Collapsed'
                }
            }
            $diagSpinnerTimer.Stop()
            $diagJobMonitor.Stop()
        }
        elseif ($jobState -eq 'Failed') {
            $txtDiagOutput.Text = "Operation failed."
            Remove-Job -Job $Script:DiagJob -Force
            $Script:DiagJob = $null
            $diagJobMonitor.Stop()
            $diagSpinnerTimer.Stop()
        }
        elseif ($jobState -eq 'Running') {
            # For traceroute, show live output
            if ($Script:DiagType -eq 'trace') {
                $liveOutput = Receive-Job -Job $Script:DiagJob -Keep
                if ($liveOutput) {
                    $txtDiagOutput.Text = $liveOutput
                }
            }
        }
    } catch {
        # Silently handle any job state errors
    }
})

# Wire Diagnostics
$btnRunPing.Add_Click({
    $target = if ([string]::IsNullOrWhiteSpace($txtPingTarget.Text)) { '1.1.1.1' } else { $txtPingTarget.Text }
    $btnRunPing.IsEnabled = $false
    $spinnerPing.Visibility = 'Visible'
    $lblPingStatus.Visibility = 'Visible'
    $btnCancelPing.Visibility = 'Visible'
    $diagSpinnerTimer.Start()
    $txtDiagOutput.Text = "Running ping to $target..."
    
    $Script:DiagType = 'ping'
    $Script:DiagJob = Start-Job -ScriptBlock {
        param($t)
        ping.exe -n 4 $t 2>&1 | Out-String
    } -ArgumentList $target
    $diagJobMonitor.Start()
})

$btnRunLookup.Add_Click({
    $domain = if ([string]::IsNullOrWhiteSpace($txtLookupTarget.Text)) { 'example.com' } else { $txtLookupTarget.Text }
    $btnRunLookup.IsEnabled = $false
    $spinnerLookup.Visibility = 'Visible'
    $lblLookupStatus.Visibility = 'Visible'
    $btnCancelLookup.Visibility = 'Visible'
    $diagSpinnerTimer.Start()
    $txtDiagOutput.Text = "Looking up $domain..."
    
    $Script:DiagType = 'lookup'
    $Script:DiagJob = Start-Job -ScriptBlock {
        param($d)
        try {
            $result = Resolve-DnsName -Name $d -ErrorAction Stop
            $output = "Name:    $d`r`n`r`n"
            foreach ($r in $result) {
                if ($r.Type -eq 'A') {
                    $output += "Address: $($r.IPAddress)`r`n"
                }
                elseif ($r.Type -eq 'AAAA') {
                    $output += "Address: $($r.IPAddress) (IPv6)`r`n"
                }
                elseif ($r.Type -eq 'CNAME') {
                    $output += "Alias:   $($r.NameHost)`r`n"
                }
            }
            return $output
        } catch {
            return "DNS lookup failed: $($_.Exception.Message)"
        }
    } -ArgumentList $domain
    $diagJobMonitor.Start()
})

$btnRunTrace.Add_Click({
    $target = if ([string]::IsNullOrWhiteSpace($txtTraceTarget.Text)) { '1.1.1.1' } else { $txtTraceTarget.Text }
    $btnRunTrace.IsEnabled = $false
    $spinnerTrace.Visibility = 'Visible'
    $lblTraceStatus.Visibility = 'Visible'
    $btnCancelTrace.Visibility = 'Visible'
    $diagSpinnerTimer.Start()
    $txtDiagOutput.Text = "Tracing route to $target...`r`n"
    
    $Script:DiagType = 'trace'
    $Script:DiagJob = Start-Job -ScriptBlock {
        param($t)
        tracert.exe $t 2>&1 | Out-String
    } -ArgumentList $target
    $diagJobMonitor.Start()
})

# Cancel buttons
$btnCancelPing.Add_Click({
    if ($Script:DiagJob -and $Script:DiagType -eq 'ping') {
        Stop-Job -Job $Script:DiagJob
        Remove-Job -Job $Script:DiagJob -Force
        $Script:DiagJob = $null
        $txtDiagOutput.Text = "Ping cancelled by user."
        $btnRunPing.IsEnabled = $true
        $spinnerPing.Visibility = 'Collapsed'
        $lblPingStatus.Visibility = 'Collapsed'
        $btnCancelPing.Visibility = 'Collapsed'
        $diagSpinnerTimer.Stop()
        $diagJobMonitor.Stop()
    }
})

$btnCancelLookup.Add_Click({
    if ($Script:DiagJob -and $Script:DiagType -eq 'lookup') {
        Stop-Job -Job $Script:DiagJob
        Remove-Job -Job $Script:DiagJob -Force
        $Script:DiagJob = $null
        $txtDiagOutput.Text = "Lookup cancelled by user."
        $btnRunLookup.IsEnabled = $true
        $spinnerLookup.Visibility = 'Collapsed'
        $lblLookupStatus.Visibility = 'Collapsed'
        $btnCancelLookup.Visibility = 'Collapsed'
        $diagSpinnerTimer.Stop()
        $diagJobMonitor.Stop()
    }
})

$btnCancelTrace.Add_Click({
    if ($Script:DiagJob -and $Script:DiagType -eq 'trace') {
        Stop-Job -Job $Script:DiagJob
        Remove-Job -Job $Script:DiagJob -Force
        $Script:DiagJob = $null
        $txtDiagOutput.Text = "Trace cancelled by user."
        $btnRunTrace.IsEnabled = $true
        $spinnerTrace.Visibility = 'Collapsed'
        $lblTraceStatus.Visibility = 'Collapsed'
        $btnCancelTrace.Visibility = 'Collapsed'
        $diagSpinnerTimer.Stop()
        $diagJobMonitor.Stop()
    }
})
$btnFlushDNS.Add_Click({ $txtDiagOutput.Text = Invoke-NcRepair -Action 'FlushDNS' })
$btnReleaseRenew.Add_Click({ $txtDiagOutput.Text = Invoke-NcRepair -Action 'ReleaseRenew' })
$btnWinsockReset.Add_Click({ $txtDiagOutput.Text = Invoke-NcRepair -Action 'WinsockReset' })
$btnClearARP.Add_Click({ $txtDiagOutput.Text = Invoke-NcRepair -Action 'ClearARP' })
$btnCopyDiag.Add_Click({ if ($txtDiagOutput.Text) { Copy-NcText $txtDiagOutput.Text } })
$btnExportDiag.Add_Click({
    if ($txtDiagOutput.Text) {
        $path = Export-NcText -Text $txtDiagOutput.Text -ExportFolder $Script:Settings.ExportFolder -BaseName "diag_$(Get-Date -Format yyyyMMdd_HHmmss)"
        [System.Windows.MessageBox]::Show("Exported: $path", 'Export', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
    }
})

# Wire Settings
$btnBrowseExport.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $null = $dialog.ShowDialog()
    if ($dialog.SelectedPath) { $txtExportFolder.Text = $dialog.SelectedPath }
})
$btnBrowseCli.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = 'exe files (*.exe)|*.exe|All files (*.*)|*.*'
    $ofd.Title = 'Select speedtest.exe (Ookla)'
    if ($ofd.ShowDialog() -eq 'OK') { $txtCliPath.Text = $ofd.FileName }
})

# Desktop Shortcut Handlers
$btnCreateShortcut.Add_Click({
    try {
        $desktopPath = [Environment]::GetFolderPath('Desktop')
        $shortcutPath = Join-Path $desktopPath 'Network Check.lnk'
        
        if (Test-Path $shortcutPath) {
            $result = [System.Windows.MessageBox]::Show('Desktop shortcut already exists. Overwrite?', 'Create Shortcut', [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
            if ($result -eq 'No') { return }
        }
        
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        
        # Use VBScript launcher for hidden window
        $vbsLauncher = Join-Path $Script:AppRoot 'Run-NetworkCheck.vbs'
        if (Test-Path -LiteralPath $vbsLauncher) {
            $Shortcut.TargetPath = 'wscript.exe'
            $Shortcut.Arguments = "`"$vbsLauncher`""
        }
        else {
            # Fallback to PowerShell if VBS not found
            $Shortcut.TargetPath = 'powershell.exe'
            $Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($Script:AppRoot)\NetworkCheckApp.ps1`""
        }
        
        $Shortcut.WorkingDirectory = $Script:AppRoot
        
        # Use custom icon if available, otherwise use PowerShell icon
        $iconPath = Join-Path $Script:AppRoot 'assets\desktop_icon.ico'
        if (Test-Path $iconPath) {
            $Shortcut.IconLocation = $iconPath
        } else {
            $Shortcut.IconLocation = "$($Script:AppRoot)\NetworkCheckApp.ps1,0"
        }
        
        $Shortcut.Description = 'Network Speed Test and Diagnostics Tool'
        $Shortcut.Save()
        
        [System.Windows.MessageBox]::Show('Desktop shortcut created successfully!', 'Success', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
    } catch {
        [System.Windows.MessageBox]::Show("Failed to create shortcut: $($_.Exception.Message)", 'Error', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
    }
})

$btnRemoveShortcut.Add_Click({
    try {
        $desktopPath = [Environment]::GetFolderPath('Desktop')
        $shortcutPath = Join-Path $desktopPath 'Network Check.lnk'
        
        if (-not (Test-Path $shortcutPath)) {
            [System.Windows.MessageBox]::Show('No desktop shortcut found.', 'Remove Shortcut', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
            return
        }
        
        Remove-Item -Path $shortcutPath -Force
        [System.Windows.MessageBox]::Show('Desktop shortcut removed successfully!', 'Success', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
    } catch {
        [System.Windows.MessageBox]::Show("Failed to remove shortcut: $($_.Exception.Message)", 'Error', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
    }
})

$btnSaveSettings.Add_Click({
    try {
        $Script:Settings.ExportFolder = $txtExportFolder.Text
        $Script:Settings.OoklaCLIPath = $txtCliPath.Text
        $Script:Settings.AutoExportMorningCheck = [bool]$chkAutoExport.IsChecked
        $Script:Settings.CheckUpdatesOnStartup = [bool]$chkCheckUpdates.IsChecked
        $Script:Settings.DarkMode = [bool]$rbDarkMode.IsChecked
        Save-NcSettings -AppRoot $Script:AppRoot -Settings $Script:Settings
        [System.Windows.MessageBox]::Show('Settings saved.', 'Settings', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
    } catch {
        [System.Windows.MessageBox]::Show("Failed to save settings: $($_.Exception.Message)", 'Settings', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
    }
})

# Wire Update functionality
$btnCheckUpdates.Add_Click({
    try {
        $btnCheckUpdates.IsEnabled = $false
        $lblUpdateStatus.Text = "Checking for updates..."
        
        # Check for updates
        $updateInfo = Test-NcUpdateAvailable -AppRoot $Script:AppRoot
        
        if ($updateInfo.Error) {
            [System.Windows.MessageBox]::Show("Could not check for updates: $($updateInfo.Error)", 'Update Check', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null
            $btnCheckUpdates.IsEnabled = $true
            return
        }
        
        if ($updateInfo.UpdateAvailable) {
            # Show update popup
            $lblInstalledVersion.Text = "v$($updateInfo.CurrentVersion)"
            $lblNewVersion.Text = "v$($updateInfo.LatestVersion)"
            $lblUpdateStatus.Text = ""
            
            # Store release info
            $window.Resources['UpdateInfo'] = $updateInfo
            
            # Show popup
            $updateOverlay.Visibility = 'Visible'
        }
        else {
            [System.Windows.MessageBox]::Show("You are already running the latest version (v$($updateInfo.CurrentVersion)).", 'No Update Available', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
        }
        
        $btnCheckUpdates.IsEnabled = $true
    }
    catch {
        $btnCheckUpdates.IsEnabled = $true
        [System.Windows.MessageBox]::Show("Update check failed: $($_.Exception.Message)", 'Update Check', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
    }
})

# Update popup handlers
$btnCloseUpdate.Add_Click({
    $updateOverlay.Visibility = 'Collapsed'
})

$btnLater.Add_Click({
    $updateOverlay.Visibility = 'Collapsed'
})

$btnUpgrade.Add_Click({
    try {
        $updateInfo = $window.Resources['UpdateInfo']
        if (-not $updateInfo) { return }
        
        # Disable buttons during update
        $btnUpgrade.IsEnabled = $false
        $btnLater.IsEnabled = $false
        $lblUpdateStatus.Text = "Downloading update..."
        
        # Install update
        $result = Install-NcUpdate -AppRoot $Script:AppRoot -DownloadUrl $updateInfo.ReleaseInfo.DownloadUrl -Version $updateInfo.LatestVersion
        
        if ($result.Success) {
            $lblUpdateStatus.Text = "Update installed successfully!"
            
            # Ask to restart
            $restartResult = [System.Windows.MessageBox]::Show(
                "Update to v$($updateInfo.LatestVersion) installed successfully!`n`nThe application needs to restart to use the new version.`n`nRestart now?",
                'Update Complete',
                [System.Windows.MessageBoxButton]::YesNo,
                [System.Windows.MessageBoxImage]::Information
            )
            
            if ($restartResult -eq [System.Windows.MessageBoxResult]::Yes) {
                # Restart the application using VBScript launcher (hidden)
                $Script:AllowClose = $true
                
                # Check if VBScript launcher exists, use it for hidden restart
                $vbsLauncher = Join-Path $Script:AppRoot 'Run-NetworkCheck.vbs'
                if (Test-Path -LiteralPath $vbsLauncher) {
                    Start-Process -FilePath 'wscript.exe' -ArgumentList "`"$vbsLauncher`"" -WindowStyle Hidden
                }
                else {
                    # Fallback to direct PowerShell launch
                    Start-Process -FilePath 'powershell.exe' -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Script:AppRoot\NetworkCheckApp.ps1`"" -WindowStyle Hidden
                }
                
                $window.Close()
            }
            else {
                $updateOverlay.Visibility = 'Collapsed'
            }
        }
        else {
            $lblUpdateStatus.Text = "Update failed: $($result.Error)"
            [System.Windows.MessageBox]::Show("Update failed: $($result.Error)", 'Update Error', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
            $btnUpgrade.IsEnabled = $true
            $btnLater.IsEnabled = $true
        }
    }
    catch {
        $lblUpdateStatus.Text = "Update failed!"
        [System.Windows.MessageBox]::Show("Update failed: $($_.Exception.Message)", 'Update Error', [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
        $btnUpgrade.IsEnabled = $true
        $btnLater.IsEnabled = $true
    }
})

# Show window (keep-alive window guard)
try {
    $window.add_Closing({ param($s,$e)
        try {
            $now = [DateTime]::UtcNow
            $msg = '[' + (Get-Date).ToString('o') + '] UI: Window closing requested'
            Add-Content -LiteralPath (Join-Path $Script:AppRoot 'engine.log') -Value $msg
            if (-not $Script:AllowClose) { #  -and ($now -lt $Script:KeepAliveUntil))
                if ($Script:SpeedJob -and $Script:SpeedJob.State -eq 'Running') {
                    $e.Cancel = $true
                    [System.Windows.MessageBox]::Show("A speed test is in progress. Please stop it before closing.", "Test in Progress", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null
                }
            }

            # Stop any running job if window is closing for good
            if (-not $e.Cancel -and $Script:SpeedJob) {
                Stop-NcSpeedTest -Job $Script:SpeedJob
            }
        } catch {}
    })
} catch {}
$window.ShowDialog() | Out-Null
