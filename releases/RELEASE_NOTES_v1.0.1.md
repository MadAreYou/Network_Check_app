# Network Check v1.0.1 - Release Notes

**Release Date:** November 8, 2025  
**Download:** [NetworkCheck-v1.0.1-Portable.zip](https://github.com/MadAreYou/Network_Check_app/releases/download/v1.0.1/NetworkCheck-v1.0.1-Portable.zip)

---

## 🔧 Bug Fixes

### Portability Fix - Settings.ps1 Path Resolution
- **Fixed:** Hardcoded absolute paths causing "Access Denied" errors on different machines
- **Added:** Automatic conversion of relative paths to absolute based on app location
- **Result:** App now works correctly when extracted to any folder location

This was a critical fix for users running the app on different computers. The app previously failed to start when extracted to a different path than the original development machine.

---

## ✨ Improvements

### Added Run-NetworkCheck.bat Launcher
- **Easy Start:** Double-click to launch the app without right-click "Run with PowerShell"
- **Hidden Window:** Cleaner execution with hidden PowerShell window
- **Error Handling:** Helpful instructions if the app fails to start

Simply double-click `Run-NetworkCheck.bat` to start the application!

---

## ⚙️ Configuration Changes

### config.json - User-Generated File
- **No Longer Tracked:** `config.json` is now excluded from version control
- **Auto-Created:** Will be automatically generated on first run with correct paths
- **Portable:** No conflicts when moving the app to different locations

Your settings are preserved locally and won't conflict with updates!

---

## 📦 Installation

1. **Download:** [NetworkCheck-v1.0.1-Portable.zip](https://github.com/MadAreYou/Network_Check_app/releases/download/v1.0.1/NetworkCheck-v1.0.1-Portable.zip)
2. **Extract:** Unzip to any folder on your computer
3. **Run:** Double-click `Run-NetworkCheck.bat`

**No installation required!** The app is fully portable and can be run from any location, including USB drives.

---

## 📋 Requirements

- Windows 10/11 (PowerShell 5.1+)
- Internet connection for speed tests
- Administrator rights (for some diagnostics)

---

## 🐛 Known Issues

None reported for this version.

---

## 📝 Full Changelog

See [CHANGELOG.md](https://github.com/MadAreYou/Network_Check_app/blob/main/CHANGELOG.md) for complete version history.

---

## 💬 Feedback & Support

- **Email:** juraj@madzo.eu
- **LinkedIn:** [linkedin.com/in/juraj-madzunkov-457389104](https://linkedin.com/in/juraj-madzunkov-457389104)
- **Issues:** [GitHub Issues](https://github.com/MadAreYou/Network_Check_app/issues)

---

## ☕ Support the Project

If you find this app useful, consider supporting development:

**Revolut:** @jurajcy93

---

**Previous Release:** [v1.0.0](https://github.com/MadAreYou/Network_Check_app/releases/tag/v1.0.0)
