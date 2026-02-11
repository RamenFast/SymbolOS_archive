# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT - symbolos_hub.ps1
# ║  🎨 Color: 🔵 #0000CD (devotion to truth)
# ║  QT-005: The Hub Architecture
# ╚══════════════════════════════════════════════════════════════╝
#
#        /\_/\
#       ( o.o )  "The hub sees all, connects all, serves all."
#        > ^ <
#       /|   |\
#      (_|   |_)  - Rhy 🦊
#
# Mercer-Opus local orchestrator daemon.
# Runs as a long-lived process managing:
#   1. Llama-server lifecycle (start/stop/health)
#   2. GitHub sync (pull/push/issue check - when online)
#   3. Process health (detect zombies, resource monitoring)
#   4. Ring heartbeat (periodic system health snapshot)
#
# Designed offline-first: works without internet, syncs opportunistically.
#
Param(
  [int]$HeartbeatSeconds    = 60,
  [int]$SyncIntervalMinutes = 15,
  [int]$LlamaHealthSeconds  = 30,
  [string]$LlamaUrl         = "http://127.0.0.1:8080",
  [switch]$NoLlama,
  [switch]$NoSync,
  [switch]$Once,
  [switch]$Verbose
)

$ErrorActionPreference = 'Continue'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$logDir   = Join-Path $repoRoot 'local_ai\cache\hub_logs'
$stateFile = Join-Path $repoRoot 'local_ai\cache\hub_state.json'

# Ensure log directory exists
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

# ─── Logging ─────────────────────────────────────────────────────────────────

function Write-HubLog {
  Param(
    [string]$Level = "INFO",
    [string]$Component,
    [string]$Message
  )
  $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  $line = "[$ts] [$Level] [$Component] $Message"

  $color = switch ($Level) {
    "INFO"  { "Gray" }
    "OK"    { "Green" }
    "WARN"  { "Yellow" }
    "ERROR" { "Red" }
    "SYNC"  { "Cyan" }
    default { "White" }
  }
  Write-Host $line -ForegroundColor $color

  # Append to daily log file
  $logFile = Join-Path $logDir ("hub_{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))
  Add-Content -Path $logFile -Value $line -ErrorAction SilentlyContinue
}

# ─── State Management ────────────────────────────────────────────────────────

$hubState = @{
  started_at             = (Get-Date).ToUniversalTime().ToString('o')
  last_heartbeat         = $null
  last_sync_attempt      = $null
  last_sync_success      = $null
  llama_status           = "unknown"
  llama_restarts         = 0
  sync_failures          = 0
  connectivity           = "unknown"
  cycle_count            = 0
}

function Save-HubState {
  $hubState | ConvertTo-Json -Depth 3 | Out-File -FilePath $stateFile -Encoding UTF8 -Force -ErrorAction SilentlyContinue
}

function Update-HubState {
  Param([string]$Key, $Value)
  $hubState[$Key] = $Value
  Save-HubState
}

# ─── Connectivity Check ─────────────────────────────────────────────────────

function Test-Internet {
  try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $result = $tcp.BeginConnect("github.com", 443, $null, $null)
    $success = $result.AsyncWaitHandle.WaitOne(3000)
    if ($success) {
      $tcp.EndConnect($result)
      $tcp.Close()
      return $true
    }
    $tcp.Close()
    return $false
  } catch {
    return $false
  }
}

# ─── Llama Server Lifecycle ─────────────────────────────────────────────────

function Test-LlamaHealth {
  try {
    $r = Invoke-RestMethod -Uri "$LlamaUrl/health" -TimeoutSec 5 -ErrorAction Stop
    return ($r.status -eq 'ok')
  } catch {
    return $false
  }
}

function Get-LlamaProcess {
  Get-Process -Name 'llama-server' -ErrorAction SilentlyContinue | Select-Object -First 1
}

function Start-LlamaServer {
  $script = Join-Path $repoRoot 'scripts\run_llama_server.ps1'
  if (-not (Test-Path $script)) {
    Write-HubLog -Level "ERROR" -Component "LLAMA" -Message "run_llama_server.ps1 not found"
    return $false
  }

  # Check prerequisites
  $binDir = Join-Path $repoRoot 'local_ai\bin'
  $modelDir = Join-Path $repoRoot 'local_ai\models'
  $hasExe = Get-ChildItem -Path $binDir -Filter 'llama-server.exe' -File -ErrorAction SilentlyContinue | Select-Object -First 1
  $hasModel = Get-ChildItem -Path $modelDir -Filter '*.gguf' -File -ErrorAction SilentlyContinue | Select-Object -First 1

  if (-not $hasExe -or -not $hasModel) {
    Write-HubLog -Level "WARN" -Component "LLAMA" -Message "Missing binary or model - cannot start server"
    return $false
  }

  Write-HubLog -Level "INFO" -Component "LLAMA" -Message "Starting llama-server..."
  # Start in a new hidden process so it doesn't block the hub
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "powershell.exe"
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
  $psi.WorkingDirectory = $repoRoot
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true
  $psi.RedirectStandardOutput = $false
  $psi.RedirectStandardError = $false

  try {
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    # Wait for it to come up
    $waited = 0
    while ($waited -lt 30) {
      Start-Sleep -Seconds 2
      $waited += 2
      if (Test-LlamaHealth) {
        Write-HubLog -Level "OK" -Component "LLAMA" -Message "Server started and healthy (waited ${waited}s)"
        Update-HubState -Key "llama_restarts" -Value ($hubState.llama_restarts + 1)
        return $true
      }
    }
    Write-HubLog -Level "ERROR" -Component "LLAMA" -Message "Server started but not healthy after 30s"
    return $false
  } catch {
    Write-HubLog -Level "ERROR" -Component "LLAMA" -Message "Failed to start: $_"
    return $false
  }
}

