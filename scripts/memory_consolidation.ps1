# SymbolOS - Memory Consolidation Daemon ("Dream Engine")
# Keeps the GPU saturated by continuously processing memory files through the LLM.
# Fills all 4 parallel slots with semantic extraction, connection-mapping, and
# concept consolidation - like biological sleep consolidation, but running
# alongside waking activity.
#
#        /\_/\
#       ( o.o )  "The mind that never rests, dreams while awake."
#        > ^ <
#       /|   |\
#      (_|   |_)  -- Rhy
#
Param(
  [string]$LlamaUrl = "http://127.0.0.1:8080",
  [int]$CycleDelaySeconds = 5,
  [int]$MaxConcurrent = 3,         # Leave 1 slot free for real-time requests
  [int]$MaxTokens = 512,
  [switch]$Once,
  [switch]$Verbose
)

$ErrorActionPreference = 'Continue'
$repoRoot = Split-Path -Parent $PSScriptRoot
$memoryDir = Join-Path $repoRoot 'memory'
$docsDir = Join-Path $repoRoot 'docs'
$cacheDir = Join-Path $repoRoot 'local_ai\cache'
$graphPath = Join-Path $cacheDir 'memory_graph.json'
$statePath = Join-Path $cacheDir 'consolidation_state.json'

# ---- UTF-8 JSON builder (same as agent loop - PS 5.1 workaround) -----------

function Escape-JsonString([string]$s) {
  $sb = New-Object System.Text.StringBuilder ($s.Length * 2)
  for ($i = 0; $i -lt $s.Length; $i++) {
    $c = $s[$i]
    switch ($c) {
      '"'  { [void]$sb.Append('\"') }
      '\'  { [void]$sb.Append('\\') }
      "`n" { [void]$sb.Append('\n') }
      "`r" { [void]$sb.Append('\r') }
      "`t" { [void]$sb.Append('\t') }
      default {
        $code = [int]$c
        if ($code -lt 0x20) {
          [void]$sb.AppendFormat('\u{0:x4}', $code)
        } elseif ([char]::IsHighSurrogate($c) -and ($i + 1) -lt $s.Length -and [char]::IsLowSurrogate($s[$i + 1])) {
          [void]$sb.Append($c)
          $i++
          [void]$sb.Append($s[$i])
        } else {
          [void]$sb.Append($c)
        }
      }
    }
  }
  return $sb.ToString()
}

function Invoke-LlmSync {
  # Synchronous LLM call using .NET HttpWebRequest with proper UTF-8.
  # Used inside runspaces for true parallel execution across GPU slots.
  Param(
    [string]$Url,
    [string]$JsonBody
  )
  try {
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($JsonBody)
    $req = [System.Net.HttpWebRequest]::Create($Url)
    $req.Method = "POST"
    $req.ContentType = "application/json; charset=utf-8"
    $req.Timeout = 180000
    $req.ContentLength = $bodyBytes.Length
    $reqStream = $req.GetRequestStream()
    $reqStream.Write($bodyBytes, 0, $bodyBytes.Length)
    $reqStream.Close()
    $webResp = $req.GetResponse()
    $respStream = $webResp.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($respStream, [System.Text.Encoding]::UTF8)
    $respText = $reader.ReadToEnd()
    $reader.Close()
    $webResp.Close()
    return $respText
  } catch {
    return $null
  }
}

