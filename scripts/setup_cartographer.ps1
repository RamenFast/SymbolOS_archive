# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT — setup_cartographer.ps1
# ║  🎨 Color: 🟣 #8B00FF (relational / semantic)
# ╚══════════════════════════════════════════════════════════════╝
#
#   📐 The Cartographer — Semantic Memory Navigator
#
#   Downloads nomic-embed-text-v1.5 GGUF model and sets up the
#   embeddings infrastructure for concept-based memory retrieval.
#
#        /\_/\
#       ( o.o )  "Maps are made of meanings, not just marks."
#        > ^ <    — Rhy 🦊
#       /|   |\
#

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modelDir = Join-Path $repoRoot 'local_ai\models'
$cacheDir = Join-Path $repoRoot 'local_ai\cache'
$embeddingsDir = Join-Path $cacheDir 'embeddings'

# Create directories
New-Item -Path $embeddingsDir -ItemType Directory -Force | Out-Null

# Model spec
$modelName = 'nomic-embed-text-v1.5.Q5_K_M.gguf'
$modelPath = Join-Path $modelDir $modelName
$modelSize = 287309824  # ~274 MB

# HuggingFace repo: nomic-ai/nomic-embed-text-v1.5-GGUF
$hfRepo = 'nomic-ai/nomic-embed-text-v1.5-GGUF'
$hfUrl = "https://huggingface.co/$hfRepo/resolve/main/$modelName"

function Write-Ok { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info { param([string]$msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Fail { param([string]$msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }

Write-Host "`n╔═══════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  📐 Cartographer Setup — Semantic Embeddings Engine ║" -ForegroundColor Magenta
Write-Host "╚═══════════════════════════════════════════════════════╝`n" -ForegroundColor Magenta

# Check if model already exists
if (Test-Path $modelPath) {
  $existingSize = (Get-Item $modelPath).Length
  $existingSizeMB = [math]::Round($existingSize / 1048576, 2)
  $minSize = 270 * 1048576  # 270 MB in bytes
  $maxSize = 280 * 1048576  # 280 MB in bytes
  if ($existingSize -gt $minSize -and $existingSize -lt $maxSize) {
    Write-Ok "Embedding model already downloaded: $modelPath"
    Write-Info "  Size: $existingSizeMB MB"
    Write-Host "`nSetup complete. Run scripts\cartographer.ps1 to start embedding generation.`n" -ForegroundColor Green
    exit 0
  } else {
    Write-Info "Existing file size $existingSizeMB MB doesn't match expected. Re-downloading..."
    Remove-Item $modelPath -Force
  }
}

Write-Info "Downloading nomic-embed-text-v1.5 GGUF (~274 MB)..."
Write-Info "  From: $hfUrl"
Write-Info "  To:   $modelPath"
Write-Host ""

try {
  # Use Invoke-WebRequest with progress (PS 5.1 compatible)
  $ProgressPreference = 'Continue'
  Invoke-WebRequest -Uri $hfUrl -OutFile $modelPath -UseBasicParsing

  $finalSize = (Get-Item $modelPath).Length
  $finalSizeMB = [math]::Round($finalSize / 1048576, 2)
  Write-Ok "Downloaded successfully: $finalSizeMB MB"

} catch {
  Write-Fail "Download failed: $_"
  Write-Info "`nManual download option:"
  Write-Info "  1. Visit: https://huggingface.co/$hfRepo/tree/main"
  Write-Info "  2. Download $modelName"
  Write-Info "  3. Place in: $modelDir"
  exit 1
}

Write-Host ""
Write-Ok "Cartographer setup complete!"
Write-Host ""
Write-Info "Next steps:"
Write-Info "  1. Run: .\scripts\cartographer.ps1 -GenerateAll"
Write-Info "     (Embeds all docs/ and memory/ files)"
Write-Info "  2. Embeddings stored in: local_ai\cache\embeddings\"
Write-Info "  3. Semantic search API will be available on port 8081"
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "The map awaits. Every concept has coordinates." -ForegroundColor Magenta
Write-Host "☂🦊🐢 — The Cartographer is ready" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Magenta
