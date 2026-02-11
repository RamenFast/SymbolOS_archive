# SymbolOS Overnight Orchestrator
# Saturates all system resources for useful work while Ben sleeps.
#
# GPU:     Dream Engine (LLM inference, 3/4 parallel slots)
# CPU:     Repo integrity checks, hash verification, index building
# Network: Git fetch/pull, NTP sync
# Disk:    Temp cleanup, log rotation
# RAM:     Everything running concurrently
#
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\overnight_orchestrator.ps1
#
#        /\_/\
#       ( o.o )  "While you sleep, I dream for both of us."
#        > ^ <
#       /|   |\
#      (_|   |_)  -- Rhy
#
Param(
  [int]$DreamCycleDelay = 60,       # Seconds between Dream Engine cycles
  [int]$MainLoopDelay   = 300,      # Seconds between orchestrator main cycles (5 min)
  [string]$LlamaUrl     = "http://127.0.0.1:8080",
  [switch]$Once                     # Run one cycle and exit (for testing)
)

$ErrorActionPreference = 'Continue'
$repoRoot = Split-Path -Parent $PSScriptRoot
$cacheDir = Join-Path $repoRoot 'local_ai\cache'
$logPath  = Join-Path $cacheDir 'overnight_log.jsonl'
$reportPath = Join-Path $cacheDir 'overnight_report.json'

# ---- Logging ----------------------------------------------------------------

function Log-Event([string]$level, [string]$component, [string]$message) {
  $ts = Get-Date -Format 'o'
  $entry = @{ ts = $ts; level = $level; component = $component; msg = $message }
  $json = $entry | ConvertTo-Json -Compress
  Add-Content -Path $logPath -Value $json -Encoding UTF8
  $color = switch ($level) {
    'INFO'  { 'Cyan' }
    'WARN'  { 'Yellow' }
    'ERROR' { 'Red' }
    'OK'    { 'Green' }
    default { 'Gray' }
  }
  Write-Host "[$($ts.Substring(11,8))] [$component] $message" -ForegroundColor $color
}

# ---- Health Checks ----------------------------------------------------------

function Test-LlamaServer {
  try {
    $r = Invoke-RestMethod -Uri "$LlamaUrl/health" -TimeoutSec 5 -ErrorAction Stop
    return $r.status -eq 'ok'
  } catch { return $false }
}

