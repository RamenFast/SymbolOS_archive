Param(
  [string]$RepoRoot = "",
  [int]$RetryCount = 3,
  [int]$RetryDelayMinutes = 20,
  [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function _Emoji([int]$codePoint) {
  return [System.Char]::ConvertFromUtf32($codePoint)
}

function _WithVS16([string]$s) {
  return $s + [char]0xFE0F
}

function Write-RunnerBanner {
  Param([string]$Status = "OK")

  $glyphs = (
    (_Emoji 0x1F9EC) +
    (_WithVS16 ([System.Char]::ConvertFromUtf32(0x2602))) +
    (_Emoji 0x1F9FE) +
    (_WithVS16 (_Emoji 0x1F6E1)) +
    (_Emoji 0x1F9E0) +
    (_Emoji 0x1F52E)
  )

  $statusGlyph = switch ($Status) {
    "OK" { _Emoji 0x2705 }
    "WARN" { (_WithVS16 ([System.Char]::ConvertFromUtf32(0x26A0))) }
    "FAIL" { _Emoji 0x26D4 }
    default { (_WithVS16 ([System.Char]::ConvertFromUtf32(0x26A0))) }
  }

  Write-Host ""
  Write-Host '==============================================================' -ForegroundColor DarkCyan
  Write-Host "  $glyphs  MERCER DOC ALIGNMENT RUNNER (RETRY)" -ForegroundColor DarkCyan
  Write-Host '  Quest: keep the map true - no writes - no commits' -ForegroundColor DarkCyan
  Write-Host '==============================================================' -ForegroundColor DarkCyan
  Write-Host "Status: $statusGlyph $Status" -ForegroundColor Cyan
}

function Resolve-RepoRoot {
  Param([string]$RepoRoot)

  if ($RepoRoot) {
    if (-not (Test-Path -LiteralPath $RepoRoot)) { throw "RepoRoot not found: $RepoRoot" }
    return (Resolve-Path -LiteralPath $RepoRoot).Path
  }

  return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

$root = Resolve-RepoRoot -RepoRoot $RepoRoot
$scanScript = Join-Path $root 'scripts\mercer_doc_alignment_scan.ps1'

if (-not (Test-Path -LiteralPath $scanScript)) { throw "Missing scan script: $scanScript" }

# Exit code semantics (from scan script):
#   0 => ✅ OK (no drift)
#   2 => ⚠️ WARN (drift detected; suggestion only)
# other => ⛔ FAIL (crash/error)

$finalExit = 1
$attempt = 0

while ($attempt -lt $RetryCount) {
  $attempt += 1

  if (-not $Quiet) {
    Write-RunnerBanner -Status "OK"
    Write-Host "Attempt $attempt/$RetryCount - running read-only scan..." -ForegroundColor Gray
  }

  try {
    $scanArgs = @(
      '-NoProfile',
      '-ExecutionPolicy', 'Bypass',
      '-File', $scanScript,
      '-RepoRoot', $root
    )
    if ($Quiet) {
      $scanArgs += '-Quiet'
    }

    & powershell.exe @scanArgs
    $exitCode = $LASTEXITCODE
  } catch {
    $exitCode = 99
    if (-not $Quiet) {
      Write-RunnerBanner -Status "FAIL"
      Write-Host "Scan crashed: $($_.Exception.Message)" -ForegroundColor Red
    }
  }

  if ($exitCode -eq 0) {
    if (-not $Quiet) {
      Write-RunnerBanner -Status "OK"
      Write-Host "$(_Emoji 0x2705) Scan complete: no drift." -ForegroundColor Green
      Write-Host "MercerID: MRC-20260128-0249-27" -ForegroundColor DarkCyan
    }
    exit 0
  }

  if ($exitCode -eq 2) {
    if (-not $Quiet) {
      Write-RunnerBanner -Status "WARN"
      Write-Host "$(_WithVS16 ([System.Char]::ConvertFromUtf32(0x26A0))) Scan complete: drift detected (suggestion only)." -ForegroundColor Yellow
      Write-Host "MercerID: MRC-20260128-0249-28" -ForegroundColor DarkCyan
    }
    exit 2
  }

  # Crash / error path.
  $finalExit = $exitCode

  if ($attempt -lt $RetryCount) {
    if (-not $Quiet) {
      Write-RunnerBanner -Status "FAIL"
      Write-Host "Scan failed (exit $exitCode). Retrying in $RetryDelayMinutes minutes..." -ForegroundColor Red
      Write-Host "(If all retries fail, we wait for the next scheduled 5h run.)" -ForegroundColor Gray
    }
    Start-Sleep -Seconds ($RetryDelayMinutes * 60)
    continue
  }

  if (-not $Quiet) {
    Write-RunnerBanner -Status "FAIL"
    Write-Host "All retries exhausted. Deferring until next scheduled run." -ForegroundColor Red
    Write-Host "MercerID: MRC-20260128-0249-29" -ForegroundColor DarkCyan
  }

  exit $finalExit
}

exit $finalExit
