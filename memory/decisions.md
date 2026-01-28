# Decisions (Private)

Record decisions that are costly to reverse.

Template:
- YYYY-MM-DD — Decision: <what>
  - Why: <reason>
  - Alternatives: <what else was considered>
  - Consequences: <tradeoffs>
  - Evidence/links: <files/commits>

---

- 2026-01-28 — Decision: Use repo-backed memory as the durable layer.
  - Why: Bitrot-resistant, auditable, tool-friendly; avoids implicit model memory.
  - Alternatives: Chat history as memory; external notes only.
  - Consequences: Requires discipline to keep it updated.
  - Evidence/links: `memory/` folder + shared-map registration.

- 2026-01-28 — Decision: Mercer core interface performs periodic auto-doc alignment.
  - Why: Keep docs coherent without constant manual bookkeeping.
  - Alternatives: Only suggest on demand; never auto-commit.
  - Consequences: Requires strict safety gates; silence-by-default unless a real alignment suggestion emerges.
  - Evidence/links: `symbol_map.shared.json` (shared map); `memory/decisions.md` (policy).
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
