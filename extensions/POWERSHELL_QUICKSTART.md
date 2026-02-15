# iOS 6 Debug Suite - PowerShell 7.6.0 Quick Start

## One-Click Setup & Execution

### Prerequisites

1. **PowerShell 7.6.0-preview.6 or later**
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **libimobiledevice-utils**
   ```powershell
   # Windows (via Chocolatey)
   choco install libimobiledevice-utils
   
   # Or download from: https://github.com/libimobiledevice/libimobiledevice/releases
   ```

3. **iPhone 4s connected via USB**

---

## Quick Start Commands

### 1. Auto-Detect Device & Show Menu
```powershell
# Navigate to SymbolOS directory
cd C:\path\to\SymbolOS

# Run the script
.\extensions\Invoke-iOS6Debug.ps1
```

### 2. Specific Device with Backup
```powershell
.\extensions\Invoke-iOS6Debug.ps1 -DeviceUDID "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6" -BackupPath "C:\iphone_backup"
```

### 3. One-Liner (Copy & Paste)
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; & ".\extensions\Invoke-iOS6Debug.ps1"
```

---

## Finding Your Device UDID

```powershell
# List all connected devices
idevice_id -l

# Get detailed device info
ideviceinfo -u <UDID>
```

---

## Menu Options Explained

### 1. Device Status
Shows device information:
- Product Name (e.g., iPhone 4s)
- iOS Version (e.g., 6.1.3)
- Build Version
- Serial Number

### 2. Enable USB Debugging
Pairs device with computer for USB communication.

### 3. Push File to Device
Transfer file from computer to iPhone:
```
Local file path: C:\photos\image.jpg
Remote path: /var/mobile/Media/image.jpg
```

### 4. Pull File from Device
Transfer file from iPhone to computer:
```
Remote file path: /var/mobile/Library/file.txt
Local path: C:\backup\file.txt
```

### 5. Create Backup
Backs up device data to local directory:
- Photos (DCIM)
- Documents
- Media files
- Creates manifest.json

### 6. Enter Recovery Mode
⚠️ **Warning:** Puts device into recovery mode. Device will need to be restored.

### 7. Jailbreak Options
Shows download links for:
- **evasi0n** (iOS 6.0-6.1.2)
- **p0sixspwn** (iOS 6.1.3-6.1.6)

### 8. Kernel Debugging (LLDB)
Setup instructions for remote kernel debugging:
1. Ensure device is jailbroken
2. SSH into device
3. Start debugserver
4. Connect LLDB from host

### 9. Exit
Close the script.

---

## Common Tasks

### Task: Backup iPhone 4s Photos
```powershell
# Run script
.\extensions\Invoke-iOS6Debug.ps1

# Select: 5 (Create Backup)
# Photos will be saved to: $HOME\iphone_backup\DCIM
```

### Task: Transfer File to Device
```powershell
# Run script
.\extensions\Invoke-iOS6Debug.ps1

# Select: 3 (Push File to Device)
# Enter local path: C:\myfile.txt
# Enter remote path: /var/mobile/myfile.txt
```

### Task: Setup Kernel Debugging
```powershell
# Run script
.\extensions\Invoke-iOS6Debug.ps1

# Select: 8 (Kernel Debugging)
# Follow the instructions displayed
```

---

## Troubleshooting

### "Device not found"
```powershell
# Check USB connection
Get-PnpDevice -Class USB

# List devices
idevice_id -l

# Restart libimobiledevice service
Get-Service usbmuxd -ErrorAction SilentlyContinue | Restart-Service
```

### "libimobiledevice not found"
```powershell
# Install via Chocolatey
choco install libimobiledevice-utils

# Or add to PATH manually
$env:Path += ";C:\Program Files\libimobiledevice\bin"
```

### "Access Denied" errors
```powershell
# Run PowerShell as Administrator
# Right-click PowerShell → Run as Administrator

# Or set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Script won't run
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set to allow scripts
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Then run script
.\extensions\Invoke-iOS6Debug.ps1
```

---

## Advanced Usage

### Automated Backup Script
```powershell
# backup_iphone.ps1
param(
    [string]$UDID = (idevice_id -l | Select-Object -First 1),
    [string]$BackupPath = "$HOME\iphone_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
)

# Import the main script functions
. .\extensions\Invoke-iOS6Debug.ps1

# Create backup
New-DeviceBackup -UDID $UDID -BackupPath $BackupPath

Write-Host "Backup complete: $BackupPath" -ForegroundColor Green
```

Run it:
```powershell
.\backup_iphone.ps1
```

### Batch File Transfer
```powershell
# transfer_files.ps1
param(
    [string]$UDID = (idevice_id -l | Select-Object -First 1),
    [string]$LocalDir = "C:\files_to_transfer",
    [string]$RemoteDir = "/var/mobile/Documents"
)

. .\extensions\Invoke-iOS6Debug.ps1

Get-ChildItem $LocalDir | ForEach-Object {
    Push-FileToDevice -UDID $UDID `
                      -LocalPath $_.FullName `
                      -RemotePath "$RemoteDir/$($_.Name)"
}
```

---

## PowerShell 7 Features Used

- **Modern color support** with `Write-Host -ForegroundColor`
- **Unicode box drawing** for menu headers
- **Parameter validation** with `ValidateSet`
- **Cross-platform compatibility** (Windows, macOS, Linux)
- **Error handling** with `$ErrorActionPreference`
- **Progress tracking** with status messages

---

## Integration with SymbolOS

This script integrates with SymbolOS's symbolic cognition framework:

- **Symbol System:** Uses emoji and color coding for status indication
- **Meeting Place:** Coordinates with other SymbolOS agents
- **Memory System:** Logs all operations to `memory/working_set.md`
- **Verification Ring (R6):** Ensures all operations are verified before execution

---

## Security Notes

⚠️ **Important:**
- Only use on devices you own
- Default SSH password on jailbroken devices: `alpine` (change immediately)
- Backup sensitive data before jailbreaking
- Keep device firmware updated when not in use

---

## Support & Documentation

- **Full Guide:** See `docs/iOS6_DEBUGGING_GUIDE.md`
- **Python Version:** See `extensions/ios6_debug_suite.py`
- **Batch Version:** See `extensions/ios6_debug_windows.bat`

---

**SymbolOS iOS 6 Debug Suite** | Built with ☂️ 🦊 🐢
