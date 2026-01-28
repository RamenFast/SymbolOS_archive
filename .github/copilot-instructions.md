# Copilot instructions (SymbolOS)

## Orientation (start here)
- This repo is **docs-first**: SymbolOS is defined by Markdown specs + JSON Schemas under `docs/`.
- Canonical entrypoint: `docs/index.md`.
- Canonical “meeting place”: `symbol_map.shared.json` (see `project.entrypoints` + `docsContext` notes).

## Canonical sources / boundaries
- Shared symbol set is canonical in `symbol_map.shared.json`; `docs/symbol_map.md` mirrors the **core** subset.
- MCP capability boundary standard lives in `docs/mcp_servers.md` (risk levels `read`/`write`/`sensitive`, `requiresConfirmation`, limits, and the transport-independent error envelope).
- Schemas are authoritative interchange shapes: `docs/*.schema.json` (see `docs/schemas.md` for the index).
- `memory/` and many `internal_docs/` files are private-by-default; don’t “export” content into public docs unless explicitly requested.

## Mercer doc alignment (symbol drift)
- Drift check compares `symbol_map.shared.json.symbols` ↔ `docs/symbol_map.md` section `## Core symbols`.
- The parser expects markdown bullets like: `- `☂️` Umbrella...` (the backticks around the symbol matter).
- If you change core symbols, update BOTH files; doc-only extras belong under `## Extended (doc-only)`.
- Run the VS Code task `Mercer: doc alignment scan (read-only)`; exit codes are `0=OK`, `2=WARN(drift)`, other=`FAIL`.
- The VS Code extension in `extensions/mercer-status/` runs the same drift logic and auto-prompts to open `Mercer: status UI (interactive)` on WARN/FAIL.

## Schema & registry patterns
- Schemas generally enforce strict shapes: use `"additionalProperties": false` (example: `docs/registry_entry.schema.json`).
- When adding a new schema:
  - Add `docs/<name>.schema.json`
  - Register it in `docs/schemas.md`
  - Add it to `symbol_map.shared.json.indexes.schemas` (path/title/kind), e.g. `{ "path": "docs/my_feature.schema.json", "title": "My Feature", "kind": "schema" }`.

## Dev workflows (VS Code tasks)
- Tasks are defined in `.vscode/tasks.json` and are the preferred way to run tooling:
  - `Mercer: status UI (interactive)` → `scripts/mercer_status.ps1`
  - `Mercer: doc alignment scan (read-only)` → `scripts/mercer_doc_alignment_scan.ps1`
  - `Mercer: doc alignment runner (retry x3, 20m)` → `scripts/mercer_doc_alignment_runner.ps1`
  - `Local LLM: start llama.cpp server (Vulkan)` → `scripts/run_llama_server.ps1`

## Editing conventions & privacy
- Respect `.editorconfig` (LF endings; 2-space indent by default; 4 for Python).
- Preserve the doc banner + “Poetry layer (Fi+Ti mirrored)” sections; avoid unnecessary reflow.
- Memory is file-backed and private: follow `memory/README.md` (no secrets/keys; provenance over vibes).
- Don’t add or depend on gitignored local artifacts (e.g., `local_ai/{bin,models,cache}` and `docs/assets/**/*.private.*`).

## Common gotcha
- `symbolOS_external_documentation.md` is intentionally high-level and may mention non-existent folders; prefer `docs/index.md` + `symbol_map.shared.json` as the source of truth.
