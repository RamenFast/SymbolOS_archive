Param(
  [string]$RepoRoot = "",
  [string]$TaskName = "SymbolOS - Mercer Doc Alignment Scan (5h)",
  [int]$Hours = 5,
  [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

function Resolve-RepoRoot {
  Param([string]$RepoRoot)

  if ($RepoRoot) {
    if (-not (Test-Path -LiteralPath $RepoRoot)) { throw "RepoRoot not found: $RepoRoot" }
    return (Resolve-Path -LiteralPath $RepoRoot).Path
  }

  return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

$root = Resolve-RepoRoot -RepoRoot $RepoRoot
$runnerScript = Join-Path $root 'scripts\mercer_doc_alignment_runner.ps1'

if (-not (Test-Path -LiteralPath $runnerScript)) { throw "Missing runner script: $runnerScript" }

if ($Uninstall) {
  if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false | Out-Null
    Write-Host "✅ Uninstalled scheduled task: $TaskName" -ForegroundColor Green
    Write-Host "MercerID: MRC-20260128-0249-24" -ForegroundColor DarkCyan
  } else {
    Write-Host "⚠️ Task not found: $TaskName" -ForegroundColor Yellow
  }
  exit 0
}

# Create an action that runs the read-only runner (includes crash handling + retries).
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`" -RepoRoot `"{1}`" -RetryCount 3 -RetryDelayMinutes 20 -Quiet" -f $runnerScript, $root)

# Trigger every N hours.
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(2) -RepetitionInterval (New-TimeSpan -Hours $Hours) -RepetitionDuration ([TimeSpan]::MaxValue)

# Run only when user is logged on (safest default; no elevated secrets).
$principal = New-ScheduledTaskPrincipal -UserId $env:UserName -LogonType Interactive -RunLevel Limited

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew -StartWhenAvailable

$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings

Register-ScheduledTask -TaskName $TaskName -InputObject $task -Force | Out-Null

Write-Host "✅ Installed scheduled task: $TaskName" -ForegroundColor Green
Write-Host "- Cadence: every $Hours hours" -ForegroundColor Gray
Write-Host "- Mode: Prefetch-only (read-only scan; no writes)" -ForegroundColor Gray
Write-Host "MercerID: MRC-20260128-0249-25" -ForegroundColor DarkCyan
