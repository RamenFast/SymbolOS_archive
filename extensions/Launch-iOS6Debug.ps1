#Requires -Version 7.0
<#
.SYNOPSIS
    One-Click Launcher for iOS 6 Debug Suite
    
.DESCRIPTION
    Simplest possible entry point - just run this and go!
    
.EXAMPLE
    .\Launch-iOS6Debug.ps1
#>

# Bypass execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Check if main script exists
$MainScript = Join-Path $ScriptDir "Invoke-iOS6Debug.ps1"

if (-not (Test-Path $MainScript)) {
    Write-Host "ERROR: Invoke-iOS6Debug.ps1 not found!" -ForegroundColor Red
    Write-Host "Expected location: $MainScript" -ForegroundColor Yellow
    exit 1
}

# Run the main script
& $MainScript
