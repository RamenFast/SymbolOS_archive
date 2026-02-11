# SymbolOS - Cartographer Core
# Semantic embeddings engine for concept-based memory retrieval

param(
  [switch]$GenerateAll,
  [string]$Query = ""
)

$ErrorActionPreference = 'Stop'

# Paths
$repoRoot = Split-Path -Parent $PSScriptRoot
$modelDir = Join-Path $repoRoot 'local_ai\models'
$binDir = Join-Path $repoRoot 'local_ai\bin'
$embeddingsDir = Join-Path $repoRoot 'local_ai\cache\embeddings'
$vectorDbPath = Join-Path $embeddingsDir 'vectors.json'

$modelName = 'nomic-embed-text-v1.5.Q5_K_M.gguf'
$modelPath = Join-Path $modelDir $modelName
$llamaServer = Join-Path $binDir 'llama-server.exe'

$embeddingPort = 8082
$embeddingEndpoint = "http://localhost:$embeddingPort/embedding"

# Ensure directories exist
New-Item -Path $embeddingsDir -ItemType Directory -Force | Out-Null

function Write-Cart { param([string]$msg) Write-Host "[CART] $msg" -ForegroundColor Magenta }
function Write-Ok { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info { param([string]$msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }

function Start-EmbeddingServer {
  Write-Cart "Starting llama-server for embeddings on port $embeddingPort..."
  
  $process = Start-Process -FilePath $llamaServer `
    -ArgumentList @(
      '-m', $modelPath,
      '--port', $embeddingPort,
      '--embedding',
      '--n-gpu-layers', '99',
      '--ctx-size', '2048'
    ) `
    -WindowStyle Hidden `
    -PassThru
    
  Start-Sleep -Seconds 3
  
  try {
    $response = Invoke-WebRequest -Uri "http://localhost:$embeddingPort/health" -TimeoutSec 2 -UseBasicParsing
    Write-Ok "Embedding server started (PID $($process.Id))"
    return $process
  } catch {
    Write-Warning "Server may still be starting..."
    Start-Sleep -Seconds 2
    return $process
  }
}

function Get-TextEmbedding {
  param([string]$Text)
  
  # Clean text: remove problematic Unicode characters
  $cleanText = $Text -replace '[^\x00-\x7F]', ' '
  
  $body = @{
    content = $cleanText
  } | ConvertTo-Json -Compress
  
  try {
    $response = Invoke-RestMethod -Uri $embeddingEndpoint `
      -Method Post `
      -Body $body `
      -ContentType 'application/json; charset=utf-8' `
      -TimeoutSec 30
    
    return $response.embedding
  } catch {
    Write-Warning "Embedding request failed: $_"
    return $null
  }
}

function Get-DocumentsToEmbed {
  Write-Info "Scanning for documents..."
  
  $docs = @()
  $docsPath = Join-Path $repoRoot 'docs'
  $memoryPath = Join-Path $repoRoot 'memory'
  
  $patterns = @('*.md', '*.json')
  
  foreach ($pattern in $patterns) {
    $docs += Get-ChildItem -Path $docsPath -Filter $pattern -Recurse -File
    $docs += Get-ChildItem -Path $memoryPath -Filter $pattern -Recurse -File
  }
  
  Write-Ok "Found $($docs.Count) documents"
  return $docs
}

function Get-FileHash-SHA256 {
  param([string]$Path)
  $hash = Get-FileHash -Path $Path -Algorithm SHA256
  return $hash.Hash
}

function Load-VectorDb {
  if (Test-Path $vectorDbPath) {
    $content = Get-Content $vectorDbPath -Raw | ConvertFrom-Json
    Write-Info "Loaded existing vector DB: $($content.documents.Count) documents"
    return $content
  } else {
    Write-Info "Creating new vector database..."
    return @{
      version = 1
      model = $modelName
      embedding_dim = 768
      documents = @()
    }
  }
}

function Save-VectorDb {
  param($VectorDb)
  
  $json = $VectorDb | ConvertTo-Json -Depth 10
  Set-Content -Path $vectorDbPath -Value $json -Encoding UTF8
  Write-Ok "Vector DB saved: $vectorDbPath"
}

function Generate-Embeddings {
  Write-Cart "=== Cartographer: Embedding Generation ==="
  Write-Host ""
  
  # Start server
  $serverProcess = Start-EmbeddingServer
  
  try {
    # Load existing DB
    $db = Load-VectorDb
    $existingHashes = @{}
    foreach ($doc in $db.documents) {
      $existingHashes[$doc.path] = $doc.hash
    }
    
    # Get documents
    $documents = Get-DocumentsToEmbed
    $newDocs = @()
    
    Write-Info "Checking for changes..."
    foreach ($doc in $documents) {
      $relPath = $doc.FullName.Replace($repoRoot, '').TrimStart('\')
      $hash = Get-FileHash-SHA256 -Path $doc.FullName
      
      if (-not $existingHashes.ContainsKey($relPath) -or $existingHashes[$relPath] -ne $hash) {
        $newDocs += @{
          file = $doc
          path = $relPath
          hash = $hash
        }
      }
    }
    
    if ($newDocs.Count -eq 0) {
      Write-Ok "All documents already embedded. Nothing to do."
      return
    }
    
    Write-Cart "Embedding $($newDocs.Count) new/changed documents..."
    Write-Host ""
    
    $embedded = @()
    $counter = 0
    
    foreach ($docInfo in $newDocs) {
      $counter++
      Write-Host "[$counter/$($newDocs.Count)] $($docInfo.path)" -ForegroundColor Gray
      
      # Read content
      $content = Get-Content $docInfo.file.FullName -Raw -ErrorAction SilentlyContinue
      if (-not $content) { continue }
      
      # Truncate if too long
      if ($content.Length -gt 32768) {
        $content = $content.Substring(0, 32768)
      }
      
      # Get embedding
      $embedding = Get-TextEmbedding -Text $content
      if ($embedding) {
        $embedded += @{
          id = [guid]::NewGuid().ToString()
          path = $docInfo.path
          hash = $docInfo.hash
          size = $docInfo.file.Length
          mtime = $docInfo.file.LastWriteTime.ToString('o')
          embedding = $embedding
          preview = $content.Substring(0, [Math]::Min(200, $content.Length))
        }
      }
      
      Start-Sleep -Milliseconds 100
    }
    
    # Merge with existing DB
    $mergedDocs = @()
    $embeddedPaths = @{}
    foreach ($doc in $embedded) {
      $embeddedPaths[$doc.path] = $doc
    }
    
    foreach ($doc in $db.documents) {
      if (-not $embeddedPaths.ContainsKey($doc.path)) {
        $mergedDocs += $doc
      }
    }
    $mergedDocs += $embedded
    
    $db.documents = $mergedDocs
    Save-VectorDb -VectorDb $db
    
    Write-Host ""
    Write-Ok "Embedded $($embedded.Count) documents. Total: $($mergedDocs.Count)"
    
  } finally {
    if ($serverProcess) {
      Write-Info "Stopping embedding server..."
      Stop-Process -Id $serverProcess.Id -Force -ErrorAction SilentlyContinue
    }
  }
}

function Search-Semantic {
  param(
    [string]$QueryText,
    [int]$TopK = 5
  )
  
  Write-Cart "=== Semantic Search ==="
  Write-Host ""
  Write-Info "Query: $QueryText"
  Write-Host ""
  
  # Start server
  $serverProcess = Start-EmbeddingServer
  
  try {
    # Load DB
    $db = Load-VectorDb
    if ($db.documents.Count -eq 0) {
      Write-Warning "No embeddings in database. Run -GenerateAll first."
      return
    }
    
    # Get query embedding
    Write-Info "Generating query embedding..."
    $queryEmbedding = Get-TextEmbedding -Text $QueryText
    if (-not $queryEmbedding) {
      Write-Warning "Failed to generate query embedding"
      return
    }
    
    # Compute cosine similarity
    Write-Info "Searching $($db.documents.Count) documents..."
    $results = @()
    
    foreach ($doc in $db.documents) {
      $dotProduct = 0
      $normA = 0
      $normB = 0
      
      for ($i = 0; $i -lt $queryEmbedding.Count; $i++) {
        $dotProduct += $queryEmbedding[$i] * $doc.embedding[$i]
        $normA += $queryEmbedding[$i] * $queryEmbedding[$i]
        $normB += $doc.embedding[$i] * $doc.embedding[$i]
      }
      
      $similarity = $dotProduct / ([Math]::Sqrt($normA) * [Math]::Sqrt($normB))
      
      $results += @{
        path = $doc.path
        similarity = $similarity
        preview = $doc.preview
      }
    }
    
    # Sort by similarity and take top K
    $topResults = $results | Sort-Object -Property similarity -Descending | Select-Object -First $TopK
    
    Write-Host ""
    Write-Ok "Top $TopK results:"
    Write-Host ""
    
    $rank = 1
    foreach ($result in $topResults) {
      $score = [Math]::Round($result.similarity, 4)
      Write-Host "  $rank. " -NoNewline -ForegroundColor Yellow
      Write-Host $result.path -ForegroundColor Cyan
      Write-Host "     Score: $score" -ForegroundColor Gray
      Write-Host "     $($result.preview.Substring(0, [Math]::Min(80, $result.preview.Length)))..." -ForegroundColor DarkGray
      Write-Host ""
      $rank++
    }
    
  } finally {
    if ($serverProcess) {
      Write-Info "Stopping embedding server..."
      Stop-Process -Id $serverProcess.Id -Force -ErrorAction SilentlyContinue
    }
  }
}

# Main execution
Write-Host ""
Write-Host "=== Cartographer ===" -ForegroundColor Magenta
Write-Host ""

if ($GenerateAll) {
  Generate-Embeddings
  exit 0
}

if ($Query) {
  Search-Semantic -QueryText $Query -TopK 5
  exit 0
}

# Show usage
Write-Info "Usage:"
Write-Info "  .\scripts\cartographer_core.ps1 -GenerateAll"
Write-Info "  .\scripts\cartographer_core.ps1 -Query agape"
Write-Host ""