function Restart-LlamaServer {
  Log-Event 'WARN' 'LLAMA' 'Server down, attempting restart...'
  Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force
  Start-Sleep -Seconds 3
  $serverScript = Join-Path $repoRoot 'scripts\run_llama_server.ps1'
  if (Test-Path $serverScript) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$serverScript`"" -WindowStyle Hidden
    Start-Sleep -Seconds 15
    if (Test-LlamaServer) {
      Log-Event 'OK' 'LLAMA' 'Server restarted successfully'
      return $true
    }
  }
  Log-Event 'ERROR' 'LLAMA' 'Failed to restart server'
  return $false
}

# ---- Dream Engine Management -------------------------------------------------

$script:dreamJob = $null

function Start-DreamEngine {
  if ($script:dreamJob -and $script:dreamJob.State -eq 'Running') { return }
  $consolidationScript = Join-Path $repoRoot 'scripts\memory_consolidation.ps1'
  if (-not (Test-Path $consolidationScript)) {
    Log-Event 'ERROR' 'DREAM' "Script not found: $consolidationScript"
    return
  }
  Log-Event 'INFO' 'DREAM' "Starting Dream Engine (cycle delay: ${DreamCycleDelay}s)"
  $script:dreamJob = Start-Job -ScriptBlock {
    param($script, $delay)
    & powershell -NoProfile -ExecutionPolicy Bypass -File $script -CycleDelaySeconds $delay
  } -ArgumentList $consolidationScript, $DreamCycleDelay
  Log-Event 'OK' 'DREAM' "Dream Engine started as job $($script:dreamJob.Id)"
}

function Get-DreamEngineStatus {
  if (-not $script:dreamJob) { return 'not-started' }
  return $script:dreamJob.State
}

# ---- CPU Work: Repo Integrity & Analysis ------------------------------------

function Invoke-RepoIntegrityCheck {
  Log-Event 'INFO' 'INTEGRITY' 'Running repo integrity checks...'
  $issues = @()

  # 1. Verify all tracked files exist
  $tracked = git -C $repoRoot ls-files 2>$null
  $missing = @()
  foreach ($f in $tracked) {
    $fullPath = Join-Path $repoRoot $f
    if (-not (Test-Path $fullPath)) { $missing += $f }
  }
  if ($missing.Count -gt 0) {
    $issues += "Missing tracked files: $($missing -join ', ')"
    Log-Event 'WARN' 'INTEGRITY' "Missing files: $($missing.Count)"
  }

  # 2. Check JSON validity of all .json files
  $jsonFiles = Get-ChildItem $repoRoot -Include '*.json' -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch 'node_modules|\.git|local_ai[\\/]cache|target' }
  $badJson = @()
  foreach ($jf in $jsonFiles) {
    try {
      $null = Get-Content $jf.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
      $badJson += $jf.Name
    }
  }
  if ($badJson.Count -gt 0) {
    $issues += "Invalid JSON: $($badJson -join ', ')"
    Log-Event 'WARN' 'INTEGRITY' "Bad JSON files: $($badJson -join ', ')"
  } else {
    Log-Event 'OK' 'INTEGRITY' "All $($jsonFiles.Count) JSON files valid"
  }

  # 3. Check markdown link integrity (internal links)
  $mdFiles = Get-ChildItem $repoRoot -Include '*.md' -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch 'node_modules|\.git|target' }
  $brokenLinks = @()
  foreach ($mf in $mdFiles) {
    $content = Get-Content $mf.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    # Match markdown links like [text](path)
    $matches2 = [regex]::Matches($content, '\[([^\]]+)\]\(([^)]+)\)')
    foreach ($m in $matches2) {
      $linkTarget = $m.Groups[2].Value
      # Skip external URLs, anchors, and mailto
      if ($linkTarget -match '^(https?://|#|mailto:)') { continue }
      # Strip anchors
      $linkPath = ($linkTarget -split '#')[0]
      if (-not $linkPath) { continue }
      $resolved = Join-Path (Split-Path $mf.FullName) $linkPath
      if (-not (Test-Path $resolved)) {
        $rel = $mf.FullName.Replace($repoRoot, '').TrimStart('\')
        $brokenLinks += "$rel -> $linkTarget"
      }
    }
  }
  if ($brokenLinks.Count -gt 0) {
    Log-Event 'WARN' 'INTEGRITY' "Broken internal links: $($brokenLinks.Count)"
    foreach ($bl in $brokenLinks | Select-Object -First 10) {
      Log-Event 'WARN' 'INTEGRITY' "  $bl"
    }
    $issues += "Broken links: $($brokenLinks.Count)"
  } else {
    Log-Event 'OK' 'INTEGRITY' "All internal markdown links valid"
  }

  # 4. Schema validation: ensure schemas referenced in schemas.md exist
  $schemasIndex = Join-Path $repoRoot 'docs\schemas.md'
  if (Test-Path $schemasIndex) {
    $schemaContent = Get-Content $schemasIndex -Raw
    $schemaRefs = [regex]::Matches($schemaContent, '\[([^\]]+)\]\(([^)]+\.schema\.json)\)')
    $missingSchemas = @()
    foreach ($sr in $schemaRefs) {
      $schemaPath = Join-Path (Join-Path $repoRoot 'docs') $sr.Groups[2].Value
      if (-not (Test-Path $schemaPath)) { $missingSchemas += $sr.Groups[2].Value }
    }
    if ($missingSchemas.Count -gt 0) {
      $issues += "Missing schemas: $($missingSchemas -join ', ')"
      Log-Event 'WARN' 'INTEGRITY' "Missing schemas: $($missingSchemas -join ', ')"
    } else {
      Log-Event 'OK' 'INTEGRITY' "All $($schemaRefs.Count) referenced schemas exist"
    }
  }

  return @{
    issues = $issues
    tracked_files = $tracked.Count
    json_files = $jsonFiles.Count
    md_files = $mdFiles.Count
    broken_links = $brokenLinks.Count
  }
}

# ---- CPU Work: Build File Index & Stats ------------------------------------

function Build-RepoIndex {
  Log-Event 'INFO' 'INDEX' 'Building repo file index...'
  $allFiles = Get-ChildItem $repoRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]|[\\/]node_modules[\\/]|[\\/]target[\\/]|[\\/]local_ai[\\/](bin|models|cache)[\\/]' }

  $byExt = @{}
  $totalSize = 0
  $totalLines = 0
  foreach ($f in $allFiles) {
    $ext = if ($f.Extension) { $f.Extension.ToLower() } else { '(none)' }
    if (-not $byExt.ContainsKey($ext)) { $byExt[$ext] = @{ count = 0; size = 0; lines = 0 } }
    $byExt[$ext].count++
    $byExt[$ext].size += $f.Length
    $totalSize += $f.Length
    # Count lines for text files
    if ($ext -in @('.md','.ps1','.json','.html','.css','.js','.ts','.py','.rs','.hs','.sh','.yaml','.yml','.toml')) {
      $lc = (Get-Content $f.FullName -ErrorAction SilentlyContinue | Measure-Object).Count
      $byExt[$ext].lines += $lc
      $totalLines += $lc
    }
  }

  $index = @{
    generated = (Get-Date -Format 'o')
    total_files = $allFiles.Count
    total_size_bytes = $totalSize
    total_lines = $totalLines
    by_extension = $byExt
  }

  $indexPath = Join-Path $cacheDir 'repo_index.json'
  $index | ConvertTo-Json -Depth 4 | Set-Content -Path $indexPath -Encoding UTF8
  Log-Event 'OK' 'INDEX' "Index built: $($allFiles.Count) files, $totalLines lines, $([math]::Round($totalSize/1MB,1)) MB"
  return $index
}

# ---- Network: Git Maintenance -----------------------------------------------

function Invoke-GitMaintenance {
  Log-Event 'INFO' 'GIT' 'Running git maintenance...'

  # Fetch latest from origin
  try {
    $fetchOutput = git -C $repoRoot fetch origin 2>&1 | Out-String
    if ($fetchOutput -match 'error|fatal') {
      Log-Event 'WARN' 'GIT' "Fetch issues: $fetchOutput"
    } else {
      Log-Event 'OK' 'GIT' 'Fetched from origin'
    }
  } catch {
    Log-Event 'WARN' 'GIT' "Fetch failed: $($_.Exception.Message)"
  }

  # Git GC (pack objects, prune)
  try {
    git -C $repoRoot gc --auto 2>&1 | Out-Null
    Log-Event 'OK' 'GIT' 'Git GC completed'
  } catch {
    Log-Event 'WARN' 'GIT' "GC failed: $($_.Exception.Message)"
  }

  # Check ahead/behind
  $ahead = (git -C $repoRoot rev-list --count "origin/main..HEAD" 2>$null)
  $behind = (git -C $repoRoot rev-list --count "HEAD..origin/main" 2>$null)
  Log-Event 'INFO' 'GIT' "Ahead: $ahead, Behind: $behind"

  return @{ ahead = [int]$ahead; behind = [int]$behind }
}

# ---- Disk: Temp Cleanup & Log Rotation --------------------------------------

function Invoke-DiskMaintenance {
  Log-Event 'INFO' 'DISK' 'Running disk maintenance...'
  $freed = 0

  # Clean temp files older than 2 days
  $tempDirs = @($env:TEMP)
  foreach ($td in $tempDirs) {
    if (Test-Path $td) {
      $old = Get-ChildItem $td -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-2) }
      foreach ($f in $old) {
        try {
          $freed += $f.Length
          Remove-Item $f.FullName -Force -ErrorAction Stop
        } catch { }
      }
    }
  }

  # Rotate overnight log if > 5MB
  if ((Test-Path $logPath) -and (Get-Item $logPath).Length -gt 5MB) {
    $archivePath = $logPath -replace '\.jsonl$', "_$(Get-Date -Format 'yyyyMMdd').jsonl"
    Move-Item $logPath $archivePath -Force
    Log-Event 'INFO' 'DISK' "Rotated log to $archivePath"
  }

  $drive = Get-PSDrive C
  Log-Event 'OK' 'DISK' "Freed: $([math]::Round($freed/1MB,1)) MB | Free: $([math]::Round($drive.Free/1GB,1)) GB"
  return @{ freed_bytes = $freed; free_gb = [math]::Round($drive.Free/1GB,1) }
}

# ---- CPU Work: Symbol Map Drift Check (lightweight) -------------------------

function Invoke-SymbolDriftCheck {
  Log-Event 'INFO' 'DRIFT' 'Checking symbol map for drift...'
  $sharedPath = Join-Path $repoRoot 'symbol_map.shared.json'
  $docPath = Join-Path $repoRoot 'docs\symbol_map.md'

  if (-not (Test-Path $sharedPath) -or -not (Test-Path $docPath)) {
    Log-Event 'WARN' 'DRIFT' 'Cannot check drift - files missing'
    return @{ status = 'missing-files' }
  }

  $shared = Get-Content $sharedPath -Raw | ConvertFrom-Json
  $docContent = Get-Content $docPath -Raw

  # Extract symbols from shared JSON
  $jsonSymbols = @{}
  foreach ($s in $shared.symbols) {
    $jsonSymbols[$s.symbol] = $s.name
  }

  # Extract symbols from doc markdown (pattern: - `SYMBOL` Name...)
  $docSymbols = @{}
  $docMatches = [regex]::Matches($docContent, '- `([^`]+)` ([^\r\n]+)')
  foreach ($dm in $docMatches) {
    $sym = $dm.Groups[1].Value
    $name = ($dm.Groups[2].Value -split ' [-]+ ')[0].Trim()
    $docSymbols[$sym] = $name
  }

  $inJsonOnly = $jsonSymbols.Keys | Where-Object { -not $docSymbols.ContainsKey($_) }
  $inDocOnly  = $docSymbols.Keys | Where-Object { -not $jsonSymbols.ContainsKey($_) }

  if ($inJsonOnly.Count -eq 0 -and $inDocOnly.Count -eq 0) {
    Log-Event 'OK' 'DRIFT' "No drift detected ($($jsonSymbols.Count) symbols aligned)"
    return @{ status = 'aligned'; count = $jsonSymbols.Count }
  } else {
    Log-Event 'WARN' 'DRIFT' "Drift detected: $($inJsonOnly.Count) JSON-only, $($inDocOnly.Count) doc-only"
    return @{ status = 'drift'; json_only = $inJsonOnly.Count; doc_only = $inDocOnly.Count }
  }
}

# ---- Dream Engine Graph Analysis (CPU-bound) --------------------------------

function Invoke-GraphAnalysis {
  $graphPath = Join-Path $cacheDir 'memory_graph.json'
  if (-not (Test-Path $graphPath)) {
    Log-Event 'INFO' 'GRAPH' 'No graph file yet, skipping analysis'
    return $null
  }

  Log-Event 'INFO' 'GRAPH' 'Analyzing dream graph...'
  $graph = Get-Content $graphPath -Raw | ConvertFrom-Json

  # Compute connectivity stats
  $conceptToNodes = @{}
  foreach ($node in $graph.nodes) {
    foreach ($c in $node.concepts) {
      if (-not $conceptToNodes.ContainsKey($c)) { $conceptToNodes[$c] = @() }
      $conceptToNodes[$c] += $node.source
    }
  }

  # Count edges (shared concepts)
  $edgeCount = 0
  $maxDegree = 0
  $nodeDegrees = @{}
  foreach ($pair in $conceptToNodes.GetEnumerator()) {
    $nodeList = $pair.Value
    for ($i = 0; $i -lt $nodeList.Count; $i++) {
      for ($j = $i+1; $j -lt $nodeList.Count; $j++) {
        $edgeCount++
        if (-not $nodeDegrees.ContainsKey($nodeList[$i])) { $nodeDegrees[$nodeList[$i]] = 0 }
        if (-not $nodeDegrees.ContainsKey($nodeList[$j])) { $nodeDegrees[$nodeList[$j]] = 0 }
        $nodeDegrees[$nodeList[$i]]++
        $nodeDegrees[$nodeList[$j]]++
      }
    }
  }

  if ($nodeDegrees.Count -gt 0) {
    $maxDegree = ($nodeDegrees.Values | Measure-Object -Maximum).Maximum
    $avgDegree = [math]::Round(($nodeDegrees.Values | Measure-Object -Average).Average, 1)
  } else {
    $avgDegree = 0
  }

  # Tier distribution
  $tierDist = @{}
  foreach ($n in $graph.nodes) {
    if (-not $tierDist.ContainsKey($n.tier)) { $tierDist[$n.tier] = 0 }
    $tierDist[$n.tier]++
  }

  $analysis = @{
    nodes = $graph.nodes.Count
    edges = $edgeCount
    concepts = $graph.global_concepts.Count
    cycles = $graph.cycle_count
    max_degree = $maxDegree
    avg_degree = $avgDegree
    tier_distribution = $tierDist
    top_concepts = ($graph.global_concepts | Select-Object -First 10)
  }

  Log-Event 'OK' 'GRAPH' "Graph: $($analysis.nodes) nodes, $edgeCount edges, avg degree $avgDegree, $($analysis.cycles) cycles"
  return $analysis
}

# ---- Report Builder ---------------------------------------------------------

function Build-OvernightReport([hashtable]$results) {
  $report = @{
    generated = (Get-Date -Format 'o')
    hostname = $env:COMPUTERNAME
    system = @{
      cpu = (Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue).Name
      ram_gb = [math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize/1MB, 1)
      disk_free_gb = [math]::Round((Get-PSDrive C).Free/1GB, 1)
    }
    services = @{
      llama_server = (Test-LlamaServer)
      dream_engine = (Get-DreamEngineStatus)
    }
    results = $results
    summary = "Overnight orchestration complete."
  }

  $report | ConvertTo-Json -Depth 6 | Set-Content -Path $reportPath -Encoding UTF8
  Log-Event 'OK' 'REPORT' "Report saved to $reportPath"
  return $report
}

# ---- Main Loop --------------------------------------------------------------

Write-Host ""
Write-Host "+=================================================================+" -ForegroundColor Magenta
Write-Host "|  SymbolOS Overnight Orchestrator                                 |" -ForegroundColor Magenta
Write-Host "|  GPU + CPU + RAM + Network + Disk  |  Full Resource Utilization   |" -ForegroundColor Magenta
Write-Host "+=================================================================+" -ForegroundColor Magenta
Write-Host ""

# Ensure cache dir
if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }

Log-Event 'INFO' 'MAIN' 'Overnight orchestrator starting...'
Log-Event 'INFO' 'MAIN' "Config: DreamCycle=${DreamCycleDelay}s, MainLoop=${MainLoopDelay}s"

# Phase 1: Ensure services are running
Log-Event 'INFO' 'MAIN' '--- Phase 1: Service Health ---'
if (Test-LlamaServer) {
  Log-Event 'OK' 'MAIN' 'LLaMA server is running'
} else {
  Restart-LlamaServer
}

# Start Dream Engine
Start-DreamEngine

$cycle = 0
$allResults = @{}

do {
  $cycle++
  $cycleStart = Get-Date
  Log-Event 'INFO' 'MAIN' "============ Orchestrator Cycle $cycle ============"

  # Service health check
  if (-not (Test-LlamaServer)) {
    Restart-LlamaServer
    Start-DreamEngine  # Restart dream engine if server was restarted
  }

  # Check Dream Engine job status
  $dreamStatus = Get-DreamEngineStatus
  if ($dreamStatus -ne 'Running') {
    Log-Event 'WARN' 'DREAM' "Dream Engine status: $dreamStatus - restarting"
    Start-DreamEngine
  }

  # CPU-bound work (these run on CPU while GPU handles Dream Engine)
  $integrityResult = Invoke-RepoIntegrityCheck
  $allResults['integrity'] = $integrityResult

  $indexResult = Build-RepoIndex
  $allResults['index'] = $indexResult

  $driftResult = Invoke-SymbolDriftCheck
  $allResults['drift'] = $driftResult

  $graphResult = Invoke-GraphAnalysis
  if ($graphResult) { $allResults['graph'] = $graphResult }

  # Network + Disk
  $gitResult = Invoke-GitMaintenance
  $allResults['git'] = $gitResult

  $diskResult = Invoke-DiskMaintenance
  $allResults['disk'] = $diskResult

  # Build report
  Build-OvernightReport -results $allResults

  $elapsed = ((Get-Date) - $cycleStart).TotalSeconds
  Log-Event 'INFO' 'MAIN' "Cycle $cycle complete in $([math]::Round($elapsed,1))s"

  if ($Once) { break }

  Log-Event 'INFO' 'MAIN' "Next cycle in ${MainLoopDelay}s..."
  Start-Sleep -Seconds $MainLoopDelay
} while ($true)

# Cleanup
if ($script:dreamJob) {
  Stop-Job $script:dreamJob -ErrorAction SilentlyContinue
  Remove-Job $script:dreamJob -ErrorAction SilentlyContinue
}

Log-Event 'INFO' 'MAIN' 'Overnight orchestrator stopped.'

#
#    ___
#   / :turtle: \    the ship sails itself at night
#  |  ._. |    the crew sleeps, the stars compute
#   \_____/    morning finds the work done clean
#