function Invoke-LlamaHealthCheck {
  if ($NoLlama) { return }

  $healthy = Test-LlamaHealth
  $proc = Get-LlamaProcess

  if ($healthy) {
    if ($hubState.llama_status -ne "healthy") {
      Write-HubLog -Level "OK" -Component "LLAMA" -Message "Server healthy at $LlamaUrl"
    }
    Update-HubState -Key "llama_status" -Value "healthy"
    return
  }

  # Not healthy
  if ($proc) {
    # Process exists but not responding - might be loading model
    Write-HubLog -Level "WARN" -Component "LLAMA" -Message "Process running (PID $($proc.Id)) but /health failed"
    Update-HubState -Key "llama_status" -Value "unresponsive"
    return
  }

  # Process is gone - try to restart
  Write-HubLog -Level "WARN" -Component "LLAMA" -Message "Server not running - attempting restart"
  Update-HubState -Key "llama_status" -Value "restarting"
  $started = Start-LlamaServer
  if ($started) {
    Update-HubState -Key "llama_status" -Value "healthy"
  } else {
    Update-HubState -Key "llama_status" -Value "failed"
  }
}

# ─── GitHub Sync ─────────────────────────────────────────────────────────────

function Invoke-GitHubSync {
  if ($NoSync) { return }

  $online = Test-Internet
  Update-HubState -Key "connectivity" -Value $(if ($online) { "online" } else { "offline" })

  if (-not $online) {
    if ($Verbose) { Write-HubLog -Level "INFO" -Component "SYNC" -Message "Offline - skipping sync" }
    return
  }

  Update-HubState -Key "last_sync_attempt" -Value (Get-Date).ToUniversalTime().ToString('o')

  try {
    # Pull latest from origin
    Push-Location $repoRoot
    $pullOutput = git pull --ff-only origin main 2>&1 | Out-String
    Pop-Location

    if ($pullOutput -match "Already up to date") {
      if ($Verbose) { Write-HubLog -Level "SYNC" -Component "SYNC" -Message "Already up to date" }
    } elseif ($pullOutput -match "Fast-forward") {
      Write-HubLog -Level "SYNC" -Component "SYNC" -Message "Pulled new changes: $($pullOutput.Trim())"
    } elseif ($pullOutput -match "fatal|error|CONFLICT") {
      Write-HubLog -Level "ERROR" -Component "SYNC" -Message "Pull failed: $($pullOutput.Trim())"
      Update-HubState -Key "sync_failures" -Value ($hubState.sync_failures + 1)
      return
    }

    # Check for uncommitted orchestrator state changes
    Push-Location $repoRoot
    $status = git status --porcelain 2>&1 | Out-String
    Pop-Location

    if ($status.Trim()) {
      if ($Verbose) { Write-HubLog -Level "INFO" -Component "SYNC" -Message "Local changes detected (not auto-committing)" }
    }

    Update-HubState -Key "last_sync_success" -Value (Get-Date).ToUniversalTime().ToString('o')
    Update-HubState -Key "sync_failures" -Value 0

  } catch {
    Write-HubLog -Level "ERROR" -Component "SYNC" -Message "Sync error: $_"
    Update-HubState -Key "sync_failures" -Value ($hubState.sync_failures + 1)
  }
}

# ─── Process Health ──────────────────────────────────────────────────────────

