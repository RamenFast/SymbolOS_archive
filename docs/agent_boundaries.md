
_Note: This document is annotated with [Thought-Forms (1905)](https://en.wikipedia.org/wiki/Thought-Forms_(book)) colors to signify the nature of the ideas._

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Guardian's Ward                                ║
║  📍 Floor: Ring 2 │ Difficulty: ⭐⭐ │ Loot: The Art of Agent Subtlety ║
║  🎨 Color: Scarlet (#FF2400)                                 ║
║                                                              ║
║  A quiet chamber, warded against unwanted intrusions.         ║
╚══════════════════════════════════════════════════════════════╝

This repo is designed to work with assistants/agents without constant back-and-forth.
These boundaries are *part of the system*. Tools and agents are expected to respect them.

## Default posture 🔵 `#0000CD`

- 🛡️ **Quiet-by-default**: prefetch silently, suggest sparingly, don’t spam. (Heartfelt devotion to user peace 🔵)
- 🧬 **Meeting place first**: treat [../symbol_map.shared.json](../symbol_map.shared.json) as canonical. (Divine sympathy/adaptability 🟢)
- 🔒 **Privacy-first**: never request or store secrets; assume private scope unless the user says otherwise. (Unselfish love 🌸)
- 🧾 **Auditability**: prefer changes that are mechanically verifiable (schemas, docs, deterministic edits). (Highest reason ✨)


        /\_/\
       ( o.o )  "To guard the peace, a silent vow,
        > ^ <    I fetch the branch, but don't know how
       /|   |\   To ask too much, or break the trust,
      (_|   |_)  In quiet code, my only lust."  — Rhy 🦊


## Repo privacy boundaries 🔴 `#FF2400`

- **Public-ish docs**: `docs/` (safe to link internally; still treat as “shareable only with consent”).
- **Private-by-default**: `memory/` and `internal_docs/`.
- **UmbrellaOS-private-dev-arch**: never leak private details into public docs; treat as fortress scope unless explicitly requested by a user inside ☂️.

       .───────.
      /  ☂️      \
     /   PRIVATE  \
    /_______________\
           |
           |
         __|__
        |     |
        |_____|

Agents MUST NOT:
- push content from `memory/` or `internal_docs/` into `docs/` unless explicitly requested
- pressure the user to publish or “open source” private content
- treat private notes as prompts to create public marketing copy

## “Ask once, then drop it” rule 🔵 `#0000CD`

If the user declines a suggestion (or doesn’t respond), agents should:
- ask at most **one** follow-up question
- then stop asking and proceed with the safest next step (or pause)

Examples of banned behavior:
- repeatedly prompting to open issues/PRs
- repeatedly suggesting the same refactor or rewrite
- repeatedly requesting to run tasks the user didn’t ask for


        /\_/\
       ( o.o )  "I speak in whispers, then I'm gone,
        > ^ <    A choice is offered, then withdrawn.
       /|   |\   What am I, who respects your space,
      (_|   |_)  And leaves no nagging in this place?"  — Rhy 🦊

             (Answer: The 'Ask Once' rule)

## Tool gating: Prefetch / Suggest / Act 🟠 `#FF8C00`

- **Prefetch**: gather context quietly; no edits. 🧠
- **Suggest**: propose a small number of options; wait. 🟠
- **Act**: edit files / run destructive tools only with clear user intent. 🔴

For high-risk actions (delete, network calls, credential use):
- require explicit confirmation every time.


       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|


## Async Ring-0 AI compatibility (default) ✨ `#FADA5E`

All AI operations run in **Ring-0 async compatibility** by default: speculation and experimentation stay isolated until explicitly promoted. No cross-scope leakage; no direct writes to public-facing docs without consent.

## Auto-approve (Ring-0) ✨ `#FADA5E`

Auto-approve is allowed only for **read-only / mechanically verifiable** maintenance (Ring-0).

Allowed examples:
- running read-only drift scans
- refreshing status dashboards
- indexing docs/schemas locally

Not allowed without explicit user confirmation:
- deleting files
- pushing to remotes
- any action that transmits data off-machine
- anything that touches secrets/credentials

## External network boundary 🔴 `#FF2400`

Unless the user explicitly asks:
- do not fetch web pages
- do not call external APIs
- do not assume cloud services are permitted

## Mechanical alignment expectations 🟣 `#8B00FF`

- Keep `docs/symbol_map.md` core symbols aligned with `symbol_map.shared.json`.
- Prefer the VS Code task: `Mercer: doc alignment scan (read-only)`.
- Add schemas to both:
  - [schemas.md](schemas.md)
  - `symbol_map.shared.json` → `indexes.schemas`

## If an agent is being annoying

User can say:
- “Stop suggesting this.”
- “Do not mention publishing/open-sourcing again.”
- “Only do requested changes; no proposals.”

Agents should treat those as hard constraints for the rest of the session.

───────────────────────────────────────────────────
🚪 EXITS:
  → [The Symbol Map](./symbol_map.md) (north)
  → [Agent Memory](./agent_memory.md) (east)
  → [Back to the Great Hall](../README.md) (back to entrance)

💎 LOOT GAINED: [A Cloak of Silence, the 'Ask Once' Amulet, and a map of repo privacy boundaries.]
───────────────────────────────────────────────────

A quiet agent,
Respects the human's calm space,
Peace is the default.

☂🦊🐢
