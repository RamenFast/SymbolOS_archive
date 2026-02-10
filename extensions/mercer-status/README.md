# Mercer Status (SymbolOS) — Minimal VS Code Extension

Purpose: on VS Code startup (when this workspace contains `symbol_map.shared.json`), check SymbolOS drift (core symbols) and only prompt/launch the status UI when drift is `WARN` or `FAIL`.

## What it does
- Computes drift by comparing:
  - `symbol_map.shared.json` symbols
  - vs `docs/symbol_map.md` → **## Core symbols**
- If drift is `WARN/FAIL`, it can run the existing task: **Mercer: status UI (interactive)**.

## Install (dev)
This is a local workspace extension scaffold.

1. Open this workspace in VS Code.
2. Run **Developer: Open Extensions Folder** or use extension development mode:
   - Open a new VS Code window with:
     - Command: **Developer: Reload Window** after adding it as a development extension, or
     - Use: `code --extensionDevelopmentPath=<path-to-SymbolOS>/extensions/mercer-status <path-to-SymbolOS>`

If you want this packaged and installable as a `.vsix`, we can add a proper TypeScript build and `vsce` packaging flow.

## Settings
- `mercerStatus.devMode` (default: false)
- `mercerStatus.autoApproveOnDrift` (default: false)
- `mercerStatus.promptBeforeAutoRun` (default: true)
- `mercerStatus.autoLaunchOnDrift` (default: true)
- `mercerStatus.notifyOnOk` (default: false)
- `mercerStatus.taskLabel` (default: `Mercer: status UI (interactive)`)

## Commands
- **Mercer: Show Status UI**
- **Mercer: Check Drift (Core Symbols)**