function Build-JsonBody {
  # Build the JSON request body for a chat completion.
  Param(
    [string]$System,
    [string]$UserMessage,
    [int]$Tokens = 512,
    [double]$Temperature = 0.3
  )
  $msgs = @()
  if ($System) { $msgs += @{ role = "system"; content = $System } }
  $msgs += @{ role = "user"; content = $UserMessage }

  $msgParts = @()
  foreach ($m in $msgs) {
    $r = Escape-JsonString $m.role
    $ct = Escape-JsonString $m.content
    $msgParts += "{`"role`":`"$r`",`"content`":`"$ct`"}"
  }
  $msgsJson = "[" + ($msgParts -join ",") + "]"
  $tempStr = $Temperature.ToString([System.Globalization.CultureInfo]::InvariantCulture)
  return "{`"messages`":$msgsJson,`"temperature`":$tempStr,`"max_tokens`":$Tokens,`"stream`":false,`"chat_template_kwargs`":{`"enable_thinking`":false}}"
}

function Invoke-ParallelLlm {
  # Fire multiple LLM requests in parallel using PowerShell runspaces.
  # Each runspace gets its own thread - bypasses PS 5.1's STA deadlock issue.
  # Returns an array of results in the same order as the input.
  Param(
    [array]$Jobs  # Each: @{ System = "..."; UserMessage = "..."; Tokens = 512 }
  )
  $url = "$LlamaUrl/v1/chat/completions"
  $pool = [RunspaceFactory]::CreateRunspacePool(1, $MaxConcurrent)
  $pool.Open()

  $runspaces = @()
  foreach ($job in $Jobs) {
    $jsonBody = Build-JsonBody -System $job.System -UserMessage $job.UserMessage -Tokens $job.Tokens
    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript({
      param($Url, $JsonBody)
      try {
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($JsonBody)
        $req = [System.Net.HttpWebRequest]::Create($Url)
        $req.Method = "POST"
        $req.ContentType = "application/json; charset=utf-8"
        $req.Timeout = 180000
        $req.ContentLength = $bodyBytes.Length
        $reqStream = $req.GetRequestStream()
        $reqStream.Write($bodyBytes, 0, $bodyBytes.Length)
        $reqStream.Close()
        $webResp = $req.GetResponse()
        $respStream = $webResp.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($respStream, [System.Text.Encoding]::UTF8)
        $respText = $reader.ReadToEnd()
        $reader.Close()
        $webResp.Close()
        return $respText
      } catch {
        return $null
      }
    }).AddArgument($url).AddArgument($jsonBody)

    $handle = $ps.BeginInvoke()
    $runspaces += @{ PS = $ps; Handle = $handle }
  }

  # Harvest all results (blocks until each completes)
  $results = @()
  foreach ($rs in $runspaces) {
    try {
      $raw = $rs.PS.EndInvoke($rs.Handle)
      if ($rs.PS.Streams.Error.Count -gt 0) {
        Write-Host "    [RUNSPACE-ERR] $($rs.PS.Streams.Error[0])" -ForegroundColor Red
      }
      if ($raw -and $raw.Count -gt 0 -and $raw[0]) {
        try {
          $resp = $raw[0] | ConvertFrom-Json
          $results += $resp.choices[0].message.content
        } catch {
          $results += $null
        }
      } else {
        $results += $null
      }
    } catch {
      Write-Host "    [HARVEST-ERR] $_" -ForegroundColor Red
      $results += $null
    }
    $rs.PS.Dispose()
  }

  $pool.Close()
  $pool.Dispose()

  return ,$results
}

# ---- File Discovery ---------------------------------------------------------

function Get-MemoryFiles {
  # Collect all processable files from memory/ and docs/ (markdown + JSON)
  $files = [System.Collections.ArrayList]::new()

  # Memory tier files (M0-M6)
  foreach ($tier in @('m0_episodic','m1_semantic','m2_procedural','m3_intentional','m4_affective','m5_relational','m6_predictive')) {
    $tierDir = Join-Path $memoryDir $tier
    if (Test-Path $tierDir) {
      $tierFiles = Get-ChildItem -Path $tierDir -Filter '*.md' -File -Recurse -ErrorAction SilentlyContinue
      foreach ($f in $tierFiles) { [void]$files.Add(@{ Path = $f.FullName; Tier = $tier; Kind = "memory" }) }
    }
  }

  # Top-level memory files
  foreach ($f in @('decisions.md','glossary.md','open_loops.md','working_set.md','tavern_board.md')) {
    $p = Join-Path $memoryDir $f
    if (Test-Path $p) { [void]$files.Add(@{ Path = $p; Tier = "core"; Kind = "memory" }) }
  }

  # Session logs
  $logs = Get-ChildItem -Path $memoryDir -Filter 'session_log_*.md' -File -ErrorAction SilentlyContinue
  foreach ($f in $logs) { [void]$files.Add(@{ Path = $f.FullName; Tier = "sessions"; Kind = "memory" }) }

  # Quest threads
  $qtDir = Join-Path $memoryDir 'quest_threads'
  if (Test-Path $qtDir) {
    $qts = Get-ChildItem -Path $qtDir -Filter 'QT-*.md' -File -ErrorAction SilentlyContinue
    foreach ($f in $qts) { [void]$files.Add(@{ Path = $f.FullName; Tier = "quests"; Kind = "memory" }) }
  }

  # Docs (specs, guides - semantic context)
  $docFiles = Get-ChildItem -Path $docsDir -Filter '*.md' -File -ErrorAction SilentlyContinue
  foreach ($f in $docFiles) { [void]$files.Add(@{ Path = $f.FullName; Tier = "docs"; Kind = "docs" }) }

  return ,$files
}

# ---- Consolidation Prompts --------------------------------------------------

$SystemPrompt = @"
You are the Dream Engine of SymbolOS - a background memory consolidation process.
Your job is to extract structured semantic data from documents. You process memory
files like a sleeping brain consolidates experiences.

Output ONLY valid JSON with this exact shape (no markdown, no prose):
{
  "concepts": ["concept1", "concept2"],
  "connections": [{"to_concept": "X", "relation": "relates_to", "strength": 0.8}],
  "summary": "One-line summary of this document's core meaning",
  "open_threads": ["Any unresolved questions or pending actions"],
  "emotional_valence": "neutral|positive|negative|mixed",
  "symbols_referenced": ["list any SymbolOS symbols mentioned"]
}

Rules:
- Extract 3-8 concepts (noun phrases, proper names, technical terms)
- Connections reference concepts from OTHER documents you've seen, or universal concepts
- Strength is 0.0-1.0 (how strong the conceptual link is)
- Keep summary under 30 words
- open_threads: only if the document has genuinely unfinished business
- symbols_referenced: emoji or named symbols from SymbolOS (umbrella, fox, turtle, orb, etc.)
"@

function Build-ExtractionPrompt {
  Param(
    [string]$FilePath,
    [string]$Content,
    [string]$Tier
  )
  $relPath = $FilePath.Replace($repoRoot, '').TrimStart('\','/')
  # Truncate very large files to avoid blowing context
  if ($Content.Length -gt 6000) {
    $Content = $Content.Substring(0, 6000) + "`n[... truncated at 6000 chars]"
  }
  return @"
Process this $Tier file: $relPath

---FILE CONTENT---
$Content
---END---

Extract the structured JSON. Remember: ONLY output the JSON object, nothing else.
"@
}

