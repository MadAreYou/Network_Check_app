function Get-NcNetworkName {
    try {
        # Try PowerShell cmdlet first (works for both WiFi and wired)
        # Look for any connected profile with IPv4 connectivity
        $profiles = Get-NetConnectionProfile -ErrorAction SilentlyContinue | 
                    Where-Object { 
                        $_.IPv4Connectivity -eq 'Internet' -or 
                        $_.IPv4Connectivity -eq 'LocalNetwork' -or
                        $_.NetworkCategory -ne 'Undefined'
                    } | 
                    Sort-Object -Property @{Expression={$_.IPv4Connectivity -eq 'Internet'}; Descending=$true}
        
        # Try to get the first profile with Internet, then LocalNetwork
        $profile = $profiles | Select-Object -First 1
        
        if ($profile -and $profile.Name) {
            return $profile.Name
        }
        
        # Fallback: Try netsh for WiFi SSID
        try {
            $wlanOutput = netsh wlan show interfaces 2>$null
            if ($wlanOutput) {
                $ssidLine = $wlanOutput | Select-String -Pattern '^\s*SSID\s*:\s*(.+)$'
                if ($ssidLine) {
                    $ssid = $ssidLine.Matches.Groups[1].Value.Trim()
                    if ($ssid -and $ssid -ne '') {
                        return $ssid
                    }
                }
            }
        } catch { }
        
        # Fallback: WMIC for network profile name (works for wired)
        $result = & $env:SystemRoot\System32\wbem\WMIC.exe /NameSpace:\\Root\StandardCimv2 Path MSFT_NetConnectionProfile Where "IPv4Connectivity='4'" Get Name /Format:MOF 2>$null
        $joinedResult = ($result -join ' ')
        if ($joinedResult -match 'Name\s*=\s*"([^"]+)"') {
            return $Matches[1]
        }
        
        # Last resort: Get active network adapter description
        try {
            $adapter = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | 
                       Where-Object { $_.Status -eq 'Up' } | 
                       Select-Object -First 1
            if ($adapter) {
                return "$($adapter.InterfaceDescription) (Active)"
            }
        } catch { }
        
        return 'Unknown'
    } catch { 'Unknown' }
}

function Get-NcLanIp {
    try {
        $result = ipconfig | Select-String -Pattern 'IPv4 Address.*: *(.+)$'
        return ($result | ForEach-Object { $_.Matches.Groups[1].Value.Trim() } | Select-Object -First 1)
    } catch { '' }
}

function Get-NcDefaultGateway {
    try {
        $result = ipconfig | Select-String -Pattern 'Default Gateway.*: *(.+)$'
        $gateways = $result | ForEach-Object { 
            $value = $_.Matches.Groups[1].Value.Trim()
            # Filter out empty values, IPv6 (::), and special characters
            # Only return valid IPv4 addresses
            if ($value -and $value -ne '::' -and $value -match '^\d+\.\d+\.\d+\.\d+$') {
                return $value
            }
        }
        return ($gateways | Select-Object -First 1)
    } catch { '' }
}

function Get-NcDhcpServer {
    try {
        $lines = wmic nicconfig where "IPEnabled='TRUE'" get DHCPServer /value
        foreach ($line in $lines) {
            if ($line -like 'DHCPServer=*') { return $line.Split('=')[1].Trim() }
        }
        return ''
    } catch { '' }
}

function Get-NcDnsServers {
    try {
        $servers = @()
        $captureNext = $false
        $lines = netsh interface ip show config
        foreach ($ln in $lines) {
            if ($ln -match 'DNS servers configured through DHCP') {
                $ip = ($ln -split ':',2)[1].Trim()
                if ($ip -and $ip -ne 'None') { $servers += $ip; $captureNext = $true } else { $captureNext = $false }
                continue
            }
            if ($captureNext) {
                $ip = $ln.Trim()
                if ($ip -and ($ip -match '^\d+\.\d+\.\d+\.\d+$')) { $servers += $ip } else { $captureNext = $false }
            }
        }
        if (-not $servers) { $servers = @() }
        return ,$servers
    } catch { @() }
}

function Get-NcMacAddress {
    try {
        $line = (getmac /v | Select-String -Pattern "\\Device\\Tcpip").Line
        if ($line) {
            $parts = $line -split '\s+'
            $mac = ($parts | Where-Object { $_ -match '^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2}){5}$' } | Select-Object -First 1)
            return $mac
        }
        return ''
    } catch { '' }
}

function Get-NcHostname {
    try {
        $result = ipconfig -all | Select-String -Pattern 'Host Name.*: *(.+)$'
        return ($result | ForEach-Object { $_.Matches.Groups[1].Value.Trim() } | Select-Object -First 1)
    } catch { $env:COMPUTERNAME }
}

function Get-NcPublicIp {
    try {
        # Try multiple methods for reliability
        # Method 1: Use Invoke-RestMethod (fastest)
        try {
            $ip = (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 3).Trim()
            if ($ip -match '^\d+\.\d+\.\d+\.\d+$') { return $ip }
        } catch {}
        
        # Method 2: OpenDNS resolver
        try {
            $lines = nslookup myip.opendns.com. resolver1.opendns.com 2>$null | Select-String -Pattern '^Address: *(.+)$'
            $ip = ($lines | ForEach-Object { $_.Matches.Groups[1].Value.Trim() } | Select-Object -Last 1)
            if ($ip -match '^\d+\.\d+\.\d+\.\d+$') { return $ip }
        } catch {}
        
        # Method 3: Alternative API
        try {
            $ip = (Invoke-RestMethod -Uri 'https://icanhazip.com' -TimeoutSec 3).Trim()
            if ($ip -match '^\d+\.\d+\.\d+\.\d+$') { return $ip }
        } catch {}
        
        return ''
    } catch { '' }
}

function Get-NcIspOrg {
    try {
        $org = & curl.exe -s ipinfo.io/org
        if ($org) { return ($org -join '').Trim() }
        return ''
    } catch { '' }
}

function Get-NcNetworkSnapshot {
    $ssid    = Get-NcNetworkName
    $lanIp   = Get-NcLanIp
    $gateway = Get-NcDefaultGateway
    $dhcp    = Get-NcDhcpServer
    $dns     = Get-NcDnsServers
    $mac     = Get-NcMacAddress
    $hostNameVar    = Get-NcHostname
    $pubIp   = Get-NcPublicIp
    $isp     = Get-NcIspOrg
    [pscustomobject]@{
        Timestamp = (Get-Date)
        SSID      = $ssid
        LANIP     = $lanIp
        Gateway   = $gateway
        DHCP      = $dhcp
        DNS       = $dns
        MAC       = $mac
        Hostname  = $hostNameVar
        PublicIP  = $pubIp
        ISP       = $isp
    }
}
