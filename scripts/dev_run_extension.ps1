# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT — dev_run_extension.ps1
# ║  🎨 Color: 🟢 #228B22 (adaptability)
# ╚══════════════════════════════════════════════════════════════╝
#
#        /\_/\
#       ( o.o )  "PowerShell? More like PowerSpell. ✨"
#        > ^ <
#       /|   |\
#      (_|   |_)  — Rhy 🦊
#
param(
  [string]$WorkspacePath = $PSScriptRoot + '\..',
  [string]$ExtensionPath = $PSScriptRoot + '\..\extensions\mercer-status'
)

$ErrorActionPreference = 'Stop'

$workspace = (Resolve-Path -LiteralPath $WorkspacePath).Path
$ext = (Resolve-Path -LiteralPath $ExtensionPath).Path

function Resolve-CodeCommand {
  $cmd = Get-Command code -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Path }

  $candidates = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
    "$env:ProgramFiles(x86)\Microsoft VS Code\bin\code.cmd"
  )

  foreach ($c in $candidates) {
    if (Test-Path -LiteralPath $c) { return $c }
  }

  return $null
}

$code = Resolve-CodeCommand
if (-not $code) {
  Write-Host 'Could not find VS Code `code` launcher.' -ForegroundColor Red
  Write-Host 'Fix: install VS Code or enable the Shell Command: Install `code` command in PATH.'
  exit 1
}

Write-Host "Workspace: $workspace"
Write-Host "Extension: $ext"
Write-Host "Launching: $code" 

& $code --extensionDevelopmentPath "$ext" "$workspace"

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
