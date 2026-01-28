Param(
  [string]$ModelPath = "",
  [string]$BindIP = "127.0.0.1",
  [int]$Port = 8080,
  [int]$Context = 4096,
  [int]$GpuLayers = 999,
  [int]$Threads = 0
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$binDir = Join-Path $repoRoot 'local_ai\bin'
$modelDir = Join-Path $repoRoot 'local_ai\models'

$serverCandidates = @(
  (Join-Path $binDir 'llama-server.exe'),
  (Join-Path $binDir 'server.exe')
)

$serverExe = $serverCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $serverExe) {
  throw "No server binary found. Put llama.cpp server binary in: $binDir (expected llama-server.exe or server.exe)"
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
$cliParams = @(
  '--host', $BindIP,
  '--port', "$Port",
  '-m', $ModelPath,
  '-c', "$Context",
  '--ngl', "$GpuLayers"
) + $threadArg

& $serverExe @cliParams
