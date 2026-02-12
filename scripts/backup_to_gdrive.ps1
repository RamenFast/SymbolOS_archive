# SymbolOS Google Drive Backup — GPLv3
# Backs up the SymbolOS repo to Google Drive using rclone.
# Usage: .\scripts\backup_to_gdrive.ps1 [-Full] [-DryRun]
# Remote: manus_google_drive: (configured in ~/.gdrive-rclone.ini)
# Target: manus_google_drive:SymbolOS_Backup/
#
# Safe by default: uses rclone copy (additive, never deletes from dest).
# Idempotent: skips files that already exist and haven't changed.

param(
    [switch]$Full,       # Back up entire repo (default: critical dirs only)
    [switch]$DryRun,     # Show what would be copied without copying
    [switch]$Verbose     # Extra logging
)

$ErrorActionPreference = "Stop"

# ── Config ──────────────────────────────────────────────────
$RcloneConfig   = Join-Path $env:USERPROFILE ".gdrive-rclone.ini"
$Remote         = "manus_google_drive"
$DestBase       = "SymbolOS_Backup"
$RepoRoot       = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path (Join-Path $RepoRoot ".git"))) {
    $RepoRoot = Split-Path -Parent $PSScriptRoot
}
$Timestamp      = Get-Date -Format "yyyy-MM-dd_HH-mm"
$LogDir         = Join-Path $RepoRoot "logs"
$LogFile        = Join-Path $LogDir "backup_$Timestamp.log"

# Critical directories (default backup set)
$CriticalDirs = @(
    "memory",
    "docs",
    "prompts",
    "scripts",
    "internal_docs",
    "web\src",
    "mcp_gateway",
    "mcp_servers",
    "extensions",
    ".github"
)

# Critical root files
$CriticalFiles = @(
    "symbol_map.shared.json",
    "README.md",
    ".editorconfig",
    "content.json"
)

# ── Helpers ─────────────────────────────────────────────────
function Log($msg) {
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $msg"
    Write-Host $line
    if (Test-Path $LogDir) { Add-Content -Path $LogFile -Value $line }
}

function Run-Rclone-Copy {
    param(
        [string]$Source,
        [string]$Dest,
        [string[]]$ExtraArgs = @()
    )
    $allArgs = @("copy", $Source, $Dest, "--config", $RcloneConfig)
    if ($DryRun)  { $allArgs += "--dry-run" }
    if ($Verbose) { $allArgs += "-v" }
    $allArgs += $ExtraArgs
    Log "  > rclone $($allArgs -join ' ')"
    $output = & rclone @allArgs 2>&1
    $output | ForEach-Object { Log "    $_" }
    if ($LASTEXITCODE -ne 0) { Log "  WARNING: rclone exited with code $LASTEXITCODE" }
}

function Run-Rclone-Copyto {
    param(
        [string]$Source,
        [string]$Dest
    )
    $allArgs = @("copyto", $Source, $Dest, "--config", $RcloneConfig)
    if ($DryRun)  { $allArgs += "--dry-run" }
    if ($Verbose) { $allArgs += "-v" }
    Log "  > rclone $($allArgs -join ' ')"
    $output = & rclone @allArgs 2>&1
    $output | ForEach-Object { Log "    $_" }
    if ($LASTEXITCODE -ne 0) { Log "  WARNING: rclone exited with code $LASTEXITCODE" }
}

# ── Preflight ───────────────────────────────────────────────
if (-not (Get-Command rclone -ErrorAction SilentlyContinue)) {
    Write-Error "rclone not found. Install from https://rclone.org/downloads/"
    exit 1
}
if (-not (Test-Path $RcloneConfig)) {
    Write-Error "rclone config not found at $RcloneConfig"
    exit 1
}

# Create log directory
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

# ── Check disk space ───────────────────────────────────────
$drive = (Get-Item $RepoRoot).PSDrive
$freeGB = [math]::Round($drive.Free / 1GB, 1)
Log "=============================================="
Log "  SymbolOS Google Drive Backup"
Log "=============================================="
Log "Local free space: ${freeGB}GB"
Log "Repo root: $RepoRoot"
Log "Remote: ${Remote}:${DestBase}/"
Log "Mode: $(if ($Full) {'FULL'} else {'CRITICAL DIRS ONLY'})"
if ($DryRun) { Log "** DRY RUN -- no files will be transferred **" }
Log "----------------------------------------------"

# ── Execute backup ──────────────────────────────────────────
$startTime = Get-Date

if ($Full) {
    Log "Backing up entire repo..."
    Run-Rclone-Copy -Source $RepoRoot -Dest "${Remote}:${DestBase}/full/" -ExtraArgs @(
        "--exclude", ".git/**",
        "--exclude", "node_modules/**",
        "--exclude", "local_ai/bin/**",
        "--exclude", "local_ai/models/**",
        "--exclude", "local_ai/cache/**",
        "--exclude", "logs/**"
    )
} else {
    # Back up critical directories
    foreach ($dir in $CriticalDirs) {
        $srcPath = Join-Path $RepoRoot $dir
        if (Test-Path $srcPath) {
            Log "Backing up $dir/"
            $destDir = $dir -replace '\\', '/'
            Run-Rclone-Copy -Source $srcPath -Dest "${Remote}:${DestBase}/${destDir}/"
        } else {
            Log "Skipping $dir/ (not found)"
        }
    }

    # Back up critical root files
    foreach ($file in $CriticalFiles) {
        $srcPath = Join-Path $RepoRoot $file
        if (Test-Path $srcPath) {
            Log "Backing up $file"
            Run-Rclone-Copyto -Source $srcPath -Dest "${Remote}:${DestBase}/${file}"
        } else {
            Log "Skipping $file (not found)"
        }
    }
}

$elapsed = (Get-Date) - $startTime
Log "----------------------------------------------"
Log "Backup complete in $([math]::Round($elapsed.TotalSeconds, 1))s"
Log "Done."
