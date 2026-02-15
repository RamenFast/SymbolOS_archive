# iOS 6 Comprehensive Debugging Guide for SymbolOS

## Overview

This guide provides complete instructions for enabling all debugging modes on iPhone 4s running iOS 6.x, including USB debugging, kernel debugging, memory inspection, file transfer in recovery mode, and exploitation of unpatched vulnerabilities.

**Target Device:** iPhone 4s  
**Target OS:** iOS 6.0 - 6.1.6  
**Host OS:** Windows, macOS, or Linux  
**Requirements:** libimobiledevice, LLDB, iTunes (or equivalent), jailbreak tools

---

## Part 1: Prerequisites & Setup

### 1.1 Install Required Tools

#### On Windows (via WSL2 or native):
```bash
# Install libimobiledevice and related tools
sudo apt-get update
sudo apt-get install -y libimobiledevice-utils libimobiledevice-dev libusbmuxd-tools ifuse

# Install LLDB and debugging tools
sudo apt-get install -y lldb gdb

# Install Python dependencies
pip install --upgrade libimobiledevice
```

#### On macOS:
```bash
# Install via Homebrew
brew install libimobiledevice usbmuxd ifuse lldb

# Install Python dependencies
pip install libimobiledevice
```

#### On Linux:
```bash
# Ubuntu/Debian
sudo apt-get install -y libimobiledevice-utils libimobiledevice-dev libusbmuxd-tools ifuse lldb

# Fedora/RHEL
sudo dnf install -y libimobiledevice-utils lldb
```

### 1.2 Verify Device Connection

```bash
# List connected devices
idevice_id -l

# Get device information
ideviceinfo -u <UDID>

# Check device model and iOS version
ideviceinfo -u <UDID> | grep -E "ProductName|ProductVersion|BuildVersion"
```

---

## Part 2: USB Debugging

### 2.1 Enable USB Debugging via Lockdown

```bash
# Pair device with host
idevicepair pair

# Verify pairing
idevicepair validate

# Enable developer mode (iOS 6 requires jailbreak for full USB debug)
ideviceinstaller -u <UDID> -l  # List installed apps
```

### 2.2 File Transfer via USB

#### Push File to Device:
```bash
idevicepush -u <UDID> /local/path/file.txt /remote/path/file.txt
```

#### Pull File from Device:
```bash
idevicepull -u <UDID> /remote/path/file.txt /local/path/file.txt
```

#### Mount Device Filesystem (requires jailbreak):
```bash
# Create mount point
mkdir -p /mnt/iphone

# Mount device
ifuse -u <UDID> /mnt/iphone

# Access files
ls -la /mnt/iphone/

# Unmount
fusermount -u /mnt/iphone
```

---

## Part 3: Kernel Debugging with LLDB

### 3.1 Enable Kernel Debugging

On a jailbroken iPhone 4s with SSH access:

```bash
# SSH into device
ssh root@<DEVICE_IP>

# Start debugserver on device
debugserver 0.0.0.0:5037 -k
```

### 3.2 Connect LLDB from Host

```bash
# Forward port
ideviceproxy -u <UDID> 5037 5037

# Connect LLDB
lldb

# In LLDB:
(lldb) gdb-remote localhost:5037
(lldb) target create /path/to/kernel
(lldb) breakpoint set --name main
(lldb) continue
```

### 3.3 Kernel Memory Inspection

```bash
# Read memory
(lldb) memory read 0x80000000 --size 256

# Write memory (requires kernel debugging enabled)
(lldb) memory write 0x80000000 0x12345678

# Search memory
(lldb) memory find --expression "pattern" 0x80000000 0x90000000
```

---

## Part 4: Recovery Mode File Transfer

### 4.1 Enter Recovery Mode

```bash
# Method 1: Via ideviceenterrecovery
ideviceenterrecovery -u <UDID>

# Method 2: Manual (hold buttons)
# 1. Connect iPhone to computer
# 2. Hold Power + Home buttons for 10 seconds
# 3. Release Power, continue holding Home for 5-10 seconds
# 4. Device enters recovery mode (screen shows "Connect to iTunes")
```

