# SymbolOS Desktop TUI

A **ratatui**-based terminal UI that brings the SymbolOS dungeon explorer to the terminal.
Reads `symbol_map.shared.json` and presents the ring model, symbol registry, agent roster,
and d20 wisdom roller in a retro BBS aesthetic.

## Quick Start

```bash
cd desktop
cargo run
```

Or point to a specific symbol map:

```bash
cargo run -- ../symbol_map.shared.json
```

## Controls

| Key | Action |
|-----|--------|
| `←`/`→` or `Tab` | Switch tabs |
| `↑`/`↓` or `j`/`k` | Navigate lists |
| `r` | Roll for wisdom |
| `q` or `Esc` | Quit |

## Tabs

1. **⚓ Rings** — Animated R0-R7 ring model with 1905 Thoughtforms colors
2. **🗺 Symbols** — Full symbol registry from `symbol_map.shared.json` with detail panel
3. **⚔ Party** — All 7 agents with HP gauges
4. **🎲 Wisdom** — d20 wisdom roller with Rhy ASCII art

## Architecture

```
desktop/
├── Cargo.toml          Dependencies: ratatui, crossterm, serde, serde_json
└── src/
    └── main.rs         Single-file TUI (~500 lines, zero-dep on external services)
```

## Dependencies

- **ratatui 0.29** — Terminal UI framework
- **crossterm 0.28** — Cross-platform terminal manipulation
- **serde 1 + serde_json 1** — JSON parsing for symbol_map.shared.json

## Design

Matches the Chromacore '97 BBS aesthetic:
- Dark background (#080810 equivalent)
- 1905 Thoughtforms color palette for rings
- Monospace fonts throughout
- Box-drawing characters for borders
- Animated ring wheel that cycles every ~1s
- Rhy fox ASCII art in the wisdom tab
