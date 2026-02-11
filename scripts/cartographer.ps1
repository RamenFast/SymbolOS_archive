# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT — cartographer.ps1
# ║  🎨 Color: 🟣 #8B00FF (relational / semantic memory)
# ╚══════════════════════════════════════════════════════════════╝
#
#   📐 The Cartographer — GPU Engine #2 (M2 Semantic Memory)
#
#   Generates embeddings for all memory + docs files using
#   nomic-embed-text-v1.5 via llama.cpp. Enables concept-based
#   semantic search across the entire knowledge graph.
#
#        /\_/\
#       ( o.o )  "Meanings map to vectors; search by soul, not syntax."
#        > ^ <    — Rhy 🦊
#

Param(
  [switch]$GenerateAll,      # Embed all files from scratch
  [switch]$WatchMode,        # Continuous file watching + incremental updates
  [switch]$SearchServer,     # Start HTTP API server for semantic search
  [int]$Port = 8081,         # Search API port
  [string]$Query = ""        # One-shot search query
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modelDir = Join-Path $repoRoot 'local_ai\models'
$binDir = Join-Path $repoRoot 'local_ai\bin'
$cacheDir = Join-Path $repoRoot 'local_ai\cache'
$embeddingsDir = Join-Path $cacheDir 'embeddings'
$vectorDbPath = Join-Path $embeddingsDir 'vectors.json'

# Embedding model
$embeddingModel = 'nomic-embed-text-v1.5.Q5_K_M.gguf'
$embeddingModelPath = Join-Path $modelDir $embeddingModel

# Paths to embed
$scanPaths = @(
  (Join-Path $repoRoot 'docs'),
  (Join-Path $repoRoot 'memory')
)

# Embedding server endpoint (llama.cpp /embedding)
$embeddingUrl = 'http://127.0.0.1:8082/embedding'

function Write-Ok { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info { param([string]$msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn { param([string]$msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Fail { param([string]$msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }
function Write-Cart { param([string]$msg) Write-Host "[CART] $msg" -ForegroundColor Magenta }

# Vector database structure:
# {
#   "version": "1.0",
#   "model": "nomic-embed-text-v1.5",
#   "embedding_dim": 768,
#   "documents": [
#     {
#       "id": "sha256:abc123...",
#       "path": "docs/index.md",
#       "hash": "sha256:abc123...",
#       "size": 1234,
#       "mtime":  "2026-02-11T12:34:56Z",
#       "embedding": [0.123, -0.456, ...],  // 768 dimensions
#       "preview": "First 200 chars..."
#     }
#   ]
# }

function Get-FileHash-Fast {
  param([string]$Path)
  $sha256 = [System.Security.Cryptography.SHA256]::Create()
  $stream = [System.IO.File]::OpenRead($Path)
  try {
    $hashBytes = $sha256.ComputeHash($stream)
    return [System.BitConverter]::ToString($hashBytes).Replace('-', '').ToLower()
  } finally {
    $stream.Close()
  }
}

function Start-EmbeddingServer {
  Write-Cart "Starting embeddings server on port 8082..."

  # Check if model exists
  if (-not (Test-Path $embeddingModelPath)) {
    Write-Fail "Embedding model not found: $embeddingModelPath"
    Write-Info "Run: .\scripts\setup_cartographer.ps1"
    exit 1
  }

  # Find llama-server.exe
  $serverExe = Get-ChildItem -Path $binDir -Recurse -File -Filter 'llama-server.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $serverExe) {
    Write-Fail "llama-server.exe not found in $binDir"
    exit 1
  }

  # Check if port is already in use
  $existing = Get-NetTCPConnection -LocalPort 8082 -ErrorAction SilentlyContinue
  if ($existing) {
    Write-Warn "Port 8082 already in use. Assuming embeddings server is running."
    return $null
  }

  # Start server in background
  $serverArgs = @(
    '--host', '127.0.0.1',
    '--port', '8082',
    '-m', $embeddingModelPath,
    '--embedding',
    '-ngl', '999',  # GPU offload
    '--parallel', '4'
  )

  $process = Start-Process -FilePath $serverExe.FullName -ArgumentList $serverArgs -PassThru -WindowStyle Hidden

  # Wait for server to be ready
  $maxWait = 30
  $waited = 0
  while ($waited -lt $maxWait) {
    try {
      $response = Invoke-RestMethod -Uri 'http://127.0.0.1:8082/health' -Method Get -TimeoutSec 2 -ErrorAction Stop
      Write-Ok "Embeddings server ready (PID $($process.Id))"
      return $process
    } catch {
      Start-Sleep -Seconds 1
      $waited++
    }
  }

  Write-Fail "Embeddings server failed to start within ${maxWait}s"
  exit 1
}

function Get-TextEmbedding {
  param([string]$Text)

  $body = @{
    content = $Text
  } | ConvertTo-Json -Compress

  try {
    $response = Invoke-RestMethod -Uri $embeddingUrl -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 30
    return $response.embedding
  } catch {
    Write-Warn "Embedding request failed: $_"
    return $null
  }
}

function Load-VectorDb {
  if (-not (Test-Path $vectorDbPath)) {
    return @{
      version = "1.0"
      model = "nomic-embed-text-v1.5"
      embedding_dim = 768
      documents = @()
    }
  }

  return Get-Content $vectorDbPath -Raw | ConvertFrom-Json
}

function Save-VectorDb {
  param($Db)

  New-Item -Path $embeddingsDir -ItemType Directory -Force | Out-Null
  $Db | ConvertTo-Json -Depth 10 -Compress | Set-Content $vectorDbPath -Encoding UTF8
}

function Get-DocumentsToEmbed {
  param([switch]$ForceAll)

  $db = Load-VectorDb
  $existingHashes = @{}
  foreach ($doc in $db.documents) {
    $existingHashes[$doc.path] = $doc.hash
  }

  $toEmbed = @()

  foreach ($scanPath in $scanPaths) {
    if (-not (Test-Path $scanPath)) {
      Write-Warn "Path not found: $scanPath"
      continue
    }

    $files = Get-ChildItem -Path $scanPath -Recurse -File -Include *.md,*.json,*.txt -ErrorAction SilentlyContinue

    foreach ($file in $files) {
      # Skip certain paths
      if ($file.FullName -match 'node_modules|\.git|local_ai\\cache') {
        continue
      }

      $relativePath = $file.FullName.Replace($repoRoot, '').TrimStart('\')
      $currentHash = Get-FileHash-Fast -Path $file.FullName

      if ($ForceAll -or $existingHashes[$relativePath] -ne $currentHash) {
        $toEmbed += @{
          fullPath = $file.FullName
          relativePath = $relativePath
          hash = $currentHash
          size = $file.Length
          mtime = $file.LastWriteTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
      }
    }
  }

  return $toEmbed
}

function Generate-Embeddings {
  param([switch]$ForceAll)

  Write-Cart "Scanning for documents to embed..."

  $docs = Get-DocumentsToEmbed -ForceAll:$ForceAll

  if ($docs.Count -eq 0) {
    Write-Ok "All documents are up to date. No embedding needed."
    return
  }

  Write-Info "Found $($docs.Count) documents to process"

  # Start embeddings server
  $serverProcess = Start-EmbeddingServer

  # Load existing DB
  $db = Load-VectorDb
  $existingById = @{}
  foreach ($doc in $db.documents) {
    $existingById[$doc.path] = $doc
  }

  $success = 0
  $failed = 0

  for ($i = 0; $i -lt $docs.Count; $i++) {
    $doc = $docs[$i]
    $percent = [math]::Round((($i + 1) / $docs.Count) * 100, 1)

    Write-Progress -Activity "Embedding documents" -Status "$($i + 1) / $($docs.Count) - $($doc.relativePath)" -PercentComplete $percent

    try {
      # Read file content
      $content = Get-Content $doc.fullPath -Raw -Encoding UTF8

      # Truncate if too long (8192 tokens ~= 32KB text)
      if ($content.Length -gt 32000) {
        $content = $content.Substring(0, 32000) + "..."
      }

      # Generate embedding
      $embedding = Get-TextEmbedding -Text $content

      if (-not $embedding) {
        Write-Warn "  Failed to embed: $($doc.relativePath)"
        $failed++
        continue
      }

      # Create or update document entry
      $docEntry = @{
        id = "sha256:$($doc.hash)"
        path = $doc.relativePath
        hash = $doc.hash
        size = $doc.size
        mtime = $doc.mtime
        embedding = $embedding
        preview = $content.Substring(0, [math]::Min(200, $content.Length)).Replace("`n", " ").Replace("`r", "")
      }

      # Update or add to DB
      if ($existingById.ContainsKey($doc.relativePath)) {
        # Replace existing
        for ($j = 0; $j -lt $db.documents.Count; $j++) {
          if ($db.documents[$j].path -eq $doc.relativePath) {
            $db.documents[$j] = $docEntry
            break
          }
        }
      } else {
        # Add new
        $db.documents += $docEntry
      }

      $success++

    } catch {
      Write-Warn "  Error processing $($doc.relativePath): $_"
      $failed++
    }
  }

  Write-Progress -Activity "Embedding documents" -Completed

  # Save updated DB
  Save-VectorDb -Db $db

  Write-Ok "Embedding complete: $success success, $failed failed"
  Write-Info "Vector database: $vectorDbPath ($($db.documents.Count) total documents)"

  # Stop embeddings server if we started it
  if ($serverProcess) {
    Write-Info "Stopping embeddings server..."
    Stop-Process -Id $serverProcess.Id -Force -ErrorAction SilentlyContinue
  }
}

function Search-Semantic {
  param([string]$Query, [int]$TopK = 5)

  Write-Cart "Searching: $Query"

  # Start embeddings server for query
  $serverProcess = Start-EmbeddingServer

  # Get query embedding
  $queryEmbedding = Get-TextEmbedding -Text $Query

  if (-not $queryEmbedding) {
    Write-Fail "Failed to generate query embedding"
    return
  }

  # Load vector DB
  $db = Load-VectorDb

  if ($db.documents.Count -eq 0) {
    Write-Warn "Vector database is empty. Run with -GenerateAll first."
    return
  }

  # Compute cosine similarity for each document
  $results = @()

  foreach ($doc in $db.documents) {
    $dotProduct = 0.0
    $normA = 0.0
    $normB = 0.0

    for ($i = 0; $i -lt $queryEmbedding.Count; $i++) {
      $dotProduct += $queryEmbedding[$i] * $doc.embedding[$i]
      $normA += $queryEmbedding[$i] * $queryEmbedding[$i]
      $normB += $doc.embedding[$i] * $doc.embedding[$i]
    }

    $similarity = $dotProduct / ([math]::Sqrt($normA) * [math]::Sqrt($normB))

    $results += @{
      path = $doc.path
      similarity = $similarity
      preview = $doc.preview
      size = $doc.size
      mtime = $doc.mtime
    }
  }

  # Sort by similarity descending
  $results = $results | Sort-Object -Property similarity -Descending | Select-Object -First $TopK

  # Display results
  Write-Host "`nTop $TopK results:" -ForegroundColor Magenta
  Write-Host ("=" * 60) -ForegroundColor Magenta

  for ($i = 0; $i -lt $results.Count; $i++) {
    $r = $results[$i]
    $simPercent = [math]::Round($r.similarity * 100, 1)

    Write-Host "`n$($i + 1). [$simPercent%] $($r.path)" -ForegroundColor Cyan
    Write-Host "   $($r.preview)" -ForegroundColor Gray
  }

  Write-Host ("`n" + "=" * 60 + "`n") -ForegroundColor Magenta

  # Stop embeddings server
  if ($serverProcess) {
    Stop-Process -Id $serverProcess.Id -Force -ErrorAction SilentlyContinue
  }

  return $results
}

# ═══════════════════════════════════════════════════════
#  MAIN EXECUTION
# ═══════════════════════════════════════════════════════

Write-Host "`n╔═══════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  📐 The Cartographer — Semantic Memory Navigator     ║" -ForegroundColor Magenta
Write-Host "╚═══════════════════════════════════════════════════════╝`n" -ForegroundColor Magenta

if ($GenerateAll) {
  Generate-Embeddings -ForceAll
  exit 0
}

if ($Query) {
  Search-Semantic -Query $Query -TopK 5
  exit 0
}

if ($WatchMode) {
  Write-Cart "Watch mode not yet implemented. Coming soon."
  exit 1
}

if ($SearchServer) {
  Write-Cart "Search API server not yet implemented. Coming soon."
  exit 1
}

# Default: show usage
Write-Info "Usage:"
Write-Info "  .\scripts\cartographer.ps1 -GenerateAll          # Embed all docs + memory files"
Write-Info "  .\scripts\cartographer.ps1 -Query 'agape'        # Semantic search"
Write-Info "  .\scripts\cartographer.ps1 -WatchMode            # Continuous embedding (TODO)"
Write-Info "  .\scripts\cartographer.ps1 -SearchServer         # Start HTTP API (TODO)"
Write-Host ""

#
#   📐 ☂🦊🐢
#   Coordinates mapped. Concepts connected.
#   The memory graph awaits your query.
#
