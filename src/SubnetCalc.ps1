# SubnetCalc.ps1 - Subnet and CIDR calculation functions
# No UI dependencies - pure math only.

# ─── Helpers ────────────────────────────────────────────────────────────────

function ConvertTo-NcIPLong {
    # Convert dotted-quad IP string to [long] (uint32 safe range via [long])
    param([Parameter(Mandatory)][string]$IP)
    $p = $IP.Split('.')
    return [long]([long]$p[0] * 16777216 + [long]$p[1] * 65536 + [long]$p[2] * 256 + [long]$p[3])
}

function ConvertFrom-NcIPLong {
    # Convert [long] (0–4294967295) back to dotted-quad string.
    # IMPORTANT: use [Math]::Floor, NOT [int] cast.
    # [int] uses banker's rounding so values like 255.996 round UP to 256,
    # corrupting the dotted-quad output for any octet value of 255.
    param([Parameter(Mandatory)][long]$Value)
    $a = [int][Math]::Floor($Value / 16777216)
    $b = [int][Math]::Floor(($Value % 16777216) / 65536)
    $c = [int][Math]::Floor(($Value % 65536) / 256)
    $d = [int]($Value % 256)
    return "$a.$b.$c.$d"
}

function Get-NcMaskLong {
    # Return the subnet mask as [long] from its prefix-length (0–32)
    param([Parameter(Mandatory)][int]$Bits)
    if ($Bits -eq 0)  { return [long]0 }
    if ($Bits -eq 32) { return [long]4294967295 }
    [long]$hostMask = [long]([Math]::Pow(2, 32 - $Bits)) - 1
    return [long](4294967295 - $hostMask)
}

function Get-NcMaskBitsFromDotted {
    # Count contiguous leading 1-bits in a dotted-quad subnet mask
    param([Parameter(Mandatory)][string]$SubnetMask)
    [long]$m = ConvertTo-NcIPLong $SubnetMask
    $bits = 0
    for ($i = 31; $i -ge 0; $i--) {
        $bit = [int](($m -shr $i) -band 1)
        if ($bit -eq 1) { $bits++ } else { break }
    }
    return $bits
}

function Get-NcHexIP {
    # Return hex-dotted representation, e.g. 192.168.0.1 → C0.A8.00.01
    param([Parameter(Mandatory)][string]$IP)
    $p = $IP.Split('.')
    return '{0:X2}.{1:X2}.{2:X2}.{3:X2}' -f [int]$p[0], [int]$p[1], [int]$p[2], [int]$p[3]
}

function Get-NcSubnetBitmap {
    # Build the subnet bitmap string e.g. 110nnnnn.nnnnnnnn.nnnnnnnn.hhhhhhhh
    # ClassIdBits : how many leading bits belong to the class identifier (A=1, B=2, C=3)
    # MaskBits    : total prefix length
    param(
        [Parameter(Mandatory)][string]$IP,
        [Parameter(Mandatory)][int]$MaskBits,
        [Parameter(Mandatory)][int]$ClassIdBits
    )
    [long]$ipLong = ConvertTo-NcIPLong $IP
    # Build 32-char binary string (MSB first)
    $binStr = [Convert]::ToString($ipLong, 2).PadLeft(32, '0')

    $result = ''
    for ($i = 0; $i -lt 32; $i++) {
        if ($i -gt 0 -and $i % 8 -eq 0) { $result += '.' }
        if ($i -lt $ClassIdBits) {
            $result += $binStr[$i]   # actual class-identifier bit value
        }
        elseif ($i -lt $MaskBits) {
            $result += 'n'           # network bit
        }
        else {
            $result += 'h'           # host bit
        }
    }
    return $result
}

function Get-NcFirstOctetRange {
    # Return the first-octet range string for each class
    param([Parameter(Mandatory)][string]$Class)
    switch ($Class) {
        'A' { return '1 - 127' }
        'B' { return '128 - 191' }
        'C' { return '192 - 223' }
        default { return '' }
    }
}

function Resolve-NcClass {
    # Auto-detect class from first octet (A/B/C only; D/E shown as C)
    param([Parameter(Mandatory)][string]$IP)
    $first = [int]($IP.Split('.')[0])
    if    ($first -ge 1   -and $first -le 127)  { return 'A' }
    elseif ($first -ge 128 -and $first -le 191) { return 'B' }
    else                                         { return 'C' }
}

# ─── Subnet Calculator ───────────────────────────────────────────────────────

