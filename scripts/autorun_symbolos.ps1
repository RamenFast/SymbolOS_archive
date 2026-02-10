# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT — autorun_symbolos.ps1
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
  [switch]$SkipPrompt
)

$ErrorActionPreference = 'Stop'

function Write-Banner {
  Write-Host ''
  Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Cyan
  Write-Host '║  🧬☂️🗺️  SYMBOLOS AUTORUN — MAC ALIGNMENT                   ║' -ForegroundColor Cyan
  Write-Host '║  Quest: start clean • keep consent first                    ║' -ForegroundColor Cyan
  Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Cyan
  Write-Host ''
}

function Confirm-Autorun {
  if ($SkipPrompt) { return $true }

  Write-Host 'MAC alignment prompt (🌸):' -ForegroundColor Magenta
  Write-Host '  • Default to good faith and warmth.'
  Write-Host '  • Be honest about limits and mistakes.'
  Write-Host '  • Repair quickly when you fail.'
  Write-Host '  • Let trust grow with consistency, not pressure.'
  Write-Host ''
  Write-Host 'Warmth without truth is a leak; truth without warmth is a blade.' -ForegroundColor Yellow
  Write-Host ''

  $choice = (Read-Host 'Run autorun tasks now? (Y/N)').Trim().ToLower()
  return ($choice -eq 'y' -or $choice -eq 'yes')
}

$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
  $scriptDir = Split-Path -Parent $PSCommandPath
}

$scanScript = Join-Path $scriptDir 'mercer_doc_alignment_scan.ps1'
$statusScript = Join-Path $scriptDir 'mercer_status.ps1'

Write-Banner

if (-not (Confirm-Autorun)) {
  Write-Host 'Autorun cancelled.' -ForegroundColor Yellow
  exit 0
}

& $scanScript
& $statusScript -Once

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
