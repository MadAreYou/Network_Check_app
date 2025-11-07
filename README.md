#  Network Check App

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)

A modern, lightweight Windows desktop application for comprehensive network diagnostics and speed testing. Built with PowerShell and WPF, featuring a clean interface with dark mode support.

##  Features

###  Speed Test
- **Powered by Ookla Speedtest CLI** - Industry-standard speed testing
- Real-time download/upload speed measurements
- Ping, jitter, and latency metrics
- ISP and server information
- Export results to JSON format
- Auto-export option for automated testing

###  Network Information
- Automatic network name detection (WiFi/Ethernet)
- Public and local IP addresses
- Gateway and DNS server information
- One-click refresh with timestamp
- Clean, organized display

###  Diagnostics Tools
- **Traceroute** - Trace network path to any host
- **DNS Cache Flush** - Clear DNS resolver cache
- **IP Release/Renew** - Refresh DHCP configuration
- **Winsock Reset** - Fix network stack issues
- **ARP Cache Clear** - Clear address resolution cache
- Real-time command output display

###  Settings & Customization
- **Light/Dark Mode** - Toggle between themes
- **Export Folder** - Configure where results are saved
- **Desktop Shortcut** - Create/remove desktop shortcuts
- **Ookla CLI Path** - Customize speedtest.exe location
- Clean JSON-based configuration

###  Contact & Support
- Direct email and LinkedIn links
- Optional donation support (Revolut QR code)
- Professional contact popup

##  Installation

### Option 1: Portable Release (Recommended)
1. Download the latest `NetworkCheck-vX.X.X-Portable.zip` from [Releases](https://github.com/MadAreYou/Network_Check_app/tree/main/releases)
2. Extract to any folder
3. Run `Run-NetworkCheck.bat`

### Option 2: Clone Repository
```powershell
git clone https://github.com/MadAreYou/Network_Check_app.git
cd Network_Check_app
.\NetworkCheckApp.ps1
```

##  Quick Start

1. **Launch the application**
   - Double-click `Run-NetworkCheck.bat`
   - Or right-click `NetworkCheckApp.ps1`  "Run with PowerShell"

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

##  Requirements

- **Operating System**: Windows 10/11 (or Windows Server 2016+)
- **PowerShell**: Version 5.1 or later (pre-installed on Windows 10/11)
- **Internet**: Required for speed testing
- **Permissions**: Some diagnostics require Administrator privileges

##  Building from Source

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

##  Project Structure

```
Network_Check_app/
 NetworkCheckApp.ps1       # Main application entry point
 config.json              # User configuration (auto-created)
 speedtest.exe            # Ookla Speedtest CLI (1.2MB)
 ui/
    MainWindow.xaml      # WPF interface definition
 src/
    Settings.ps1         # Configuration management
    Export.ps1           # Result export functions
    NetworkInfo.ps1      # Network information gathering
    Diagnostics.ps1      # Diagnostic tool implementations
    SpeedTest.ps1        # Speed test execution
 assets/
    desktop_icon.ico     # Desktop shortcut icon
    revolut_qr.png       # Donation QR code (optional)
 build/
    Build-Portable.ps1   # Portable release packager
    Build-Config.json    # Build configuration
    README.md            # Build documentation
 exports/                 # Speed test results (user data)
```

##  Screenshots

*Coming soon - Add screenshots of:*
- Speed Test tab in action
- Network Info display
- Diagnostics tools
- Dark mode vs Light mode
- Settings panel

##  Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add YourFeature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

##  Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

##  License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

**Note**: This project includes the Ookla Speedtest CLI (`speedtest.exe`), which is licensed separately by Ookla. See https://www.speedtest.net/apps/cli

##  Author

**Juraj Madžunkov**
- LinkedIn: [LinkedIn](https://linkedin.com/in/juraj-madzunkov-457389104)
- Email: juraj@madzo.eu

##  Support

This app is free and open-source. If you find it useful, consider buying me a coffee!

**Revolut**: @jurajcy93

##  Acknowledgments

- [Ookla](https://www.speedtest.net/) for the excellent Speedtest CLI
- The PowerShell and WPF communities for inspiration and resources

---

<div align="center">
Made with  in PowerShell
</div>