# ---- Graph Management -------------------------------------------------------

function Load-Graph {
  if (Test-Path $graphPath) {
    try {
      $json = [System.IO.File]::ReadAllText($graphPath, [System.Text.Encoding]::UTF8)
      return ($json | ConvertFrom-Json)
    } catch { }
  }
  return @{
    version = "1.0"
    generated = $null
    cycle_count = 0
    nodes = @()
    global_concepts = @()
  }
}

function Save-Graph {
  Param($Graph)
  $Graph.generated = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
  # Use .NET serializer - ConvertTo-Json works for non-emoji data (graph is ASCII-safe)
  $json = $Graph | ConvertTo-Json -Depth 10
  $dir = Split-Path $graphPath
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  [System.IO.File]::WriteAllText($graphPath, $json, [System.Text.Encoding]::UTF8)
}

function Load-State {
  if (Test-Path $statePath) {
    try {
      $json = [System.IO.File]::ReadAllText($statePath, [System.Text.Encoding]::UTF8)
      return ($json | ConvertFrom-Json)
    } catch { }
  }
  return @{ last_processed = @{} }
}

function Save-State {
  Param($State)
  $json = $State | ConvertTo-Json -Depth 5
  [System.IO.File]::WriteAllText($statePath, $json, [System.Text.Encoding]::UTF8)
}