### 4.2 File Transfer in Recovery Mode

Using libirecovery:

```bash
# Install libirecovery
sudo apt-get install -y libirecovery-dev

# Send file to device in recovery mode
irecovery -u <UDID> -s "send /path/to/file.bin"

# Receive file from device
irecovery -u <UDID> -s "receive /path/to/output.bin"
```

### 4.3 Backup Photos in Recovery Mode

```bash
# Create backup directory
mkdir -p ~/iphone_backup

# Mount device filesystem
ifuse -u <UDID> /mnt/iphone

# Copy photos
cp -r /mnt/iphone/DCIM ~/iphone_backup/photos

# Unmount
fusermount -u /mnt/iphone

# Verify backup
ls -la ~/iphone_backup/photos/
```

---

## Part 5: Jailbreaking iOS 6

### 5.1 Untethered Jailbreak with evasi0n (iOS 6.0-6.1.2)

**Download:** [evasi0n.com](http://evasi0n.com/) (archived)

```bash
# On Windows/macOS:
1. Download evasi0n
2. Connect iPhone 4s
3. Run evasi0n
4. Click "Jailbreak"
5. Follow on-screen instructions
6. Device will reboot and be jailbroken
```

### 5.2 Untethered Jailbreak with p0sixspwn (iOS 6.1.3-6.1.6)

**Download:** p0sixspwn tool

```bash
# Prerequisites
# - iTunes 11.1.5 to 12.1.3
# - iPhone 4s on iOS 6.1.3-6.1.6

# On Windows/macOS:
1. Download p0sixspwn
2. Connect iPhone 4s
3. Run p0sixspwn
4. Click "Jailbreak"
5. Device will reboot with Cydia installed
```

### 5.3 Verify Jailbreak

```bash
# SSH into device (after jailbreak)
ssh root@<DEVICE_IP>

# Default password: "alpine" (change immediately)
# Check for Cydia
ls -la /Applications/ | grep Cydia

# Install OpenSSH via Cydia for persistent SSH access
```

---

## Part 6: Exploitation of Unpatched Vulnerabilities

### 6.1 iOS 6.1.3 Lock Screen Bypass

**Vulnerability:** Emergency call bypass allows access to contacts, photos, and dialer without passcode.

```bash
# On locked device:
1. Tap "Emergency Call"
2. Dial any number
3. Tap "Call"
4. Tap "Power" to end call
5. Quickly tap "Home" button
6. Swipe up to access Control Center
7. Access Photos, Contacts, or Dialer
```

### 6.2 Kernel Memory Exploitation

Requires kernel debugging enabled:

```bash
# Read kernel memory
(lldb) memory read 0x80000000 --size 4096 --format x

# Find kernel base
(lldb) image list -b

# Locate kernel structures
(lldb) memory find --expression "KERN" 0x80000000 0x90000000
```

### 6.3 Privilege Escalation

After jailbreak, gain root access:

```bash
# SSH into device
ssh root@<DEVICE_IP>

# Verify root access
whoami  # Should output: root

# Access system files
ls -la /System/Library/

# Modify system files (use with caution)
# Example: Disable passcode requirement
# Modify: /var/mobile/Library/Preferences/com.apple.springboard.plist
```

---

## Part 7: Secure Backup Implementation

### 7.1 Create Comprehensive Backup

```bash
#!/bin/bash
# backup_iphone.sh

UDID="$1"
BACKUP_DIR="$2"

if [ -z "$UDID" ] || [ -z "$BACKUP_DIR" ]; then
    echo "Usage: $0 <UDID> <BACKUP_DIR>"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

echo "[*] Backing up iPhone 4s..."

# Mount filesystem
MOUNT_POINT="/mnt/iphone_backup"
mkdir -p "$MOUNT_POINT"
ifuse -u "$UDID" "$MOUNT_POINT"

if [ $? -ne 0 ]; then
    echo "[!] Failed to mount device"
    exit 1
fi

# Backup directories
BACKUP_DIRS=(
    "DCIM"           # Photos
    "Documents"      # App documents
    "Library"        # App library data
    "Media"          # Media files
    "Caches"         # Cache files
)

for dir in "${BACKUP_DIRS[@]}"; do
    if [ -d "$MOUNT_POINT/$dir" ]; then
        echo "[+] Backing up $dir..."
        cp -r "$MOUNT_POINT/$dir" "$BACKUP_DIR/"
    fi
done

# Create backup manifest
cat > "$BACKUP_DIR/manifest.json" << EOF
{
    "device_udid": "$UDID",
    "backup_date": "$(date -Iseconds)",
    "backup_version": "1.0",
    "directories": $(printf '%s\n' "${BACKUP_DIRS[@]}" | jq -R . | jq -s .)
}
EOF

# Unmount
fusermount -u "$MOUNT_POINT"

echo "[+] Backup complete: $BACKUP_DIR"
```

### 7.2 Encrypt Backup

```bash
# Create encrypted archive
tar czf - "$BACKUP_DIR" | openssl enc -aes-256-cbc -salt -out backup.tar.gz.enc

# Decrypt later
openssl enc -d -aes-256-cbc -in backup.tar.gz.enc | tar xz
```

---

## Part 8: Using SymbolOS Debug Suite

### 8.1 Run Debug Suite

```bash
# Basic usage
python3 extensions/ios6_debug_suite.py --udid <UDID>

# With backup
python3 extensions/ios6_debug_suite.py --udid <UDID> --backup ~/iphone_backup

# Verbose output
python3 extensions/ios6_debug_suite.py --udid <UDID> --verbose

# Specific debug mode
python3 extensions/ios6_debug_suite.py --udid <UDID> --mode kernel_debug --port 5037
```

### 8.2 Available Commands

```python
# In Python
from extensions.ios6_debug_suite import IOSDebugSession, DebugConfig, DebugMode

config = DebugConfig(
    device_udid="<UDID>",
    debug_mode=DebugMode.USB_DEBUG,
    backup_path="~/iphone_backup"
)

session = IOSDebugSession(config)
session.run()

# File transfer
session.usb_debugger.push_file("/local/file.txt", "/remote/file.txt")
session.usb_debugger.pull_file("/remote/file.txt", "/local/file.txt")

# Kernel debugging
session.kernel_debugger.read_memory(0x80000000, 256)
session.kernel_debugger.write_memory(0x80000000, b'\x00' * 256)

# Backup
session.secure_backup("~/iphone_backup")
```

---

## Part 9: Troubleshooting

### Device Not Detected

```bash
# Check USB connection
lsusb | grep Apple

# Reinstall libimobiledevice
sudo apt-get remove --purge libimobiledevice-utils
sudo apt-get install libimobiledevice-utils

# Check usbmuxd daemon
sudo systemctl restart usbmuxd
```

### LLDB Connection Failed

```bash
# Verify debugserver is running on device
ssh root@<DEVICE_IP> ps aux | grep debugserver

# Restart debugserver
ssh root@<DEVICE_IP> killall debugserver
ssh root@<DEVICE_IP> debugserver 0.0.0.0:5037 -k
```

### Recovery Mode Issues

```bash
# Force recovery mode
ideviceenterrecovery -u <UDID>

# Check recovery mode status
ideviceinfo -u <UDID> | grep Recovery

# Exit recovery mode
idevicerestore -u <UDID> --latest
```

---

## Part 10: Security & Ethical Considerations

⚠️ **IMPORTANT:** This guide is for authorized testing and personal device recovery only.

- **Ownership:** Only use these tools on devices you own or have explicit permission to debug
- **Data Privacy:** Respect user data and privacy when accessing device contents
- **Legal Compliance:** Ensure compliance with local laws regarding device modification
- **Backup First:** Always create backups before attempting exploits or modifications

---

## References

- [libimobiledevice Documentation](https://libimobiledevice.org/)
- [iOS Jailbreak Wiki](https://theapplewiki.com/wiki/Jailbreak)
- [LLDB Debugging Guide](https://lldb.llvm.org/)
- [iOS 6 Security Updates](https://support.apple.com/en-us/103599)

---

**SymbolOS iOS 6 Debug Suite** | Built with ☂️ and 🦊
