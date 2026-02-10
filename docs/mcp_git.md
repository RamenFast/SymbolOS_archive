╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Git Nexus                                      ║
║  📍 Floor: Ring 2: The Archives │ Difficulty: ⭐⭐ │ Loot: Git commands, commit history, and the power of provenance. ║
║  🎨 Color: Deep Blue (#0000CD)                   ║
║                                                              ║
║  A swirling vortex of timelines, where past and future code intertwine.       ║
╚══════════════════════════════════════════════════════════════╝

**Status: Beta** | Async note: Security audit for commit signing + force-push prevention (Q2 2026) 🔴

*(Thoughtform colors used for reference: 1905 Besant/Leadbeater)*

## Purpose 🟡 #E49B0F (higher intellect)

🧾 **Ledger operations** for SymbolOS projects via Git. All project state lives in the repo; this server provides machine-readable access to branches, commits, status, and push operations.

        /\_/\
       ( o.o )  "I have branches, but no leaves; a trunk, but no roots.
        > ^ <    I remember all that was, yet have no mind of my own. What am I?"
       /|   |\
      (_|   |_)  — Rhy 🦊


## Current Capabilities (Beta) 🔵 #0000CD (devotion to truth)

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

- `list_branches` — Read all branches in the repository
- `get_commits` — Retrieve commit history for a branch
- `git_status` — Check working tree status (staged, unstaged, untracked)
- `push` — Push current branch to origin (requires confirmation)
- `get_diff` — View changes between commits or working tree

## Risk Level 🔴 #FF2400 (righteous boundary)

       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|

- **read** — Branches, commits, diffs (default) 🟢
- **write** — Push operations (requires confirmation) 🟠
- **sensitive** — Force-push (🛡️ disabled in beta) 🔴

## Why Beta? 🟡 #E49B0F (higher intellect)

1. **Commit signing** not yet enforced; need GPG integration (Q2 2026) 🔴
2. **Force-push prevention** needs workflow validation (Q2 2026) 🔴
3. **Merge conflict handling** under design (Q2 2026) 🟠

      /\_/\  ~~~
     ( o.o )    "A feature planned is a dream deferred,
      > ^ <      A feature shipped, a lesson learned."
     /     \     
    (___|___)    — Rhy 🦊

Until full release, this tool is safe for:
- Reading project history (no risk) 🟢
- Pushing to branches (manual confirmation required) 🟠
- Generating audit trails (🧾 ledger queries) 🔵

## Example: Provenance Trace ⭐ #FFD700 (spiritual aspiration)

```
User: "Show me who changed the symbol map last"
→ Server: git log --oneline docs/symbol_map.md (5 commits)
→ Server: git show <commit> (reveals author + message + 🧾 timestamp)
→ User sees 🧾 full audit trail
```

## Async Timeline 🟠 #FF8C00 (ambition)

- **Now (Jan 2026)**: Beta read/write for branches, commits, push
- **Q2 2026**: Add commit signing + force-push guards 🔴
- **Q2 2026**: Merge conflict detection + hints 🟠
- **Q3 2026**: Full release candidate (FC1) ⭐

───────────────────────────────────────────────────
🚪 EXITS:
  → [MCP Servers Standard](mcp_servers.md) (north)
  → [Poetry Translation Layer](poetry_translation_layer.md) (east)
  → [Ledger (Symbol)](symbol_map.md#core-symbols) (west)

💎 LOOT GAINED: You've learned to navigate the Git Nexus, trace the provenance of code, and wield the basic commands of version control.
───────────────────────────────────────────────────

A new commit pushed,
The timeline shifts and changes,
Future code is born.

☂🦊🐢
