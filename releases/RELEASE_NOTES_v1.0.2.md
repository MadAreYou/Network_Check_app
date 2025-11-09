# Network Check v1.0.2 Release Notes

**Release Date**: November 9, 2025

## 🎉 What's New

### Auto-Update System
The biggest feature in this release is the **integrated auto-update system**! Network Check can now automatically check for and install updates directly from GitHub.

**Features:**
- ✅ **Automatic Checks** - App checks for updates on startup (can be disabled in Settings)
- ✅ **Manual Checks** - Click "Check for Updates" button in Settings tab
- ✅ **One-Click Installation** - Download and install updates with a single click
- ✅ **Smart Preservation** - Your settings and exported data are preserved during updates
- ✅ **Version Display** - See your current version in Settings tab (e.g., "Current version: v1.0.2")

**How to Use:**
1. Open Settings tab
2. See "Check for Updates" button in bottom-left corner
3. Click to manually check, or let it auto-check on startup
4. If update available, popup shows installed vs new version
5. Click "Upgrade Now" to install automatically
6. App restarts with new version!

### Hidden PowerShell Window
No more black console windows! We've added a VBScript launcher for a cleaner user experience.

**New Launchers:**
- ✅ **Run-NetworkCheck.vbs** - Double-click to launch app with NO PowerShell window (recommended)
- ✅ **Run-NetworkCheck.bat** - Enhanced batch launcher using VBScript wrapper

Both methods now launch the app silently without showing the PowerShell console.

### UI Enhancements

**Settings Tab:**
- Current version display (shows "Current version: v1.0.2")
- "Check for Updates" button (bottom-left corner)
- "Check for updates on startup" checkbox

**Update Popup:**
- Modern popup design with clean layout
- Shows installed version vs new version
- Real-time update status messages
- "Upgrade Now" and "Later" buttons
- Automatic restart prompt after successful update

## 🔧 Bug Fixes

- Fixed XAML structure corruption in Contact popup overlay
- Resolved XML parse error that prevented app launch in some cases
- Fixed Contact popup display issues

## ⚙️ Configuration Changes

New settings added to `config.json`:
```json
{
  "CheckUpdatesOnStartup": true,
  "LastUpdateCheck": "2025-11-09T12:00:00Z"
}
```

These settings are automatically added to existing configurations.

## 📁 New Files

- `src\Update.ps1` - Auto-update functionality module
- `Run-NetworkCheck.vbs` - VBScript hidden launcher

## 🔄 Upgrade Instructions

### From v1.0.1 or v1.0.0:

**Option 1: Auto-Update (Recommended)**
1. Download and extract v1.0.2
2. Future updates will be automatic!

**Option 2: Manual Update**
1. Download `NetworkCheck-v1.0.2-Portable.zip`
2. Extract to new folder
3. Copy your `config.json` from old installation (optional)
4. Copy your `exports` folder from old installation (optional)
5. Run `Run-NetworkCheck.vbs`

**Note**: Your settings and exports are preserved automatically during auto-updates.

## 📋 System Requirements

- **OS**: Windows 10/11 (or Windows Server 2016+)
- **PowerShell**: 5.1 or later (pre-installed on Windows 10/11)
- **Internet**: Required for speed testing and auto-updates
- **Permissions**: Some diagnostics require Administrator privileges

## 🚀 Quick Start

1. Extract `NetworkCheck-v1.0.2-Portable.zip`
2. Double-click `Run-NetworkCheck.vbs` (recommended) or `Run-NetworkCheck.bat`
3. Go to Settings tab to configure auto-updates
4. Enjoy automatic updates going forward!

## 📖 Documentation

- [README.md](../README.md) - Full application documentation
- [CHANGELOG.md](../CHANGELOG.md) - Complete version history
- [UPDATE-FEATURE-GUIDE.md](../UPDATE-FEATURE-GUIDE.md) - Update feature guide

## 🐛 Known Issues

None at this time. Please report any issues on [GitHub Issues](https://github.com/MadAreYou/Network_Check_app/issues).

## 💬 Feedback & Support

- **Email**: juraj@madzo.eu
- **LinkedIn**: [Juraj Madzunkov](https://linkedin.com/in/juraj-madzunkov-457389104)
- **GitHub Issues**: [Report a bug or request a feature](https://github.com/MadAreYou/Network_Check_app/issues)

## 💖 Support the Project

This app is free and open-source. If you find it useful, consider buying me a coffee!

**Revolut**: @jurajcy93

---

**Full Changelog**: [v1.0.1...v1.0.2](https://github.com/MadAreYou/Network_Check_app/compare/v1.0.1...v1.0.2)

**Download**: [NetworkCheck-v1.0.2-Portable.zip](https://github.com/MadAreYou/Network_Check_app/releases/tag/v1.0.2)
