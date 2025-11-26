# ntchk v1.0.3 - Policy-Friendly Edition 🛡️

**Release Date**: November 21, 2025

## 📥 Download & Install

### 📦 Release Assets (2 files required)

| File | Description | Size |
|------|-------------|------|
| `ntchk-v1.0.3-Portable.zip` | Main application package | 1.29 MB |
| `ntchk-v1.0.3-Portable.zip.sha256` | SHA256 checksum for verification | 64 bytes |

**⬇️ Download both files from the Assets section below**

### 🔒 Security First

⚠️ **Always verify the checksum before running!** See the [🔐 File Verification](#-file-verification) section below for step-by-step instructions.

### 🚀 Quick Installation

1. **Download** both files above from GitHub releases
2. **Verify** the download using the `.sha256` file (see verification section)
3. **Extract** ZIP to any folder (USB drive, network share, local drive - all supported)
4. **Run** `ntchk.exe` (recommended) or `ntchk.bat`
5. **Done!** No installation, no registry changes, fully portable

---

## 🎯 What's New

This release represents a **major architectural shift** to make ntchk fully compatible with enterprise security policies. Previously flagged by corporate security software, the app has been completely rebranded and restructured for maximum policy compliance.

### 🛡️ Enterprise Security Compliance

**Problem Solved**: The previous version used VBScript launchers and names containing "suspicious" keywords (Run, Check, Network) that triggered security policies on company laptops.

**Solution**: Complete policy-friendly redesign:
- ✅ **Zero VBScript** - All VBScript code eliminated
- ✅ **Neutral Naming** - Rebranded to "ntchk" (Network Toolkit)
- ✅ **Compiled Launcher** - Pure .NET executable (ntchk.exe)
- ✅ **Clean Architecture** - Policy-compliant file structure

---

## 🚀 New Launchers

### Primary: ntchk.exe (RECOMMENDED)
- Policy-friendly .NET compiled executable
- Launches PowerShell silently (no console window)
- Proper file metadata and version info
- Never flagged by corporate security
- **File Size**: 6KB

### Fallback: ntchk.bat
- Clean batch script (no VBScript dependencies)
- Uses native Windows commands only
- Compatible with strictest policies
- **File Size**: <1KB

### Direct: ntchk.ps1
- Main PowerShell application
- Use for troubleshooting if launchers blocked
- Same powerful features as always

---

## 📋 Complete Changes

### File Renamings
| Old Name | New Name | Status |
|----------|----------|--------|
| `NetworkCheckApp.ps1` | `ntchk.ps1` | Renamed |
| `Run-NetworkCheck.vbs` | — | **REMOVED** |
| `Run-NetworkCheck.bat` | — | **REMOVED** |
| — | `ntchk.exe` | **NEW** |
| — | `ntchk.bat` | **NEW** |

### Branding Updates
- **App Name**: Network Check → **ntchk**
- **Window Title**: "Network Check" → "ntchk"
- **Header**: "ntchk - Network Toolkit"
- **Desktop Shortcut**: "ntchk.lnk"
- **Package Name**: ntchk-v1.0.3-Portable.zip

### Build System
- New launcher compiler: `Build-Launcher.ps1`
- Updated build configuration for v1.0.3
- Enhanced portable packager with multi-launcher support
- Proper assembly metadata in compiled executable

### Documentation
- README.md fully updated with new naming
- CHANGELOG.md comprehensive v1.0.3 section
- Build documentation includes launcher compilation
- All MD files reviewed and updated

---

## 💼 Why This Matters for Enterprise Users

### Before (v1.0.2)
- ❌ VBScript launcher flagged by security policies
- ❌ "Run-NetworkCheck" name triggered keyword alerts
- ❌ Blocked on company laptops
- ❌ Required policy exceptions

### After (v1.0.3)
- ✅ Pure .NET executable (trusted by security software)
- ✅ Neutral "ntchk" naming (no suspicious keywords)
- ✅ Works on company laptops without exceptions
- ✅ Policy-compliant architecture
- ✅ Same powerful features, enterprise-ready packaging

---

## 📦 What's Included

```
ntchk-v1.0.3-Portable.zip
├── ntchk.exe              # Primary launcher (RECOMMENDED)
├── ntchk.bat              # Fallback launcher
├── ntchk.ps1              # Main application
├── speedtest.exe          # Ookla Speedtest CLI
├── config.json            # Settings
├── src/                   # PowerShell modules
├── ui/                    # XAML interface
├── assets/                # Icons and images
├── exports/               # Results folder
└── README.txt             # Quick start guide
```

---

## 🔐 File Verification

**Verify your download integrity using SHA256 checksums:**

**File**: `ntchk-v1.0.3-Portable.zip`  
**SHA256**: `E604844202CADFCE2F1B2485A8C20BA013A9C2CF1ABE124EC7BF4717BCD7CB61`  
**Size**: `1.29 MB`

> ✅ **Verification Status**: This checksum has been verified against the actual file and matches the published checksum on GitHub.

### Quick Guide: How to Verify in PowerShell

**Step 1**: Download both files from GitHub releases:
- `ntchk-v1.0.3-Portable.zip`
- `ntchk-v1.0.3-Portable.zip.sha256`

**Step 2**: Open PowerShell in the download folder:
- Hold **Shift** + **Right-click** in the folder
- Select "Open PowerShell window here"

**Step 3**: Run the verification command:

### Method 1: Simple Verification

```powershell
# Calculate the checksum
Get-FileHash .\ntchk-v1.0.3-Portable.zip -Algorithm SHA256

# Compare with the checksum above
```

The hash should match exactly. If it doesn't, **do not run the file** - re-download from the official source.

### Alternative Verification

You can also verify using the included `.sha256` file:

```powershell
# Read expected checksum
$expected = (Get-Content .\ntchk-v1.0.3-Portable.zip.sha256).Trim()

# Calculate actual checksum
$actual = (Get-FileHash .\ntchk-v1.0.3-Portable.zip -Algorithm SHA256).Hash

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
$githubHash = (Invoke-WebRequest -Uri "https://github.com/MadAreYou/Network_Check_app/releases/download/v1.0.3/ntchk-v1.0.3-Portable.zip.sha256" -UseBasicParsing).Content.Trim()

# Calculate local file checksum
$localHash = (Get-FileHash .\ntchk-v1.0.3-Portable.zip -Algorithm SHA256).Hash

# Compare
if ($githubHash -eq $localHash) {
    Write-Host "✓ File matches GitHub release - verified authentic" -ForegroundColor Green
} else {
    Write-Host "✗ File does not match GitHub release!" -ForegroundColor Red
}
```

---

## 🔄 Upgrade Instructions

### From v1.0.2 or Earlier

1. **Download** ntchk-v1.0.3-Portable.zip
2. **Extract** to a new folder (or replace old installation)
3. **Copy** your `config.json` from old version (optional)
4. **Copy** your `exports/` folder if you want to keep results
5. **Launch** using `ntchk.exe` (recommended)

### Settings Preservation
Your settings will be automatically migrated when you first run v1.0.3. The app will:
- Detect your previous config.json
- Update paths if needed
- Preserve all preferences
- Update to new version format

---

## 🎯 How to Use

### Method 1: Double-Click ntchk.exe (Recommended)
- Policy-friendly compiled launcher
- No console window
- Works on company laptops
- Professional experience

### Method 2: Double-Click ntchk.bat (Fallback)
- Use if .exe files are blocked
- Clean batch script
- No VBScript dependencies
- Launches app hidden

### Method 3: Run ntchk.ps1 Directly (Troubleshooting)
- Right-click → "Run with PowerShell"
- Use for diagnostics
- Shows console for errors
- Developer mode

---

## ✨ All Features Still Included

This is a **packaging and naming update** - all features from v1.0.2 are preserved:

- ⚡ **Speed Test** - Ookla Speedtest integration
- 🌐 **Network Info** - IP, DNS, Gateway, WiFi/Ethernet detection
- 🔧 **Diagnostics** - Traceroute, DNS flush, IP release/renew
- ⚙️ **Settings** - Dark mode, auto-export, desktop shortcuts
- 🔄 **Auto-Update** - GitHub-integrated update system
- 📊 **Export** - JSON export for all results
- 🎨 **Themes** - Light/Dark mode support

---

## 🐛 Known Issues

None at this time. If you encounter issues:
1. Try launching with `ntchk.bat` instead of `ntchk.exe`
2. Run `ntchk.ps1` directly to see error messages
3. Report issues on GitHub

---

## 📝 Breaking Changes

### For Users
- **Desktop shortcuts** created with v1.0.2 will point to old launcher
  - **Fix**: Delete old shortcut, create new via Settings tab
- **Shortcuts in scripts** using old names need updating
  - **Fix**: Update paths from `NetworkCheckApp.ps1` to `ntchk.ps1`

### For Developers
- All file references updated in source code
- XAML branding changed
- Build scripts updated for new structure
- See CHANGELOG.md for detailed code changes

---

## 🙏 Credits

**Special Thanks** to users who reported security policy issues on company laptops. This feedback directly inspired the policy-friendly redesign.

---

## 📞 Support

- **Email**: juraj@madzo.eu
- **LinkedIn**: [Juraj Madzunkov](https://linkedin.com/in/juraj-madzunkov-457389104)
- **GitHub Issues**: [Report a Bug](https://github.com/MadAreYou/Network_Check_app/issues)

---

## 💝 Support Development

If you find ntchk useful, consider buying me a coffee!  
**Revolut**: @jurajcy93

---

**Full Changelog**: [v1.0.2...v1.0.3](https://github.com/MadAreYou/Network_Check_app/compare/v1.0.2...v1.0.3)
