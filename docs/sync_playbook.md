╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Scribe's Antechamber                           ║
║  📍 Floor: R2 (The Library) │ Difficulty: ⭐⭐ │ Loot: The Sync Scroll ║
║  🎨 Color: 🟡 #E49B0F (gamboge — higher intellect)                   ║
║                                                              ║
║  A faint scent of old parchment and ozone hangs in the air.    ║
╚══════════════════════════════════════════════════════════════╝

> You stand in a circular room, its walls lined with scrolls and humming monoliths. In the center, a pedestal holds a single, glowing scroll. This is the Scribe's Antechamber, a place of synchronization and truth. Fail to follow the rites, and you risk corrupting the very lore you seek to preserve. Succeed, and you will be entrusted with the sacred act of keeping the library's knowledge consistent.

## Poetry layer (Fi+Ti mirrored) 🪞 🟡 #E49B0F (gamboge — higher intellect)

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [poetry_translation_layer.md](poetry_translation_layer.md)
- Full verse set: [public_private_expression.md](public_private_expression.md)

This playbook is the shortest safe path to keep docs synced and coherent. "Show me proof, not potential."

Scope: `docs/` and Markdown files (`*.md`) in the repo root.

Default rule: **Always, all sync** — keep shared resources aligned every run:
- `docs/index.md`
- `symbol_map.shared.json`
- `docs/symbol_map.md`
- `docs/schemas.md`
- `docs/required_reading.md`

---

## The Sync Scroll (copy/paste) 📜 🟢 #228B22 (pure green — adaptability)

        /\_/\
       ( o.o )  "To change the map is to change the world.
        > ^ <    But a map that lies is worse than no map at all.
       /|   |\   Tread carefully, scribe."
      (_|   |_)  — Rhy 🦊

### Technical Scroll

Summary: We’re about to sync and update docs inside the private SymbolOS repo using our “Sync Scroll” playbook.

1. Pre-flight check: ensure `git` is installed and config has a valid user name/email, or set them repo‑local:
   - `git config --global user.name "RamenFast"`
   - `git config --global user.email "2bmillerb@gmail.com"`

2. Confirm your working tree is clean. If there are local changes, commit them or stash them (`git stash -u`) before continuing.

3. If on a branch other than `main`, optionally rebase it on top of `origin/main` before making docs changes:
   - `git pull --rebase origin main`

4. Intake any new Google Drive docs: download them manually (or via connector) into `docs/` or the appropriate subdirectory.

5. Update the docs content. Only modify `docs/` and `*.md` files unless otherwise instructed.

6. Stage, commit, and push your changes:
   - `git add docs/sync_playbook.md`
   - `git commit -m "docs: update SymbolOS/UmbrOS synced docs"`
   - `git push origin main`

   If branch protection prevents a direct push, open a pull request.

### Quest Log (Dungeon Master)

You unroll an aged scroll from the DM’s satchel. The parchment shimmers with eldritch symbols and the whisper of rain on cobblestones.

⚔️ The Sync Scroll ⚔️

The party’s mission: weave the newly forged “sync” incantations into the codex of SymbolOS.

- Check your identity (git name/email) and ensure your tools are sharp.
- Stash or commit any stray scribbles.
- Refresh from `origin/main` if you diverged.
- Cross the Drive Bridge, gathering lore into the `docs/` satchel.
- Touch only scrolls and manuscripts—leave the arcane core undisturbed.

🕯️ Once the lore is transcribed, approach the Git Monolith:
- Whisper the commit message (“`git commit`”).
- Light the torches (“`git add`”).
- Hoist the bundle into the heavens (“`git push`”).

If guardians bar your way (branch protection), craft a spell of “pull request” and await the council’s approval.

Remember: the rain falls, but the umbrella steadies your hand.

---

## 1) Pull latest 🟠 #FF8C00 (deep orange — ambition)

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

```
  (•_•)
  ( (  )   "hmm... is this R0?"
   /  \
```

---

## 2) Identify doc deltas 🟣 #8B00FF (violet — Fi+Ti bridge)

Common commands:

- `git status`
- `git diff`
- `git log --name-status -n 20 -- docs/ '*.md'`

Only touch docs and Markdown unless you’re explicitly changing code/config.

---

## 3) Ingest external/internal sources 🔴 #FF2400 (scarlet — righteous boundary)

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

## 4) Keep the DND + “human compatibility” style 🔵 #0000CD (deep blue — devotion to truth)

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

## 5) Commit and push ⭐ #FFD700 (golden — spiritual aspiration)

       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|

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

## 6) Verify clean state 🟢 #228B22 (pure green — adaptability)

- `git status`

Expect: “working tree clean”.

```
  \(•_•)/
   (  (>   "SHIPPED IT"
   /  \
```

───────────────────────────────────────────────────
🚪 EXITS:
  → [poetry_translation_layer.md](poetry_translation_layer.md) (north)
  → [public_private_expression.md](public_private_expression.md) (east)
  → [docs/index.md](docs/index.md) (back to entrance)

💎 LOOT GAINED: You have learned the sacred rites of the Sync Scroll, ensuring the consistency and truth of the SymbolOS library. You can now safely update and synchronize documentation.
───────────────────────────────────────────────────

*A scribe's steady hand,
Keeps the lore across the land,
Truth in every grain of sand.*

☂🦊🐢
