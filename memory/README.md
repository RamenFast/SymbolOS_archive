# Repo-backed Memory System (Private)

This folder is the **durable memory layer** for SymbolOS/UmbrellaOS work.
It is intentionally **file-backed** (git history + diffs) and does **not** rely on chat logs or any model's built-in memory.

## Principles
- Default-private: treat all content here as private unless explicitly exported elsewhere.
- No secrets: do not store credentials, seed phrases, API keys, tokens, or private keys.
  - Store **references** instead (e.g., "Seed vault stored in <system>, last rotated YYYY-MM-DD").
- Provenance: decisions should link to artifacts (docs, schemas, commits) when possible.
- Bitrot resistance: keep content short, dated, and regularly pruned.

## Files
- `working_set.md`: what matters *right now* (purpose, constraints, next actions).
- `decisions.md`: important decisions + rationale.
- `open_loops.md`: promises/tasks/questions that must not be dropped.
- `glossary.md`: stable meanings/terms (coordinate with `symbol_map.shared.json` when needed).
- `session_log_YYYY-MM-DD.md`: append-only session notes.

## Operating loop
1. Read `../symbol_map.shared.json` (meeting place).
2. Update `working_set.md` before starting new work.
3. Record any irreversible/important choices in `decisions.md`.
4. Track tasks/promises in `open_loops.md`.
5. Write a short `session_log_YYYY-MM-DD.md` at end of session.

## Drift tracking
If you track an "alignment/drift" score, record it in `working_set.md` with the basis for the estimate.
Avoid hiding failures; instead, keep the workflow resilient and non-blocking unless truly critical.
