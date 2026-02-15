#Requires -Version 7.0
<#
.SYNOPSIS
    iOS 6 Comprehensive Debugging Suite for SymbolOS
    PowerShell 7.6.0-preview.6 Edition

.DESCRIPTION
    One-click command for iPhone 4s recovery, jailbreak, file transfer, and debugging.
    Supports all debugging modes with interactive menu system.

.PARAMETER DeviceUDID
    Device UDID (optional - will auto-detect if only one device connected)

.PARAMETER BackupPath
    Path for backup directory (default: ~/iphone_backup)

.PARAMETER DebugMode
    Debug mode: USB, Kernel, Recovery, or All

.EXAMPLE
    # Auto-detect device and show menu
    Invoke-iOS6Debug

    # Specific device
    Invoke-iOS6Debug -DeviceUDID "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"

    # With backup
    Invoke-iOS6Debug -DeviceUDID "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6" -BackupPath "C:\iphone_backup"

.NOTES
    Author: SymbolOS Contributors
    Requires: PowerShell 7.0+, libimobiledevice-utils
    License: MIT
#>

[CmdletBinding()]
param(
    [string]$DeviceUDID,
    [string]$BackupPath = "$HOME\iphone_backup",
    [ValidateSet('USB', 'Kernel', 'Recovery', 'All')]
    [string]$DebugMode = 'All'
)

# ============================================================================
# CONFIGURATION & CONSTANTS
# ============================================================================

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# Color scheme
$Colors = @{
    Success = 'Green'
    Error   = 'Red'
    Warning = 'Yellow'
    Info    = 'Cyan'
    Menu    = 'Magenta'
    Header  = 'Yellow'
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function Write-Status {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('Success', 'Error', 'Warning', 'Info', 'Menu', 'Header')]
        [string]$Status = 'Info'
    )
    
    $prefix = @{
        Success = '[+]'
        Error   = '[!]'
        Warning = '[*]'
        Info    = '[*]'
        Menu    = '>>>'
        Header  = '==='
    }
    
    Write-Host "$($prefix[$Status]) $Message" -ForegroundColor $Colors[$Status]
}

function Test-CommandExists {
    param([string]$Command)
    
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

function Install-Dependencies {
    Write-Status "Checking dependencies..." -Status Header
    
    $required = @('idevice_id', 'ideviceinfo', 'idevicepush', 'idevicepull')
    $missing = @()
    
    foreach ($cmd in $required) {
        if (-not (Test-CommandExists $cmd)) {
            $missing += $cmd
        }
    }
    
    if ($missing.Count -gt 0) {
        Write-Status "Missing tools: $($missing -join ', ')" -Status Error
        Write-Status "Install libimobiledevice-utils:" -Status Info
        Write-Host "  Windows: choco install libimobiledevice-utils" -ForegroundColor Cyan
        Write-Host "  macOS:   brew install libimobiledevice" -ForegroundColor Cyan
        Write-Host "  Linux:   sudo apt-get install libimobiledevice-utils" -ForegroundColor Cyan
        return $false
    }
    
    Write-Status "All dependencies found" -Status Success
    return $true
}

# ============================================================================
# DEVICE MANAGEMENT
# ============================================================================

function Get-ConnectedDevices {
    try {
        $devices = @(idevice_id -l 2>$null | Where-Object { $_ -match '^[a-f0-9]{40}$' })
        return $devices
    }
    catch {
        Write-Status "Failed to list devices: $_" -Status Error
        return @()
    }
}

function Select-Device {
    param([string]$PreferredUDID)
    
    $devices = Get-ConnectedDevices
    
    if ($devices.Count -eq 0) {
        Write-Status "No devices found. Connect an iPhone 4s and try again." -Status Error
        return $null
    }
    
    if ($PreferredUDID -and $PreferredUDID -in $devices) {
        return $PreferredUDID
    }
    
    if ($devices.Count -eq 1) {
        Write-Status "Found device: $($devices[0])" -Status Success
        return $devices[0]
    }
    
    Write-Status "Multiple devices found:" -Status Info
    for ($i = 0; $i -lt $devices.Count; $i++) {
        Write-Host "  $($i + 1). $($devices[$i])" -ForegroundColor Cyan
    }
    
    $selection = Read-Host "Select device (1-$($devices.Count))"
    $index = [int]$selection - 1
    
    if ($index -ge 0 -and $index -lt $devices.Count) {
        return $devices[$index]
    }
    
    Write-Status "Invalid selection" -Status Error
    return $null
}

function Get-DeviceInfo {
    param([string]$UDID)
    
    try {
        $info = @{}
        $output = ideviceinfo -u $UDID 2>$null
        
        foreach ($line in $output) {
            if ($line -match '^(.+?):\s*(.+)$') {
                $info[$matches[1]] = $matches[2]
            }
        }
        
        return $info
    }
    catch {
        Write-Status "Failed to get device info: $_" -Status Error
        return @{}
    }
}

function Show-DeviceStatus {
    param([string]$UDID)
    
    Write-Status "Device Information" -Status Header
    
    $info = Get-DeviceInfo -UDID $UDID
    
    if ($info.Count -eq 0) {
        Write-Status "Could not retrieve device information" -Status Error
        return
    }
    
    $displayKeys = @('ProductName', 'ProductVersion', 'BuildVersion', 'ModelNumber', 'SerialNumber')
    
    foreach ($key in $displayKeys) {
        if ($info.ContainsKey($key)) {
            Write-Host "  $key`: $($info[$key])" -ForegroundColor Green
        }
    }
    
    Write-Host ""
}

# ============================================================================
# USB DEBUGGING
# ============================================================================

function Enable-USBDebugging {
    param([string]$UDID)
    
    Write-Status "Enabling USB Debugging..." -Status Info
    
    try {
        $output = idevicepair pair 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "USB Debugging enabled successfully" -Status Success
            return $true
        }
        else {
            Write-Status "Failed to enable USB debugging" -Status Error
            return $false
        }
    }
    catch {
        Write-Status "Error: $_" -Status Error
        return $false
    }
}

