function Test-NcAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal $id
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-NcPing {
    param([Parameter(Mandatory)][string] $Target)
    try {
        $output = ping.exe -n 4 $Target 2>&1 | Out-String
        return $output
    } catch {
        return $_.Exception.ToString()
    }
}

function Invoke-NcNslookup {
    param([Parameter(Mandatory)][string] $Target)
    try {
        # Use PowerShell's Resolve-DnsName for reliable results
        $result = Resolve-DnsName -Name $Target -ErrorAction Stop
        $output = "Name:    $Target`r`n`r`n"
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
}

function Invoke-NcTraceroute {
    param([Parameter(Mandatory)][string] $Target)
    try { (tracert.exe $Target 2>&1) | Out-String } catch { $_.Exception.ToString() }
}

function Invoke-NcRepair {
    param([ValidateSet('FlushDNS','ReleaseRenew','WinsockReset','ClearARP')] [string] $Action)
    if (-not (Test-NcAdmin)) {
        return "Action '$Action' may require Administrator. Please run the app as Administrator."
    }
    switch ($Action) {
        'FlushDNS'     { (ipconfig.exe /flushdns 2>&1) | Out-String }
        'ReleaseRenew' { (ipconfig.exe /release 2>&1 | Out-String) + (ipconfig.exe /renew 2>&1 | Out-String) }
        'WinsockReset' { (netsh.exe winsock reset 2>&1) | Out-String }
        'ClearARP'     { (arp.exe -d 2>&1) | Out-String }
    }
}

function Get-NcServiceName {
    param([int] $Port)
    $services = @{
        20 = 'FTP-DATA'; 21 = 'FTP'; 22 = 'SSH'; 23 = 'TELNET'; 25 = 'SMTP'
        53 = 'DNS'; 80 = 'HTTP'; 110 = 'POP3'; 143 = 'IMAP'; 443 = 'HTTPS'
        445 = 'SMB'; 465 = 'SMTPS'; 587 = 'SMTP'; 993 = 'IMAPS'; 995 = 'POP3S'
        1433 = 'MSSQL'; 1521 = 'Oracle'; 3306 = 'MySQL'; 3389 = 'RDP'; 5432 = 'PostgreSQL'
        5900 = 'VNC'; 8080 = 'HTTP-Alt'; 8443 = 'HTTPS-Alt'; 27017 = 'MongoDB'
    }
    if ($services.ContainsKey($Port)) { return $services[$Port] }
    return ''
}

function Invoke-NcPortScan {
    param(
        [Parameter(Mandatory)][string] $Target,
        [Parameter(Mandatory)][string] $PortRange,
        [int] $Timeout = 1000
    )
    
    try {
        # Parse port range (supports "80,443,3389" or "1-1024" or mixed "20-25,80,443")
        $portsToScan = @()
        $rangeParts = $PortRange -split ','
        
        foreach ($part in $rangeParts) {
            $part = $part.Trim()
            if ($part -match '^(\d+)-(\d+)$') {
                $start = [int]$Matches[1]
                $end = [int]$Matches[2]
                if ($start -gt $end) { $start,$end = $end,$start }
                $portsToScan += $start..$end
            }
            elseif ($part -match '^\d+$') {
                $portsToScan += [int]$part
            }
        }
        
        if ($portsToScan.Count -eq 0) {
            return "Invalid port range format. Use: 80,443 or 1-1024 or 20-25,80,443"
        }
        
        # Limit to reasonable number
        if ($portsToScan.Count -gt 5000) {
            return "Port range too large (max 5000 ports). Please use a smaller range."
        }
        
        $results = @()
        $openCount = 0
        $closedCount = 0
        
        # Scan ports
        foreach ($port in $portsToScan) {
            $status = 'CLOSED'
            $service = Get-NcServiceName -Port $port
            
            try {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $connect = $tcpClient.BeginConnect($Target, $port, $null, $null)
                $wait = $connect.AsyncWaitHandle.WaitOne($Timeout, $false)
                
                if ($wait -and $tcpClient.Connected) {
                    $status = 'OPEN'
                    $openCount++
                    $tcpClient.Close()
                } else {
                    $closedCount++
                }
                $tcpClient.Close()
            } catch {
                $closedCount++
            }
            
            # Only show open ports and first/last closed for brevity
            if ($status -eq 'OPEN' -or $port -eq $portsToScan[0] -or $port -eq $portsToScan[-1]) {
                $serviceName = if ($service) { "($service)" } else { '' }
                $results += "Port $port`:  $status  $serviceName"
            }
        }
        
        # Build output
        $output = "Port Scan Results for $Target`r`n"
        $output += "="*50 + "`r`n"
        $output += "Total Ports Scanned: $($portsToScan.Count)`r`n"
        $output += "Open: $openCount | Closed/Filtered: $closedCount`r`n"
        $output += "="*50 + "`r`n`r`n"
        
        if ($openCount -eq 0) {
            $output += "No open ports found.`r`n"
        } else {
            $output += $results -join "`r`n"
        }
        
        return $output
        
    } catch {
        return "Port scan failed: $($_.Exception.Message)"
    }
}
