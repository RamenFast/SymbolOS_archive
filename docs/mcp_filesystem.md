# MCP Filesystem Server

```
╔══════════════════════════════════════════════════════════════╗
║  🧩☂️  MCP FILESYSTEM SERVER — STRUCTURED FILE OPS          ║
║  Quest: safe read/write/delete within workspace              ║
╚══════════════════════════════════════════════════════════════╝
```

**Status: Beta** | Async note: Permission audit + .gitignore integration (Q2 2026)

## Purpose

🧩 **Schema-safe file operations** for SymbolOS projects. All file I/O is path-normalized and respects workspace boundaries.

## Current Capabilities (Beta)

- `read_file` — Read file contents (any type)
- `write_file` — Create/update files (with schema validation where defined)
- `delete_file` — Remove files (requires confirmation)
- `list_directory` — Enumerate directory contents
- `get_file_metadata` — Retrieve size, modified time, permissions

## Risk Level

- **read** — Read files, list directories (default)
- **write** — Create/update files (default)
- **sensitive** — Delete operations (🛡️ requires confirmation)

## Why Beta?

1. **Permission checking** incomplete; need .gitignore audit (Q2 2026)
2. **Schema validation** for JSON/YAML only; other formats accept-all (Q2 2026)
3. **Symlink handling** under review for security (Q2 2026)

Until full release, this tool is safe for:
- Reading any file in the workspace (no risk)
- Writing files with schema validation (JSON, YAML, Markdown)
- Deleting files (with manual confirmation)

## Example: Safe Schema Write

```
User: "Create a new precog card"
→ Server: validate shape against precog_card.schema.json
→ Server: write to docs/cards/my_card.json
→ Server: return 🧾 created + git diff preview
```

## Constraints

- All paths normalized to workspace root
- Cannot escape workspace directory (`../../../etc/passwd` rejected)
- Respects `.gitignore` for writing (Q2 2026; not yet enforced)
- Binary files returned as base64

## Async Timeline

- **Now (Jan 2026)**: Beta read/write/delete with path normalization
- **Q2 2026**: Add full .gitignore respect + permission audit
- **Q2 2026**: Schema validation for all common formats
- **Q2 2026**: Symlink security review complete
- **Q3 2026**: Full release candidate (FC1)

## See Also

- [MCP Servers Standard](mcp_servers.md) — Risk levels, confirmation gates, error envelope
- [Schema Index](schemas.md) — All structured shapes validated by this server
- [Schema (Symbol)](symbol_map.md#core-symbols) — 🧩 meaning
