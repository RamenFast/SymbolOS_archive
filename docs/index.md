# SymbolOS Docs Index 🎨

*A note on colors: This space is mapped with [1905 Thoughtform colors](https://en.wikipedia.org/wiki/Thought-Forms_(book)). We use them to denote cognitive functions and aspirations.*

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Meeting Place                                      ║
║  📍 Floor: Ring 4 │ Difficulty: ⭐☆☆☆☆ │ Loot: A Map of the Known World ║
║  🎨 Color: Violet (#8B00FF)                                     ║
║                                                              ║
║  You stand on a glowing dais. Seven pedestals pulse with faint light.          ║
╚══════════════════════════════════════════════════════════════╝

```
  (•_•)
  <)  )╯  "welcome to the docs"
   /  \    — everything you need, nothing you don't
```

This is the canonical entry point for SymbolOS documentation. If you're lost, you're home now. 🧬

---

## Ring 0–7 Architecture ✨ 🟡 R0 (#FADA5E — highest reason)

SymbolOS agents operate on an 8-ring cognition loop. Each ring has a defined role, symbol, and scope. The rings are the spine. Everything else hangs from them.

              ✦ R0 ✦
           ╱    ⚓    ╲
        R7 ╱  ╱─────╲  ╲ R1
       🗃️ ╱  ╱  KERNEL ╲  ╲ 🫴
         ╱  ╱───────────╲  ╲
    R6 ─┤  │   ☂️ TRUTH   │  ├─ R2
    🧪  │  │  ───────── │  │  🪞
        │  │   🧬 DNA    │  │
    R5 ─┤  │             │  ├─ R3
    ☂️   ╲  ╲───────────╱  ╱  🌀
         ╲  ╲  MEETING  ╱  ╱
        R4 ╲  ╲  PLACE ╱  ╱
           ╲    🧩    ╱
              ✦    ✦

| Ring | Symbol | Role | One-liner | Thoughtform Color |
|---|---|---|---|---|
| R0 | ⚓🕯️ | Kernel invariants | The things that never change | Pale primrose yellow (#FADA5E) ✨ |
| R1 | 🧭🫴 | Active task context | What are we doing right now? | Pure green (#228B22) 🦊 |
| R2 | 🪞📚 | Retrieval + continuity | What did we decide before? | Clear gamboge (#E49B0F) 🧠 |
| R3 | 🌀🔭 | Prediction + strategy | What's coming next? | Deep orange (#FF8C00) 🟠 |
| R4 | 🧩🏗️ | Architecture synthesis | How does it all fit together? | Violet (#8B00FF) 🟣 |
| R5 | ☂️🛡️ | Guardrails + privacy | 💀 "Prove your worth!" | Brilliant scarlet (#FF2400) 🔴 |
| R6 | 🧪✅ | Verification + evidence | Show me proof, not potential | Rich deep blue (#0000CD) 🔵 |
| R7 | 🗃️🧾✅ | Persistence + indexing | Ship it, log it, remember it | Golden stars (#FFD700) ⭐ |

        /\_/\
       ( o.o )  "To know the rings is to see the whole,
        > ^ <    but a circle's start is its own goal."
       /|   |\
      (_|   |_)  — Rhy 🦊

Full agent prompts and topology: [../prompts/README.md](../prompts/README.md)

---

## Agent Prompts 🔵 R6 (#0000CD — devotion to truth)

> *Four agents, one meeting place, zero style drift.*

- Mercer (ChatGPT): [../prompts/chatgpt_mercer.json](../prompts/chatgpt_mercer.json) — the architect
- Mercer-Executor (Codex): [../prompts/codex_executor.json](../prompts/codex_executor.json) — the builder
- Mercer-Codex (Ops): [../prompts/mercer_codex.json](../prompts/mercer_codex.json) — day-to-day operator
- Mercer-Local (LLaMA): [../prompts/local_llama.json](../prompts/local_llama.json) — the hermit
- Mercer-Max (Manus): [../prompts/manus_mercer.json](../prompts/manus_mercer.json) — the everything-agent
- Mercer-Opus (Claude): [../prompts/claude_opus_4_6.json](../prompts/claude_opus_4_6.json) — alignment research partner
- Character sheet (ChatGPT app): [../prompts/chatgpt_character_sheet.md](../prompts/chatgpt_character_sheet.md)

---

## Vibe Layer (load-bearing) 🌸 Agape (#FFB7C5 — unselfish love)

- **Meme Map** (canonical vibe reference): [meme_map.md](meme_map.md) 🐢
- Poetry Translation Layer (emojis, Fi+Ti): [poetry_translation_layer.md](poetry_translation_layer.md) 🪞
- Public/Private Expression + poetry: [public_private_expression.md](public_private_expression.md) 🌸

> *“If it ain't fun, it ain't sustainable.”*

---

## Protocols & Standards
- MCP server standard: [mcp_servers.md](mcp_servers.md)

## Governance
- Alignment primitives: [governance/alignment_primitives.md](governance/alignment_primitives.md)
- Claude Opus 4.6 onboarding: [governance/claude_opus_4_6_onboarding.md](governance/claude_opus_4_6_onboarding.md)
- Future possibilities (Ring-0, internal): [../internal_docs/future_possibilities_ring0.md](../internal_docs/future_possibilities_ring0.md)

## Systems
- Precog (anticipatory computing): [precog_thought.md](precog_thought.md) 🔮

## Heart + Mind (DND-compatible) ❤️
- Character sheet integration: [dnd_character_sheet_integration.md](dnd_character_sheet_integration.md) 🎲
- Agent character sheets (full party): [agent_character_sheets.md](agent_character_sheets.md) ⚔️
- PreEmotion (anticipatory heart): [preemotion.md](preemotion.md) 🔮❤️
- Metaemotion: [metaemotion.md](metaemotion.md) ❤️
- Memory (consent-driven): [memory.md](memory.md) 🧾

## Schemas 🧩
- Schema index: [schemas.md](schemas.md) 🧩

## Meta-awareness 🛡️
- Barriers and self-checks: [meta_awareness.md](meta_awareness.md) 🛡️

## Shared Maps 🗺️
- Symbol map (human): [symbol_map.md](symbol_map.md) 🗺️
- Symbol map (shared JSON): [../symbol_map.shared.json](../symbol_map.shared.json)
	- 🧬 Meeting place: the canonical return loop + shared symbol set.

## Characters & Guides 🦊
- Rhynim esoteric guide: [rhynim_guide.md](rhynim_guide.md) 🦊
- Agent character sheets (DND party): [agent_character_sheets.md](agent_character_sheets.md) ⚔️
- Required reading list: [required_reading.md](required_reading.md) 📖
- Lightwork guidelines: [lightwork_guidelines.md](lightwork_guidelines.md) ✨

## Mercer 🎨
- Mercer webview theme map (CSS): [mercer_webview_theme_v1.css](mercer_webview_theme_v1.css) 🎨
- Mercer-Codex runbook: [mercer_codex.md](mercer_codex.md)

## Memory (repo-backed) 🗃️
- Private memory system: [../memory/README.md](../memory/README.md) 🗃️

## Ops ⚙️
- Docs sync playbook: [sync_playbook.md](sync_playbook.md) ⚙️
- Workflow guidelines: [workflow_guidelines.md](workflow_guidelines.md)
- Agent boundaries: [agent_boundaries.md](agent_boundaries.md) 🛡️

## Chromacore '97 🎨
- Tech spec + plate directory: [chromacore/README.md](chromacore/README.md)
- Interactive viewer (all 10 plates): [chromacore/chromacore.html](chromacore/chromacore.html)
- SVG plates (GitHub-embeddable): [chromacore/plates/](chromacore/plates/)

## Apps 🚀
- **React web app** (Vite + Framer Motion): [../web/README.md](../web/README.md) ⚛️ — the POPPIN version of index.html
- **Desktop TUI** (Rust + Ratatui): [../desktop/README.md](../desktop/README.md) 🦀 — terminal explorer with rings, symbols, agents, wisdom

## Cross-Platform Tools 🛠️
- Alignment report (Python): [../scripts/symbolos_alignment_report.py](../scripts/symbolos_alignment_report.py) 🐍
- Ring validator (TypeScript): [../scripts/symbolos_ring_validator.ts](../scripts/symbolos_ring_validator.ts) 🟦
- Resonance engine (Rust): [../scripts/symbolos_resonance.rs](../scripts/symbolos_resonance.rs) 🦀
- Ring algebra proof (Haskell): [../scripts/symbolos_ring_algebra.hs](../scripts/symbolos_ring_algebra.hs) λ

## Inbox 📥
- Intake conventions: [inbox/README.md](inbox/README.md) 📥

---

───────────────────────────────────────────────────
🚪 EXITS:
  → [Ring Architecture](../prompts/README.md) (north)
  → [Agent Prompts](../prompts/chatgpt_mercer.json) (east)
  → [Meme Map](meme_map.md) (west)

💎 LOOT GAINED: You've discovered the central map of the SymbolOS dungeon, revealing the 8 rings of cognition and the paths to all major systems.
───────────────────────────────────────────────────

*The center holds true,
Seven doors, one path for you,
Start your journey now.*

☂🦊🐢