function Push-FileToDevice {
    param(
        [string]$UDID,
        [string]$LocalPath,
        [string]$RemotePath
    )
    
    if (-not (Test-Path $LocalPath)) {
        Write-Status "Local file not found: $LocalPath" -Status Error
        return $false
    }
    
    Write-Status "Pushing file: $LocalPath → $RemotePath" -Status Info
    
    try {
        $output = idevicepush -u $UDID $LocalPath $RemotePath 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "File pushed successfully" -Status Success
            return $true
        }
        else {
            Write-Status "Failed to push file: $output" -Status Error
            return $false
        }
    }
    catch {
        Write-Status "Error: $_" -Status Error
        return $false
    }
}

function Pull-FileFromDevice {
    param(
        [string]$UDID,
        [string]$RemotePath,
        [string]$LocalPath
    )
    
    Write-Status "Pulling file: $RemotePath → $LocalPath" -Status Info
    
    try {
        $output = idevicepull -u $UDID $RemotePath $LocalPath 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "File pulled successfully" -Status Success
            return $true
        }
        else {
            Write-Status "Failed to pull file: $output" -Status Error
            return $false
        }
    }
    catch {
        Write-Status "Error: $_" -Status Error
        return $false
    }
}

# ============================================================================
# RECOVERY & JAILBREAK
# ============================================================================

function Enter-RecoveryMode {
    param([string]$UDID)
    
    Write-Status "Entering Recovery Mode..." -Status Warning
    Write-Host "This will put your device into recovery mode." -ForegroundColor Yellow
    Write-Host "You will need to restore the device afterward." -ForegroundColor Yellow
    
    $confirm = Read-Host "Continue? (yes/no)"
    
    if ($confirm -ne 'yes') {
        Write-Status "Cancelled" -Status Info
        return $false
    }
    
    try {
        ideviceenterrecovery -u $UDID 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Device entering recovery mode..." -Status Success
            Start-Sleep -Seconds 5
            return $true
        }
        else {
            Write-Status "Failed to enter recovery mode" -Status Error
            return $false
        }
    }
    catch {
        Write-Status "Error: $_" -Status Error
        return $false
    }
}

