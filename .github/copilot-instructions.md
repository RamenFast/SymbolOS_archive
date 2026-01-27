## SymbolOS / UmbrellaOS — Copilot Notes

### Big picture
- Canonical documentation lives in root_☂️/; repo-root copies (index.md, STYLEGUIDE.md, Documentation/) are mirrors for portability. Update root_☂️ first, then mirror if needed.
- SymbolOS and UmbrellaOS are linked by hidden map files: .symbolos/shared_map.json and .umbrella/symbol_map.json (both at repo root and root_☂️).
- The bootstrap scripts in root_☂️/ (symbol_bootstrap.py, umbrella_bootstrap.py) generate/refresh those maps and establish the hidden directories.

### Developer workflows
- Map regeneration is done by running the bootstrap scripts from the directory where the hidden folders should be created (root_☂️ or repo root). Paths are relative (./.symbolos, ./.umbrella).
- symbol_bootstrap.py can repair Git index corruption by deleting .git/index.lock and rebuilding .git/index; be cautious when running it in other repos.
- Running log lives in Mercer_Zip_Starter/notes.txt (mirror in root_☂️/Mercer_Zip_Starter/notes.txt).

### Conventions to follow
- Compatibility-first docs: no spaces in names, portable/Obsidian-safe links. See root_☂️/index.md.
- Naming is lowercase with hyphen separators; filenames often encode stylesheet variants (e.g., flow_mode_ring0_badge_blackline.png). See root_☂️/STYLEGUIDE.md.
- Visuals are geometry-only; avoid font-dependent emoji glyphs or Kabbalah node-graphs. Fi + Ti motifs must be present when creating new symbols.

### Key files and sources of truth
- Visual system and exports: root_☂️/STYLEGUIDE.md and symbolos/assets/ (badges, thoughtforms, symbols).
- Scope/status and private/public rules: Documentation/DOCS_INDEX.md and Documentation/STATUS.md (private + sandbox by default; SymbolicOS_dev is the live private branch).
- Live map data: .symbolos/shared_map.json (SymbolOS) and .umbrella/symbol_map.json (UmbrellaOS).

### Notes on missing references
- index.md references KERNEL.md, REGISTRY.md, CHANNEL_FLOW.md, DISSOCIATION_AWARENESS.md, and trees/; these are planned and may not exist yet. Do not create them unless requested.

---
description: Custom settings for the SymbolOS project.
privacy: no-telemetry
applyTo: /.vscode/settings.json
---
Set the following VS Code settings for this project:
- Enable auto-saving of files after a delay.
- Set the editor tab size to 2 spaces.
- Enable format on save.
- Trim trailing whitespace on save.
- Ensure a final newline is inserted at the end of files.
