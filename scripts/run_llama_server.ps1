# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT — run_llama_server.ps1
# ║  🎨 Color: 🟢 #228B22 (adaptability)
# ╚══════════════════════════════════════════════════════════════╝
#
#        /\_/\
#       ( o.o )  "PowerShell? More like PowerSpell. ✨"
#        > ^ <
#       /|   |\
#      (_|   |_)  — Rhy 🦊
#
Param(
  [string]$ServerDirOrExe = "",
  [string]$ModelPath = "",
  [string]$BindIP = "127.0.0.1",
  [int]$Port = 8080,
  [int]$Context = 32768,
  [int]$GpuLayers = 999,
  [int]$Threads = 0
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$binDir = Join-Path $repoRoot 'local_ai\bin'
$modelDir = Join-Path $repoRoot 'local_ai\models'

function Resolve-LlamaServerExe {
  Param(
    [string]$ServerDirOrExe,
    [string]$DefaultBinDir
  )

  $searchRoots = @()

  if ($ServerDirOrExe) {
    if (Test-Path -LiteralPath $ServerDirOrExe) {
      $item = Get-Item -LiteralPath $ServerDirOrExe
      if ($item.PSIsContainer) {
        $searchRoots += $item.FullName
      } else {
        return $item.FullName
      }
    } else {
      throw "ServerDirOrExe does not exist: $ServerDirOrExe"
    }
  }

  if (Test-Path -LiteralPath $DefaultBinDir) {
    $searchRoots += $DefaultBinDir
  }

  foreach ($root in $searchRoots | Select-Object -Unique) {
    $hit = Get-ChildItem -Path $root -Recurse -File -Filter 'llama-server.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hit) { return $hit.FullName }

    $hit = Get-ChildItem -Path $root -Recurse -File -Filter 'server.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hit) { return $hit.FullName }
  }

  return $null
}

$serverExe = Resolve-LlamaServerExe -ServerDirOrExe $ServerDirOrExe -DefaultBinDir $binDir
if (-not $serverExe) {
  throw "No server binary found. Provide -ServerDirOrExe pointing to an extracted llama.cpp folder or place llama-server.exe under: $binDir"
}

if (-not $ModelPath) {
  $ModelPath = Get-ChildItem -Path $modelDir -Filter '*.gguf' -File -ErrorAction SilentlyContinue | Select-Object -First 1 | ForEach-Object { $_.FullName }
}

if (-not $ModelPath -or -not (Test-Path $ModelPath)) {
  throw "No GGUF model found. Put one *.gguf in: $modelDir (or pass -ModelPath)."
}

$threadArg = @()
if ($Threads -gt 0) {
  $threadArg = @('-t', "$Threads")
}

Write-Host "Starting llama server" -ForegroundColor Cyan
Write-Host "  exe:   $serverExe"
Write-Host "  model: $ModelPath"
Write-Host "  url:   http://${BindIP}:${Port}"

# Common llama.cpp flags (may vary by build/version)
# --host/--port : bind address
# -m            : model path
# -c            : context length
# Qwen3 defaults to thinking mode, which puts all output in reasoning_content
# and leaves content empty. The web UI only shows content, so it looks blank.
# --no-webui             → disables web UI; API-only (MCP + scripts access via /v1/*)
# --reasoning-format none  → keeps thoughts in content (not split to reasoning_content)
# --chat-template-kwargs   → tells the Jinja template to disable thinking by default
# -fa                    -> flash attention (lower VRAM for KV cache, enables larger ctx)
# --parallel 4           -> concurrent request slots (fills GPU between token bursts)
# Per-request overrides still work (e.g. MCP server can send enable_thinking: true)
$cliParams = @(
  '--host', $BindIP,
  '--port', "$Port",
  '-m', $ModelPath,
  '-c', "$Context",
  '-ngl', "$GpuLayers",
  '-fa', 'on',
  '--parallel', '4',
  '--no-webui',
  '--reasoning-format', 'none',
  '--chat-template-kwargs', '{\"enable_thinking\":false}'
) + $threadArg

& $serverExe @cliParams

#
#    ___
#   / 🐢 \    "this is fine"
#  |  ._. |   — script complete
#   \_____/   — umbrella held
#    |   |
#
# loops run, scripts hum clean
# the fox grins, the turtle nods
# execute — breathe
#
# ☂🦊🐢
