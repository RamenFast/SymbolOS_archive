# iOS 6 Debugging Extensions for SymbolOS

Complete toolkit for iPhone 4s recovery, jailbreaking, file transfer, and comprehensive debugging on iOS 6.

## 📋 Files Included

### Core Scripts

| File | Language | Purpose |
|------|----------|---------|
| `Invoke-iOS6Debug.ps1` | PowerShell 7.6.0 | Full-featured interactive menu (recommended) |
| `Launch-iOS6Debug.ps1` | PowerShell 7.6.0 | One-click launcher (easiest) |
| `ios6_debug_suite.py` | Python 3 | Cross-platform debugging module |
| `ios6_debug_windows.bat` | Batch | Legacy Windows batch interface |

### Documentation

| File | Purpose |
|------|---------|
| `POWERSHELL_QUICKSTART.md` | PowerShell 7 quick start guide |
| `iOS6_DEBUG_README.md` | This file |

### Full Documentation

- `../docs/iOS6_DEBUGGING_GUIDE.md` - Comprehensive debugging guide (50+ pages)

---

## 🚀 Quick Start (Choose One)

### Option 1: PowerShell (Recommended) ⭐

**Easiest one-click method:**
```powershell
cd C:\path\to\SymbolOS
.\extensions\Launch-iOS6Debug.ps1
```

**Or with parameters:**
```powershell
.\extensions\Invoke-iOS6Debug.ps1 -DeviceUDID "a1b2c3d4..." -BackupPath "C:\backup"
```

### Option 2: Python (Cross-Platform)

```bash
python3 extensions/ios6_debug_suite.py --udid <UDID> --backup ~/iphone_backup
```

### Option 3: Batch (Legacy Windows)

```cmd
cd C:\path\to\SymbolOS\extensions
ios6_debug_windows.bat <UDID>
```

---

## 🎯 Features

### USB Debugging
- ✅ Device pairing and detection
- ✅ File push/pull via USB
- ✅ Device information retrieval
- ✅ Filesystem mounting (requires jailbreak)

### Kernel Debugging
- ✅ LLDB/GDB remote debugging
- ✅ Memory inspection and modification
- ✅ Breakpoint management
- ✅ Kernel symbol resolution

### Recovery Mode
- ✅ Enter recovery mode
- ✅ File transfer in recovery
- ✅ Photo backup in recovery
- ✅ Device restoration

### Jailbreaking
- ✅ evasi0n (iOS 6.0-6.1.2)
- ✅ p0sixspwn (iOS 6.1.3-6.1.6)
- ✅ Exploit lock screen vulnerabilities
- ✅ Privilege escalation

### Backup & Transfer
- ✅ Automatic photo backup
- ✅ Selective file transfer
- ✅ Encrypted backup support
- ✅ Manifest generation

---

## 📦 Installation

### Prerequisites

#### Windows
```powershell
# Install libimobiledevice
choco install libimobiledevice-utils

# Or download from:
# https://github.com/libimobiledevice/libimobiledevice/releases
```

#### macOS
```bash
brew install libimobiledevice usbmuxd ifuse lldb
```

#### Linux
```bash
sudo apt-get install libimobiledevice-utils ifuse lldb
```

### Setup

1. **Clone/Download SymbolOS**
   ```bash
   git clone https://github.com/RamenFast/SymbolOS.git
   cd SymbolOS
   ```

2. **Verify installation**
   ```powershell
   idevice_id -l  # Should list connected devices
   ```

3. **Run the launcher**
   ```powershell
   .\extensions\Launch-iOS6Debug.ps1
   ```

---

## 🎮 Interactive Menu Guide

### Main Menu Options

```
1. Device Status          → Show device info (model, iOS version, etc.)
2. Enable USB Debugging   → Pair device for USB communication
3. Push File to Device    → Transfer file from PC to iPhone
4. Pull File from Device  → Transfer file from iPhone to PC
5. Create Backup          → Backup photos and data
6. Enter Recovery Mode    → Put device in recovery mode
7. Jailbreak Options      → Show jailbreak tool downloads
8. Kernel Debugging       → Setup LLDB remote debugging
9. Exit                   → Close the program
```

---

## 💾 Backup & Recovery

### Create Backup
```powershell
# Run the script
.\extensions\Launch-iOS6Debug.ps1

# Select: 5 (Create Backup)
# Backup location: $HOME\iphone_backup
```

### Restore from Backup
```powershell
# Files are organized by type:
# $HOME\iphone_backup\DCIM\       (photos)
# $HOME\iphone_backup\Documents\  (documents)
# $HOME\iphone_backup\Media\      (media)
# $HOME\iphone_backup\manifest.json (metadata)
```

---

## 🔧 Advanced Usage

