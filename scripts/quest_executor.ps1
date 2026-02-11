#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Quest Executor — Autonomous task execution daemon for Mercer-Local

.DESCRIPTION
  Polls active quest threads every 10 minutes, extracts markdown checklists,
  routes tasks to Mercer-Local via MCP, saves progress, prevents drift.

.PARAMETER RunOnce
  Execute one task cycle and exit (for testing)

.PARAMETER Verbose
  Enable detailed logging output

.PARAMETER MaxTasks
  Maximum tasks to execute before stopping (default: 10 per 3-hour session)

.EXAMPLE
  .\quest_executor.ps1 -RunOnce -Verbose        # Test single cycle
  .\quest_executor.ps1 -MaxTasks 5              # Limited autonomous run
  .\quest_executor.ps1                          # Full daemon mode

.NOTES
  Part of SymbolOS Phase 1 — Offline autonomous operation
  Designed for RX 6750 XT + Mercer-Local (Qwen3-8B)
#>

param(
  [switch]$RunOnce,
  [switch]$Verbose,
  [int]$MaxTasks = 10
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Paths
$WorkspaceRoot = Split-Path $PSScriptRoot -Parent
$QuestThreadsDir = Join-Path $WorkspaceRoot "memory\quest_threads"
$EpisodicDir = Join-Path $WorkspaceRoot "memory\m0_episodic"
$SymbolMapPath = Join-Path $WorkspaceRoot "symbol_map.shared.json"
$LogPath = Join-Path $WorkspaceRoot "local_ai\cache\quest_executor_log.jsonl"
$ContextPath = Join-Path $WorkspaceRoot "local_ai\cache\mercer_local_context.md"

# Constants
$PollInterval = 600  # 10 minutes
$ContextRefreshInterval = 1800  # 30 minutes
$TaskTimeout = 1200  # 20 minutes
$MaxDiskUsagePercent = 90
$LocalLlmEndpoint = "http://127.0.0.1:8080/v1/chat/completions"

# State
$TasksExecuted = 0
$LastContextRefresh = [DateTime]::MinValue
$StartTime = Get-Date

function Write-Log {
  param([string]$Message, [string]$Level = "INFO")

  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $logEntry = @{
    timestamp = $timestamp
    level = $Level
    message = $Message
    executor = "quest_executor"
  } | ConvertTo-Json -Compress

  Add-Content -Path $LogPath -Value $logEntry

  if ($Verbose -or $Level -eq "ERROR") {
    $color = switch ($Level) {
      "ERROR" { "Red" }
      "WARN"  { "Yellow" }
      "SUCCESS" { "Green" }
      default { "White" }
    }
    Write-Host "[$timestamp] $Level : $Message" -ForegroundColor $color
  }
}

function Test-SafetyConstraints {
  # Check disk space
  $drive = (Get-Item $WorkspaceRoot).PSDrive
  $usage = [math]::Round(($drive.Used / $drive.Used + $drive.Free) * 100, 2)

  if ($usage -gt $MaxDiskUsagePercent) {
    Write-Log "Disk usage ${usage}% exceeds limit ${MaxDiskUsagePercent}%" "ERROR"
    return $false
  }

  # Check if symbol map changed (another agent modified state)
  $currentHash = (Get-FileHash $SymbolMapPath -Algorithm SHA256).Hash
  if ($script:LastSymbolMapHash -and $currentHash -ne $script:LastSymbolMapHash) {
    Write-Log "Symbol map changed externally — stopping for safety" "WARN"
    return $false
  }
  $script:LastSymbolMapHash = $currentHash

  # Check task budget
  if ($TasksExecuted -ge $MaxTasks) {
    Write-Log "Max tasks ($MaxTasks) reached — stopping" "INFO"
    return $false
  }

  return $true
}

function Get-ActiveQuests {
  $quests = @()

  Get-ChildItem -Path $QuestThreadsDir -Filter "QT-*.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw

    # Extract front matter status
    if ($content -match '(?ms)^---\s*\n.*?status:\s*(\w+).*?\n---') {
      $status = $matches[1]

      if ($status -eq "active") {
        # Extract unchecked tasks
        $tasks = [regex]::Matches($content, '^\s*-\s*\[\s*\]\s*(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline) |
                 ForEach-Object { $_.Groups[1].Value.Trim() }

        if ($tasks.Count -gt 0) {
          $quests += @{
            File = $_.FullName
            Name = $_.BaseName
            Tasks = $tasks
          }
        }
      }
    }
  }

  return $quests
}

function Invoke-LocalLlm {
  param(
    [string]$Prompt,
    [string]$SystemMessage = ""
  )

  $body = @{
    model = "qwen3-8b"
    messages = @(
      @{ role = "system"; content = $SystemMessage }
      @{ role = "user"; content = $Prompt }
    )
    temperature = 0.7
    max_tokens = 2000
  } | ConvertTo-Json -Depth 10

  try {
    $response = Invoke-RestMethod -Uri $LocalLlmEndpoint -Method Post -Body $body -ContentType "application/json" -TimeoutSec $TaskTimeout
    return $response.choices[0].message.content
  }
  catch {
    Write-Log "LLM request failed: $_" "ERROR"
    return $null
  }
}

function Update-QuestProgress {
  param(
    [string]$QuestFile,
    [string]$CompletedTask
  )

  $content = Get-Content $QuestFile -Raw

  # Find and check the task
  $pattern = [regex]::Escape("- [ ] $CompletedTask")
  $replacement = "- [x] $CompletedTask"

  $newContent = $content -replace $pattern, $replacement

  if ($newContent -ne $content) {
    Set-Content -Path $QuestFile -Value $newContent -NoNewline
    Write-Log "Checked task in $([System.IO.Path]::GetFileName($QuestFile)): $CompletedTask" "SUCCESS"
  }
}

function Execute-Task {
  param($Quest, $Task)

  Write-Log "Starting task from $($Quest.Name): $Task" "INFO"

  # Refresh context if needed
  if (((Get-Date) - $LastContextRefresh).TotalSeconds -gt $ContextRefreshInterval) {
    if (Test-Path $ContextPath) {
      $script:SystemContext = Get-Content $ContextPath -Raw
      $script:LastContextRefresh = Get-Date
      Write-Log "Context refreshed from $ContextPath" "INFO"
    }
  }

  # Build prompt
  $prompt = @"
You are Mercer-Local, working autonomously on quest: $($Quest.Name)

Current task: $Task

Instructions:
1. Complete this specific task
2. Be thorough but concise
3. Save any artifacts to memory/m0_episodic/ if needed
4. Return your work as markdown

Context:
$script:SystemContext
"@

  # Execute via LLM
  $result = Invoke-LocalLlm -Prompt $prompt -SystemMessage "You are Mercer-Local, a local AI agent in SymbolOS. You work autonomously on quests, document your work, and prevent drift by staying aligned with the symbol map."

  if ($result) {
    # Save work log
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $workLogPath = Join-Path $EpisodicDir "quest_work_${timestamp}.md"

    $workLog = @"
# Quest Work Log
**Quest:** $($Quest.Name)
**Task:** $Task
**Timestamp:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Executor:** Mercer-Local (autonomous)

## Output

$result

---
*Generated by quest_executor.ps1*
"@

    Set-Content -Path $workLogPath -Value $workLog
    Write-Log "Task completed → $workLogPath" "SUCCESS"

    # Update quest thread
    Update-QuestProgress -QuestFile $Quest.File -CompletedTask $Task

    $script:TasksExecuted++
    return $true
  }
  else {
    Write-Log "Task execution failed" "ERROR"
    return $false
  }
}

function Start-QuestExecutor {
  Write-Log "Quest Executor starting (MaxTasks: $MaxTasks, RunOnce: $RunOnce)" "INFO"

  # Load initial context
  if (Test-Path $ContextPath) {
    $script:SystemContext = Get-Content $ContextPath -Raw
    $script:LastContextRefresh = Get-Date
  }
  else {
    Write-Log "Context file not found: $ContextPath" "WARN"
    $script:SystemContext = "No context available"
  }

  # Initialize symbol map hash
  $script:LastSymbolMapHash = (Get-FileHash $SymbolMapPath -Algorithm SHA256).Hash

  do {
    # Safety checks
    if (-not (Test-SafetyConstraints)) {
      Write-Log "Safety constraint failed — shutting down" "WARN"
      break
    }

    # Find active quests
    $activeQuests = Get-ActiveQuests

    if ($activeQuests.Count -eq 0) {
      Write-Log "No active quests found" "INFO"
    }
    else {
      Write-Log "Found $($activeQuests.Count) active quest(s)" "INFO"

      # Execute first available task
      $taskExecuted = $false
      foreach ($quest in $activeQuests) {
        if ($quest.Tasks.Count -gt 0) {
          $task = $quest.Tasks[0]  # Take first unchecked task

          if (Execute-Task -Quest $quest -Task $task) {
            $taskExecuted = $true
            break  # One task per cycle
          }
        }
      }

      if (-not $taskExecuted) {
        Write-Log "No tasks executed this cycle" "INFO"
      }
    }

    # Report runtime stats
    $runtime = ((Get-Date) - $StartTime).TotalMinutes
    Write-Log "Runtime: $([math]::Round($runtime, 1)) min | Tasks: $TasksExecuted / $MaxTasks" "INFO"

    if (-not $RunOnce) {
      Write-Log "Sleeping $PollInterval seconds..." "INFO"
      Start-Sleep -Seconds $PollInterval
    }

  } while (-not $RunOnce -and $TasksExecuted -lt $MaxTasks)

  Write-Log "Quest Executor stopped (Tasks executed: $TasksExecuted)" "INFO"
}

# Main
try {
  # Ensure directories exist
  @($EpisodicDir, (Split-Path $LogPath -Parent)) | ForEach-Object {
    if (-not (Test-Path $_)) {
      New-Item -Path $_ -ItemType Directory -Force | Out-Null
    }
  }

  Start-QuestExecutor
}
catch {
  Write-Log "Fatal error: $_" "ERROR"
  exit 1
}
