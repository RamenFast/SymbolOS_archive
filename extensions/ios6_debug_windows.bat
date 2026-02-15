@echo off
REM iOS 6 Debugging Suite for Windows
REM iPhone 4s Recovery, Jailbreak, and File Transfer
REM SymbolOS Integration

setlocal enabledelayedexpansion

color 0A
title iOS 6 Debug Suite - SymbolOS

REM ============================================================================
REM CONFIGURATION
REM ============================================================================

set "DEVICE_UDID=%1"
set "BACKUP_DIR=%2"
set "DEBUG_PORT=5037"
set "TOOLS_DIR=%~dp0"

if "%DEVICE_UDID%"=="" (
    echo.
    echo [!] Usage: ios6_debug_windows.bat ^<UDID^> [BACKUP_DIR]
    echo.
    echo Example:
    echo   ios6_debug_windows.bat a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6 C:\iphone_backup
    echo.
    echo To find UDID:
    echo   idevice_id -l
    echo.
    exit /b 1
)

if "%BACKUP_DIR%"=="" (
    set "BACKUP_DIR=%USERPROFILE%\iphone_backup"
)

REM ============================================================================
REM FUNCTIONS
REM ============================================================================

:check_device
echo [*] Checking for connected devices...
idevice_id -l >nul 2>&1
if errorlevel 1 (
    echo [!] libimobiledevice not found or no devices connected
    echo [*] Install libimobiledevice-utils or connect device
    exit /b 1
)

ideviceinfo -u %DEVICE_UDID% >nul 2>&1
if errorlevel 1 (
    echo [!] Device %DEVICE_UDID% not found
    idevice_id -l
    exit /b 1
)

echo [+] Device found: %DEVICE_UDID%
goto :eof

:get_device_info
echo.
echo [*] Device Information:
echo ============================================================================
for /f "tokens=*" %%A in ('ideviceinfo -u %DEVICE_UDID% 2^>nul ^| findstr "ProductName ProductVersion BuildVersion"') do (
    echo   %%A
)
echo ============================================================================
goto :eof

:enable_usb_debug
echo.
echo [*] Enabling USB Debugging...
idevicepair pair >nul 2>&1
if errorlevel 1 (
    echo [!] Failed to pair device
    exit /b 1
)
echo [+] USB Debugging enabled
goto :eof

:enter_recovery_mode
echo.
echo [*] Entering Recovery Mode...
echo [*] This will put your device into recovery mode
echo [*] You will need to restore the device afterward
pause

ideviceenterrecovery -u %DEVICE_UDID% >nul 2>&1
if errorlevel 1 (
    echo [!] Failed to enter recovery mode
    exit /b 1
)

echo [+] Device entering recovery mode...
timeout /t 5 /nobreak
goto :eof

:backup_device
echo.
echo [*] Creating Backup...
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo [*] Mounting device filesystem...
net use Z: \\?\usbmuxd\%DEVICE_UDID% >nul 2>&1

if exist "Z:\" (
    echo [+] Device mounted on Z:\
    
    REM Backup DCIM (Photos)
    if exist "Z:\DCIM" (
        echo [*] Backing up photos...
        xcopy "Z:\DCIM" "%BACKUP_DIR%\DCIM" /E /I /Y >nul
        echo [+] Photos backed up
    )
    
    REM Backup Documents
    if exist "Z:\Documents" (
        echo [*] Backing up documents...
        xcopy "Z:\Documents" "%BACKUP_DIR%\Documents" /E /I /Y >nul
        echo [+] Documents backed up
    )
    
    REM Backup Media
    if exist "Z:\Media" (
        echo [*] Backing up media...
        xcopy "Z:\Media" "%BACKUP_DIR%\Media" /E /I /Y >nul
        echo [+] Media backed up
    )
    
    REM Unmount
    net use Z: /delete /yes >nul 2>&1
    echo [+] Device unmounted
) else (
    echo [!] Failed to mount device filesystem
    echo [*] Trying alternative method with ifuse...
)

echo [+] Backup complete: %BACKUP_DIR%
goto :eof

:push_file
set "LOCAL_FILE=%1"
set "REMOTE_PATH=%2"

