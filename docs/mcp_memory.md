# MCP Memory Server

```
╔══════════════════════════════════════════════════════════════╗
║  🧾☂️  MCP MEMORY SERVER — REPO-BACKED CONSENT-DRIVEN       ║
║  Quest: durable state without cloud lock-in                  ║
╚══════════════════════════════════════════════════════════════╝
```

**Status: Beta** | Async note: Consent flows + memory expiry policies (Q2 2026)

## Purpose

🧾 **Durable memory operations** for SymbolOS projects. All memory is file-backed (in `memory/` directory), git-tracked, and provenance-auditable. No cloud. No secrets. Consent-first.

## Current Capabilities (Beta)

- `read_working_set` — Read current working context
- `write_working_set` — Update active tasks, focus, intent
- `read_decisions` — Retrieve past decision log
- `write_decision` — Record new decision (timestamp + rationale + symbols)
- `read_open_loops` — List unresolved questions
- `write_open_loop` — Add new open loop
- `read_glossary` — Look up terminology
- `write_glossary_entry` — Add/update term definition

## Risk Level

- **read** — All read operations (default)
- **write** — All write operations (default; no confirmation needed for memory)
- **sensitive** — Secrets/credentials (🛡️ rejected; mem policy forbids storage)

## Why Beta?

1. **Consent flows** not yet enforced; need explicit opt-in for capture (Q2 2026)
2. **Memory expiry** rules undefined; what data auto-purges after N days? (Q2 2026)
3. **Redaction** tooling incomplete for sensitive content (Q2 2026)

Until full release, this tool is safe for:
- Reading all memory files (no risk)
- Writing decisions, loops, glossary entries (safe; no secrets)
- No auto-purge (data persists; user manually removes)

## File Structure

```
memory/
├── README.md              # System overview + consent policy
├── working_set.md         # Current focus + intent
├── decisions.md           # Timestamped decision log (🧾)
├── open_loops.md          # Unresolved questions
├── glossary.md            # Terminology index
└── session_log_*.md       # Per-session journal (private)
```

## Example: Decision Logging

```
User: "I'm choosing to use local LLM instead of cloud API"
→ Server: write_decision(
    title: "Local-first compute",
    rationale: "Privacy + cost control + offline capability",
    symbols: ["🔒", "🧠", "💰"],
    timestamp: 2026-01-28T14:23:00Z,
    commit: <git-hash>
  )
→ File: memory/decisions.md updated
→ Server: git add memory/decisions.md (staged for next commit)
→ 🧾 Full audit trail in git history
```

## Async Timeline

- **Now (Jan 2026)**: Beta read/write for all memory types; git-backed
- **Q2 2026**: Add explicit consent flows (prompt before capture)
- **Q2 2026**: Implement memory expiry rules (30/60/90-day tiers)
- **Q2 2026**: Redaction tooling for sensitive content
- **Q3 2026**: Full release candidate (FC1)

## Consent Policy

Memory capture is **consent-driven**:
1. User takes action or makes decision
2. Server asks "Log this to memory?" (if consent not yet given)
3. User approves → file written + git staging
4. No secrets/credentials ever stored (rejected at write time)

## See Also

- [Memory (Docs)](memory.md) — External policy + retention guidance
- [Memory (System)](../memory/README.md) — Private system details (repo-backed)
- [Ledger (Symbol)](symbol_map.md#core-symbols) — 🧾 meaning
- [Privacy (Symbol)](symbol_map.md#core-symbols) — 🔒 meaning