function Invoke-NcSubnetCalc {
    <#
    .SYNOPSIS
        Compute all subnet fields for the Subnet Calculator tab.
    .PARAMETER IPAddress
        Dotted-quad IP, e.g. "192.168.0.1"
    .PARAMETER SubnetMask
        Dotted-quad mask, e.g. "255.255.255.0"
    .PARAMETER Class
        Network class: 'A', 'B', or 'C'
    #>
    param(
        [Parameter(Mandatory)][string]$IPAddress,
        [Parameter(Mandatory)][string]$SubnetMask,
        [Parameter(Mandatory)][string]$Class
    )

    # Basic IP validation
    if ($IPAddress -notmatch '^\d{1,3}(\.\d{1,3}){3}$') { return $null }
    foreach ($oct in $IPAddress.Split('.')) { if ([int]$oct -gt 255) { return $null } }

    try {
        [long]$ipLong      = ConvertTo-NcIPLong $IPAddress
        [long]$maskLong    = ConvertTo-NcIPLong $SubnetMask
        [long]$wildcardLong = 4294967295 - $maskLong
        [long]$networkLong  = $ipLong -band $maskLong
        [long]$broadcastLong = $networkLong -bor $wildcardLong

        $maskBits  = Get-NcMaskBitsFromDotted $SubnetMask
        $hostBits  = 32 - $maskBits

        # Class default prefix lengths: A=/8, B=/16, C=/24
        $classBits = switch ($Class) { 'A' { 8 } 'B' { 16 } default { 24 } }
        $subnetBits = [Math]::Max(0, $maskBits - $classBits)

        $maxSubnets = if ($subnetBits -gt 0) { [long]([Math]::Pow(2, $subnetBits)) } else { [long]1 }
        $hostsPerSubnet = if ($hostBits -ge 2) { [long]([Math]::Pow(2, $hostBits) - 2) } else { [long]0 }

        $firstHostLong = $networkLong + 1
        $lastHostLong  = $broadcastLong - 1
        $hostRange = if ($hostBits -ge 2) {
            "$(ConvertFrom-NcIPLong $firstHostLong) - $(ConvertFrom-NcIPLong $lastHostLong)"
        } else { 'N/A' }

        $classIdBits = switch ($Class) { 'A' { 1 } 'B' { 2 } default { 3 } }
        $bitmap = Get-NcSubnetBitmap -IP $IPAddress -MaskBits $maskBits -ClassIdBits $classIdBits

        return [PSCustomObject]@{
            HexIP            = Get-NcHexIP $IPAddress
            WildcardMask     = ConvertFrom-NcIPLong $wildcardLong
            SubnetBits       = $subnetBits
            MaskBits         = $maskBits
            MaxSubnets       = $maxSubnets
            HostsPerSubnet   = $hostsPerSubnet
            HostAddressRange = $hostRange
            SubnetID         = ConvertFrom-NcIPLong $networkLong
            BroadcastAddress = ConvertFrom-NcIPLong $broadcastLong
            SubnetBitmap     = $bitmap
            FirstOctetRange  = Get-NcFirstOctetRange $Class
        }
    }
    catch { return $null }
}

# ─── CIDR Calculator ─────────────────────────────────────────────────────────

function Invoke-NcCIDRCalc {
    <#
    .SYNOPSIS
        Compute all CIDR fields for the CIDR Calculator tab.
    .PARAMETER IPAddress
        Dotted-quad IP, e.g. "10.0.0.0"
    .PARAMETER MaskBits
        Prefix length 1–32
    #>
    param(
        [Parameter(Mandatory)][string]$IPAddress,
        [Parameter(Mandatory)][int]$MaskBits
    )

    if ($IPAddress -notmatch '^\d{1,3}(\.\d{1,3}){3}$') { return $null }
    foreach ($oct in $IPAddress.Split('.')) { if ([int]$oct -gt 255) { return $null } }
    if ($MaskBits -lt 1 -or $MaskBits -gt 32) { return $null }

    try {
        [long]$ipLong       = ConvertTo-NcIPLong $IPAddress
        [long]$maskLong     = Get-NcMaskLong $MaskBits
        [long]$wildcardLong = 4294967295 - $maskLong
        [long]$networkLong  = $ipLong -band $maskLong
        [long]$broadcastLong = $networkLong -bor $wildcardLong

        $hostBits        = 32 - $MaskBits
        # "Maximum Subnets" on subnet-calculator.com = 2^hostBits (total block size)
        # "Maximum Addresses"                         = 2^hostBits - 2 (usable hosts)
        $maxSubnets  = [long]([Math]::Pow(2, $hostBits))
        $maxAddresses = if ($hostBits -ge 2) { $maxSubnets - 2 } else { [long]0 }

        $networkAddr   = ConvertFrom-NcIPLong $networkLong
        $firstHostLong = $networkLong + 1
        $lastHostLong  = $broadcastLong - 1
        $addrRange = if ($hostBits -ge 2) {
            "$(ConvertFrom-NcIPLong $firstHostLong) - $(ConvertFrom-NcIPLong $lastHostLong)"
        } else { 'N/A' }

        return [PSCustomObject]@{
            CIDRNetmask   = ConvertFrom-NcIPLong $maskLong
            WildcardMask  = ConvertFrom-NcIPLong $wildcardLong
            MaxSubnets    = $maxSubnets
            MaxAddresses  = $maxAddresses
            CIDRNetwork   = $networkAddr
            CIDRNotation  = "$networkAddr/$MaskBits"
            AddressRange  = $addrRange
        }
    }
    catch { return $null }
}