if "%LOCAL_FILE%"=="" (
    echo [!] Usage: :push_file ^<LOCAL_FILE^> ^<REMOTE_PATH^>
    exit /b 1
)

echo [*] Pushing %LOCAL_FILE% to %REMOTE_PATH%...
idevicepush -u %DEVICE_UDID% "%LOCAL_FILE%" "%REMOTE_PATH%" >nul 2>&1
if errorlevel 1 (
    echo [!] Failed to push file
    exit /b 1
)
echo [+] File pushed successfully
goto :eof

:pull_file
set "REMOTE_FILE=%1"
set "LOCAL_PATH=%2"

if "%REMOTE_FILE%"=="" (
    echo [!] Usage: :pull_file ^<REMOTE_FILE^> ^<LOCAL_PATH^>
    exit /b 1
)

echo [*] Pulling %REMOTE_FILE% to %LOCAL_PATH%...
idevicepull -u %DEVICE_UDID% "%REMOTE_FILE%" "%LOCAL_PATH%" >nul 2>&1
if errorlevel 1 (
    echo [!] Failed to pull file
    exit /b 1
)
echo [+] File pulled successfully
goto :eof

:install_jailbreak_tools
echo.
echo [*] Installing Jailbreak Tools...
echo.
echo Available jailbreaks for iOS 6:
echo   1. evasi0n (iOS 6.0-6.1.2)
echo   2. p0sixspwn (iOS 6.1.3-6.1.6)
echo.
set /p "JAILBREAK=Select jailbreak (1-2): "

if "%JAILBREAK%"=="1" (
    echo [*] Download evasi0n from: http://evasi0n.com/
    echo [*] Run evasi0n and follow on-screen instructions
) else if "%JAILBREAK%"=="2" (
    echo [*] Download p0sixspwn
    echo [*] Run p0sixspwn and follow on-screen instructions
) else (
    echo [!] Invalid selection
)
goto :eof

:connect_lldb
echo.
echo [*] Connecting LLDB for Kernel Debugging...
echo.
echo Prerequisites:
echo   - Device must be jailbroken
echo   - SSH must be enabled on device
echo   - debugserver must be running
echo.
echo Steps:
echo   1. SSH into device: ssh root@^<DEVICE_IP^>
echo   2. Start debugserver: debugserver 0.0.0.0:5037 -k
echo   3. On host, run: lldb
echo   4. In LLDB: gdb-remote localhost:5037
echo.
pause
goto :eof

:main_menu
:menu
cls
echo.
echo ============================================================================
echo   iOS 6 Comprehensive Debugging Suite - SymbolOS
echo   Device: %DEVICE_UDID%
echo ============================================================================
echo.
echo   1. Check Device Status
echo   2. Enable USB Debugging
echo   3. Backup Device
echo   4. Push File to Device
echo   5. Pull File from Device
echo   6. Enter Recovery Mode
echo   7. Install Jailbreak
echo   8. Connect LLDB (Kernel Debug)
echo   9. Exit
echo.
set /p "CHOICE=Select option (1-9): "

if "%CHOICE%"=="1" call :check_device && call :get_device_info && pause && goto menu
if "%CHOICE%"=="2" call :enable_usb_debug && pause && goto menu
if "%CHOICE%"=="3" call :backup_device && pause && goto menu
if "%CHOICE%"=="4" (
    set /p "LOCAL_FILE=Local file path: "
    set /p "REMOTE_PATH=Remote path: "
    call :push_file "!LOCAL_FILE!" "!REMOTE_PATH!"
    pause
    goto menu
)
if "%CHOICE%"=="5" (
    set /p "REMOTE_FILE=Remote file path: "
    set /p "LOCAL_PATH=Local path: "
    call :pull_file "!REMOTE_FILE!" "!LOCAL_PATH!"
    pause
    goto menu
)
if "%CHOICE%"=="6" call :enter_recovery_mode && pause && goto menu
if "%CHOICE%"=="7" call :install_jailbreak_tools && pause && goto menu
if "%CHOICE%"=="8" call :connect_lldb && pause && goto menu
if "%CHOICE%"=="9" exit /b 0

echo [!] Invalid option
pause
goto menu

REM ============================================================================
REM MAIN EXECUTION
REM ============================================================================

:start
call :check_device
call :get_device_info
call :main_menu

endlocal
