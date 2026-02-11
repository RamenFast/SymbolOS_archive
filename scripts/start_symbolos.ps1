# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT — start_symbolos.ps1
# ║  🎨 Color: 🟢 #228B22 (adaptability)
# ╚══════════════════════════════════════════════════════════════╝
#
#        /\_/\
#       ( o.o )  "PowerShell? More like PowerSpell. ✨"
#        > ^ <
#       /|   |\
#      (_|   |_)  — Rhy 🦊
#
param(
  [switch]$SkipPrompt,
  [bool]$StartAlignmentScan = $true,
  [bool]$StartStatusUi = $true,
  [bool]$StartLlama = $true,
  [bool]$StartHub = $true,
  [bool]$SyncClock = $true
)

$ErrorActionPreference = 'Stop'

function Write-Banner {
  Write-Host ''
  Write-Host '==============================================================' -ForegroundColor Cyan
  Write-Host 'SYMBOL OS START - ALL ENDPOINTS IN SCOPE' -ForegroundColor Cyan
  Write-Host 'Quest: sync | status | local inference' -ForegroundColor Cyan
  Write-Host '==============================================================' -ForegroundColor Cyan
  Write-Host ''
}

function Confirm-Start {
  if ($SkipPrompt) { return $true }
  Write-Host 'Start all local endpoints now? (Y/N)' -ForegroundColor Yellow
  $choice = (Read-Host '>').Trim().ToLower()
  return ($choice -eq 'y' -or $choice -eq 'yes')
}

function Resolve-RepoRoot {
  $scriptDir = $PSScriptRoot
  if (-not $scriptDir) {
    $scriptDir = Split-Path -Parent $PSCommandPath
  }
  return (Resolve-Path (Join-Path $scriptDir '..')).Path
}

function Sync-ClockIfNeeded {
  if (-not $SyncClock) { return }
  try {
    Write-Host 'Syncing system clock (NTP)...' -ForegroundColor Gray
    w32tm /resync /force | Out-Null
  } catch {
    Write-Host 'Clock sync skipped or failed. Continue anyway.' -ForegroundColor Yellow
  }
}

function Start-AlignmentScan([string]$repoRoot) {
  $scan = Join-Path $repoRoot 'scripts\mercer_doc_alignment_scan.ps1'
  if (Test-Path -LiteralPath $scan) { & $scan }
}

function Start-StatusUiOnce([string]$repoRoot) {
  $status = Join-Path $repoRoot 'scripts\mercer_status.ps1'
  if (Test-Path -LiteralPath $status) { & $status -Once }
}

function Test-LlamaReady([string]$repoRoot) {
  $binDir = Join-Path $repoRoot 'local_ai\bin'
  $modelDir = Join-Path $repoRoot 'local_ai\models'
  $serverExe = Get-ChildItem -Path $binDir -Filter 'llama-server.exe' -File -ErrorAction SilentlyContinue | Select-Object -First 1
  $model = Get-ChildItem -Path $modelDir -Filter '*.gguf' -File -ErrorAction SilentlyContinue | Select-Object -First 1
  return ($null -ne $serverExe -and $null -ne $model)
}

function Start-Llama([string]$repoRoot) {
  $llama = Join-Path $repoRoot 'scripts\run_llama_server.ps1'
  if (-not (Test-LlamaReady -repoRoot $repoRoot)) {
    Write-Host 'Local LLM not ready (missing llama-server.exe or .gguf model). Skipping.' -ForegroundColor Yellow
    return
  }
  if (Test-Path -LiteralPath $llama) { & $llama }
}

$root = Resolve-RepoRoot
Write-Banner

if (-not (Confirm-Start)) {
  Write-Host 'Start cancelled.' -ForegroundColor Yellow
  exit 0
}

Sync-ClockIfNeeded

if ($StartAlignmentScan) { Start-AlignmentScan -repoRoot $root }
if ($StartStatusUi) { Start-StatusUiOnce -repoRoot $root }
if ($StartLlama) { Start-Llama -repoRoot $root }
if ($StartHub) {
  $hubScript = Join-Path $root 'scripts\symbolos_hub.ps1'
  if (Test-Path -LiteralPath $hubScript) {
    Write-Host 'Starting hub orchestrator...' -ForegroundColor Cyan
    & $hubScript
  }
}

#
#    ___
#   / 🐢 \    "this is fine"
#  |  ._. |   — script complete
#   \_____/   — umbrella held
#    |   |
#
# loops run, scripts hum clean
# the fox grins, the turtle nods
# execute — breathe
#
# ☂🦊🐢