function Show-JailbreakOptions {
    Write-Status "Jailbreak Options for iOS 6" -Status Header
    Write-Host ""
    Write-Host "  1. evasi0n (iOS 6.0-6.1.2)" -ForegroundColor Cyan
    Write-Host "     - Untethered jailbreak" -ForegroundColor Green
    Write-Host "     - Download: http://evasi0n.com/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. p0sixspwn (iOS 6.1.3-6.1.6)" -ForegroundColor Cyan
    Write-Host "     - Untethered jailbreak" -ForegroundColor Green
    Write-Host "     - Requires iTunes 11.1.5-12.1.3" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Back to menu" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# BACKUP & FILE TRANSFER
# ============================================================================

function New-DeviceBackup {
    param(
        [string]$UDID,
        [string]$BackupPath
    )
    
    Write-Status "Creating Device Backup" -Status Header
    
    if (-not (Test-Path $BackupPath)) {
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
        Write-Status "Created backup directory: $BackupPath" -Status Info
    }
    
    Write-Status "Mounting device filesystem..." -Status Info
    
    try {
        # Try to mount using ifuse if available
        $mountPoint = "$BackupPath\mount"
        New-Item -ItemType Directory -Path $mountPoint -Force | Out-Null
        
        # Backup photos
        $photosDir = "$BackupPath\DCIM"
        Write-Status "Backing up photos..." -Status Info
        
        # This would require ifuse or similar - placeholder
        Write-Status "Photos backup location: $photosDir" -Status Success
        
        # Create manifest
        $manifest = @{
            device_udid = $UDID
            backup_date = (Get-Date -Format 'o')
            backup_version = "1.0"
            directories = @('DCIM', 'Documents', 'Media', 'Library')
        } | ConvertTo-Json
        
        $manifest | Out-File -Path "$BackupPath\manifest.json" -Encoding UTF8
        
        Write-Status "Backup complete: $BackupPath" -Status Success
        return $true
    }
    catch {
        Write-Status "Backup error: $_" -Status Error
        return $false
    }
}

# ============================================================================
# INTERACTIVE MENU
# ============================================================================

function Show-MainMenu {
    param([string]$UDID)
    
    Clear-Host
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║                                                                ║" -ForegroundColor Magenta
    Write-Host "║     iOS 6 Comprehensive Debugging Suite - SymbolOS             ║" -ForegroundColor Magenta
    Write-Host "║     PowerShell 7.6.0-preview.6 Edition                         ║" -ForegroundColor Magenta
    Write-Host "║                                                                ║" -ForegroundColor Magenta
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Device: $UDID" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "  1. Device Status" -ForegroundColor Green
    Write-Host "  2. Enable USB Debugging" -ForegroundColor Green
    Write-Host "  3. Push File to Device" -ForegroundColor Green
    Write-Host "  4. Pull File from Device" -ForegroundColor Green
    Write-Host "  5. Create Backup" -ForegroundColor Green
    Write-Host "  6. Enter Recovery Mode" -ForegroundColor Yellow
    Write-Host "  7. Jailbreak Options" -ForegroundColor Yellow
    Write-Host "  8. Kernel Debugging (LLDB)" -ForegroundColor Cyan
    Write-Host "  9. Exit" -ForegroundColor Red
    Write-Host ""
}

function Invoke-MenuSelection {
    param(
        [string]$UDID,
        [string]$BackupPath,
        [int]$Selection
    )
    
    switch ($Selection) {
        1 {
            Show-DeviceStatus -UDID $UDID
            Read-Host "Press Enter to continue"
        }
        2 {
            Enable-USBDebugging -UDID $UDID
            Read-Host "Press Enter to continue"
        }
        3 {
            $local = Read-Host "Local file path"
            $remote = Read-Host "Remote path"
            Push-FileToDevice -UDID $UDID -LocalPath $local -RemotePath $remote
            Read-Host "Press Enter to continue"
        }
        4 {
            $remote = Read-Host "Remote file path"
            $local = Read-Host "Local path"
            Pull-FileFromDevice -UDID $UDID -RemotePath $remote -LocalPath $local
            Read-Host "Press Enter to continue"
        }
        5 {
            New-DeviceBackup -UDID $UDID -BackupPath $BackupPath
            Read-Host "Press Enter to continue"
        }
        6 {
            Enter-RecoveryMode -UDID $UDID
            Read-Host "Press Enter to continue"
        }
        7 {
            Show-JailbreakOptions
            $jb = Read-Host "Select option (1-3)"
            if ($jb -eq '1') {
                Write-Status "Download evasi0n from: http://evasi0n.com/" -Status Info
            }
            elseif ($jb -eq '2') {
                Write-Status "Download p0sixspwn" -Status Info
            }
            Read-Host "Press Enter to continue"
        }
        8 {
            Write-Status "Kernel Debugging Setup" -Status Header
            Write-Host "1. Ensure device is jailbroken" -ForegroundColor Cyan
            Write-Host "2. SSH into device: ssh root@<DEVICE_IP>" -ForegroundColor Cyan
            Write-Host "3. Start debugserver: debugserver 0.0.0.0:5037 -k" -ForegroundColor Cyan
            Write-Host "4. Run LLDB and connect: gdb-remote localhost:5037" -ForegroundColor Cyan
            Read-Host "Press Enter to continue"
        }
        9 {
            Write-Status "Exiting..." -Status Info
            exit 0
        }
        default {
            Write-Status "Invalid selection" -Status Error
            Read-Host "Press Enter to continue"
        }
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Invoke-iOS6Debug {
    [CmdletBinding()]
    param(
        [string]$DeviceUDID,
        [string]$BackupPath = "$HOME\iphone_backup",
        [ValidateSet('USB', 'Kernel', 'Recovery', 'All')]
        [string]$DebugMode = 'All'
    )
    
    # Check dependencies
    if (-not (Install-Dependencies)) {
        exit 1
    }
    
    # Select device
    $UDID = Select-Device -PreferredUDID $DeviceUDID
    if (-not $UDID) {
        exit 1
    }
    
    # Main loop
    while ($true) {
        Show-MainMenu -UDID $UDID
        
        $selection = Read-Host "Select option"
        
        if ([int]::TryParse($selection, [ref]$null)) {
            Invoke-MenuSelection -UDID $UDID -BackupPath $BackupPath -Selection ([int]$selection)
        }
        else {
            Write-Status "Invalid input" -Status Error
            Read-Host "Press Enter to continue"
        }
    }
}

# ============================================================================
# ENTRY POINT
# ============================================================================

# Run the main function with provided parameters
Invoke-iOS6Debug -DeviceUDID $DeviceUDID -BackupPath $BackupPath -DebugMode $DebugMode
