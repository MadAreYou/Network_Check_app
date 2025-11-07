function Accept-NcOoklaLicense {
    param(
        [Parameter(Mandatory)] [string] $AppRoot,
        [Parameter(Mandatory)] $Settings
    )
    # Determine speedtest.exe path using same precedence as Start-NcSpeedTest
    $path = $null
    if ($Settings.OoklaCLIPath -and (Test-Path -LiteralPath $Settings.OoklaCLIPath)) { $path = $Settings.OoklaCLIPath }
    if (-not $path) {
        $local = Join-Path $AppRoot 'speedtest.exe'
        if (Test-Path -LiteralPath $local) { $path = $local }
    }
    if (-not $path) {
        try { $cmd = Get-Command speedtest -ErrorAction SilentlyContinue; if ($cmd) { $path = $cmd.Source } } catch {}
    }
    if (-not $path) { return [pscustomobject]@{ Success=$false; Error='Ookla CLI not found' } }

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $path
        $psi.Arguments = '--version --accept-license --accept-gdpr'
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.CreateNoWindow = $true
        $p = [System.Diagnostics.Process]::Start($psi)
        $p.WaitForExit(10000) | Out-Null
        if (-not $p.HasExited) { try { $p.Kill() } catch {} ; return [pscustomobject]@{ Success=$false; Error='License preflight timed out' } }
        if ($p.ExitCode -eq 0) { return [pscustomobject]@{ Success=$true } }
        $err = $p.StandardError.ReadToEnd()
        return [pscustomobject]@{ Success=$false; Error=($err -as [string]) }
    } catch {
        return [pscustomobject]@{ Success=$false; Error=$_.Exception.Message }
    }
}

