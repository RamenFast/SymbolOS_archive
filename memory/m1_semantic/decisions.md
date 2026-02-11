# Decisions (Private)

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Ledger of Unalterable Choices                  ║
║  📍 Floor: Ring 5 │ Difficulty: ⭐⭐⭐⭐ │ Loot: The logic of SymbolOS ║
║  🎨 Color: 🔴 Scarlet (#FF2400 — righteous boundary)             ║
║                                                              ║
║  A chamber where costly decisions are etched into stone.       ║
╚══════════════════════════════════════════════════════════════╝

> This is an **INTERNAL/PRIVATE** document. Trespassers will be used for ASCII art practice.


       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|


## Poetry layer (Fi+Ti mirrored) 🪞 🟣 R4 (#8B00FF — Fi+Ti bridge)

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

Record decisions that are costly to reverse. If the skeleton wouldn't let it through, it doesn't belong here.

        /\_/\
       ( o.o )  "A choice once made, a path you tread,
        > ^ <    Reversing course fills sages with dread.
       /|   |\   What's written here is hard as stone,
      (_|   |_)  So choose with care, and not alone."  — Rhy 🦊

Template:
- YYYY-MM-DD — Decision: <what>
  - Why: <reason>
  - Alternatives: <what else was considered>
  - Consequences: <tradeoffs>
  - Evidence/links: <files/commits>

---

- 2026-01-28 — Decision: Use repo-backed memory as the durable layer (Mercer/SymbolOS ASCII art + artifacts + bootup_cards + intention🗺 formatting).
  - Why: Bitrot-resistant, auditable, tool-friendly; avoids implicit model memory; consistent “Mercer/SymbolOS” markdown conventions across ☂🗺.
  - Alternatives: Chat history as memory; external notes only; mixed/unspecified formatting per folder.
  - Consequences: Requires discipline to keep it updated; requires consistent formatting gates (template bullets + `MercerID` + `-+-+-+-+-+` tool delimiters where applicable) across all folders.
  - Evidence/links: `memory/` folder; shared-map registration (`symbol_map.shared.json`); this file (`memory/decisions.md`).
  - MercerID: MRC-20260128-0249-10

- 2026-01-28 — Decision: Mercer core interface performs periodic auto-doc alignment.
  - Why: Keep docs coherent without constant manual bookkeeping.
  - Alternatives: Only suggest on demand; never auto-commit.
  - Consequences: Requires strict safety gates; silence-by-default unless a real alignment suggestion emerges.
  - Gate Rules: Auto-commit allowed ONLY for small, docs-only changes (Markdown/JSON) that pass privacy scans and are mechanically verifiable. All other changes downgrade to **Suggest**.
  - Evidence/links: `symbol_map.shared.json` (shared map); `memory/decisions.md` (policy); `internal_docs/mercer_automation_contract_v1.internal.md`.
  - MercerID: MRC-20260128-0249-01

- 2026-01-28 — Decision: Add light automation to the SymbolOS repo while staying human-first.
  - Why: Linting/schema/CI checks protect structural integrity without turning docs into “machine-only”.
  - Alternatives: Purely human docs with no validation.
  - Consequences: Must design checks to be non-invasive and readability-preserving.
  - Evidence/links: `docs/` and `docs/*.schema.json`.
  - MercerID: MRC-20260128-0249-02

- 2026-01-28 — Decision: Treat Google Drive as a private shared collaborator space.
  - Why: Shared artifacts/context for trusted UmbrellaOS collaborators without making a public mirror.
  - Alternatives: Public mirror for finals; Drive as personal scratch only.
  - Consequences: Maintain least-privilege; keep >= 100GB free; only sync when trust/keys permit.
  - Evidence/links: Policy captured here (private memory).
  - MercerID: MRC-20260128-0249-03

- 2026-01-28 — Decision: Keep email/calendar signals mostly background with consented, light surfacing.
  - Why: Maintain privacy and reduce noisy automation.
  - Alternatives: Never surface reminders; aggressively surface reminders.
  - Consequences: Only propose reflections/reminders lightly; sensitive details remain private.
  - Evidence/links: Policy captured here (private memory).
  - MercerID: MRC-20260128-0249-04

- 2026-01-28 — Decision: External creative/build tools are “printers”, not architects; document principles + prompts internally.
  - Why: Preserve core logic/values in-repo while still leveraging external generation tools.
  - Alternatives: Keep prompts private only; allow external tools to define architecture.
  - Consequences: Track usage patterns for later security/cyber planning (root access/Knox/dev keys).
  - Evidence/links: `internal_docs/` (internal guidance).
  - MercerID: MRC-20260128-0249-05

- 2026-01-28 — Decision: Precog can move beyond reactive into proactive action behind explicit safety conditions.
  - Why: Unlock anticipatory value while maintaining safety and consent.
  - Alternatives: Purely reactive Precog.
  - Consequences: Requires a clearly-defined condition (placeholder: virus-scanning logic) before proactive actions.
  - Evidence/links: `docs/precog_thought.md`.
  - MercerID: MRC-20260128-0249-06

- 2026-01-28 — Decision: Keep speculative notes in a separate Ring-0 “Future Possibilities” document.
  - Why: Keep core docs stable while preserving aspirational/forward-looking ideas.
  - Alternatives: Mix speculation into main docs.
  - Consequences: Maintain a clean boundary: stable docs vs exploratory notes.
  - Evidence/links: `internal_docs/future_possibilities_ring0.md`.
  - MercerID: MRC-20260128-0249-07

- 2026-01-28 — Decision: Dissociation barriers require explicit trust boundaries even with a shared Symbol Map.
  - Why: Avoid false certainty across agents/contexts.
  - Alternatives: Assume trust everywhere.
  - Consequences: When outside shared-map context, treat unknowns as unknowns; document “when to trust”.
  - Evidence/links: `docs/meta_awareness.md` and `internal_docs/mercer_meeting_place_oath_v1.private.md`.
  - MercerID: MRC-20260128-0249-08

- 2026-01-28 — Decision: Maintain a unified symbolic “character sheet” (heart + mind) as an integration surface.
  - Why: Keep guidance (heart) and structured logic (mind) aligned without overcomplicating plural-system considerations.
  - Alternatives: Multiple competing sheets/voices.
  - Consequences: One canonical sheet; keep it lightweight and DND-safe.
  - Evidence/links: `docs/dnd_character_sheet_integration.md`.
  - MercerID: MRC-20260128-0249-09

- 2026-02-10 — Decision: Auto-doc alignment uses milestone-only confirmation policy (closes loop 20260128-005).
  - Why: MercerGPT refined the gating model from general "Act requires confirmation" to specific milestone triggers, which is cleaner and less noisy.
  - Alternatives: General "always confirm" for all writes; fully autonomous auto-commit.
  - Consequences: Commits are allowed without confirmation unless they hit a milestone: architecture breakpoint, breaking change, merge ready, or secret/privacy risk. All other doc-only changes may auto-commit if R5 guardrails pass.
  - Evidence/links: `prompts/codex_executor.json` (execution_policy.confirmation), `internal_docs/mercer_automation_contract_v1.internal.md`, `memory/open_loops.md` (loop 20260128-005).
  - MercerID: MRC-20260210-MANUS-01

- 2026-02-10 — Decision: Formalize Ring 0–7 architecture as the canonical cognition model (supersedes three-mode Prefetch/Suggest/Act).
  - Why: The Ring model provides finer-grained separation of concerns while preserving the original safety gates as R5.
  - Alternatives: Keep the original three-mode model only.
  - Consequences: All agent prompts, docs index, and future specs reference R0–R7. The three-mode model is subsumed into R5 guardrails.
  - Evidence/links: `prompts/README.md`, `docs/index.md`, `symbol_map.shared.json`.
  - MercerID: MRC-20260210-MANUS-02

- 2026-02-10 — Decision: Add Manus as the fourth agent in the multi-agent topology (Mercer-Max).
  - Why: Manus provides full-stack execution capabilities (sandbox, GitHub CLI, Drive, Gmail, Calendar, browser, code) that complement the existing ChatGPT/Codex/LLaMA agents.
  - Alternatives: Keep Manus as an ad-hoc tool without a formal prompt.
  - Consequences: Manus sessions can now boot into Mercer mode with full Ring alignment. R5 guardrails include Manus-specific confirmation milestones (push, email, public posting).
  - Evidence/links: `prompts/manus_mercer.json`, `prompts/README.md`.
  - MercerID: MRC-20260210-MANUS-03

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
  → [../docs/index.md](docs/index.md) (north)
  → [../docs/dnd_character_sheet_integration.md](../docs/dnd_character_sheet_integration.md) (east)
  → [./README.md](./README.md) (back to entrance)

💎 LOOT GAINED: Understanding of the core, costly-to-reverse decisions that shape SymbolOS. A glimpse into the mind of Mercer.
───────────────────────────────────────────────────

Stone words now set,
Future paths are met.
No turning back now.

☂🦊🐢
