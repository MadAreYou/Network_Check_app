# Build System for Network Check

This folder contains the automated packaging system for creating portable distributions.

## Quick Start

**To build the portable package:**

1. **Double-click** `BUILD.ps1`
   - OR run: `.\Build-Portable.ps1`

2. Wait for the build to complete

3. Find your package in: `releases\NetworkCheck-v1.0-Portable.zip`

---

## Files in This Folder

- **`BUILD.ps1`** - Quick launcher (just double-click this!)
- **`Build-Portable.ps1`** - Main build automation script
- **`Build-Config.json`** - Build settings (version, name, files to include)

---

## Build Configuration

Edit `Build-Config.json` to customize:

```json
{
  "AppName": "Network Check",
  "Version": "1.0.0",           ← Update this for new releases
  "Author": "Juraj Madzunkov",
  "ExeName": "NetworkCheck.exe"
}
```

---

## What Gets Packaged

The build script automatically includes:

✓ NetworkCheckApp.ps1 (main app)
✓ speedtest.exe (Ookla CLI)
✓ src\ (PowerShell modules)
✓ ui\ (XAML interface files)
✓ assets\ (icons, QR code)
✓ config.json (clean default settings)
✓ README.txt (auto-generated)
✓ Run-NetworkCheck.bat (launcher)

**Excluded:**
- Build files
- Logs
- User exports
- Git/IDE files

---

## Output

After building, you'll find in `releases\`:

```
NetworkCheck-v1.0-Portable.zip
```

This ZIP is ready to distribute - users just extract and run!

---

## Advanced Options

Run with parameters:

```powershell
.\Build-Portable.ps1 -OpenOutput      # Opens releases folder when done
.\Build-Portable.ps1 -SkipClean       # Keep temporary build files
```

---

## Troubleshooting

**Build fails?**
- Make sure you're in the project root
- Check that all source files exist
- Ensure config.json is clean (no personal paths)

**ZIP is too large?**
- Remove speedtest.exe if you want users to download it separately
- Check for leftover log files in src/ui folders

---

## Next Steps

After building:

1. **Test the package**
   - Extract to a new folder
   - Run and verify everything works
   - Test on a clean Windows machine if possible

2. **Distribute**
   - Upload to GitHub Releases
   - Share via your website
   - Send directly to users

3. **Version Management**
   - Update version in `Build-Config.json` for each release
   - Keep old ZIPs in releases folder for history

---

## Contact

For build system issues, contact:
- Email: juraj@madzo.eu
- LinkedIn: linkedin.com/in/juraj-madzunkov-457389104
