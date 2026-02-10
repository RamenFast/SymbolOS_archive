# SymbolOS External Documentation

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️📖  EXTERNAL DOCUMENTATION — FOR CURIOUS HUMANS          ║
║  Quest: explain SymbolOS without losing the magic            ║
║                                                              ║
║  "The umbrella is big enough."                               ║
╚══════════════════════════════════════════════════════════════╝
```

```
  (•_•)
  <)  )╯  "welcome, stranger"
   /  \    — you found something interesting
```

## Overview

This repository is a private development space for **SymbolOS**, a symbolic operating system and communication framework. SymbolOS defines a consistent symbolic language and style for system communication using intuitive symbols, emoji glyphs, poetry, memes, and colour codes. The project enables clear, concise communication between system components, users, AI agents, and external systems while maintaining privacy and security.

This repository includes a growing set of developer-facing documentation under `docs/`. This document serves as an introduction for external audiences and provides high-level guidelines.

> *"If it ain't fun, it ain't sustainable."* — Mercer Meme Canon, Rule 5

## Documentation Index

Start here:

- **Docs index** (the meeting place trailhead): [docs/index.md](docs/index.md)
- **Schemas index**: [docs/schemas.md](docs/schemas.md)
- **Meme Map** (yes, really — and it's load-bearing): [docs/meme_map.md](docs/meme_map.md)

If you are integrating tooling (e.g., a VS Code assistant/extension), the canonical shared symbol+docs map is:

- [symbol_map.shared.json](symbol_map.shared.json) — the machine-readable meeting place

Optional (public-safe) Mercer expression:

- [docs/public_private_expression.md](docs/public_private_expression.md)

Agent prompts (paste and go):

- [prompts/README.md](prompts/README.md) — four agents, one meeting place, zero style drift

## Getting Started

1. **Project goals.** The goal of SymbolOS is to create a symbolic interface layer that encodes system status and interactions using intuitive symbols, colour codes, and an 8-ring cognition architecture (Ring 0–7). All future code and documentation should adhere to these principles.
2. **Repository structure.** This repository includes:
   - `docs/`: developer documentation, style guides, protocol specifications, the meme map, and user guides.
   - `internal_docs/`: private design docs, the oath, automation contracts, and poetry layers.
   - `memory/`: repo-backed memory system — working set, open loops, decisions, glossary.
   - `prompts/`: canonical agent system prompts for ChatGPT, Codex, LLaMA, and Manus.
   - `scripts/`: automation scripts for status checks, doc alignment, and local LLM setup.
   - `extensions/`: VS Code extension for Mercer status.
   - `src/`: core source code for the SymbolOS runtime and API (when ready).
   - `examples/`: sample scripts demonstrating how to interact with SymbolOS (when ready).
3. **Documentation.** Contributors should document each module clearly, explaining its purpose, input/output behaviour and any dependencies. Use markdown (`.md`) files and embed diagrams where appropriate. And drop a turtle in the comments. 🐢

## Development Guidelines

### 1. Commit Messages

Use the Mercer-enhanced commit format:

```
🧬 [scope] description — vibe line

<body>
```

Where the emoji signals the type (🧬 feature, 🐢 fix, ☂️ docs, ⚓ refactor, 🧪 test, 🔥 chore), `scope` identifies the module, and `description` summarises the change. The vibe line is a short meme or poetry excerpt that makes the git log a joy to read.

**Examples:**
```
🧬 [prompts] add Manus Max agent prompt — "we ball, but we verify"
🐢 [memory] close loops 001, 002, 005 — "shipped it, umbrella held"
⚓ [R0] formalize Ring 0-7 architecture — the map is steady
☂️ [docs] inject meme layer across all docs — vibes are load-bearing
```

### 2. Code Style

Adhere to the project's chosen language style guide (e.g., PEP 8 for Python or Google JavaScript Style Guide). Use meaningful variable names, consistent indentation and comments to clarify complex logic. Keep functions small and single-purpose.

**Bonus:** Drop ASCII memes in long code comments as landmarks. A turtle in a 200-line file is a gift to future-you.

```
    ___
   / 🐢 \    "you're deep in the code now"
  |  ._. |   "but the logic is sound"
   \_____/   "keep going"
    |   |
```

### 3. Branching Model

Use a simple branching model:

- The `main` branch represents the latest stable development state. All development work should occur on feature branches created from `main`.
- Feature branches should be named `feature/<description>` and merged back to `main` via pull requests.
- Bug fixes use `fix/<description>` and documentation updates use `docs/<description>`.

### 4. Issues and Pull Requests

When raising an issue, provide sufficient context, steps to reproduce (if applicable) and expected outcomes. Pull requests should be focused on a single change and include a brief description, references to any related issues and relevant reviewers.

> *The skeleton guards the merge gate. Respect the skeleton.* 💀

## Next Steps

To continue development:

1. Define the **SymbolOS specification**: document the symbolic language, icons, and communication patterns.
2. Draft a **style guide**: describe how to use symbols and typography in communication. *(See [meme_map.md](docs/meme_map.md) for the vibe layer.)*
3. Add initial runtime code (when ready) and link it from [docs/index.md](docs/index.md).
4. Keep schemas authoritative and keep [docs/schemas.md](docs/schemas.md) updated.

## Disclaimer

This external document provides high-level information only. Proprietary details and the internal style map are not included here.

The memes, however, are free. 🐢

---

```
  \(•_•)/
   (  (>   "thanks for reading"
   /  \    — the umbrella is big enough
```
