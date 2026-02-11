# SymbolOS - Cartographer Setup (Simplified)
# Downloads nomic-embed-text-v1.5 GGUF model for semantic embeddings

param()

$ErrorActionPreference = 'Stop'

# Paths
$repoRoot = Split-Path -Parent $PSScriptRoot
$localAiDir = Join-Path $repoRoot 'local_ai'
$cacheDir = Join-Path $localAiDir 'cache'
$modelDir = Join-Path $localAiDir 'models'
$embeddingsDir = Join-Path $cacheDir 'embeddings'

# Create directories
New-Item -Path $modelDir -ItemType Directory -Force | Out-Null
New-Item -Path $embeddingsDir -ItemType Directory -Force | Out-Null

# Model info
$modelName = 'nomic-embed-text-v1.5.Q5_K_M.gguf'
$modelPath = Join-Path $modelDir $modelName
$hfRepo = 'nomic-ai/nomic-embed-text-v1.5-GGUF'
$hfUrl = "https://huggingface.co/$hfRepo/resolve/main/$modelName`?download=true"

Write-Host "=== Cartographer Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check existing model
if (Test-Path $modelPath) {
  $existingSize = (Get-Item $modelPath).Length
  $sizeMB = [math]::Round($existingSize / 1048576, 2)
  $minBytes = 270 * 1048576
  $maxBytes = 280 * 1048576

  if ($existingSize -gt $minBytes -and $existingSize -lt $maxBytes) {
    Write-Host "[OK] Model already exists: $sizeMB MB" -ForegroundColor Green
    Write-Host ""
    Write-Host "Run: .\scripts\cartographer.ps1 -GenerateAll" -ForegroundColor Yellow
    exit 0
  } else {
    Write-Host "[WARN] Existing file size mismatch, re-downloading..." -ForegroundColor Yellow
    Remove-Item $modelPath -Force
  }
}

# Download
Write-Host "Downloading nomic-embed-text-v1.5 (~274 MB)..." -ForegroundColor Cyan
Write-Host "From: $hfUrl" -ForegroundColor Gray
Write-Host ""

try {
  $ProgressPreference = 'Continue'
  Invoke-WebRequest -Uri $hfUrl -OutFile $modelPath -UseBasicParsing

  $finalSize = (Get-Item $modelPath).Length
  $finalMB = [math]::Round($finalSize / 1048576, 2)

  Write-Host ""
  Write-Host "[OK] Downloaded: $finalMB MB" -ForegroundColor Green
  Write-Host ""
  Write-Host "Next: .\scripts\cartographer.ps1 -GenerateAll" -ForegroundColor Yellow
  Write-Host ""

} catch {
  Write-Host ""
  Write-Host "[ERROR] Download failed: $_" -ForegroundColor Red
  Write-Host ""
  Write-Host "Manual download:" -ForegroundColor Yellow
  Write-Host "  1. Visit: https://huggingface.co/$hfRepo/tree/main"
  Write-Host "  2. Download: $modelName"
  Write-Host "  3. Place in: $modelDir"
  Write-Host ""
  exit 1
}
