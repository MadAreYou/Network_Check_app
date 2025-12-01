# ntchk v1.0.5 - Auto-Update Fix (Portable Mode)

## 📥 Download & Install

### 📦 Release Assets (2 files required)

| File | Description | Size |
|------|-------------|------|
| `ntchk-v1.0.5-Portable.zip` | Main application package | 1.29 MB |
| `ntchk-v1.0.5-Portable.zip.sha256` | SHA256 checksum for verification | 64 bytes |

**⬇️ Download both files from the Assets section below**

### 🔒 Security First

⚠️ **Always verify the checksum before running!** See the **File Verification** section below for step-by-step instructions.

### 🚀 Quick Installation

1. **Download** both files above from GitHub releases
2. **Verify** the download using the `.sha256` file (see verification section)
3. **Extract** ZIP to any folder (USB drive, network share, local drive - all supported)
4. **Run** `ntchk.exe` (recommended) or `ntchk.bat`
5. **Done!** No installation, no registry changes, fully portable

---

## 🔧 Critical Update - Fixed Auto-Update Mechanism

This release fixes the **infinite update loop** issue that prevented v1.0.3 users from upgrading to newer versions.

### ✅ What's Fixed

#### **Portable Update System**
- Updates now download to `extracted/` folder in the app directory (no more %TEMP% usage)
- **Two-stage update process:**
  1. Download update files to `extracted/` folder
  2. Close application to release file locks
  3. Updater script copies files from `extracted/` to app root
  4. Restore user settings and restart app
  5. Clean up temporary files automatically

#### **Resolved Issues**
- ✅ Fixed infinite update loop caused by file locking
- ✅ Fixed failed updates when .ps1 files were locked by running process
- ✅ Updater now runs in hidden window (no visible PowerShell console)
- ✅ All update files preserved in app folder (fully portable)

#### **Automatic File Preservation**
- `config.json` - Your settings are always preserved
- `exports/*` - Export history never overwritten
- Automatic backup and restore during updates

### 🛡️ Fully Portable & Safe

- **No hardcoded paths** - Works from any folder location
- **No TEMP dependencies** - Everything stays in app folder
- **Network drive safe** - Works on UNC paths and USB drives
- **All paths dynamic** - Uses `$AppRoot` parameter throughout

### 📋 Detailed Logs

Update process creates two log files for troubleshooting:
- `upgrade-debug.log` - Download and extraction details
- `update.log` - File copy operations and restart status

### 🧹 Code Improvements

- Removed debug message boxes from update workflow
- Cleaner error messages with log file locations
- Improved user experience during updates
- Hidden PowerShell window during update process

---

## 📥 Installation

**For New Users:**
1. Download `ntchk-v1.0.5-Portable.zip`
2. Extract to any folder
3. Run `ntchk.exe` (recommended) or `ntchk.bat`

**For v1.0.4 Users:**
- ✅ **Auto-update works!** Just click the upgrade button when prompted

**For v1.0.3 Users:**
- ⚠️ Manual update recommended:
  1. Download v1.0.5 ZIP
  2. Extract to a new folder
  3. Copy your `config.json` and `exports/` folder to the new installation
  4. Future auto-updates will work from v1.0.5 onwards

---

## 🔄 What's Included

All features from v1.0.4 plus the update fix:
- ✅ TCP Port Scanner (real network scanning)
- ✅ Internet Speed Test (Ookla CLI)
- ✅ Network Information (IP, DNS, Gateway)
- ✅ Ping & Traceroute Diagnostics
- ✅ Export to CSV
- ✅ Auto-update mechanism (now working properly!)

---

## 📦 Technical Details

**Package:** `ntchk-v1.0.5-Portable.zip` (1.29 MB)

**Contents:**
- `ntchk.exe` - Policy-friendly launcher (recommended)
- `ntchk.bat` - Fallback launcher
- `ntchk.ps1` - Main PowerShell application
- `speedtest.exe` - Ookla CLI for speed tests
- `src/` - PowerShell modules
- `ui/` - XAML interface files
- `assets/` - Icons and images
- `config.json` - Configuration file
- `README.txt` - User documentation

**Requirements:**
- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1+ (built into Windows)
- .NET Framework 4.5+ (built into Windows)
- Internet connection for speed tests and updates

---

## File Verification

**Verify your download integrity using SHA256 checksums:**

**File**: `ntchk-v1.0.5-Portable.zip`  
**SHA256**: `BE81A6493696C90521452EECD1E78CB1FE5BC633B7837B5DF5876149A6B95969`  
**Size**: `1.29 MB`

> ✅ **Verification Status**: This checksum has been verified against the actual file and matches the published checksum on GitHub.

### Quick Guide: How to Verify in PowerShell

**Step 1**: Download both files from GitHub releases:
- `ntchk-v1.0.5-Portable.zip`
- `ntchk-v1.0.5-Portable.zip.sha256`

**Step 2**: Open PowerShell in the download folder:
- Hold **Shift** + **Right-click** in the folder
- Select "Open PowerShell window here"

**Step 3**: Run the verification command:

### Method 1: Simple Verification

```powershell
# Calculate the checksum
Get-FileHash .\ntchk-v1.0.5-Portable.zip -Algorithm SHA256

# Compare with the checksum above
```

The hash should match exactly. If it doesn't, **do not run the file** - re-download from the official source.

### Alternative Verification

You can also verify using the included `.sha256` file:

```powershell
# Read expected checksum
$expected = (Get-Content .\ntchk-v1.0.5-Portable.zip.sha256).Trim()

# Calculate actual checksum
$actual = (Get-FileHash .\ntchk-v1.0.5-Portable.zip -Algorithm SHA256).Hash

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
$githubHash = (Invoke-WebRequest -Uri "https://github.com/MadAreYou/Network_Check_app/releases/download/v1.0.5/ntchk-v1.0.5-Portable.zip.sha256" -UseBasicParsing).Content.Trim()

# Calculate local file checksum
$localHash = (Get-FileHash .\ntchk-v1.0.5-Portable.zip -Algorithm SHA256).Hash

# Compare
if ($githubHash -eq $localHash) {
    Write-Host "✓ File matches GitHub release - verified authentic" -ForegroundColor Green
} else {
    Write-Host "✗ File does not match GitHub release!" -ForegroundColor Red
}
```

---

## 🐛 Known Issues

None reported in v1.0.5

---

## 📞 Support

If you encounter any issues:
1. Check `upgrade-debug.log` and `update.log` in the app folder
2. Open an issue on GitHub with log files attached
3. Include Windows version and PowerShell version (`$PSVersionTable`)

---

## 🙏 Thank You

Thank you for using ntchk! This update ensures a smooth auto-update experience for all future releases.

**Upgrade now to get the fix and enjoy seamless updates going forward!** 🚀
