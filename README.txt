=====================================
  Network Check v1.0.0
=====================================

Network Speed Test and Diagnostics Tool

Author: Juraj Madzunkov
(c) 2025 Juraj Madzunkov

=====================================
QUICK START
=====================================

1. Extract this ZIP to any folder
2. Run: NetworkCheckApp.ps1
   - Right-click â†’ Run with PowerShell
   - OR double-click if .ps1 files are associated

3. First-time setup:
   - The app will auto-configure paths
   - Go to Settings â†’ Create Desktop Shortcut (optional)

=====================================
REQUIREMENTS
=====================================

- Windows 10/11 (PowerShell 5.1+)
- Internet connection for speed tests
- Administrator rights (for some diagnostics)

=====================================
FEATURES
=====================================

âœ“ Speed Test (powered by Ookla)
  - Download/Upload speeds
  - Ping and latency
  - ISP and server info
  - Export results to JSON

âœ“ Network Information
  - Network name (WiFi/Ethernet)
  - IP address (public & local)
  - Gateway and DNS servers
  - Connection type and status
  - Auto-refresh with timestamp

âœ“ Diagnostics
  - Traceroute to custom hosts
  - DNS flush
  - IP release/renew
  - Winsock reset
  - ARP cache clear

âœ“ Settings
  - Light/Dark mode themes
  - Export folder configuration
  - Auto-export after speed test
  - Desktop shortcut management

=====================================
PORTABLE MODE
=====================================

This app is fully portable:
- No installation required
- No registry changes
- All settings in config.json
- Can run from USB drive
- Move folder anywhere

=====================================
CONTACT & SUPPORT
=====================================

Email: juraj@madzo.eu
LinkedIn: linkedin.com/in/juraj-madzunkov-457389104

If you like this app, consider buying me a coffee!
Revolut: @jurajcy93

=====================================
TROUBLESHOOTING
=====================================

If the app doesn't start:
1. Right-click NetworkCheckApp.ps1
2. Select "Run with PowerShell"
3. If blocked by security:
   - Right-click â†’ Properties
   - Check "Unblock" â†’ OK

For execution policy errors:
  powershell.exe -ExecutionPolicy Bypass -File NetworkCheckApp.ps1

=====================================
