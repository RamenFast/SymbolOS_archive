$promptPath = Join-Path $PSScriptRoot "..\prompts\mercer_codex.json"
$runbookPath = Join-Path $PSScriptRoot "..\docs\mercer_codex.md"

$codeCommand = Get-Command code -ErrorAction SilentlyContinue
if ($null -ne $codeCommand) {
  & $codeCommand.Path -r $promptPath $runbookPath
  Write-Output "Opened Mercer-Codex prompt and runbook in VS Code."
  exit 0
}

Write-Output "VS Code CLI not found. Open these files manually:"
Write-Output "- $promptPath"
Write-Output "- $runbookPath"
