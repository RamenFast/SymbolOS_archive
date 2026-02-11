# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT — setup_local_llama.ps1
# ║  🎨 Color: 🟢 #228B22 (adaptability) + ⭐ #FFD700 (aspiration)
# ║  📍 Quest: QT-004 Local Llama Design
# ╚══════════════════════════════════════════════════════════════╝
#
#        /\_/\
#       ( o.o )  "Overnight the forge fires — by dawn, a local mind."
#        > ^ <
#       /|   |\
#      (_|   |_)  — Rhy 🦊
#
# Downloads llama.cpp (Vulkan) + Qwen2.5-8B-Instruct Q5_K_M GGUF.
# Designed to run unattended overnight on Ben's RX 6750 XT machine.
# See: docs/local_llama_design_v1.md for the full design rationale.
#
# Usage:
#   .\scripts\setup_local_llama.ps1              # default: latest llama.cpp + primary model
#   .\scripts\setup_local_llama.ps1 -SkipBinary  # model only (binary already downloaded)
#   .\scripts\setup_local_llama.ps1 -SkipModel   # binary only (model already downloaded)
#   .\scripts\setup_local_llama.ps1 -Model phi4   # download Phi-4-Mini sprint model instead

Param(
  [switch]$SkipBinary,
  [switch]$SkipModel,
  [switch]$SkipVerify,
  [ValidateSet('qwen8b', 'phi4')]
  [string]$Model = 'qwen8b',
  [string]$HfToken = ''
)

$ErrorActionPreference = 'Stop'

# ── Paths ──────────────────────────────────────────────────────
$repoRoot  = Split-Path -Parent $PSScriptRoot
$binDir    = Join-Path $repoRoot 'local_ai\bin'
$modelDir  = Join-Path $repoRoot 'local_ai\models'
$cacheDir  = Join-Path $repoRoot 'local_ai\cache'

# ── Model definitions ─────────────────────────────────────────
$models = @{
  'qwen8b' = @{
    Name         = 'Qwen3-8B Q5_K_M'
    FileName     = 'Qwen3-8B-Q5_K_M.gguf'
    MinSizeBytes = 5000000000   # ~5 GB minimum (actual ~5.45 GB)
    Sources      = @(
      'https://huggingface.co/Qwen/Qwen3-8B-GGUF/resolve/main/Qwen3-8B-Q5_K_M.gguf'
    )
  }
  'phi4' = @{
    Name         = 'Phi-4-Mini Q4_K_M'
    FileName     = 'phi-4-mini-instruct-q4_k_m.gguf'
    MinSizeBytes = 2000000000   # ~2 GB minimum (actual ~2.5 GB)
    Sources      = @(
      'https://huggingface.co/bartowski/phi-4-mini-instruct-GGUF/resolve/main/phi-4-mini-instruct-Q4_K_M.gguf',
      'https://huggingface.co/lmstudio-community/phi-4-mini-instruct-GGUF/resolve/main/phi-4-mini-instruct-Q4_K_M.gguf'
    )
  }
}

# ── Helpers ────────────────────────────────────────────────────

function Write-Step {
  Param([string]$Msg)
  Write-Host "`n=== $Msg ===" -ForegroundColor Cyan
}

function Write-Ok {
  Param([string]$Msg)
  Write-Host "  [OK] $Msg" -ForegroundColor Green
}

function Write-Warn {
  Param([string]$Msg)
  Write-Host "  [WARN] $Msg" -ForegroundColor Yellow
}

function Write-Fail {
  Param([string]$Msg)
  Write-Host "  [FAIL] $Msg" -ForegroundColor Red
}

function Ensure-Dir {
  Param([string]$Path)
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Write-Ok "Created $Path"
  } else {
    Write-Ok "Exists: $Path"
  }
}

function Download-WithResume {
  Param(
    [string]$Url,
    [string]$OutPath,
    [string]$Label,
    [string]$AuthToken = ''
  )
  # Use curl.exe (Windows built-in) for resume support + progress bar
  $curlExe = Get-Command curl.exe -ErrorAction SilentlyContinue
  if (-not $curlExe) {
    throw "curl.exe not found. Windows 10+ should have it. Check System32."
  }

  Write-Host "    Downloading: $Label" -ForegroundColor White
  Write-Host "    URL: $Url" -ForegroundColor DarkGray
  Write-Host "    Dest: $OutPath" -ForegroundColor DarkGray

  # -L = follow redirects, -C - = resume, --progress-bar = visual progress
  # --fail = return error on HTTP 4xx/5xx
  $curlArgs = @(
    '-L', '-C', '-',
    '--fail',
    '--progress-bar',
    '-o', $OutPath
  )
  if ($AuthToken) {
    $curlArgs += @('-H', "Authorization: Bearer $AuthToken")
  }
  $curlArgs += $Url

  & curl.exe @curlArgs
  if ($LASTEXITCODE -ne 0) {
    return $false
  }
  return $true
}

