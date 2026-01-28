Param(
  [string]$RepoRoot = "",
  [switch]$Quiet,
  [int]$MaxExamples = 10
)

$ErrorActionPreference = 'Stop'

function _Emoji([int]$codePoint) {
  return [System.Char]::ConvertFromUtf32($codePoint)
}

function _WithVS16([string]$s) {
  # Variation Selector-16 to force emoji presentation when supported.
  return $s + [char]0xFE0F
}

function Write-Banner {
  Param([string]$Status = "OK")

  $glyphs = (
    (_Emoji 0x1F9EC) +
    (_WithVS16 ([System.Char]::ConvertFromUtf32(0x2602))) +
    (_Emoji 0x1F9FE) +
    (_WithVS16 (_Emoji 0x1F6E1)) +
    (_Emoji 0x1F9E0) +
    (_Emoji 0x1F52E)
  )

  $statusGlyph = switch ($Status) {
    "OK" { _Emoji 0x2705 }
    "WARN" { (_WithVS16 ([System.Char]::ConvertFromUtf32(0x26A0))) }
    "FAIL" { _Emoji 0x26D4 }
    default { (_WithVS16 ([System.Char]::ConvertFromUtf32(0x26A0))) }
  }

  Write-Host ""
  Write-Host '==============================================================' -ForegroundColor DarkCyan
  Write-Host "  $glyphs  MERCER DOC ALIGNMENT SCAN (READ-ONLY)" -ForegroundColor DarkCyan
  Write-Host '==============================================================' -ForegroundColor DarkCyan
  Write-Host "Status: $statusGlyph $Status" -ForegroundColor Cyan
}

function Resolve-RepoRoot {
  Param([string]$RepoRoot)

  if ($RepoRoot) {
    if (-not (Test-Path -LiteralPath $RepoRoot)) { throw "RepoRoot not found: $RepoRoot" }
    return (Resolve-Path -LiteralPath $RepoRoot).Path
  }

  # Default: repo root is parent of scripts/
  return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Get-SharedSymbols {
  Param([string]$MapPath)

  $json = Get-Content -LiteralPath $MapPath -Raw | ConvertFrom-Json
  $symbols = @()
  foreach ($s in $json.symbols) {
    if ($null -ne $s.symbol -and ("$($s.symbol)".Trim()).Length -gt 0) {
      $symbols += ("$($s.symbol)".Trim())
    }
  }

  return $symbols | Select-Object -Unique
}

function Get-DocSymbols {
  Param([string]$DocPath)

  $text = Get-Content -LiteralPath $DocPath -Raw

  $heading = "## Core symbols"
  $start = $text.IndexOf($heading, [System.StringComparison]::OrdinalIgnoreCase)
  if ($start -lt 0) {
    throw "Could not find '$heading' section in: $DocPath"
  }

  $afterHeading = $start + $heading.Length

  # Find next markdown H2 after the core section.
  # Must handle both LF and CRLF line endings.
  $rest = $text.Substring($afterHeading)
  $nextHeadingMatch = [regex]::Match($rest, '(?m)^\s*##\s+')
  if (-not $nextHeadingMatch.Success) {
    $section = $rest
  } else {
    $section = $rest.Substring(0, $nextHeadingMatch.Index)
  }

  # Parse markdown list entries like: - `🧬` Meeting place ...
  $regex = [regex]::new('^\s*-\s*`(?<sym>[^`]+)`\s+', [System.Text.RegularExpressions.RegexOptions]::Multiline)
  $symbolMatches = $regex.Matches($section)

  $symbols = @()
  foreach ($m in $symbolMatches) {
    $sym = $m.Groups['sym'].Value.Trim()
    if ($sym) { $symbols += $sym }
  }

  return $symbols | Select-Object -Unique
}

$root = Resolve-RepoRoot -RepoRoot $RepoRoot
$mapPath = Join-Path $root 'symbol_map.shared.json'
$docPath = Join-Path $root 'docs\symbol_map.md'

if (-not (Test-Path -LiteralPath $mapPath)) { throw "Missing shared map: $mapPath" }
if (-not (Test-Path -LiteralPath $docPath)) { throw "Missing doc symbol map: $docPath" }

$shared = Get-SharedSymbols -MapPath $mapPath
$docCore = Get-DocSymbols -DocPath $docPath

$missingInCore = @($shared | Where-Object { $_ -notin $docCore })
$extraInCore = @($docCore | Where-Object { $_ -notin $shared })

$status = "OK"
if ($missingInCore.Count -gt 0 -or $extraInCore.Count -gt 0) { $status = "WARN" }

if (-not $Quiet) { Write-Banner -Status $status }

# Ti-ish structured output (read-only)
if (-not $Quiet) {
  $ok = _Emoji 0x2705
  $ledger = _Emoji 0x1F9FE
  $shield = _WithVS16 (_Emoji 0x1F6E1)
  $crystal = _Emoji 0x1F52E
  Write-Host "$ok Objective: detect drift between shared symbol map and human doc" -ForegroundColor Green
  Write-Host "$ledger Inputs: $mapPath ; $docPath" -ForegroundColor Gray
  Write-Host "$shield Constraints: READ-ONLY, no writes, no commits" -ForegroundColor Gray
  Write-Host "$crystal Decision: Prefetch-only scan (Suggest if drift found)" -ForegroundColor Gray
}

if ($status -eq "OK") {
  if (-not $Quiet) {
    Write-Host "" 
    Write-Host "$(_Emoji 0x2705) No drift detected. Core symbols match shared map." -ForegroundColor Green
  }
  exit 0
}

# Suggestion output (still no side effects)
Write-Host "" 
Write-Host "$(_WithVS16 ([System.Char]::ConvertFromUtf32(0x26A0))) Drift detected (suggestion only - no writes performed)." -ForegroundColor Yellow

if ($missingInCore.Count -gt 0) {
  $examples = $missingInCore | Select-Object -First $MaxExamples
  Write-Host ("- Missing in docs/symbol_map.md core section: " + ($examples -join ' ')) -ForegroundColor Yellow
  if ($missingInCore.Count -gt $examples.Count) {
    Write-Host ("  (and {0} more)" -f ($missingInCore.Count - $examples.Count)) -ForegroundColor Yellow
  }
}

if ($extraInCore.Count -gt 0) {
  $examples = $extraInCore | Select-Object -First $MaxExamples
  Write-Host ("- Extra in docs/symbol_map.md core section (not in shared map): " + ($examples -join ' ')) -ForegroundColor Yellow
  if ($extraInCore.Count -gt $examples.Count) {
    Write-Host ("  (and {0} more)" -f ($extraInCore.Count - $examples.Count)) -ForegroundColor Yellow
  }
}

Write-Host "" 
Write-Host "Verify: open docs/symbol_map.md and symbol_map.shared.json; reconcile core vs extended lists." -ForegroundColor Gray
Write-Host "MercerID: MRC-20260128-0249-23" -ForegroundColor DarkCyan

exit 2
