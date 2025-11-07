# Network Check - Version History

## Version 1.0.0 (2025-11-07)

### Features
- ✨ **Speed Test** - Powered by Ookla Speedtest CLI
  - Download/Upload speeds with real-time progress
  - Ping, jitter, and latency measurements
  - ISP and server information
  - Export results to JSON format
  
- 🌐 **Network Information**
  - Network name detection (WiFi and Ethernet)
  - Public and local IP addresses
  - Gateway and DNS server information
  - Auto-refresh with timestamp
  - Lime green progress spinner
  
- 🔧 **Diagnostics Tools**
  - Traceroute to custom hosts
  - DNS cache flush
  - IP release/renew
  - Winsock reset
  - ARP cache clear
  - Real-time output display
  
- ⚙️ **Settings & Customization**
  - Light/Dark mode themes
  - Export folder configuration
  - Auto-export after speed test
  - Desktop shortcut management
  - Ookla CLI path configuration
  
- 📞 **Contact & Support**
  - Email and LinkedIn links
  - Donation QR code (Revolut)
  - Professional contact popup

### UI/UX Improvements
- Fixed dark mode display across all tabs
- Clean contact popup with proper character encoding
- LinkedIn displayed as "[in]LinkedIn Profile" with brand color
- Desktop shortcut creation/removal buttons
- Responsive layout with proper theming

### Build System
- Automated portable ZIP packaging
- Clean configuration templates
- Professional documentation generation
- Version management system

### Technical Details
- Built with PowerShell 5.1+ and WPF
- Fully portable - no installation required
- No registry modifications
- Clean JSON-based configuration
- Async operations for responsive UI
- Multi-network-type support (WiFi/Ethernet)

### Known Limitations
- Requires Windows PowerShell 5.1 or later
- Some diagnostics require Administrator privileges
- Speedtest requires internet connection

---

## Future Versions (Planned)

### Version 1.1.0 (TBD)
- [ ] Network monitoring over time
- [ ] Speed test scheduling
- [ ] Export to CSV/Excel
- [ ] Network history graphs
- [ ] Connection stability monitoring

### Version 1.2.0 (TBD)
- [ ] Multiple language support
- [ ] Custom themes
- [ ] Plugin system
- [ ] Cloud sync for settings

---

## Release Notes Template

Use this template for future releases:

```markdown
## Version X.Y.Z (YYYY-MM-DD)

### New Features
- Feature description

### Improvements
- Improvement description

### Bug Fixes
- Bug fix description

### Breaking Changes
- Any breaking changes (if applicable)
```

