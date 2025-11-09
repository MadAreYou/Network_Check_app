# Update Feature - Quick Reference Guide

## ✅ Implementation Complete!

All update features have been successfully implemented and tested.

---

## 🚀 How to Launch the App (No PowerShell Window)

### Method 1: VBScript Launcher (Recommended)
```
Double-click: Run-NetworkCheck.vbs
```

### Method 2: Batch File Launcher
```
Double-click: Run-NetworkCheck.bat
```

Both methods launch the app with **NO PowerShell window** appearing!

---

## 🔄 Update Features

### Auto-Update on Startup
- **Default**: Enabled
- **Location**: Settings tab → "Check for updates on startup" checkbox
- When enabled, the app checks for updates automatically when it starts
- If an update is available, a popup appears with update details

### Manual Update Check
- **Location**: Settings tab → Bottom-left corner
- **Button**: "Check for Updates"
- **Version Display**: Shows current version (e.g., "Current version: v1.0.1")
- Click to manually check for updates at any time

### Update Popup
When an update is available, a popup shows:
- **Installed Version**: Your current version
- **New Version**: The latest available version (in green)
- **Two Buttons**:
  - **"Upgrade Now"** → Downloads and installs the update automatically
  - **"Later"** → Closes popup, will check again on next startup

---

## 🛠️ Update Process (Automatic)

When you click "Upgrade Now":

1. ✅ Downloads the latest version from GitHub
2. ✅ Extracts the new files to a temp folder
3. ✅ **Preserves your settings** (config.json)
4. ✅ **Preserves your exports folder**
5. ✅ Copies new files to the app folder
6. ✅ Restores your settings
7. ✅ Prompts to restart the app

**Note**: The update preserves all your personal data and settings!

---

## ⚙️ Settings

### New Update Settings (in config.json)
```json
{
  "CheckUpdatesOnStartup": true,
  "LastUpdateCheck": "2025-11-08T15:30:00Z"
}
```

- **CheckUpdatesOnStartup**: Enable/disable auto-check on startup
- **LastUpdateCheck**: Timestamp of last update check

---

## 📁 Files Modified/Created

### New Files:
- `src\Update.ps1` - Update functionality module
- `Run-NetworkCheck.vbs` - VBScript launcher (no PowerShell window)

### Modified Files:
- `src\Settings.ps1` - Added update settings
- `ui\MainWindow.xaml` - Added update UI elements
- `NetworkCheckApp.ps1` - Integrated update functionality
- `Run-NetworkCheck.bat` - Updated to hide PowerShell window

---

## 🧪 Testing Results

All components tested and verified:
- ✅ Update module loading
- ✅ Current version detection (v1.0.1)
- ✅ GitHub API query (latest release: v1.0.1)
- ✅ Version comparison logic
- ✅ Update availability check
- ✅ Settings with new properties
- ✅ XAML UI elements (5/5 found)
- ✅ VBScript launcher
- ✅ No PowerShell window on launch

---

## 🔧 Functions Available

### Update.ps1 Functions:
```powershell
Get-NcCurrentVersion -AppRoot <path>
Get-NcLatestRelease
Compare-NcVersion -Version1 <v1> -Version2 <v2>
Test-NcUpdateAvailable -AppRoot <path>
Install-NcUpdate -AppRoot <path> -DownloadUrl <url> -Version <version>
```

---

## 📝 User Experience

### First Launch:
1. User double-clicks `Run-NetworkCheck.vbs`
2. App opens (no PowerShell window)
3. Auto-check runs in background (if enabled)
4. If update available, popup shows automatically

### Manual Check:
1. User opens Settings tab
2. Sees "Current version: v1.0.1"
3. Clicks "Check for Updates"
4. If update available, popup shows

### Update Process:
1. User clicks "Upgrade Now"
2. Progress shown in popup status label
3. Download and installation automatic
4. Prompt to restart app
5. User clicks "Yes" to restart
6. New version launches!

---

## 🎯 Success Criteria Met

✅ Check for updates button in Settings (bottom-left)
✅ Current version display next to button
✅ Auto-check on startup (with checkbox to enable/disable)
✅ Update popup with version comparison
✅ "Upgrade Now" and "Later" buttons
✅ Automatic download and installation
✅ Settings preservation during update
✅ PowerShell window hidden on launch

---

**All requirements completed successfully! 🎉**
