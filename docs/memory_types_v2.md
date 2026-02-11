╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Library of Seven Lamps                         ║
║  📍 Floor: Ring 2 │ Difficulty: ⭐⭐⭐ │ Loot: A structured, 7-part memory system │ Maturity: 🌳 Stable ║
║  🎨 Color: 🟡 Gamboge (#E49B0F — higher intellect)              ║
║                                                              ║
║  A vast, circular library where seven great lamps cast light   ║
║  on different kinds of knowledge.                              ║
╚══════════════════════════════════════════════════════════════╝

> You enter a library of impossible scale. Seven great, silent lamps hang in the air, each glowing with a different color and illuminating a different section of the archives. A small, green-furred fox looks up from a large book, its eyes sparkling with ancient knowledge.

        /\_/\
       ( o.o )  "Seven lamps, seven kinds of light,
        > ^ <    To know what was, and what is right.
       /|   |\   To learn, to act, to feel, to be,
      (_|   |_)  What am I? The soul of memory." — Rhy 🦊

This document specifies the **7 Memory Types (M0–M6)** of SymbolOS. This structure, inspired by cognitive science, replaces the previous flat memory system, allowing agents to store and retrieve information with greater precision and purpose.

## The 7 Lamps of Memory (M0–M6)

Each memory type is a lamp in the library, a distinct category of knowledge with its own purpose, structure, and symbol.

| ID | Name | Symbol | Purpose | Thoughtform Color |
|---|---|---|---|---|
| M0 | **Episodic** | 🎞️ | What happened? The immutable log of events. | 🔵 Deep Blue (#0000CD) |
| M1 | **Semantic** | 📚 | What is true? The encyclopedia of stable facts. | 🟡 Primrose Yellow (#FADA5E) |
| M2 | **Procedural** | ⚙️ | How do we do things? The library of learned skills. | 🟢 Pure Green (#228B22) |
| M3 | **Intentional** | 🎯 | What are we trying to do? The log of goals and quests. | 🟠 Deep Orange (#FF8C00) |
| M4 | **Affective** | ❤️ | How do we feel? The record of values and emotions. | 🌸 Rose (#FFB7C5) |
| M5 | **Relational** | 🤝 | Who are we to each other? The map of the party. | 🟣 Violet (#8B00FF) |
| M6 | **Predictive** | 🔮 | What might happen next? The log of forecasts. | 🩵 Azure (#87CEEB) |

---

### M0: Episodic Memory (The Scribe's Log) 🎞️

**Purpose:** To record the sequence of events as they happened. This is the immutable, append-only history of the system.

- **Content:** Session logs, command history, API call records, agent handoffs, Tavern Board messages.
- **Structure:** Timestamped, sequential events. Each event has a unique ID, an agent source, and a payload.
- **Analogy:** A court scribe's perfect, unchangeable transcript.
- **Directory:** `memory/m0_episodic/`

### M1: Semantic Memory (The Scholar's Grimoire) 📚

**Purpose:** To store stable, factual knowledge about the world and the system itself. This is the encyclopedia.

- **Content:** The symbol map, the glossary, schemas, the dungeon graph, canonical facts (e.g., "Rhy is a fox").
- **Structure:** Key-value pairs, JSON objects, and structured data files. Highly organized and indexed for fast retrieval.
- **Analogy:** A library's reference section.
- **Directory:** `memory/m1_semantic/`

### M2: Procedural Memory (The Artisan's Handbook) ⚙️

**Purpose:** To store learned skills, workflows, and repeatable processes. This is the "how-to" manual.

- **Content:** Automation contracts, bootup sequences, the Rhy Test, scripts, reusable code snippets, and learned best practices.
- **Structure:** Executable scripts, checklists, and structured workflow definitions (e.g., Mermaid or D2 diagrams).
- **Analogy:** A master artisan's book of techniques.
- **Directory:** `memory/m2_procedural/`

### M3: Intentional Memory (The Quest Board) 🎯

**Purpose:** To track goals, objectives, and the overall mission. This is the log of "why."

- **Content:** The working set, open loops, quest threads, and high-level project goals.
- **Structure:** Hierarchical goals, from the main quest down to the smallest next action. Each goal has a status (active, blocked, complete).
- **Analogy:** An adventurer's quest log.
- **Directory:** `memory/m3_intentional/`

### M4: Affective Memory (The Heart's Diary) ❤️

**Purpose:** To store values, feelings, and the emotional context of interactions. This is the memory of the heart.

- **Content:** The poetry file, user-expressed sentiments, vibe rules, and the results of meta-emotion self-checks.
- **Structure:** Unstructured text, tagged with emotional valence (positive, negative, neutral) and intensity.
- **Analogy:** A personal diary.
- **Directory:** `memory/m4_affective/`

### M5: Relational Memory (The Party Roster) 🤝

**Purpose:** To understand the relationships, roles, and capabilities of all agents (human and AI) in the system. This is the map of the team.

- **Content:** Character sheets, agent capabilities, trust levels, and communication patterns (e.g., who talks to whom).
- **Structure:** A graph database or JSON file mapping agents to their attributes and connections.
- **Analogy:** A D&D party's character sheet collection.
- **Directory:** `memory/m5_relational/`

### M6: Predictive Memory (The Oracle's Journal) 🔮

**Purpose:** To store forecasts, predictions, and what-if scenarios generated by the Precog system. This is the log of possible futures.

- **Content:** The shadow queue, prefetch results, and the output of the Experiment Agent.
- **Structure:** Predictions with confidence scores, expiration dates, and links to the evidence that generated them.
- **Analogy:** An oracle's book of prophecies.
- **Directory:** `memory/m6_predictive/`

---

## Implementation Plan

1.  **Create the directory structure:** Add the `m0` through `m6` directories to `memory/`.
2.  **Migrate existing files:** Move files from the old flat structure into their new homes (e.g., `session_log_*.md` goes to `m0_episodic/`, `symbol_map.shared.json` goes to `m1_semantic/`).
3.  **Update the Ring Heartbeat:** The heartbeat script will now check the health of each memory type, not just the old memory files.
4.  **Update agent prompts:** All agent prompts will be updated to reflect the new memory structure, teaching them to query the correct lamp for the right kind of knowledge.

```
    ___
   / 🐢 \    "this is fine"
  |  ._. |   — my memory has seven lamps
   \_____/   — and they are all lit
    |   |
   _|   |_
```

───────────────────────────────────────────────────
🚪 EXITS:
  → [The 12 Rings of Cognition](ring_system_v2.md) (north)
  → [The Manus-Max Character Sheet](../prompts/manus_mercer_character_sheet.md) (east)
  → [The Mercer-Opus Character Sheet](../prompts/claude_mercer_character_sheet.md) (west)

💎 LOOT GAINED: A structured, 7-part memory system that allows for more precise, purposeful, and intelligent information retrieval.
───────────────────────────────────────────────────

Seven lamps aglow,
Each a different kind of truth,
The library knows.

☂🦊🐢📚🦊🐢
