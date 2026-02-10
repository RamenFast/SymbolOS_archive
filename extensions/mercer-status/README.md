# Mercer Status (SymbolOS) — Minimal VS Code Extension

```
╔══════════════════════════════════════════════════════════════╗
║  🧬🔍☂️  MERCER STATUS — YOUR DRIFT EARLY WARNING SYSTEM      ║
║  Quest: catch misalignment before it catches you             ║
║                                                              ║
║  "Good enough signal. Start. Adjust on the way."             ║
╚══════════════════════════════════════════════════════════════╝
```

```
  (•_•)
  ( (  )   "hmm... is the symbol map drifting?"
   /  \    — this extension checks so you don't have to
```

**Purpose:** On VS Code startup (when this workspace contains `symbol_map.shared.json`), check SymbolOS drift (core symbols) and only prompt/launch the status UI when drift is `WARN` or `FAIL`.

> *Think of it as a smoke detector for your symbolic operating system. Quiet when things are fine. Loud when they're not.* 🐢

## What It Does

- Computes drift by comparing:
  - `symbol_map.shared.json` symbols
  - vs `docs/symbol_map.md` → **## Core symbols**
- If drift is `WARN/FAIL`, it can run the existing task: **Mercer: status UI (interactive)**.
- If drift is `OK`, it stays quiet. No news is good news.

```
    ___
   / 🐢 \    drift: OK
  |  ._. |   "this is fine"
   \_____/   — the symbols are aligned
    |   |
```

## Install (Dev)

This is a local workspace extension scaffold.

1. Open this workspace in VS Code.
2. Run **Developer: Open Extensions Folder** or use extension development mode:
   - Open a new VS Code window with:
     - Command: **Developer: Reload Window** after adding it as a development extension, or
     - Use: `code --extensionDevelopmentPath=<path-to-SymbolOS>/extensions/mercer-status <path-to-SymbolOS>`

If you want this packaged and installable as a `.vsix`, we can add a proper TypeScript build and `vsce` packaging flow.

> *"Imperfect action > perfect theory."* — Install it, see if it works, iterate.

## Settings

| Setting | Default | What It Does |
|---|---|---|
| `mercerStatus.autoLaunchOnDrift` | `true` | Auto-launch status UI when drift detected |
| `mercerStatus.notifyOnOk` | `false` | Show notification even when everything's fine |
| `mercerStatus.taskLabel` | `Mercer: status UI (interactive)` | The VS Code task to run on drift |

## Commands

- **Mercer: Show Status UI** — manually open the status dashboard
- **Mercer: Check Drift (Core Symbols)** — run a drift check right now

```
   💀
  /|🗝️|\    drift: FAIL
   / \       — "Prove your worth! Fix the symbols."
```

---

> *"Show me proof, not potential."* — The extension lives by this. It checks the actual files, not your intentions.
