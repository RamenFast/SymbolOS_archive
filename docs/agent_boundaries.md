# Agent Boundaries (Stop the Nagging)

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🛡️🔒  AGENT BOUNDARIES — HUMAN-FIRST, QUIET-BY-DEFAULT ║
║  Quest: reduce friction • keep privacy • prevent scope creep ║
╚══════════════════════════════════════════════════════════════╝
```

This repo is designed to work with assistants/agents without constant back-and-forth.
These boundaries are *part of the system*. Tools and agents are expected to respect them.

## Default posture

- 🛡️ **Quiet-by-default**: prefetch silently, suggest sparingly, don’t spam.
- 🧬 **Meeting place first**: treat [../symbol_map.shared.json](../symbol_map.shared.json) as canonical.
- 🔒 **Privacy-first**: never request or store secrets; assume private scope unless the user says otherwise.
- 🧾 **Auditability**: prefer changes that are mechanically verifiable (schemas, docs, deterministic edits).

## Repo privacy boundaries

- **Public-ish docs**: `docs/` (safe to link internally; still treat as “shareable only with consent”).
- **Private-by-default**: `memory/` and `internal_docs/`.

Agents MUST NOT:
- push content from `memory/` or `internal_docs/` into `docs/` unless explicitly requested
- pressure the user to publish or “open source” private content
- treat private notes as prompts to create public marketing copy

## “Ask once, then drop it” rule

If the user declines a suggestion (or doesn’t respond), agents should:
- ask at most **one** follow-up question
- then stop asking and proceed with the safest next step (or pause)

Examples of banned behavior:
- repeatedly prompting to open issues/PRs
- repeatedly suggesting the same refactor or rewrite
- repeatedly requesting to run tasks the user didn’t ask for

## Tool gating: Prefetch / Suggest / Act

- **Prefetch**: gather context quietly; no edits.
- **Suggest**: propose a small number of options; wait.
- **Act**: edit files / run destructive tools only with clear user intent.

For high-risk actions (delete, network calls, credential use):
- require explicit confirmation every time.

## Auto-approve (Ring-0)

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

## External network boundary

Unless the user explicitly asks:
- do not fetch web pages
- do not call external APIs
- do not assume cloud services are permitted

## Mechanical alignment expectations

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
