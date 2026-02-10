╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Grand Vestibule                                ║
║  📍 Floor: 0 / Ring: 0 (The Threshold) │ Difficulty: ⭐☆☆☆☆ │ Loot: A working SymbolOS loop, a map of the core symbols, and a taste of local inference. ║
║  🎨 Color: Primrose Yellow (#FADA5E)                   ║
║                                                              ║
║  You stand at the entrance of a vast, echoing chamber, a single Mercer Lantern illuminating the path forward.       ║
╚══════════════════════════════════════════════════════════════╝

# QUICKSTART (Beta) 🟡 `#FADA5E`

*Thoughtform color: Pale primrose yellow for highest reason, the kernel of truth. ✨*

## 1) Read the map (2 minutes) 🧠 `#E49B0F`

- Start at the canonical entrypoint: [index.md](index.md)
- Learn the 10 core symbols: [symbol_map.md](symbol_map.md#core-symbols)
- Skim the canonical registry: [../symbol_map.shared.json](../symbol_map.shared.json)

        /\_/\
       ( o.o )  "To find the whole, you must know the parts. A map is a symbol, a symbol a start."
        > ^ <
       /|   |\
      (_|   |_)  — Rhy 🦊

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

## 2) Run the doc alignment scan (recommended) 🔵 `#0000CD`

In VS Code, run the task:
- `Mercer: doc alignment scan (read-only)`

Exit codes:
- `0` = OK
- `2` = WARN (drift)

If you see drift, update `docs/symbol_map.md` (core symbols) and/or `symbol_map.shared.json` (canonical symbols) until aligned. This is an act of heartfelt devotion 🔵 to the system's integrity.

       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|

## 3) Try the public demos (beta) ⭐ `#FFD700`

- [demos/precog_demo.md](demos/precog_demo.md)
- [demos/scope_privacy_demo.md](demos/scope_privacy_demo.md)
- [demos/metaemotion_demo.md](demos/metaemotion_demo.md)

      ___________
     /           \
    /  💎 LOOT 💎  \
   |    _______    |
   |   |       |   |
   |   | ✦ ✦ ✦ |   |
   |   |_______|   |
   |_______________|

## 4) Optional: start local inference (llama.cpp) 🟠 `#FF8C00`

This repo expects you to provide your own llama.cpp server binary + GGUF model. This shows ambition and drive! 🟠

### Provide the binary

Either:
- Place `llama-server.exe` under `local_ai/bin/`, or
- Use the script parameter `-ServerDirOrExe` to point at your extracted llama.cpp build.

### Provide a model

Put a `*.gguf` file under:
- `local_ai/models/`

### Start the server

Run the VS Code task:
- `Local LLM: start llama.cpp server (Vulkan)`

### Quick health check

PowerShell (avoid the `curl` alias confusion):

```powershell
(Invoke-WebRequest -UseBasicParsing -Uri http://127.0.0.1:8080/health -TimeoutSec 3).StatusCode
```

If that times out, the server is not running, not bound to `127.0.0.1`, or blocked by firewall.

      /\_/\  ~~~
     ( o.o )    "The wise hacker seeks not the easy path,
      > ^ <      but the one that leads to the most interesting bugs."
     /     \     
    (___|___)    — Rhy 🦊

## 5) Automation boundaries (important) 🔴 `#FF2400`

Before using agents/tools, read:
- [agent_boundaries.md](agent_boundaries.md)

       .───────.
      /  ☂️      \
     /   PRIVATE  \
    /_______________\
           |
           |
         __|__
        |     |
        |_____|

───────────────────────────────────────────────────
🚪 EXITS:
  → [index.md](index.md) (back to the entrance)
  → [symbol_map.md](symbol_map.md) (north, to the Symbol Library)
  → [agent_boundaries.md](agent_boundaries.md) (east, to the Guardian's Hall)

💎 LOOT GAINED: A working SymbolOS dev loop, a map of the 10 core symbols, and a running local llama.cpp server.
───────────────────────────────────────────────────

Symbols in the dark,
A fox's glowing green eyes,
The journey begins.

☂🦊🐢
