# 🌐 Network Check App# 🌐 Network Check App# Network Check App (PowerShell + WPF)



![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)

![License](https://img.shields.io/badge/license-MIT-green.svg)

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)A portable Windows desktop tool with two core functions:

![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)

![License](https://img.shields.io/badge/license-MIT-green.svg)- Speed Test: Live in-app progress using a LibreSpeed-compatible CLI (or simulated if not present).

A modern, lightweight Windows desktop application for comprehensive network diagnostics and speed testing. Built with PowerShell and WPF, featuring a clean interface with dark mode support.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)- Network Info & Diagnostics: LAN/WAN/ISP snapshot, ping, DNS lookup, traceroute, and common repair actions.

## ✨ Features

![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)

### 🚀 Speed Test

- **Powered by Ookla Speedtest CLI** - Industry-standard speed testingNo external installation required at runtime. Can be packaged into a single EXE.

- Real-time download/upload speed measurements

- Ping, jitter, and latency metricsA modern, lightweight Windows desktop application for comprehensive network diagnostics and speed testing. Built with PowerShell and WPF, featuring a clean interface with dark mode support.

- ISP and server information

- Export results to JSON format## Contents

- Auto-export option for automated testing

## ✨ Features- `NetworkCheckApp.ps1` — Entry point. Loads the WPF UI and wires modules.

### 🌐 Network Information

- Automatic network name detection (WiFi/Ethernet)- `ui/MainWindow.xaml` — WPF XAML for tabs and controls.

- Public and local IP addresses

- Gateway and DNS server information### 🚀 Speed Test- `src/Settings.ps1` — App settings persistence in `config.json` next to the app.

- One-click refresh with timestamp

- Clean, organized display- **Powered by Ookla Speedtest CLI** - Industry-standard speed testing- `src/Export.ps1` — Export helpers (JSON/CSV/TXT) and clipboard copy.



### 🔧 Diagnostics Tools- Real-time download/upload speed measurements- `src/NetworkInfo.ps1` — Network snapshot functions (reusing Windows tools).

- **Traceroute** - Trace network path to any host

- **DNS Cache Flush** - Clear DNS resolver cache- Ping, jitter, and latency metrics- `src/Diagnostics.ps1` — Ping, nslookup, traceroute, and repair actions.

- **IP Release/Renew** - Refresh DHCP configuration

- **Winsock Reset** - Fix network stack issues- ISP and server information- `src/SpeedTest.ps1` — Speed test engine using `librespeed-cli.exe` if available, or a simulation fallback.

- **ARP Cache Clear** - Clear address resolution cache

- Real-time command output display- Export results to JSON format



### ⚙️ Settings & Customization- Auto-export option for automated testing## Running from source

- **Light/Dark Mode** - Toggle between themes

- **Export Folder** - Configure where results are savedOpen Windows PowerShell (v5.1) and execute:

- **Desktop Shortcut** - Create/remove desktop shortcuts

- **Ookla CLI Path** - Customize speedtest.exe location### 🌐 Network Information

- Clean JSON-based configuration

- Automatic network name detection (WiFi/Ethernet)```powershell

### 📞 Contact & Support

- Direct email and LinkedIn links- Public and local IP addresses# From the app folder

- Optional donation support (Revolut QR code)

- Professional contact popup- Gateway and DNS server informationpowershell.exe -ExecutionPolicy Bypass -File .\NetworkCheckApp.ps1



## 📦 Installation- One-click refresh with timestamp```



### Option 1: Portable Release (Recommended)- Clean, organized display