# ── Banner ─────────────────────────────────────────────────────
Write-Host ''
Write-Host '+--------------------------------------------------------------+' -ForegroundColor DarkYellow
Write-Host '|  SymbolOS Local Llama Setup                                  |' -ForegroundColor DarkYellow
Write-Host '|  Quest: QT-004 -- The Forge of Local Minds                   |' -ForegroundColor DarkYellow
Write-Host '+--------------------------------------------------------------+' -ForegroundColor DarkYellow
Write-Host ''

$selectedModel = $models[$Model]
Write-Host "  Model:  $($selectedModel.Name)" -ForegroundColor White
Write-Host "  Binary: llama.cpp Vulkan (Windows x64)" -ForegroundColor White
Write-Host "  Target: $repoRoot\local_ai\" -ForegroundColor White
Write-Host ''

# ── Step 1: Create directories ─────────────────────────────────
Write-Step "Step 1/4: Create directory structure"
Ensure-Dir $binDir
Ensure-Dir $modelDir
Ensure-Dir $cacheDir

# ── Step 2: Download llama.cpp ──────────────────────────────────
if (-not $SkipBinary) {
  Write-Step "Step 2/4: Download llama.cpp (Vulkan build)"

  $serverExe = Join-Path $binDir 'llama-server.exe'
  if (Test-Path $serverExe) {
    Write-Ok "llama-server.exe already exists at $serverExe"
    Write-Warn "To re-download, delete it first or use -SkipBinary"
  } else {
    # Query GitHub API for latest release tag
    Write-Host "  Querying GitHub for latest llama.cpp release..." -ForegroundColor White
    try {
      $releaseInfo = Invoke-RestMethod -Uri 'https://api.github.com/repos/ggml-org/llama.cpp/releases/latest' -TimeoutSec 30
      $tag = $releaseInfo.tag_name
      Write-Ok "Latest release: $tag"
    } catch {
      Write-Warn "GitHub API failed, using known latest: b7993"
      $tag = 'b7993'
    }

    $zipName = "llama-$tag-bin-win-vulkan-x64.zip"
    $zipUrl  = "https://github.com/ggml-org/llama.cpp/releases/download/$tag/$zipName"
    $zipPath = Join-Path $cacheDir $zipName

    $downloaded = Download-WithResume -Url $zipUrl -OutPath $zipPath -Label "llama.cpp $tag (Vulkan)"

    if (-not $downloaded) {
      Write-Fail "Failed to download llama.cpp from: $zipUrl"
      Write-Host "  Try downloading manually and placing llama-server.exe in: $binDir" -ForegroundColor Yellow
      exit 1
    }

    # Verify zip is a reasonable size (should be >5 MB)
    $zipSize = (Get-Item $zipPath).Length
    if ($zipSize -lt 5000000) {
      Write-Fail "Downloaded zip is suspiciously small ($zipSize bytes). May be an error page."
      Write-Host "  Check: $zipPath" -ForegroundColor Yellow
      exit 1
    }
    Write-Ok "Downloaded $zipName ($([math]::Round($zipSize / 1MB, 1)) MB)"

    # Extract
    Write-Host "  Extracting to $binDir ..." -ForegroundColor White
    $extractDir = Join-Path $cacheDir "llama-$tag-extract"
    if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

    # Find llama-server.exe in the extracted contents
    $found = Get-ChildItem -Path $extractDir -Recurse -File -Filter 'llama-server.exe' | Select-Object -First 1
    if (-not $found) {
      Write-Fail "llama-server.exe not found in archive. Contents:"
      Get-ChildItem -Path $extractDir -Recurse -File | Select-Object -ExpandProperty Name | ForEach-Object { Write-Host "    $_" }
      exit 1
    }

    # Copy all files from the same directory as llama-server.exe (DLLs, etc.)
    $sourceDir = $found.DirectoryName
    Get-ChildItem -Path $sourceDir -File | ForEach-Object {
      Copy-Item -Path $_.FullName -Destination $binDir -Force
    }
    Write-Ok "Extracted llama-server.exe + dependencies to $binDir"

    # Clean up extraction dir (keep the zip for resume/re-extract)
    Remove-Item $extractDir -Recurse -Force
  }
} else {
  Write-Step "Step 2/4: Skip binary download (--SkipBinary)"
}

