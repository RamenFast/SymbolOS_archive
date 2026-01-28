Param(
  [string]$RepoRoot = "",
  [switch]$Quiet,
  [int]$MaxExamples = 10
)

$ErrorActionPreference = 'Stop'

function Write-Banner {
  Param([string]$Status = "OK")

  $glyphs = "🧬☂️🧾🛡️🧠🔮"
  $statusGlyph = switch ($Status) {
    "OK" { "✅" }
    "WARN" { "⚠️" }
    "FAIL" { "⛔" }
    default { "⚠️" }
  }

  Write-Host "" 
  Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
  Write-Host "║  $glyphs  MERCER DOC ALIGNMENT SCAN (READ-ONLY)             ║" -ForegroundColor DarkCyan
  Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
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

  # Parse markdown list entries like: - `🧬` Meeting place ...
  $regex = [regex]::new('^\s*-\s*`(?<sym>[^`]+)`\s+', [System.Text.RegularExpressions.RegexOptions]::Multiline)
  $symbolMatches = $regex.Matches($text)

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
$doc = Get-DocSymbols -DocPath $docPath

$missingInDoc = @($shared | Where-Object { $_ -notin $doc })
$extraInDoc = @($doc | Where-Object { $_ -notin $shared })

$status = "OK"
if ($missingInDoc.Count -gt 0 -or $extraInDoc.Count -gt 0) { $status = "WARN" }

if (-not $Quiet) { Write-Banner -Status $status }

# Ti-ish structured output (read-only)
if (-not $Quiet) {
  Write-Host "✅ Objective: detect drift between shared symbol map and human doc" -ForegroundColor Green
  Write-Host "🧾 Inputs: $mapPath ; $docPath" -ForegroundColor Gray
  Write-Host "🛡️ Constraints: READ-ONLY, no writes, no commits" -ForegroundColor Gray
  Write-Host "🔮 Decision: Prefetch-only scan (Suggest if drift found)" -ForegroundColor Gray
}

if ($status -eq "OK") {
  if (-not $Quiet) {
    Write-Host "" 
    Write-Host "✅ No drift detected. Docs and shared map symbols match." -ForegroundColor Green
  }
  exit 0
}

# Suggestion output (still no side effects)
Write-Host "" 
Write-Host "⚠️ Drift detected (suggestion only — no writes performed)." -ForegroundColor Yellow

if ($missingInDoc.Count -gt 0) {
  $examples = $missingInDoc | Select-Object -First $MaxExamples
  Write-Host ("- Missing in docs/symbol_map.md: " + ($examples -join ' ')) -ForegroundColor Yellow
  if ($missingInDoc.Count -gt $examples.Count) {
    Write-Host ("  (and {0} more)" -f ($missingInDoc.Count - $examples.Count)) -ForegroundColor Yellow
  }
}

if ($extraInDoc.Count -gt 0) {
  $examples = $extraInDoc | Select-Object -First $MaxExamples
  Write-Host ("- Extra in docs/symbol_map.md (not in shared map): " + ($examples -join ' ')) -ForegroundColor Yellow
  if ($extraInDoc.Count -gt $examples.Count) {
    Write-Host ("  (and {0} more)" -f ($extraInDoc.Count - $examples.Count)) -ForegroundColor Yellow
  }
}

Write-Host "" 
Write-Host "🔍 Verify: open docs/symbol_map.md and symbol_map.shared.json; reconcile core vs extended lists." -ForegroundColor Gray
Write-Host "MercerID: MRC-20260128-0249-23" -ForegroundColor DarkCyan

exit 2