1. Download the latest `NetworkCheck-vX.X.X-Portable.zip` from [Releases](https://github.com/MadAreYou/Network_Check_app/releases)

   > **Note:** No releases yet! First release coming soon. In the meantime, use Option 2 below.If the `librespeed-cli.exe` is not present, the Speed Test tab will simulate results unless you point Settings to the CLI binary.

2. Extract to any folder

3. Run `NetworkCheckApp.ps1` or `Launch-NetworkCheck.bat`### 🔧 Diagnostics Tools



### Option 2: Clone Repository- **Traceroute** - Trace network path to any host## Speed test engine

```powershell

git clone https://github.com/MadAreYou/Network_Check_app.git- **DNS Cache Flush** - Clear DNS resolver cache- Preferred: `librespeed-cli.exe` (Windows x64) placed next to the app or configured under Settings.

cd Network_Check_app

.\NetworkCheckApp.ps1- **IP Release/Renew** - Refresh DHCP configuration- The app reads CLI output to update Ping/Download/Upload live when available; otherwise it will parse final JSON (`--json`).

```

- **Winsock Reset** - Fix network stack issues- If not available, enable "Simulate speed test" under Settings to see UI behavior without the CLI.

## 🚀 Quick Start

- **ARP Cache Clear** - Clear address resolution cache

1. **Launch the application**

   - Double-click `NetworkCheckApp.ps1` or `Launch-NetworkCheck.bat`- Real-time command output display## Packaging as a single EXE

   - Or right-click `NetworkCheckApp.ps1` → "Run with PowerShell"

You can package this app into a single executable using tools like PS2EXE. Ensure two things during packaging:

2. **Run a speed test**

   - Click the **Speed Test** tab### ⚙️ Settings & Customization1) Include `ui/` and `src/` content.

   - Click **Start Speed Test**

   - Wait for results (30-60 seconds)- **Light/Dark Mode** - Toggle between themes2) Bundle `librespeed-cli.exe` alongside the EXE (or embed as a resource if your packager supports it). The app will prefer a CLI next to the EXE.

   - Optionally export results

- **Export Folder** - Configure where results are saved

3. **Check network information**

   - Click the **Network Info** tab- **Desktop Shortcut** - Create/remove desktop shortcutsExample (optional) with PS2EXE:

   - View all network details

   - Click **Refresh** to update- **Ookla CLI Path** - Customize speedtest.exe location```powershell



4. **Use diagnostics tools**- Clean JSON-based configuration# Install PS2EXE if needed

   - Click the **Diagnostics** tab

   - Select a tool (traceroute, flush DNS, etc.)Install-Module ps2exe -Scope CurrentUser

   - View real-time output

### 📞 Contact & Support

5. **Customize settings**

   - Click the **Settings** tab- Direct email and LinkedIn links# Build single EXE

   - Configure export folder, theme, shortcuts

   - Changes save automatically- Optional donation support (Revolut QR code)ps2exe -inputFile .\NetworkCheckApp.ps1 -outputFile .\NetworkCheckApp.exe -title "Network Check" -iconFile .\app.ico



## 📋 Requirements- Professional contact popup```



- **Operating System**: Windows 10/11 (or Windows Server 2016+)

- **PowerShell**: Version 5.1 or later (pre-installed on Windows 10/11)

- **Internet**: Required for speed testing## 📦 InstallationNote: Some packagers extract to a temporary folder at runtime. This app stores `config.json` and exports in the same folder as the EXE by default.

- **Permissions**: Some diagnostics require Administrator privileges



## 🏗️ Building from Source

### Option 1: Portable Release (Recommended)## Notes

### Build Portable Release