# ---- Main Consolidation Loop ------------------------------------------------

function Invoke-ConsolidationCycle {
  $files = Get-MemoryFiles
  if ($files.Count -eq 0) {
    Write-Host "  [DREAM] No files to process" -ForegroundColor DarkGray
    return
  }

  $state = Load-State
  $graph = Load-Graph

  # Determine which files need (re)processing - hash-based change detection
  $toProcess = [System.Collections.ArrayList]::new()
  foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.Path, [System.Text.Encoding]::UTF8)
    $hash = [System.BitConverter]::ToString(
      [System.Security.Cryptography.SHA256]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($content)
      )
    ).Replace('-','')

    $relPath = $f.Path.Replace($repoRoot, '').TrimStart('\','/')
    $lastHash = $null
    if ($state.last_processed -is [hashtable]) {
      $lastHash = $state.last_processed[$relPath]
    } elseif ($state.last_processed.PSObject.Properties[$relPath]) {
      $lastHash = $state.last_processed.$relPath
    }

    if ($hash -ne $lastHash -and $content.Length -gt 50) {
      [void]$toProcess.Add(@{
        Path = $f.Path
        RelPath = $relPath
        Tier = $f.Tier
        Kind = $f.Kind
        Content = $content
        Hash = $hash
      })
    }
  }

  if ($toProcess.Count -eq 0) {
    Write-Host "  [DREAM] All files up-to-date ($($files.Count) tracked)" -ForegroundColor DarkGray
    return
  }

  Write-Host "  [DREAM] Processing $($toProcess.Count)/$($files.Count) changed files (max $MaxConcurrent parallel)" -ForegroundColor Magenta

  # Process in batches of $MaxConcurrent using runspace-based parallelism
  $nodeMap = @{}
  if ($graph.nodes) {
    foreach ($n in $graph.nodes) {
      $nodeMap[$n.source] = $n
    }
  }

  $batchIndex = 0
  while ($batchIndex -lt $toProcess.Count) {
    $batchEnd = [Math]::Min($batchIndex + $MaxConcurrent, $toProcess.Count)
    $batchFiles = @()
    $batchJobs = @()

    # Build batch
    for ($i = $batchIndex; $i -lt $batchEnd; $i++) {
      $f = $toProcess[$i]
      $prompt = Build-ExtractionPrompt -FilePath $f.Path -Content $f.Content -Tier $f.Tier
      $batchJobs += @{ System = $SystemPrompt; UserMessage = $prompt; Tokens = $MaxTokens }
      $batchFiles += $f
      if ($Verbose) { Write-Host "    [FIRE] Slot $($i - $batchIndex + 1): $($f.RelPath)" -ForegroundColor DarkYellow }
    }

    # Fire all in parallel via runspaces, wait for all to complete
    $results = Invoke-ParallelLlm -Jobs $batchJobs

    # Process results
    for ($i = 0; $i -lt $batchFiles.Count; $i++) {
      $f = $batchFiles[$i]
      $result = $results[$i]

      if ($result) {
        try {
          # Strip markdown code fences if the LLM wraps it
          $cleaned = $result -replace '(?s)```json\s*', '' -replace '(?s)```\s*$', '' -replace '^\s+', ''
          $parsed = $cleaned | ConvertFrom-Json

          $node = @{
            source = $f.RelPath
            tier = $f.Tier
            kind = $f.Kind
            concepts = @($parsed.concepts)
            connections = @($parsed.connections)
            summary = "$($parsed.summary)"
            open_threads = @($parsed.open_threads)
            emotional_valence = "$($parsed.emotional_valence)"
            symbols_referenced = @($parsed.symbols_referenced)
            last_processed = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
          }
          $nodeMap[$f.RelPath] = $node
          Write-Host "    [OK] $($f.RelPath) -> $($parsed.concepts.Count) concepts" -ForegroundColor Green

          # Update hash in state
          if ($state.last_processed -is [hashtable]) {
            $state.last_processed[$f.RelPath] = $f.Hash
          } else {
            $state.last_processed | Add-Member -NotePropertyName $f.RelPath -NotePropertyValue $f.Hash -Force
          }
        } catch {
          Write-Host "    [WARN] $($f.RelPath) - LLM returned unparseable JSON" -ForegroundColor Yellow
          if ($Verbose) { Write-Host "    Raw: $($result.Substring(0, [Math]::Min(200, $result.Length)))" -ForegroundColor DarkGray }
        }
      } else {
        Write-Host "    [ERR] $($f.RelPath) - request failed" -ForegroundColor Red
      }
    }

    $batchIndex = $batchEnd
    # Incremental save after each batch (crash-resilient)
    try {
      $graph.nodes = @($nodeMap.Values)
      Save-Graph -Graph $graph
      Save-State -State $state
    } catch {
      Write-Host "    [WARN] Incremental save failed: $_" -ForegroundColor Yellow
    }
    # Brief pause between batches to let real-time requests through
    if ($batchIndex -lt $toProcess.Count) { Start-Sleep -Seconds 1 }
  }

  # Rebuild global concept index
  $allConcepts = @{}
  foreach ($key in $nodeMap.Keys) {
    $n = $nodeMap[$key]
    foreach ($c in $n.concepts) {
      if ($c) {
        if (-not $allConcepts.ContainsKey($c)) { $allConcepts[$c] = 0 }
        $allConcepts[$c]++
      }
    }
  }
  $topConcepts = $allConcepts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 50 |
    ForEach-Object { @{ concept = $_.Key; frequency = $_.Value } }

  # Save updated graph
  $graph.nodes = @($nodeMap.Values)
  $graph.global_concepts = @($topConcepts)
  $graph.cycle_count = $graph.cycle_count + 1
  Save-Graph -Graph $graph
  Save-State -State $state

  Write-Host "  [DREAM] Cycle $($graph.cycle_count) complete: $($nodeMap.Count) nodes, $($topConcepts.Count) global concepts" -ForegroundColor Magenta
}

