╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Workflow Forge                                ║
║  📍 Floor: Ring 2 │ Difficulty: ⭐⭐ │ Loot: Clean, human docs ║
║  🎨 Color: Violet (#8B00FF)                                  ║
║                                                              ║
║  A workbench of habits: keep the repo sharp and readable.     ║
╚══════════════════════════════════════════════════════════════╝

# Workflow Guidelines (SymbolOS)

Short, practical rules to keep SymbolOS readable, maintainable, and
safe for humans and agents. This is repo-scoped guidance; do not assume
other repos match these conventions.

---

## README baseline

Every repo should have a minimal README that answers:

- Title and purpose (what this repo is for).
- Setup and usage (how to run or use it).
- Context links (where it fits in SymbolOS, if applicable).
- Contribution and license notes (if applicable).

Keep it short and link to deeper docs instead of duplicating them.

---

## Commit message rules

Use concise, imperative commit messages. Recommended pattern:

- Subject <= 50 characters, imperative mood, no trailing period.
- Blank line, then a body wrapped at 72 characters.
- Explain what changed and why, not just how.

Example:

"""
docs: add workflow guidelines

Clarify README baseline, commit rules, and branch pruning steps
so humans and agents follow a single, documented flow.
"""

---

## Issues and labels

Keep labels minimal and meaningful:

- type: bug, type: docs, type: feature
- state: needs-info, state: triage
- help wanted or good first issue (if applicable)

Avoid label sprawl. Use PR descriptions or commit messages with
"Closes #<issue>" to auto-close completed work.

---

## Branch pruning

Prune only after verifying there is no unique work to keep.
Recommended steps:

1. List merged branches:
   - git branch --merged main
2. Delete merged local branches:
   - git branch -d <branch>
3. Prune stale remote references:
   - git fetch --prune
4. Delete remote branches only after manual review:
   - git push origin --delete <branch>

If a branch has no common history with main, inspect it and cherry-pick
only what you need before deletion.

---

## References

- Docs index: docs/index.md
- Docs sync playbook: docs/sync_playbook.md

───────────────────────────────────────────────────
*Keep it small,
Keep it clear,
Truth is near.*

☂🦊🐢
