# Docs Sync Playbook (SymbolOS/UmbrellaOS)

This playbook is the shortest safe path to keep docs synced and coherent.

Scope: `docs/` and Markdown files (`*.md`) in the repo root.

---

## 1) Pull latest

From the repo root:

- `git pull origin main`

If you prefer a safer history (when allowed):

- `git pull --rebase origin main`

If you have local changes, commit them first or stash them.

Pre-flight checks:

- Ensure git identity is set (`user.name` and `user.email`) before committing.
- If your tree is dirty, either commit the pending changes or:
   - `git stash -u` before syncing
   - `git stash pop` afterwards

---

## 2) Identify doc deltas

Common commands:

- `git status`
- `git diff`
- `git log --name-status -n 20 -- docs/ '*.md'`

Only touch docs and Markdown unless you’re explicitly changing code/config.

---

## 3) Ingest external/internal sources

### Google Drive (manual intake)

This environment doesn’t automatically read Drive contents.

Recommended workflow:

1. Download the doc(s) from Drive.
2. Place them in `docs/inbox/` with a date prefix, e.g. `2026-01-27_rhynim_reading_list.md`.
3. Create a curated summary in:
   - [docs/required_reading.md](required_reading.md) (Required Reading)
4. Add a provenance header in the curated doc:
   - Source, owner, date, classification.

If you have a Drive connector available (MCP/adapter), the typical flow is:

- search for docs by keyword
- list the folder (if applicable)
- fetch content/metadata

### GitHub sources

If docs exist in other repos (e.g., VS Code agent projects or companion repos), copy only the relevant summaries and link back to the source.

---

## 4) Keep the DND + “human compatibility” style

Rules of thumb:

- Prefer short, scannable sections.
- Use explicit headings.
- Avoid huge raw dumps; summarize and link.
- When in doubt, write:
  - What changed
  - Why it matters
  - What to do next

Optional flavor: a “Dungeon Master’s Log” section is allowed, but must preserve the same factual payload.

---

## 5) Commit and push

Suggested message format:

- `docs: update SymbolOS/UmbrOS synced docs`

If commits fail due to missing identity, set it once (global) or per-repo:

- global: `git config --global user.name "..."` and `git config --global user.email "..."`
- repo-local: `git config user.name "..."` and `git config user.email "..."`

Then:

- `git push origin main`

If branch protections block direct pushes:

- create a branch (e.g., `docs-sync/YYYY-MM-DD`)
- push that branch
- open a PR

---

## 6) Verify clean state

- `git status`

Expect: “working tree clean”.