function Invoke-ProcessHealthCheck {
  # Check for known zombie patterns
  $zombies = @()

  # Check for orphaned node processes from MCP server (if they somehow leaked)
  $nodeProcs = Get-Process -Name 'node' -ErrorAction SilentlyContinue
  foreach ($p in $nodeProcs) {
    try {
      $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)" -ErrorAction SilentlyContinue).CommandLine
      if ($cmdLine -match 'mcp_local_llm' -and $p.CPU -gt 300) {
        $zombies += @{ Name = "node (MCP)"; PID = $p.Id; CPU = $p.CPU; Reason = "High CPU MCP process" }
      }
    } catch { }
  }

  # Check for stuck PowerShell scripts (agent loop gone wild)
  $psProcs = Get-Process -Name 'powershell', 'pwsh' -ErrorAction SilentlyContinue
  foreach ($p in $psProcs) {
    if ($p.Id -eq $PID) { continue } # Don't flag ourselves
    try {
      if ($p.WorkingSet64 -gt 1GB) {
        $zombies += @{ Name = "powershell"; PID = $p.Id; Memory = "$([math]::Round($p.WorkingSet64/1MB))MB"; Reason = "Memory > 1GB" }
      }
    } catch { }
  }

  if ($zombies.Count -gt 0) {
    foreach ($z in $zombies) {
      Write-HubLog -Level "WARN" -Component "HEALTH" -Message "Potential zombie: $($z.Name) PID=$($z.PID) - $($z.Reason)"
    }
    # Log but don't kill - leave that decision to the user or explicit policy
    Write-HubLog -Level "INFO" -Component "HEALTH" -Message "Zombies detected but NOT auto-killing. Use -Verbose to see details."
  }

  # Basic system resource check
  try {
    $mem = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($mem) {
      $totalGB = [math]::Round($mem.TotalVisibleMemorySize / 1MB, 1)
      $freeGB = [math]::Round($mem.FreePhysicalMemory / 1MB, 1)
      $usedPct = [math]::Round((1 - $freeGB / $totalGB) * 100, 0)

      if ($usedPct -gt 90) {
        Write-HubLog -Level "WARN" -Component "HEALTH" -Message "Memory pressure: ${usedPct}% used (${freeGB}GB free of ${totalGB}GB)"
      } elseif ($Verbose) {
        Write-HubLog -Level "INFO" -Component "HEALTH" -Message "Memory: ${usedPct}% used (${freeGB}GB free of ${totalGB}GB)"
      }
    }
  } catch { }
}

# ─── Ring Heartbeat ──────────────────────────────────────────────────────────

function Invoke-RingHeartbeat {
  $r2Status = $(if ($hubState.llama_status -eq "healthy") { "local inference active" } else { "local inference degraded" })
  $heartbeat = @{
    timestamp    = (Get-Date).ToUniversalTime().ToString('o')
    cycle        = $hubState.cycle_count
    llama        = $hubState.llama_status
    connectivity = $hubState.connectivity
    rings        = @{
      R0  = "invariants hold"
      R2  = $r2Status
      R4  = "memory files accessible"
      R5  = "orchestrator predicting"
      R8  = "health checks running"
      R9  = "logs persisting"
      R10 = "cycle $($hubState.cycle_count) complete"
    }
  }

  Update-HubState -Key "last_heartbeat" -Value $heartbeat.timestamp

  if ($Verbose -or $hubState.cycle_count % 10 -eq 0) {
    $llamaEmoji = $(if ($hubState.llama_status -eq "healthy") { "[OK]" } else { "[!!]" })
    $netEmoji = $(if ($hubState.connectivity -eq "online") { "[OK]" } else { "[--]" })
    Write-HubLog -Level "INFO" -Component "HEART" -Message "Cycle $($hubState.cycle_count) | Llama $llamaEmoji | Net $netEmoji"
  }
}

# ─── Main Loop ───────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "+--------------------------------------------------------------+" -ForegroundColor Cyan
Write-Host "|  SymbolOS Hub - Mercer-Opus Local Orchestrator               |" -ForegroundColor Cyan
Write-Host "|  QT-005: The Hub Architecture                                |" -ForegroundColor Cyan
Write-Host "+--------------------------------------------------------------+" -ForegroundColor Cyan
$syncLabel = $(if ($NoSync) { "(DISABLED)" } else { "" })
$llamaLabel = $(if ($NoLlama) { "(DISABLED)" } else { "" })
Write-Host "  Heartbeat:  every ${HeartbeatSeconds}s" -ForegroundColor Gray
Write-Host "  Sync:       every ${SyncIntervalMinutes}m $syncLabel" -ForegroundColor Gray
Write-Host "  Llama:      $LlamaUrl $llamaLabel" -ForegroundColor Gray
Write-Host "  Log dir:    $logDir" -ForegroundColor Gray
Write-Host ""

Save-HubState
Write-HubLog -Level "OK" -Component "HUB" -Message "Orchestrator started"

# Timing trackers
$lastSync = [datetime]::MinValue
$lastLlamaCheck = [datetime]::MinValue

do {
  $hubState.cycle_count++
  $now = Get-Date

  # ── Llama health (every LlamaHealthSeconds) ──
  if (($now - $lastLlamaCheck).TotalSeconds -ge $LlamaHealthSeconds) {
    Invoke-LlamaHealthCheck
    $lastLlamaCheck = $now
  }

  # ── GitHub sync (every SyncIntervalMinutes) ──
  if (($now - $lastSync).TotalMinutes -ge $SyncIntervalMinutes) {
    Invoke-GitHubSync
    $lastSync = $now
  }

  # ── Process health (every heartbeat) ──
  Invoke-ProcessHealthCheck

  # ── Ring heartbeat ──
  Invoke-RingHeartbeat

  Save-HubState

  if ($Once) { break }
  Start-Sleep -Seconds $HeartbeatSeconds

} while ($true)

Write-HubLog -Level "INFO" -Component "HUB" -Message "Orchestrator stopped (cycle $($hubState.cycle_count))"

#
#    ___
#   / 🐢 \    "this is fine"
#  |  ._. |   - the hub watches
#   \_____/   - the umbrella holds
#    |   |
#
# ☂🦊🐢
