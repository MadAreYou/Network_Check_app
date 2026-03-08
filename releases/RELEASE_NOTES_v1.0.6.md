# ntchk v1.0.6 - Subnet & CIDR Calculator

**Release Date**: March 7, 2026

## 📥 Download & Install

### 📦 Release Assets (2 files required)

| File | Description |
|------|-------------|
| `ntchk-v1.0.6-Portable.zip` | Main application package |
| `ntchk-v1.0.6-Portable.zip.sha256` | SHA256 checksum for verification |

**⬇️ Download both files from the Assets section below**

### 🔒 Security First

⚠️ **Always verify the checksum before running!** See the **File Verification** section below.

### 🚀 Quick Installation

1. **Download** both files from GitHub releases
2. **Verify** the download using the `.sha256` file
3. **Extract** ZIP to any folder (USB drive, network share, local drive - all supported)
4. **Run** `ntchk.exe` (recommended) or `ntchk.bat`
5. **Done!** No installation, no registry changes, fully portable

---

## 🎯 What's New

### 🔢 Subnet & CIDR Calculator — New Tab

A full subnet and CIDR calculation tool has been added as a new **"Subnet Calc"** tab, located between Diagnostics and Settings.

#### Subnet Calculator
Live classful subnet math. Select Network Class (A / B / C), enter an IP address, pick a subnet mask — all fields update instantly:

| Field | Description |
|-------|-------------|
| First Octet Range | Valid first-octet range for the selected class |
| Hex IP Address | Dotted hexadecimal representation of the IP |
| Wildcard Mask | Inverse mask for ACL use |
| Subnet Bits | Number of bits borrowed from the host portion |
| Mask Bits | Total prefix length |
| Maximum Subnets | Number of subnets available for the class |
| Hosts per Subnet | Usable host addresses per subnet |
| Host Address Range | First to last usable host address |
| Subnet ID | Network address |
| Broadcast Address | Directed broadcast address |
| Subnet Bitmap | Bit-level visual breakdown (class-id · network · host bits) |

#### CIDR Calculator
Live classless CIDR math. Enter an IP address and select a mask length (1–32) — all fields update instantly:

| Field | Description |
|-------|-------------|
| CIDR Netmask | Subnet mask in dotted-quad notation |
| Wildcard Mask | Inverse mask for ACL use |
| Maximum Subnets | Total number of addresses in the block (2^host-bits) |
| Maximum Addresses | Usable host addresses (Maximum Subnets − 2) |
| CIDR Network | Network address of the block |
| Net: CIDR Notation | Network address with prefix (e.g. 192.168.1.0/24) |
| CIDR Address Range | First to last usable host address |

All fields recalculate on every keystroke or dropdown change — no button required.

---

## 🛠️ Technical Notes

- New `src/SubnetCalc.ps1` module — self-contained, no external dependencies, pure PowerShell arithmetic
- Integer arithmetic uses `[Math]::Floor` throughout to prevent PowerShell banker's rounding from corrupting octet values (e.g. 255.996… rounding up to 256)
- Class selection tracked via `$Script:SubnetClass` to prevent WPF nullable bool timing issues in deeply nested event handlers
- Light and Dark mode fully supported — uses existing dynamic resource brushes

---

## 🔄 Compatibility

- All existing features unchanged (Speed Test, Network Info, Diagnostics, Settings)
- Settings and configuration backward compatible
- No new dependencies

---

## 🔒 File Verification

After downloading, verify the ZIP integrity before running:

```powershell
# Run in PowerShell in the folder where you downloaded the files
$hash = Get-FileHash "ntchk-v1.0.6-Portable.zip" -Algorithm SHA256
$expected = Get-Content "ntchk-v1.0.6-Portable.zip.sha256"
if ($hash.Hash -eq $expected.Trim()) { "✅ MATCH - Safe to extract" } else { "❌ MISMATCH - Do not run!" }
```
