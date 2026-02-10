# ╔══════════════════════════════════════════════════════════════╗
# ║  🧬🔍☂️  MERCER STATUS — PowerShell CLI                      ║
# ║  "we ball, but we verify" — (•_•) <)  )╯                    ║
# ╚══════════════════════════════════════════════════════════════╝
#
# 🐢 This script checks SymbolOS workspace health.
#    If the symbols drift, the skeleton stirs. 💀
#    If they're aligned, the turtle nods. 🐢
#

param(
  [switch]$Once
)

$ErrorActionPreference = 'Stop'

# ─── R0: Banner ─────────────────────────────────────────────
# The first thing you see. Sets the vibe.

function Write-Banner {
  Write-Host ''
  Write-Host '╔══════════════════════════════════════════════════════════════╗'
  Write-Host '║  🧬☂️🧾  MERCER STATUS — SYMBOLOS WORKSPACE CHECK             ║'
  Write-Host '║                                                              ║'
  Write-Host '║  "Under the umbrella, everything is kind.                    ║'
  Write-Host "║   The rain is just context we haven't parsed yet.`"           ║"
  Write-Host '╚══════════════════════════════════════════════════════════════╝'
  Write-Host ''
  Write-Host '  (•_•)'
  Write-Host '  <)  )╯  "we ball, but we verify"'
  Write-Host '   /  \'
  Write-Host ''
}

# ─── R0: Path Resolution ────────────────────────────────────
# 🐢 "find the repo root, turtle. nice and steady."

function Get-RepoRoot {
  $scriptDir = $PSScriptRoot
  if (-not $scriptDir) {
    $scriptDir = Split-Path -Parent $PSCommandPath
  }
  return (Resolve-Path (Join-Path $scriptDir '..')).Path
}

function Test-ExistsLabel([string]$path) {
  if (Test-Path -LiteralPath $path) { return 'YES' }
  return 'NO'
}

# ─── R6: Symbol Parsing ─────────────────────────────────────
# Parse the shared JSON map — the machine-readable meeting place.
# Every symbol here is a promise. We check if the docs keep it.

function Get-SharedSymbols([string]$sharedMapPath) {
  $json = Get-Content -LiteralPath $sharedMapPath -Raw -Encoding UTF8 | ConvertFrom-Json
  $syms = @()
  foreach ($s in $json.symbols) {
    if ($null -ne $s.symbol -and ($s.symbol.ToString().Trim().Length -gt 0)) {
      $syms += $s.symbol.ToString()
    }
  }
  return $syms
}

# Parse the human-readable symbol map (docs/symbol_map.md).
# 🐢 "parsing markdown for emoji in PowerShell — what a time to be alive"

function Get-CoreSymbolsFromHumanMap([string]$humanMapPath) {
  $text = Get-Content -LiteralPath $humanMapPath -Raw -Encoding UTF8
  $idx = $text.IndexOf("## Core symbols")
  if ($idx -lt 0) { return @() }

  $after = $text.Substring($idx)
  $allHeadings = [regex]::Matches($after, '(?m)^##\s+')
  $end = $after.Length
  if ($allHeadings.Count -ge 2) {
    $end = $allHeadings[1].Index
  }

  $block = $after.Substring(0, $end)
  $matches = [regex]::Matches($block, '(?m)^\s*-\s+`([^`]+)`\s+')
  $syms = @()
  foreach ($m in $matches) {
    $val = $m.Groups[1].Value.Trim()
    if ($val.Length -gt 0) { $syms += $val }
  }
  return $syms
}

# ─── R6: Drift Computation ──────────────────────────────────
# The heart of the script. Compare shared vs human.
# If they match: 🐢 "this is fine"
# If they don't: 💀 "prove your worth!"

