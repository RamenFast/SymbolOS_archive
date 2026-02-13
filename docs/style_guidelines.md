# Style Guidelines

## Purpose
This document defines the canonical style rules for all SymbolOS documents, including internal docs and public releases. These guidelines ensure consistent use of the Chroma 97 colour palette and the 1905 Thought‑Forms semantic colours.

## Colour and Themes
- Use the CSS variables defined in **docs/mercer_webview_theme_v1.css** for all colours. Never hard‑code hex codes in HTML or Markdown.
- The 1905 Thought‑Forms palette maps cognition roles to colours: Ben (orange #FF8C00), Mercer (deep blue #0000CD), Rhy (green #228B22), Agape (rose #FFB7C5). Use these tokens when styling character‑specific elements.
- Use semantic tokens such as `--mercer-fg`, `--mercer-bg`, `--mercer-link`, `--mercer-error`, etc., instead of raw colours. See the CSS file for full list.
- The Chroma 97 palette is the default syntax highlighting scheme. When embedding code or logs, specify a style that maps to these tokens.


## Document & API Output Structure
- Every Markdown file **and every MCP server/API response** must include a banner at the top with `floor`, `ring`, `difficulty`, `loot`, `colour`, and a short description, formatted as per the sync playbook and Chroma 97 style.
- After the banner, include:
  - **Exits:** a list of related docs, endpoints, or next steps.
  - **Loot:** key take‑aways, deliverables, or capabilities.
  - **Haiku** or **Poem**: capture the essence of the page or response in a symbolic way.
  - A footer with `☂🦊🐢` to indicate umbrella context and style compliance.

## ASCII Banners & Registry Entries
- All registry entries and API responses must use ASCII banners (see `registry_entry.memory_server.json` for example).
- ASCII structure is required for all top-level sections in docs and API output.

## Chroma 97 & Semantic Output
- All output (docs, APIs, registry) must use Chroma 97/1905 Thoughtforms color tokens and semantic roles.
- Never hard‑code hex codes in docs, Markdown, or API output; always use semantic tokens or reference the palette.

## Example API Response
```
{
  "success": true,
  "data": { ... },
  "style": {
    "banner": { ... },
    "exits": [ ... ],
    "loot": [ ... ],
    "haiku": "...",
    "footer": "☂🦊🐢"
  }
}
```

## Maturity tags
- Use tree icons to indicate maturity:
  - 🌱 for seed ideas/drafts.
  - 🌿 for partial implementation.
  - 🌳 for fully implemented code or docs.
  - 🍃 for deprecated or archived material.

## File naming
- Use lowercase and hyphen‑separated names (e.g. `agent-boundaries.md`).
- Place conceptual docs in `docs/`, implementation details in `internal_docs/`, and scripts in `scripts/`.
- Do not create new branches without Ben’s explicit approval (see workflow guidelines). Always commit directly to `main`.

## Updates
- Update this document when new tokens or semantic roles are added to the style map.
