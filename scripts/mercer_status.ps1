param(
  [switch]$Once
)

$ErrorActionPreference = 'Stop'

function Write-Banner {
  Write-Host ''
  Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Cyan
  Write-Host '║  🧬☂️🗺️  MERCER STATUS                                        ║' -ForegroundColor Cyan
  Write-Host '║  SymbolOS Workspace Pulse Check                             ║' -ForegroundColor Cyan
  Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Cyan
  Write-Host ''
}

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

function Get-CoreSymbolsFromHumanMap([string]$humanMapPath) {
  $text = Get-Content -LiteralPath $humanMapPath -Raw -Encoding UTF8
  $idx = $text.IndexOf("## Core symbols")
  if ($idx -lt 0) { return @() }

  $after = $text.Substring($idx)
  # Find the *second* heading occurrence (the first is the Core header itself)
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

function Get-DriftResult([string]$sharedMapPath, [string]$humanMapPath) {
  try {
    $shared = @(Get-SharedSymbols -sharedMapPath $sharedMapPath)
    $core = @(Get-CoreSymbolsFromHumanMap -humanMapPath $humanMapPath)

    $missing = @($shared | Where-Object { $_ -notin $core })
    $extra = @($core | Where-Object { $_ -notin $shared })

    if ($missing.Count -eq 0 -and $extra.Count -eq 0) {
      return @{ Code = 0; Summary = 'Core symbols aligned' }
    }

    $parts = @()
    if ($missing.Count -gt 0) { $parts += ("docs missing: " + ($missing -join ' ')) }
    if ($extra.Count -gt 0) { $parts += ("docs extra: " + ($extra -join ' ')) }

    return @{ Code = 2; Summary = ($parts -join '; ') }
  } catch {
    return @{ Code = 1; Summary = ("Error checking drift: " + $_.Exception.Message) }
  }
}

function Show-Status([string]$repoRoot) {
  $sharedMap = Join-Path $repoRoot 'symbol_map.shared.json'
  $docsIndex = Join-Path $repoRoot 'docs\index.md'
  $readme = Join-Path $repoRoot 'README.md'
  $humanMap = Join-Path $repoRoot 'docs\symbol_map.md'
  $lilyPrivate = Join-Path $repoRoot 'docs\assets\lily_background.private.png'
  $bootupArtDir = Join-Path $repoRoot 'docs\assets\bootup_cards'

  Write-Banner
  Write-Host "🗺️  Repo root: $repoRoot" -ForegroundColor Gray
  Write-Host ("🧬 Meeting place: symbol_map.shared.json={0} | docs/index.md={1} | README.md={2}" -f (Test-ExistsLabel $sharedMap), (Test-ExistsLabel $docsIndex), (Test-ExistsLabel $readme)) -ForegroundColor Gray
  Write-Host ("🌸 Lily backdrop (private): {0}" -f (Test-ExistsLabel $lilyPrivate)) -ForegroundColor Gray
  Write-Host ("🎨 Bootup art folder (private): {0}" -f (Test-ExistsLabel $bootupArtDir)) -ForegroundColor Gray
  Write-Host ''

  $drift = Get-DriftResult -sharedMapPath $sharedMap -humanMapPath $humanMap
  $code = [int]$drift.Code
  $emoji = if ($code -eq 0) { '✅' } elseif ($code -eq 2) { '⚠️' } else { '⛔' }
  $color = if ($code -eq 0) { 'Green' } elseif ($code -eq 2) { 'Yellow' } else { 'Red' }
  Write-Host ("📋 Doc alignment (core symbols): {0} {1}" -f $emoji, $drift.Summary) -ForegroundColor $color

  return $code
}

$repo = Get-RepoRoot
$code = Show-Status -repoRoot $repo

if ($Once) {
  exit $code
}

while ($true) {
  Write-Host ''
  Write-Host '┌─ 🎯 ACTIONS ─────────────────────────────────────────────────┐' -ForegroundColor Cyan
  Write-Host '│ [R] Refresh     [O] Docs Index     [M] Map     [P] Poetry     │' -ForegroundColor Cyan
  Write-Host '│                          [Q] Quit                            │' -ForegroundColor Cyan
  Write-Host '└───────────────────────────────────────────────────────────────┘' -ForegroundColor Cyan
  $choice = (Read-Host '→').Trim().ToLower()

  if ($choice -eq 'q' -or $choice -eq 'quit' -or $choice -eq 'exit') {
    exit $code
  }

  if ($choice -eq '' -or $choice -eq 'r') {
    $code = Show-Status -repoRoot $repo
    continue
  }

  if ($choice -eq 'o') { Invoke-Item (Join-Path $repo 'docs\index.md'); continue }
  if ($choice -eq 'm') { & code (Join-Path $repo 'symbol_map.shared.json'); continue }
  if ($choice -eq 'p') { & code (Join-Path $repo 'docs\public_private_expression.md'); continue }

  Write-Host '❌ Unknown option.' -ForegroundColor Red
}