# ── Step 3: Download model ──────────────────────────────────────
if (-not $SkipModel) {
  Write-Step "Step 3/4: Download model ($($selectedModel.Name))"

  $modelPath = Join-Path $modelDir $selectedModel.FileName
  if (Test-Path $modelPath) {
    $existingSize = (Get-Item $modelPath).Length
    if ($existingSize -ge $selectedModel.MinSizeBytes) {
      Write-Ok "Model already exists: $modelPath ($([math]::Round($existingSize / 1GB, 2)) GB)"
      Write-Warn "To re-download, delete it first or use -SkipModel"
    } else {
      Write-Warn "Partial download detected ($([math]::Round($existingSize / 1GB, 2)) GB). Resuming..."
    }
  }

  if (-not (Test-Path $modelPath) -or (Get-Item $modelPath).Length -lt $selectedModel.MinSizeBytes) {
    $success = $false
    foreach ($sourceUrl in $selectedModel.Sources) {
      Write-Host "  Trying source..." -ForegroundColor White
      $success = Download-WithResume -Url $sourceUrl -OutPath $modelPath -Label $selectedModel.Name -AuthToken $HfToken
      if ($success) {
        $dlSize = (Get-Item $modelPath).Length
        if ($dlSize -ge $selectedModel.MinSizeBytes) {
          Write-Ok "Download complete: $([math]::Round($dlSize / 1GB, 2)) GB"
          break
        } else {
          Write-Warn "File too small ($([math]::Round($dlSize / 1MB, 1)) MB), trying next source..."
          $success = $false
        }
      } else {
        Write-Warn "Source failed, trying next..."
      }
    }

    if (-not $success) {
      Write-Fail "All model sources failed (likely 401 -- HuggingFace requires auth)."
      Write-Host ''
      Write-Host '  Qwen models on HuggingFace require a free access token.' -ForegroundColor Yellow
      Write-Host '  To get one:' -ForegroundColor Yellow
      Write-Host '    1. Create account at https://huggingface.co/join' -ForegroundColor Yellow
      Write-Host '    2. Accept model license at https://huggingface.co/Qwen/Qwen2.5-8B-Instruct-GGUF' -ForegroundColor Yellow
      Write-Host '    3. Create token at https://huggingface.co/settings/tokens' -ForegroundColor Yellow
      Write-Host '    4. Re-run:' -ForegroundColor Yellow
      Write-Host '       .\scripts\setup_local_llama.ps1 -SkipBinary -HfToken YOUR_TOKEN' -ForegroundColor Cyan
      Write-Host ''
      Write-Host '  Or download manually:' -ForegroundColor Yellow
      Write-Host "    1. Download: $($selectedModel.FileName)" -ForegroundColor Yellow
      Write-Host "    2. Place in: $modelDir" -ForegroundColor Yellow
      Write-Host ''
      exit 1
    }
  }
} else {
  Write-Step "Step 3/4: Skip model download (--SkipModel)"
}

# ── Step 4: Verify ──────────────────────────────────────────────
if (-not $SkipVerify) {
  Write-Step "Step 4/4: Verify installation"

  $serverExe = Join-Path $binDir 'llama-server.exe'
  $modelPath = Join-Path $modelDir $selectedModel.FileName

  $allGood = $true

  # Check binary
  if (Test-Path $serverExe) {
    Write-Ok "Binary: $serverExe"
  } else {
    Write-Fail "Binary not found: $serverExe"
    $allGood = $false
  }

  # Check model
  if (Test-Path $modelPath) {
    $mSize = (Get-Item $modelPath).Length
    if ($mSize -ge $selectedModel.MinSizeBytes) {
      Write-Ok "Model: $modelPath ($([math]::Round($mSize / 1GB, 2)) GB)"
    } else {
      Write-Fail "Model incomplete: $([math]::Round($mSize / 1MB, 1)) MB (expected >$([math]::Round($selectedModel.MinSizeBytes / 1GB, 1)) GB)"
      $allGood = $false
    }
  } else {
    Write-Fail "Model not found: $modelPath"
    $allGood = $false
  }

  # Check Vulkan driver
  $vulkanDll = Get-ChildItem -Path $binDir -Filter 'vulkan-*.dll' -ErrorAction SilentlyContinue
  if (-not $vulkanDll) {
    $vulkanDll = Get-ChildItem -Path $binDir -Filter 'vulkan*.dll' -ErrorAction SilentlyContinue
  }
  if ($vulkanDll) {
    Write-Ok "Vulkan DLL: $($vulkanDll.Name)"
  } else {
    Write-Warn "No vulkan DLL in bin dir (may use system Vulkan -- usually fine for AMD)"
  }

  # Summary
  Write-Host ''
  if ($allGood) {
    Write-Host '+--------------------------------------------------------------+' -ForegroundColor Green
    Write-Host '|  Setup complete! Ready to launch.                            |' -ForegroundColor Green
    Write-Host '+--------------------------------------------------------------+' -ForegroundColor Green
    Write-Host ''
    Write-Host '  To start the server:' -ForegroundColor White
    Write-Host '    .\scripts\run_llama_server.ps1' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '  Or use the VS Code task:' -ForegroundColor White
    Write-Host '    "Local LLM: start llama.cpp server (Vulkan)"' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '  To verify it works:' -ForegroundColor White
    Write-Host '    Invoke-RestMethod http://127.0.0.1:8080/' -ForegroundColor Cyan
    Write-Host ''
  } else {
    Write-Host '+--------------------------------------------------------------+' -ForegroundColor Red
    Write-Host '|  Setup incomplete. Check errors above.                       |' -ForegroundColor Red
    Write-Host '+--------------------------------------------------------------+' -ForegroundColor Red
    exit 1
  }
} else {
  Write-Step 'Step 4/4: Skip verification (-SkipVerify)'
}

#
#    ___
#   / 🐢 \    "this is fine"
#  |  ._. |   — setup complete
#   \_____/   — the forge is ready
#    |   |
#
# overnight the forge fires burn
# a local mind by morning light
# the wallet breathes — free
#
# ☂🦊🐢⭐🔵
