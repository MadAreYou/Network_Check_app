# 🌐 Network Check App# Network Check App (PowerShell + WPF)



![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)A portable Windows desktop tool with two core functions:

![License](https://img.shields.io/badge/license-MIT-green.svg)- Speed Test: Live in-app progress using a LibreSpeed-compatible CLI (or simulated if not present).

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)- Network Info & Diagnostics: LAN/WAN/ISP snapshot, ping, DNS lookup, traceroute, and common repair actions.

![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)

No external installation required at runtime. Can be packaged into a single EXE.

A modern, lightweight Windows desktop application for comprehensive network diagnostics and speed testing. Built with PowerShell and WPF, featuring a clean interface with dark mode support.

## Contents

## ✨ Features- `NetworkCheckApp.ps1` — Entry point. Loads the WPF UI and wires modules.

- `ui/MainWindow.xaml` — WPF XAML for tabs and controls.

### 🚀 Speed Test- `src/Settings.ps1` — App settings persistence in `config.json` next to the app.

- **Powered by Ookla Speedtest CLI** - Industry-standard speed testing- `src/Export.ps1` — Export helpers (JSON/CSV/TXT) and clipboard copy.

- Real-time download/upload speed measurements- `src/NetworkInfo.ps1` — Network snapshot functions (reusing Windows tools).

- Ping, jitter, and latency metrics- `src/Diagnostics.ps1` — Ping, nslookup, traceroute, and repair actions.

- ISP and server information- `src/SpeedTest.ps1` — Speed test engine using `librespeed-cli.exe` if available, or a simulation fallback.

- Export results to JSON format

- Auto-export option for automated testing## Running from source

Open Windows PowerShell (v5.1) and execute:

### 🌐 Network Information

- Automatic network name detection (WiFi/Ethernet)```powershell

- Public and local IP addresses# From the app folder

- Gateway and DNS server informationpowershell.exe -ExecutionPolicy Bypass -File .\NetworkCheckApp.ps1

- One-click refresh with timestamp```

- Clean, organized display

If the `librespeed-cli.exe` is not present, the Speed Test tab will simulate results unless you point Settings to the CLI binary.

### 🔧 Diagnostics Tools

- **Traceroute** - Trace network path to any host## Speed test engine

- **DNS Cache Flush** - Clear DNS resolver cache- Preferred: `librespeed-cli.exe` (Windows x64) placed next to the app or configured under Settings.

- **IP Release/Renew** - Refresh DHCP configuration- The app reads CLI output to update Ping/Download/Upload live when available; otherwise it will parse final JSON (`--json`).

- **Winsock Reset** - Fix network stack issues- If not available, enable "Simulate speed test" under Settings to see UI behavior without the CLI.

- **ARP Cache Clear** - Clear address resolution cache

- Real-time command output display## Packaging as a single EXE

You can package this app into a single executable using tools like PS2EXE. Ensure two things during packaging:

### ⚙️ Settings & Customization1) Include `ui/` and `src/` content.

- **Light/Dark Mode** - Toggle between themes2) Bundle `librespeed-cli.exe` alongside the EXE (or embed as a resource if your packager supports it). The app will prefer a CLI next to the EXE.

- **Export Folder** - Configure where results are saved

- **Desktop Shortcut** - Create/remove desktop shortcutsExample (optional) with PS2EXE:

- **Ookla CLI Path** - Customize speedtest.exe location```powershell

- Clean JSON-based configuration# Install PS2EXE if needed

Install-Module ps2exe -Scope CurrentUser

### 📞 Contact & Support

- Direct email and LinkedIn links# Build single EXE

- Optional donation support (Revolut QR code)ps2exe -inputFile .\NetworkCheckApp.ps1 -outputFile .\NetworkCheckApp.exe -title "Network Check" -iconFile .\app.ico

- Professional contact popup```



## 📦 InstallationNote: Some packagers extract to a temporary folder at runtime. This app stores `config.json` and exports in the same folder as the EXE by default.



### Option 1: Portable Release (Recommended)## Notes

