# Phase 1 Scope — Minimum Working Lantern Prototype (Draft v0.1)

This is the smallest slice that proves the end-to-end loop:
**Lantern UI → MCP gateway → 2–3 MCP servers → visible result in UI → logged + repeatable.**

## Target deliverable (what "working" means)
- Tauri app launches
- Three panels render:
  1) **Chat / Quest**
  2) **Memory / Map**
  3) **Tools / Logs**
- A single tool call can be executed through the gateway and the result is:
  - shown in UI
  - written to a local log file (append-only)
  - (optionally) committed to git-backed memory when user confirms

## Required components (Phase 1)
1) **Tauri shell** (desktop wrapper)
2) **Web UI** (existing React/Vite is fine) with the 3 panels
3) **Local MCP gateway server**
   - routes requests to MCP servers
   - enforces mode barrier: prefetch/suggest/act
   - enforces scope barrier on tools (at minimum: filesystem)
4) **2–3 local MCP servers**
   - `local_llm` (local inference stub is fine; can return canned responses initially)
   - `memory` (read/write to `memory/` with consent gates)
   - `filesystem` (scoped read/write to an allowlisted directory)

## Explicit non-goals (Phase 1)
- Remote services / partner MCP
- Full multi-agent orchestra execution
- CRDT / complex sync conflict resolution
- Full vault integration beyond a placeholder interface

## "First demo" script (useful for regression)
1) User asks: "Search docs for 'meta-awareness'"
2) UI sends a **prefetch** call to `memory/docs-search` (read-only)
3) Gateway returns top hits
4) User clicks "Insert"
5) UI sends **act** call to write a note into `memory/session_log_YYYY-MM-DD.md`
6) UI shows "committed / not committed" status depending on consent

## Success criteria
- The gateway blocks act() without explicit confirmation
- The filesystem server cannot read outside its allowlist
- Logs show: request → barriers checked → decision → result

(Phase 2 can then replace stubs with real implementations without changing the shape.)
