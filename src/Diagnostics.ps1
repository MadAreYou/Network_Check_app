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
