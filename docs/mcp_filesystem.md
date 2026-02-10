
╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Chamber of Structured Files                  ║
║  📍 Floor: R2 (Higher Intellect) │ Difficulty: ⭐⭐ │ Loot: Safe file I/O ║
║  🎨 Color: Gamboge (#E49B0F)                                 ║
║                                                              ║
║  You stand on a floor of glowing glyphs, a room humming with the   ║
║  silent promise of order. This is a place of structured data.    ║
╚══════════════════════════════════════════════════════════════╝

## The Architect's Intent 🟡 #E49B0F (gamboge — higher intellect)

This chamber provides 🧩 **schema-safe file operations** for all SymbolOS projects. Every read, write, and delete is path-normalized, respecting the sacred boundaries of the workspace. No file operation is a matter of chance here; all is by design.

        /\_/\
       ( o.o )  "I have roots but am not a tree,
        > ^ <    I have paths but no journey you see.
       /|   |\   I hold your secrets and your keys,
      (_|   |_)  But cross my bounds, and you'll displease." — Rhy 🦊

## The Tools on the Wall ✨ 🟡 #FADA5E (primrose yellow — kernel truth)

- `read_file` — Gaze into the contents of any file.
- `write_file` — Inscribe new files, or amend the old. Where a schema is known, it is obeyed.
- `delete_file` — Banish a file from the workspace (a weighty decision, requiring confirmation).
- `list_directory` — Scry the contents of any directory.
- `get_file_metadata` — Divine the size, age, and permissions of a file.

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

## A Warning Scrawled in Chalk 🔴 #FF2400 (scarlet — righteous boundary)

- **read** — To read files and list directories is a minor risk. (🟢)
- **write** — To create or alter files is a moderate risk. (🟡)
- **sensitive** — To delete is a significant risk, and requires a second thought. (🛡️ 🔴)

## The Architect's Unfinished Work 🟠 #FF8C00 (deep orange — ambition)

This chamber is still under construction. Beware these temporary limitations:

1.  **Permission checking** is not yet complete. The chamber does not yet fully respect the wisdom of `.gitignore` (Q2 2026).
2.  **Schema validation** is sharpest for JSON and YAML. Other formats are accepted without question (Q2 2026).
3.  **Symlinks**, those treacherous portals, are under review for security (Q2 2026).

Until these works are complete, the chamber is safe for:
- Reading any file in the workspace.
- Writing files with schema validation (JSON, YAML, Markdown).
- Deleting files (with your explicit confirmation).

## A Demonstration of Power ⭐ #FFD700 (golden — spiritual aspiration)

```
User: "Craft a new precog card."
→ The chamber validates the shape against precog_card.schema.json.
→ The chamber writes the card to docs/cards/my_card.json.
→ The chamber returns a 🧾 receipt of creation, with a git diff preview for your records.
```

## The Unseen Walls 🔴 #FF2400 (scarlet — righteous boundary)

- All paths are relative to the workspace root. You cannot stray.
- Attempts to escape the workspace (e.g., `../../../etc/passwd`) are futile and will be rejected.
- The chamber will soon respect `.gitignore` for all write operations (Q2 2026).
- Binary files are returned as base64, a cryptic but faithful representation.

## Future Echoes 🔵 #0000CD (deep blue — devotion to truth)

- **Now (Jan 2026)**: Beta read/write/delete with path normalization.
- **Q2 2026**: Full respect for `.gitignore` and a complete permission audit.
- **Q2 2026**: Schema validation for all common formats.
- **Q2 2026**: Security review of symlinks complete.
- **Q3 2026**: Full release candidate (FC1).

───────────────────────────────────────────────────
🚪 EXITS:
  → [MCP Servers Standard](mcp_servers.md) (north)
  → [Schema Index](schemas.md) (east)
  → [Symbol Map](symbol_map.md#core-symbols) (west)

💎 LOOT GAINED: You have learned to safely manipulate files within the SymbolOS workspace, using structured operations that respect schemas and boundaries.
───────────────────────────────────────────────────

Filesystems bloom,
Paths branch out, a green new world,
Data finds its home.

☂🦊🐢