1. Download the latest `NetworkCheck-vX.X.X-Portable.zip` from [Releases](https://github.com/MadAreYou/Network_Check_app/releases)- WMIC usage is kept to reuse existing script logic. In a future version, we can migrate to PowerShell Get-Net* cmdlets for better forward compatibility.

```powershell

# Navigate to build folder2. Extract to any folder- Some repair actions require Administrator privileges.

cd build

3. Run `NetworkCheckApp.ps1` or `Launch-NetworkCheck.bat`- Public IP and ISP org checks require internet access.

# Run build script

.\Build-Portable.ps1



# Output: releases/NetworkCheck-vX.X.X-Portable.zip### Option 2: Clone Repository## License

```

```powershellThis app reuses Windows built-in tools. If you distribute `librespeed-cli.exe`, please include its license/attribution in your distribution.

The build script automatically:git clone https://github.com/MadAreYou/Network_Check_app.git

- Creates clean temp foldercd Network_Check_app

- Copies all required files.\NetworkCheckApp.ps1

- Generates README.txt```

- Creates launcher batch file

- Compresses to ZIP format## 🚀 Quick Start



### Customize Build1. **Launch the application**

   - Double-click `NetworkCheckApp.ps1` or `Launch-NetworkCheck.bat`

Edit `build/Build-Config.json`:   - Or right-click `NetworkCheckApp.ps1` → "Run with PowerShell"

```json

{2. **Run a speed test**

    "version": "1.0.0",   - Click the **Speed Test** tab

    "appName": "Network Check",   - Click **Start Speed Test**

    "author": "Your Name"   - Wait for results (30-60 seconds)

}   - Optionally export results

```

3. **Check network information**

## 🗂️ Project Structure   - Click the **Network Info** tab

   - View all network details

```   - Click **Refresh** to update

Network_Check_app/

├── NetworkCheckApp.ps1       # Main application entry point4. **Use diagnostics tools**

├── config.json              # User configuration (auto-created)   - Click the **Diagnostics** tab

├── speedtest.exe            # Ookla Speedtest CLI (1.2MB)   - Select a tool (traceroute, flush DNS, etc.)

├── ui/   - View real-time output

│   └── MainWindow.xaml      # WPF interface definition

├── src/5. **Customize settings**

│   ├── Settings.ps1         # Configuration management   - Click the **Settings** tab

│   ├── Export.ps1           # Result export functions   - Configure export folder, theme, shortcuts

│   ├── NetworkInfo.ps1      # Network information gathering   - Changes save automatically

│   ├── Diagnostics.ps1      # Diagnostic tool implementations

│   └── SpeedTest.ps1        # Speed test execution## 📋 Requirements

├── assets/

│   ├── desktop_icon.ico     # Desktop shortcut icon- **Operating System**: Windows 10/11 (or Windows Server 2016+)

│   └── revolut_qr.png       # Donation QR code (optional)- **PowerShell**: Version 5.1 or later (pre-installed on Windows 10/11)

├── build/- **Internet**: Required for speed testing

│   ├── Build-Portable.ps1   # Portable release packager- **Permissions**: Some diagnostics require Administrator privileges

│   ├── Build-Config.json    # Build configuration

│   └── README.md            # Build documentation## 🏗️ Building from Source

└── exports/                 # Speed test results (user data)

```### Build Portable Release



## 🎨 Screenshots```powershell

# Navigate to build folder

*Coming soon - Add screenshots of:*cd build

- Speed Test tab in action

- Network Info display# Run build script

- Diagnostics tools.\Build-Portable.ps1

- Dark mode vs Light mode

- Settings panel# Output: releases/NetworkCheck-vX.X.X-Portable.zip

```

## 🤝 Contributing

The build script automatically:

Contributions are welcome! Please feel free to submit issues or pull requests.- Creates clean temp folder

- Copies all required files

1. Fork the repository- Generates README.txt

2. Create a feature branch (`git checkout -b feature/YourFeature`)- Creates launcher batch file

3. Commit your changes (`git commit -m 'Add YourFeature'`)- Compresses to ZIP format

4. Push to the branch (`git push origin feature/YourFeature`)

5. Open a Pull Request### Customize Build



See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.Edit `build/Build-Config.json`:

```json

## 📝 Changelog{

    "version": "1.0.0",

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.    "appName": "Network Check",

    "author": "Your Name"

## 📄 License}

```

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🗂️ Project Structure

**Note**: This project includes the Ookla Speedtest CLI (`speedtest.exe`), which is licensed separately by Ookla. See https://www.speedtest.net/apps/cli

```

## 👨‍💻 AuthorNetwork_Check_app/

├── NetworkCheckApp.ps1       # Main application entry point

**Juraj Madžunkov**├── config.json              # User configuration (auto-created)

- LinkedIn: [LinkedIn](https://linkedin.com/in/juraj-madzunkov-457389104)├── speedtest.exe            # Ookla Speedtest CLI (1.2MB)

- Email: juraj@madzo.eu├── ui/

│   └── MainWindow.xaml      # WPF interface definition

## ☕ Support├── src/

│   ├── Settings.ps1         # Configuration management

This app is free and open-source. If you find it useful, consider buying me a coffee!│   ├── Export.ps1           # Result export functions

│   ├── NetworkInfo.ps1      # Network information gathering

**Revolut**: @jurajcy93│   ├── Diagnostics.ps1      # Diagnostic tool implementations

│   └── SpeedTest.ps1        # Speed test execution

## 🙏 Acknowledgments├── assets/

│   ├── desktop_icon.ico     # Desktop shortcut icon

- [Ookla](https://www.speedtest.net/) for the excellent Speedtest CLI│   └── revolut_qr.png       # Donation QR code (optional)

- The PowerShell and WPF communities for inspiration and resources├── build/

│   ├── Build-Portable.ps1   # Portable release packager

---│   ├── Build-Config.json    # Build configuration

│   └── README.md            # Build documentation

<div align="center">└── exports/                 # Speed test results (user data)

Made with ❤️ in PowerShell```

</div>

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