### Python Module Usage
```python
from extensions.ios6_debug_suite import IOSDebugSession, DebugConfig, DebugMode

config = DebugConfig(
    device_udid="a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
    debug_mode=DebugMode.KERNEL_DEBUG,
    backup_path="~/iphone_backup"
)

session = IOSDebugSession(config)
session.run()

# File operations
session.usb_debugger.push_file("/local/file.txt", "/remote/file.txt")
session.usb_debugger.pull_file("/remote/file.txt", "/local/file.txt")

# Kernel operations
session.kernel_debugger.read_memory(0x80000000, 256)
session.kernel_debugger.write_memory(0x80000000, b'\x00' * 256)

# Backup
session.secure_backup("~/iphone_backup")
```

### Batch Automation
```powershell
# backup_all_devices.ps1
$devices = idevice_id -l

foreach ($device in $devices) {
    Write-Host "Backing up $device..."
    .\extensions\Invoke-iOS6Debug.ps1 -DeviceUDID $device `
                                      -BackupPath "C:\backups\$device"
}
```

---

## 🐛 Troubleshooting

### Device Not Detected
```powershell
# Check USB connection
Get-PnpDevice -Class USB

# Restart service
Get-Service usbmuxd -ErrorAction SilentlyContinue | Restart-Service

# Verify tools installed
idevice_id -l
```

### Script Won't Run
```powershell
# Check PowerShell version
$PSVersionTable.PSVersion  # Should be 7.0+

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run as Administrator
# Right-click PowerShell → Run as Administrator
```

### File Transfer Fails
```powershell
# Verify USB debugging is enabled
# Run: Enable USB Debugging (option 2)

# Check device is accessible
ideviceinfo -u <UDID>

# Try manual transfer
idevicepush -u <UDID> C:\file.txt /var/mobile/file.txt
```

### Jailbreak Issues
```powershell
# Verify iOS version
ideviceinfo -u <UDID> | Select-String "ProductVersion"

# Use correct jailbreak:
# iOS 6.0-6.1.2  → evasi0n
# iOS 6.1.3-6.1.6 → p0sixspwn

# Check iTunes version (for p0sixspwn)
# Required: 11.1.5 - 12.1.3
```

---

## 🔐 Security & Ethics

⚠️ **Important Reminders:**

- **Ownership:** Only use on devices you own
- **Authorization:** Get explicit permission before debugging others' devices
- **Data Privacy:** Respect user data and privacy
- **Legal Compliance:** Follow local laws regarding device modification
- **Backup First:** Always backup before attempting exploits

### Default Credentials (After Jailbreak)
- **SSH Username:** `root`
- **SSH Password:** `alpine` (CHANGE IMMEDIATELY!)

---

## 📚 Documentation

### Quick References
- `POWERSHELL_QUICKSTART.md` - PowerShell 7 guide
- `../docs/iOS6_DEBUGGING_GUIDE.md` - Full 50+ page guide

### Detailed Topics
- USB Debugging (Part 2)
- Kernel Debugging with LLDB (Part 3)
- Recovery Mode File Transfer (Part 4)
- Jailbreaking iOS 6 (Part 5)
- Vulnerability Exploitation (Part 6)
- Secure Backup Implementation (Part 7)

---

## 🔗 Integration with SymbolOS

This extension integrates with SymbolOS's core systems:

### Symbol System (🧬)
Uses emoji and color coding for intuitive status indication:
- 🟢 Green = Success
- 🔴 Red = Error
- 🟡 Yellow = Warning
- 🔵 Blue = Info

### Meeting Place (🧩)
Coordinates with other SymbolOS agents through `symbol_map.shared.json`

### Memory System (🗃️)
Logs all operations to `memory/working_set.md` for continuity

### Verification Ring (R6) (🧪)
Ensures all operations are verified before execution

---

## 📞 Support

### Getting Help
1. Check `POWERSHELL_QUICKSTART.md` for common issues
2. Review `../docs/iOS6_DEBUGGING_GUIDE.md` for detailed information
3. Check device connection: `idevice_id -l`
4. Verify tools: `ideviceinfo -u <UDID>`

### Reporting Issues
- Include device UDID and iOS version
- Provide error messages and logs
- Specify which script/method you used
- Include PowerShell version: `$PSVersionTable.PSVersion`

---

## 📝 License

MIT License - See LICENSE file in repository root

---

## 🙏 Credits

**SymbolOS Contributors**
- Built with ☂️ (umbrella - protection)
- Guided by 🦊 (Rhy - trickster wisdom)
- Verified by 🐢 (turtle - patience)

---

## 🎯 Next Steps

1. **Install Prerequisites**
   ```powershell
   choco install libimobiledevice-utils
   ```

2. **Connect iPhone 4s via USB**

3. **Run Launcher**
   ```powershell
   .\extensions\Launch-iOS6Debug.ps1
   ```

4. **Select Option from Menu**

5. **Follow On-Screen Instructions**

---

**SymbolOS iOS 6 Debug Suite** | Comprehensive Debugging for Legacy iOS | Built with Care ☂️
