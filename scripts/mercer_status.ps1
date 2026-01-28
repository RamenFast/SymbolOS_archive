param(
  [switch]$Once
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pyScript = Join-Path $scriptDir 'mercer_status.py'

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
  $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
}

if (-not $pythonCmd) {
  Write-Host '⛔ Python not found on PATH (python/python3).' -ForegroundColor Red
  exit 1
}

$argsList = @($pyScript)
if ($Once) { $argsList += '--once' }

& $pythonCmd.Path @argsList
exit $LASTEXITCODE
