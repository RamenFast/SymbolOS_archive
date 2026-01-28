# MCP Git Server

```
╔══════════════════════════════════════════════════════════════╗
║  🧾☂️  MCP GIT SERVER — PROVENANCE & VERSION CONTROL         ║
║  Quest: commit history + audit trail                         ║
╚══════════════════════════════════════════════════════════════╝
```

**Status: Beta** | Async note: Security audit for commit signing + force-push prevention (Q2 2026)

## Purpose

🧾 **Ledger operations** for SymbolOS projects via Git. All project state lives in the repo; this server provides machine-readable access to branches, commits, status, and push operations.

## Current Capabilities (Beta)

- `list_branches` — Read all branches in the repository
- `get_commits` — Retrieve commit history for a branch
- `git_status` — Check working tree status (staged, unstaged, untracked)
- `push` — Push current branch to origin (requires confirmation)
- `get_diff` — View changes between commits or working tree

## Risk Level

- **read** — Branches, commits, diffs (default)
- **write** — Push operations (requires confirmation)
- **sensitive** — Force-push (🛡️ disabled in beta)

## Why Beta?

1. **Commit signing** not yet enforced; need GPG integration (Q2 2026)
2. **Force-push prevention** needs workflow validation (Q2 2026)
3. **Merge conflict handling** under design (Q2 2026)

Until full release, this tool is safe for:
- Reading project history (no risk)
- Pushing to branches (manual confirmation required)
- Generating audit trails (🧾 ledger queries)

## Example: Provenance Trace

```
User: "Show me who changed the symbol map last"
→ Server: git log --oneline docs/symbol_map.md (5 commits)
→ Server: git show <commit> (reveals author + message + 🧾 timestamp)
→ User sees 🧾 full audit trail
```

## Async Timeline

- **Now (Jan 2026)**: Beta read/write for branches, commits, push
- **Q2 2026**: Add commit signing + force-push guards
- **Q2 2026**: Merge conflict detection + hints
- **Q3 2026**: Full release candidate (FC1)

## See Also

- [MCP Servers Standard](mcp_servers.md) — Risk levels, confirmation gates, error envelope
- [Poetry Translation Layer](poetry_translation_layer.md) — How to express intent via commit messages
- [Ledger (Symbol)](symbol_map.md#core-symbols) — 🧾 meaning