1. Download the latest `NetworkCheck-vX.X.X-Portable.zip` from [Releases](https://github.com/MadAreYou/Network_Check_app/releases)- WMIC usage is kept to reuse existing script logic. In a future version, we can migrate to PowerShell Get-Net* cmdlets for better forward compatibility.

2. Extract to any folder- Some repair actions require Administrator privileges.

3. Run `NetworkCheckApp.ps1` or `Launch-NetworkCheck.bat`- Public IP and ISP org checks require internet access.



### Option 2: Clone Repository## License

```powershellThis app reuses Windows built-in tools. If you distribute `librespeed-cli.exe`, please include its license/attribution in your distribution.
git clone https://github.com/MadAreYou/Network_Check_app.git
cd Network_Check_app
.\NetworkCheckApp.ps1
```

## 🚀 Quick Start

1. **Launch the application**
   - Double-click `NetworkCheckApp.ps1` or `Launch-NetworkCheck.bat`
   - Or right-click `NetworkCheckApp.ps1` → "Run with PowerShell"

2. **Run a speed test**
   - Click the **Speed Test** tab
   - Click **Start Speed Test**
   - Wait for results (30-60 seconds)
   - Optionally export results

3. **Check network information**
   - Click the **Network Info** tab
   - View all network details
   - Click **Refresh** to update

4. **Use diagnostics tools**
   - Click the **Diagnostics** tab
   - Select a tool (traceroute, flush DNS, etc.)
   - View real-time output

5. **Customize settings**
   - Click the **Settings** tab
   - Configure export folder, theme, shortcuts
   - Changes save automatically

## 📋 Requirements

- **Operating System**: Windows 10/11 (or Windows Server 2016+)
- **PowerShell**: Version 5.1 or later (pre-installed on Windows 10/11)
- **Internet**: Required for speed testing
- **Permissions**: Some diagnostics require Administrator privileges

## 🏗️ Building from Source

### Build Portable Release

```powershell
# Navigate to build folder
cd build

# Run build script
.\Build-Portable.ps1

# Output: releases/NetworkCheck-vX.X.X-Portable.zip
```

The build script automatically:
- Creates clean temp folder
- Copies all required files
- Generates README.txt
- Creates launcher batch file
- Compresses to ZIP format

### Customize Build

Edit `build/Build-Config.json`:
```json
{
    "version": "1.0.0",
    "appName": "Network Check",
    "author": "Your Name"
}
```

## 🗂️ Project Structure

```
Network_Check_app/
├── NetworkCheckApp.ps1       # Main application entry point
├── config.json              # User configuration (auto-created)
├── speedtest.exe            # Ookla Speedtest CLI (1.2MB)
├── ui/
│   └── MainWindow.xaml      # WPF interface definition
├── src/
│   ├── Settings.ps1         # Configuration management
│   ├── Export.ps1           # Result export functions
│   ├── NetworkInfo.ps1      # Network information gathering
│   ├── Diagnostics.ps1      # Diagnostic tool implementations
│   └── SpeedTest.ps1        # Speed test execution
├── assets/
│   ├── desktop_icon.ico     # Desktop shortcut icon
│   └── revolut_qr.png       # Donation QR code (optional)
├── build/
│   ├── Build-Portable.ps1   # Portable release packager
│   ├── Build-Config.json    # Build configuration
│   └── README.md            # Build documentation
└── exports/                 # Speed test results (user data)
```

## 🎨 Screenshots

*Coming soon - Add screenshots of:*
- Speed Test tab in action
- Network Info display
- Diagnostics tools
- Dark mode vs Light mode
- Settings panel

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add YourFeature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

**Note**: This project includes the Ookla Speedtest CLI (`speedtest.exe`), which is licensed separately by Ookla. See https://www.speedtest.net/apps/cli

## 👨‍💻 Author

**Juraj Madžunkov**
- LinkedIn: [Juraj Madžunkov](https://www.linkedin.com/in/juraj-madžunkov-53419925b/)
- Email: juraj.madzunkov.main@gmail.com

## ☕ Support

This app is free and open-source. If you find it useful, consider buying me a coffee!

**Revolut**: @jurajcy93

## 🙏 Acknowledgments

- [Ookla](https://www.speedtest.net/) for the excellent Speedtest CLI
- The PowerShell and WPF communities for inspiration and resources

---

<div align="center">
Made with ❤️ in PowerShell
</div>