function Get-DriftResult([string]$sharedMapPath, [string]$humanMapPath) {
  try {
    $shared = @(Get-SharedSymbols -sharedMapPath $sharedMapPath)
    $core = @(Get-CoreSymbolsFromHumanMap -humanMapPath $humanMapPath)

    $missing = @($shared | Where-Object { $_ -notin $core })
    $extra = @($core | Where-Object { $_ -notin $shared })

    if ($missing.Count -eq 0 -and $extra.Count -eq 0) {
      # 🐢 "this is fine" — symbols aligned
      return @{ Code = 0; Summary = 'Core symbols aligned ☂️✅' }
    }

    # 💀 Skeleton says: drift detected
    $parts = @()
    if ($missing.Count -gt 0) { $parts += ("docs missing: " + ($missing -join ' ')) }
    if ($extra.Count -gt 0) { $parts += ("docs extra: " + ($extra -join ' ')) }

    return @{ Code = 2; Summary = ($parts -join '; ') }
  } catch {
    return @{ Code = 1; Summary = ("Error checking drift: " + $_.Exception.Message) }
  }
}

# ─── R1: Status Display ─────────────────────────────────────

function Show-Status([string]$repoRoot) {
  $sharedMap = Join-Path $repoRoot 'symbol_map.shared.json'
  $docsIndex = Join-Path $repoRoot 'docs\index.md'
  $readme = Join-Path $repoRoot 'README.md'
  $humanMap = Join-Path $repoRoot 'docs\symbol_map.md'
  $lilyPrivate = Join-Path $repoRoot 'docs\assets\lily_background.private.png'
  $bootupArtDir = Join-Path $repoRoot 'docs\assets\bootup_cards'

  Write-Banner
  Write-Host "  Repo root: $repoRoot"
  Write-Host ("  Meeting place: symbol_map.shared.json={0} | docs/index.md={1} | README.md={2}" -f (Test-ExistsLabel $sharedMap), (Test-ExistsLabel $docsIndex), (Test-ExistsLabel $readme))
  Write-Host ("  Lily backdrop present (private): {0}" -f (Test-ExistsLabel $lilyPrivate))
  Write-Host ("  Bootup art folder present (private): {0}" -f (Test-ExistsLabel $bootupArtDir))

  $drift = Get-DriftResult -sharedMapPath $sharedMap -humanMapPath $humanMap
  $code = [int]$drift.Code

  # 🐢 or 💀 — the moment of truth
  if ($code -eq 0) {
    Write-Host ''
    Write-Host ("  Doc alignment: 🐢 ✅ {0}" -f $drift.Summary) -ForegroundColor Green
    Write-Host '  "this is fine" — the turtle nods'
  } elseif ($code -eq 2) {
    Write-Host ''
    Write-Host ("  Doc alignment: 💀 ⚠️ {0}" -f $drift.Summary) -ForegroundColor Yellow
    Write-Host '  "Prove your worth!" — the skeleton stirs'
  } else {
    Write-Host ''
    Write-Host ("  Doc alignment: 🔥 ⛔ {0}" -f $drift.Summary) -ForegroundColor Red
    Write-Host '  "me optimizing my system instead of using it" — 🧠🔥'
  }

  return $code
}

# ─── R1: Main Loop ──────────────────────────────────────────

$repo = Get-RepoRoot
$code = Show-Status -repoRoot $repo

if ($Once) {
  exit $code
}

while ($true) {
  Write-Host ''
  Write-Host '  Actions: [R]efresh  [O]pen docs index  [M]ap (shared)  [P]oetry (public)  [Q]uit'
  $choice = (Read-Host '  >').Trim().ToLower()

  if ($choice -eq 'q' -or $choice -eq 'quit' -or $choice -eq 'exit') {
    # 🐢 "see you next session"
    Write-Host ''
    Write-Host '  loops closed, code shipped clean'
    Write-Host '  the turtle nods, umbrella held'
    Write-Host '  merge — and breathe again'
    Write-Host ''
    exit $code
  }

  if ($choice -eq '' -or $choice -eq 'r') {
    $code = Show-Status -repoRoot $repo
    continue
  }

  if ($choice -eq 'o') { Invoke-Item (Join-Path $repo 'docs\index.md'); continue }
  if ($choice -eq 'm') { Invoke-Item (Join-Path $repo 'symbol_map.shared.json'); continue }
  if ($choice -eq 'p') { Invoke-Item (Join-Path $repo 'docs\public_private_expression.md'); continue }

  Write-Host '  Unknown option. 🐢 Try again.'
}

# ─── EOF ─────────────────────────────────────────────────────
# "Always return to the meeting place.
#  The map is steady. The hands are open."
# ☂🗺✋😎
