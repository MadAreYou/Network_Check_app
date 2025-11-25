# ntchk v1.0.5 - Auto-Update Fix (Portable Mode)

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
