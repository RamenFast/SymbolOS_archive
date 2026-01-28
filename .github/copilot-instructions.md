# Copilot instructions (SymbolOS)

## Big picture
- This repo is **docs-first**: SymbolOS is defined primarily by Markdown specs + JSON Schemas.
- The canonical “meeting place” is the shared map: `symbol_map.shared.json` (see `project.entrypoints` and `docsContext`).
- Human-facing docs start at `docs/index.md`; most specs cross-link from there.

## Key components / boundaries
- **Shared symbol set**: `symbol_map.shared.json` (canonical) and `docs/symbol_map.md` (human mirror).
  - “Core symbols” drift is computed by parsing `docs/symbol_map.md` section `## Core symbols`.
- **MCP server standard**: `docs/mcp_servers.md` defines tool/resource boundaries, risk levels (`read`/`write`/`sensitive`), confirmation, limits, and a transport-independent error envelope.
- **Schemas** (authoritative interchange shapes): see `docs/schemas.md` and `docs/*.schema.json`.
  - Schemas consistently use `additionalProperties: false` (example: `docs/registry_entry.schema.json`).
- **Repo-backed private memory**: `memory/` is the durable memory layer; treat as private-by-default (see `memory/README.md`).

## Developer workflows (VS Code)
- Tasks live in `.vscode/tasks.json`:
  - `Mercer: status UI (interactive)` → runs `scripts/mercer_status.ps1`.
  - `Mercer: doc alignment scan (read-only)` → runs `scripts/mercer_doc_alignment_scan.ps1`.
  - `Local LLM: start llama.cpp server (Vulkan)` → runs `scripts/run_llama_server.ps1`.
- Mercer Status VS Code extension (minimal JS): `extensions/mercer-status/`.
  - It activates when the workspace contains `symbol_map.shared.json` and warns/launches status UI if symbol drift is WARN/FAIL.
  - Drift logic parses markdown bullets like `- `☂️` ...` inside `## Core symbols` (see `extensions/mercer-status/extension.js`).

## Conventions to follow when editing
- Respect `.editorconfig` (LF endings; 2-space indent by default; 4 for Python).
- Many docs include a consistent banner + “Poetry layer (Fi+Ti mirrored)” section near the top; preserve structure when making small edits.
- Keep docs **cross-linked** via `docs/index.md` and the `symbol_map.shared.json.indexes` lists.
- When changing symbols, treat `symbol_map.shared.json` as canonical and keep `docs/symbol_map.md` `## Core symbols` in sync (Mercer drift checks depend on this).
- When adding a new schema, add `docs/<name>.schema.json`, then register it in `docs/schemas.md` and (if it should appear in indexes) add it under `symbol_map.shared.json.indexes.schemas`.
  - Example `indexes.schemas` entry:

    ```json
    { "path": "docs/my_feature.schema.json", "title": "My Feature", "kind": "schema" }
    ```

## Privacy / local-only assets
- Do not add secrets/credentials anywhere (see `memory/README.md`).
- Local-only artifacts are gitignored:
  - `local_ai/bin/`, `local_ai/models/`, `local_ai/cache/`
  - `docs/assets/**/*.private.*`, `docs/assets/photos_import_private/`, `docs/assets/lily_background.*`

## Common “gotchas”
- `symbolOS_external_documentation.md` is high-level and may mention folders that don’t exist; prefer `docs/index.md` + the shared map as the source of truth.
- The doc alignment scan/runner scripts are **read-only** and exit with semantics: `0=OK`, `2=WARN(drift)`, other=`FAIL` (see `scripts/mercer_doc_alignment_runner.ps1`).
