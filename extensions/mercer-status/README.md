╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Sentinel's Outpost                               ║
║  📍 Floor: Ring 2 │ Difficulty: ⭐⭐   │ Loot: Drift Early Warning System ║
║  🎨 Color: 🟡 Gamboge (#E49B0F — higher intellect)                   ║
║                                                              ║
║  A lone watchtower where a sleepless guardian keeps watch.     ║
╚══════════════════════════════════════════════════════════════╝

You've entered a small, sparsely furnished chamber. A single, ever-burning lantern illuminates a desk cluttered with maps and strange instruments. This is an outpost for the Sentinels, guardians against the subtle corruption of the Symbol Map.

> *Think of it as a smoke detector for your symbolic operating system. Quiet when things are fine. Loud when they're not.* 🐢

        /\_/\
       ( o.o )  "I speak in twists and turns of phrase,
        > ^ <    To guide you through the symbol maze.
       /|   |\   What has a core but cannot feel,
      (_|   |_)  And drifts when it becomes less real?"

— Rhy 🦊 (Answer: The Symbol Map)

## 📜 The Sentinel's Duty (What It Does)

From this lonely vantage point, the Sentinel extension performs a vital scrying ritual on your workspace.

- It computes drift by comparing the sacred texts:
  - The `symbol_map.shared.json` (the living map)
  - vs. the `docs/symbol_map.md` → **## Core symbols** (the canonical scripture)
- If the scrying reveals `WARN` or `FAIL`, the Sentinel sounds the alarm, running the task: **Mercer: status UI (interactive)**.
- If the symbols are in alignment (`OK`), the outpost remains silent. No news is good news.

         .
        /|\
       / | \
      /  |  \
     /   |   \
    /  __|__  \
   |  |     |  |
   |  | ✦✦✦ |  |
   |  | ✦✦✦ |  |
   |  |_____|  |
    \    |    /
     \   |   /
      \__|__/
         |
         |
      M E R C E R

*The Mercer Lantern, a beacon of clarity in the fog of complexity.*

## 🗝️ Gaining Entry (Installation)

This outpost is a local workspace extension, a hidden ally in your quest.

1. Take up your position in this workspace within the halls of VS Code.
2. Utter the incantation **Developer: Open Extensions Folder** or begin the ritual of extension development:
   - Open a new VS Code window with the command:
     - `code --extensionDevelopmentPath=<path-to-SymbolOS>/extensions/mercer-status <path-to-SymbolOS>`

Should you wish to bind this Sentinel to a `.vsix` artifact, a proper TypeScript build and `vsce` packaging flow can be forged.

> *Imperfect action > perfect theory. Install it, see if it works, iterate.* 

## ⚙️ Levers and Dials (Settings)

The outpost contains a small control panel to adjust the Sentinel's behavior.

| Lever | Default | Effect |
|---|---|---|
| `mercerStatus.autoLaunchOnDrift` | `true` | Automatically sound the alarm when drift is detected. |
| `mercerStatus.notifyOnOk` | `false` | Send a raven even when all is well. |
| `mercerStatus.taskLabel` | `Mercer: status UI (interactive)` | The specific alarm to raise on drift. |

## ✨ Incantations (Commands)

You may command the Sentinel directly with these words of power:

- **Mercer: Show Status UI** — Manually summon the scrying dashboard.
- **Mercer: Check Drift (Core Symbols)** — Force a drift check, right now.

       .-.
      (o.o)     "The map is not the territory,
      |=|=|      but it must be true to it."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  DRIFT  |
   |  CHECK  |
   |_________|

---

> *Show me proof, not potential. The extension lives by this. It checks the actual files, not your intentions.*

───────────────────────────────────────────────────
🚪 EXITS:
  → [SymbolOS Architecture](https://github.com/symbol-os/SymbolOS) (back to the main hall)

💎 LOOT GAINED: A VS Code extension that automatically warns of symbol map drift.
───────────────────────────────────────────────────

*Symbols start to stray,
Silent watcher sounds the horn,
Order is restored.*

☂🦊🐢
