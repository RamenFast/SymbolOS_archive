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