function Start-NcSpeedTest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $AppRoot,
        [Parameter(Mandatory)] $Settings
    )

    $scriptBlock = {
        param($AppRoot, $Settings, $InitialDebugLog)

        # Helper to send data back to the main thread
        function Write-JobData {
            param([string]$Type, $Data)
            $output = [pscustomobject]@{
                Type = $Type
                Data = $Data
                Timestamp = [datetime]::UtcNow
            }
            Write-Output $output
        }

        # Re-create the logging function inside the job
        $debugLog = Join-Path $AppRoot 'engine.log'
        function Write-JobLog {
            param([string]$Message)
            $logLine = '[' + (Get-Date).ToString('o') + '] JOB-LOG: ' + $Message
            try { Add-Content -LiteralPath $debugLog -Value $logLine } catch {}
            Write-JobData -Type 'log' -Data $logLine
        }

        try {
            # Write initial logs that were passed in
            if ($InitialDebugLog) {
                try { Add-Content -LiteralPath $debugLog -Value $InitialDebugLog } catch {}
            }

            Write-JobLog "Speed test job started."

            # Resolve Ookla engine path (configured > local > PATH)
            $enginePath = $null
            if ($Settings.OoklaCLIPath -and (Test-Path -LiteralPath $Settings.OoklaCLIPath)) { $enginePath = $Settings.OoklaCLIPath }
            if (-not $enginePath) {
                $local = Join-Path $AppRoot 'speedtest.exe'
                if (Test-Path -LiteralPath $local) { $enginePath = $local }
            }
            if (-not $enginePath) {
                try { $cmd = Get-Command speedtest -ErrorAction SilentlyContinue; if ($cmd) { $enginePath = $cmd.Source } } catch {}
            }
            if (-not $enginePath) { throw 'No speed test engine found.' }
            Write-JobLog "Running Ookla speedtest..."

            # Start process with JSON output
            $startUtc = [datetime]::UtcNow
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = $enginePath
            $psi.Arguments = '--format=json --accept-license --accept-gdpr'
            $psi.WorkingDirectory = $AppRoot
            $psi.UseShellExecute = $false
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError  = $true
            $psi.CreateNoWindow = $true

            $p = [System.Diagnostics.Process]::Start($psi)
            $global:SpeedTestPid = $p.Id

            # Animate progress bars based on typical Ookla test phases (REAL test running in background)
            # Typical timing: Ping 1-2s, Download 4-12s, Upload 5-10s = ~20s total
            $lastUpdate = [datetime]::MinValue
            while (-not $p.HasExited) {
                Start-Sleep -Milliseconds 100
                $elapsed = ([datetime]::UtcNow - $startUtc).TotalSeconds
                
                # Update progress every 500ms (half second) for smooth animation
                if (([datetime]::UtcNow - $lastUpdate).TotalMilliseconds -ge 500) {
                    if ($elapsed -lt 2) {
                        # Phase 1: Ping/Server selection (0-2 seconds)
                        $pingValue = [math]::Round(2.5 + (Get-Random -Minimum -0.5 -Maximum 0.8), 2)
                        Write-JobData -Type 'progress' -Data @{ Stage='ping'; Value=$pingValue }
                    }
                    elseif ($elapsed -lt 12) {
                        # Phase 2: Download test (2-12 seconds) - typical home fiber speed
                        $downloadProgress = ($elapsed - 2) / 10.0  # 10 second download window
                        # Estimate based on typical speeds (assuming 500-900 Mbps)
                        $estimatedSpeed = [math]::Round(100 + ($downloadProgress * 800), 0)
                        Write-JobData -Type 'progress' -Data @{ Stage='download'; Value=$estimatedSpeed }
                    }
                    else {
                        # Phase 3: Upload test (12+ seconds) - typical home fiber upload
                        $uploadProgress = ($elapsed - 12) / 8.0  # 8 second upload window
                        if ($uploadProgress -gt 1.0) { $uploadProgress = 1.0 }
                        # Estimate based on typical upload speeds (assuming 50-100 Mbps)
                        $estimatedSpeed = [math]::Round(20 + ($uploadProgress * 80), 0)
                        Write-JobData -Type 'progress' -Data @{ Stage='upload'; Value=$estimatedSpeed }
                    }
                    $lastUpdate = [datetime]::UtcNow
                }
                
                # Timeout at 120 seconds
                if ($elapsed -gt 120) {
                    Write-JobLog "Timeout: killing process after 120 seconds."
                    try { $p.Kill() } catch {}
                    throw 'Speed test timed out (120s).'
                }
            }

            $exitCode = $p.ExitCode
            Write-JobLog "Process exited with code $exitCode."

            # Read stdout/stderr
            $json = $p.StandardOutput.ReadToEnd()
            $errText = $p.StandardError.ReadToEnd()
            $p.Dispose()

            if ($exitCode -ne 0) {
                throw "Speedtest failed with exit code $exitCode. Error: $errText"
            }

            # Parse the JSON output
            $result = $null
            try {
                if ($json.Length -gt 0) {
                    $parsed = $json | ConvertFrom-Json
                    if ($parsed.type -eq 'result') {
                        $result = $parsed
                    }
                }
            } catch {
                throw "JSON parsing failed: $($_.Exception.Message)"
            }

            if (-not $result) { 
                throw 'Could not parse speed test results.'
            }

            # Build the final result object from JSON data (REAL values)
            $final = [pscustomobject]@{
                Timestamp           = $result.timestamp
                PingMs              = $result.ping.latency
                DownloadMbpsAvg     = $result.download.bandwidth * 8 / 1MB
                UploadMbpsAvg       = $result.upload.bandwidth * 8 / 1MB
                DownloadLatencyIqm  = $result.download.latency.iqm
                UploadLatencyIqm    = $result.upload.latency.iqm
                PacketLoss          = $result.packetLoss
                Isp                 = $result.isp
                Server              = "$($result.server.name) ($($result.server.location))"
                ResultUrl           = $result.result.url
                RawJson             = $json
            }
            
            Write-JobLog "Test finished."
            Write-JobData -Type 'complete' -Data $final
            Write-JobLog "Job finished successfully."

        } catch {
            Write-JobLog "Error in speed test job: $($_.Exception.Message)"
            Write-JobLog "Stack trace: $($_.ScriptStackTrace)"
            Write-JobData -Type 'complete' -Data $null
        } finally {
            if ($p) { $p.Dispose() }
        }
    }

    # Prepare initial log messages on the main thread to pass to the job
    $initialLog = @()
    $initialLog += ('[' + (Get-Date).ToString('o') + '] UI-LOG: Starting speed test job...')
    $enginePath = $null
    if ($Settings.OoklaCLIPath -and (Test-Path -LiteralPath $Settings.OoklaCLIPath)) { $enginePath = $Settings.OoklaCLIPath }
    if (-not $enginePath) {
        $local = Join-Path $AppRoot 'speedtest.exe'
        if (Test-Path -LiteralPath $local) { $enginePath = $local }
    }
    if (-not $enginePath) {
        try { $cmd = Get-Command speedtest -ErrorAction SilentlyContinue; if ($cmd) { $enginePath = $cmd.Source } } catch {}
    }
    if (-not $enginePath) { throw 'No speed test engine found. Add speedtest.exe (Ookla) next to the app or configure its path in Settings.' }
    $initialLog += ('[' + (Get-Date).ToString('o') + "] UI-LOG: Launching: `"$enginePath`" --format=json --accept-license --accept-gdpr")
    $initialLog += ('[' + (Get-Date).ToString('o') + "] UI-LOG: WorkingDirectory: $AppRoot")
    
    $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $AppRoot, $Settings, ($initialLog -join "`r`n")
    return $job
}

function Stop-NcSpeedTest {
    param(
        [Parameter(Mandatory)] $Job
    )
    if ($null -eq $Job) { return }
    try {
        $debugLog = Join-Path $PSScriptRoot 'engine.log'
        Add-Content -LiteralPath $debugLog -Value ('[' + (Get-Date).ToString('o') + '] UI: Stop-NcSpeedTest called.')
        
        # Kill the speedtest.exe process started by the job
        if ($global:SpeedTestPid -gt 0) {
            try {
                Stop-Process -Id $global:SpeedTestPid -Force
                Add-Content -LiteralPath $debugLog -Value ('[' + (Get-Date).ToString('o') + "] UI: Killed process PID=$($global:SpeedTestPid)")
                $global:SpeedTestPid = 0
            } catch {
                Add-Content -LiteralPath $debugLog -Value ('[' + (Get-Date).ToString('o') + "] UI: Failed to kill process PID=$($global:SpeedTestPid): $($_.Exception.Message)")
            }
        }

        # Stop the job itself
        Stop-Job -Job $Job
        Remove-Job -Job $Job -Force
        Add-Content -LiteralPath $debugLog -Value ('[' + (Get-Date).ToString('o') + "] UI: Stopped and removed job $($Job.Name).")
    } catch {
        Add-Content -LiteralPath $debugLog -Value ('[' + (Get-Date).ToString('o') + "] UI: Error in Stop-NcSpeedTest: $($_.Exception.Message)")
    }
}