# ---- Entry Point ------------------------------------------------------------

Write-Host ""
Write-Host "+--------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "|  Dream Engine - Memory Consolidation Daemon                   |" -ForegroundColor Magenta
$slotInfo = "$MaxConcurrent/$($MaxConcurrent+1)"
Write-Host "|  GPU: fills $slotInfo parallel slots | Endpoint: $LlamaUrl  |" -ForegroundColor Magenta
Write-Host "+--------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host ""

# Health check
try {
  $h = Invoke-RestMethod -Uri "$LlamaUrl/health" -TimeoutSec 5 -ErrorAction Stop
  if ($h.status -ne 'ok') { throw "bad status" }
  Write-Host "[OK] Server online" -ForegroundColor Green
} catch {
  Write-Host "[ERROR] llama.cpp server not reachable at $LlamaUrl" -ForegroundColor Red
  exit 1
}

$cycle = 0
do {
  $cycle++
  $ts = Get-Date -Format 'HH:mm:ss'
  Write-Host "[$ts] Dream cycle $cycle" -ForegroundColor Magenta
  try {
    Invoke-ConsolidationCycle
  } catch {
    Write-Host "  [ERR] Cycle failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  [ERR] At: $($_.ScriptStackTrace)" -ForegroundColor DarkRed
  }
  if ($Once) { break }
  Write-Host "  [SLEEP] Next cycle in ${CycleDelaySeconds}s..." -ForegroundColor DarkGray
  Start-Sleep -Seconds $CycleDelaySeconds
} while ($true)

#
#    ___
#   / 🐢 \    "the dreaming mind builds bridges
#  |  ._. |    the waking mind walks across them"
#   \_____/
#    |   |
#
# neurons fire, the graph grows deep
# connections form while mortals sleep
# the fox dreams on, the patterns weave
# what emerges - you won't believe
#
# ☂🦊🐢
