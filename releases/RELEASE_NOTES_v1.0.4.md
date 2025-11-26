# ntchk v1.0.4 - Port Scanner & UI Enhancements 🔍

**Release Date**: November 25, 2025  
**Download**: [ntchk-v1.0.4-Portable.zip](https://github.com/MadAreYou/Network_Check_app/releases/tag/v1.0.4)

---

## 🎯 What's New

### 🔍 TCP Port Scanner - New Diagnostics Tool

A powerful, real-time port scanning capability has been added to the Diagnostics tab!

**Key Features:**
- ✅ **Real TCP Connect Scanning** - Live port connectivity testing (no simulation)
- ✅ **Flexible Port Input** - Single ports, ranges, lists, or mixed formats
- ✅ **Service Detection** - Automatically identifies 24+ common services
- ✅ **Smart Defaults** - Scans 18 common ports when input is empty
- ✅ **No Admin Required** - Uses TCP connect method (like `nmap -sT`)

**Supported Input Formats:**
```
80                    # Single port
80,443,3389          # Multiple ports
1-1024               # Port range
20-25,80,443,3306    # Mixed (ranges + individual)
```

**Service Name Detection:**
The scanner automatically identifies common services like HTTP (80), HTTPS (443), SSH (22), RDP (3389), MySQL (3306), PostgreSQL (5432), and many more!

**Default Common Ports:**
When you leave the port field empty, it scans: 20-25 (FTP), 53 (DNS), 80 (HTTP), 110 (POP3), 143 (IMAP), 443 (HTTPS), 445 (SMB), 587 (SMTP), 993 (IMAPS), 995 (POP3S), 1433 (MSSQL), 3306 (MySQL), 3389 (RDP), 5432 (PostgreSQL), 5900 (VNC), 8080 (HTTP-Alt), 8443 (HTTPS-Alt)

---

## ✨ UI/UX Improvements

### 📐 Fixed Diagnostics Tab Layout
- **Proper Grid Structure** - 7-row grid prevents button displacement during output
- **Scrollable Output** - Output area expands properly with border styling
- **Placeholder Text** - Input fields show helpful examples: "example.com or 192.168.0.1"

### 🎬 Animated Progress Indicators
- **Three-Dot Animation** - Visual feedback with cycling dots (. .. ...)
- **Clean Progress Messages** - Shows scanned ports without flooding output
- **Real-time Updates** - Know exactly what's being tested

---

## 📦 Installation

1. Download `ntchk-v1.0.4-Portable.zip`
2. Extract to any folder
3. Double-click **ntchk.exe** (recommended)

---

## 🔄 Upgrading from v1.0.3

Simply download and extract v1.0.4 - your settings and exports are preserved!

---

## ✨ All Features Included

This is a feature enhancement release - all features from v1.0.3 are preserved:

- ⚡ **Speed Test** - Ookla Speedtest integration
- 🌐 **Network Info** - IP, DNS, Gateway, WiFi/Ethernet detection
- 🔧 **Diagnostics** - Ping, DNS Lookup, Traceroute, DNS flush, IP release/renew
- 🔍 **Port Scanner** - NEW! TCP port scanning with service detection
- ⚙️ **Settings** - Dark mode, auto-export, desktop shortcuts
- 🔄 **Auto-Update** - GitHub-integrated update system
- 📊 **Export** - JSON export for all results
- 🎨 **Themes** - Light/Dark mode support

---

## 🛡️ Policy-Friendly Features

ntchk maintains its enterprise-ready design:
- ✅ Zero VBScript (commonly blocked by corporate policies)
- ✅ Neutral naming (avoids "suspicious" keywords)
- ✅ Compiled .exe launcher (trusted by security software)
- ✅ No admin rights required for port scanning
- ✅ Fully auditable (open source)

---

## 🔐 File Verification

**Verify your download integrity using SHA256 checksums:**

**File**: `ntchk-v1.0.4-Portable.zip`  
**SHA256**: `4E8CED50CA4D9BFAF436490D0B44211358F82C3042FE2BD38307F62AA62BF363`  
**Size**: `1.29 MB`

> ✅ **Verification Status**: This checksum has been verified against the actual file and matches the published checksum on GitHub.

### Quick Guide: How to Verify in PowerShell

**Step 1**: Download both files from GitHub releases:
- `ntchk-v1.0.4-Portable.zip`
- `ntchk-v1.0.4-Portable.zip.sha256`

**Step 2**: Open PowerShell in the download folder:
- Hold **Shift** + **Right-click** in the folder
- Select "Open PowerShell window here"

**Step 3**: Run the verification command:

### Method 1: Simple Verification

```powershell
# Calculate the checksum
Get-FileHash .\ntchk-v1.0.4-Portable.zip -Algorithm SHA256

# Compare with the checksum above
```

The hash should match exactly. If it doesn't, **do not run the file** - re-download from the official source.

### Alternative Verification

You can also verify using the included `.sha256` file:

```powershell
# Read expected checksum
$expected = (Get-Content .\ntchk-v1.0.4-Portable.zip.sha256).Trim()

# Calculate actual checksum
$actual = (Get-FileHash .\ntchk-v1.0.4-Portable.zip -Algorithm SHA256).Hash

# Compare
if ($expected -eq $actual) {
    Write-Host "✓ Checksum verified - file is authentic" -ForegroundColor Green
} else {
    Write-Host "✗ Checksum mismatch - do not use this file!" -ForegroundColor Red
}
```

### Verify Against GitHub Release

Verify the downloaded file directly from GitHub:

```powershell
# Download checksum from GitHub release
$githubHash = (Invoke-WebRequest -Uri "https://github.com/MadAreYou/Network_Check_app/releases/download/v1.0.4/ntchk-v1.0.4-Portable.zip.sha256" -UseBasicParsing).Content.Trim()

# Calculate local file checksum
$localHash = (Get-FileHash .\ntchk-v1.0.4-Portable.zip -Algorithm SHA256).Hash

# Compare
if ($githubHash -eq $localHash) {
    Write-Host "✓ File matches GitHub release - verified authentic" -ForegroundColor Green
} else {
    Write-Host "✗ File does not match GitHub release!" -ForegroundColor Red
}
```

---

## 🔧 Technical Details

**Port Scanner Implementation:**
- **Method**: TCP Connect Scan (System.Net.Sockets.TcpClient)
- **Timeout**: 1000ms per port
- **Max Ports**: 5000 per scan (safety limit)
- **Output**: Open/Closed statistics with service names

**UI Architecture:**
- **Grid Layout**: 7-row structure with proper spacing
- **Animations**: DispatcherTimer-based (500ms cycle)
- **Event Handling**: Async job execution with spinner
- **Placeholder**: Grid overlay technique for input hints

---

## 🚀 What's Next?

Future enhancements being considered:
- Additional diagnostic tools
- Enhanced export formats
- Network mapping features

---

## 📝 Full Changelog

See [CHANGELOG.md](https://github.com/MadAreYou/Network_Check_app/blob/main/CHANGELOG.md) for detailed version history.

**Full Changelog**: [v1.0.3...v1.0.4](https://github.com/MadAreYou/Network_Check_app/compare/v1.0.3...v1.0.4)

---

## 💬 Feedback & Support

Found a bug? Have a feature request?  
Open an issue on [GitHub Issues](https://github.com/MadAreYou/Network_Check_app/issues)

**Contact:**
- Email: juraj.madzunkov@example.com
- LinkedIn: [Juraj Madzunkov](https://www.linkedin.com/in/juraj-madzunkov/)

---

**Thank you for using ntchk!** 🙏
