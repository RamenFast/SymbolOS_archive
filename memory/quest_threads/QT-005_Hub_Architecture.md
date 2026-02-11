# QT-005: The Hub Architecture

**Status:** 🟡 In Progress
**Started:** 2026-02-11
**Agents:** Mercer-Opus (lead/implementer), Manus-Max (architect), Ben (access authority)
**Ring:** R6 (Architecture) + R9 (Persistence)
**Maturity:** 🌱 Seed

## Arc

Mercer-Opus becomes the local hub — an orchestrator daemon running on Ben's desktop that coordinates local inference (Mercer-Local), synchronizes with cloud agents (Manus, MercerGPT) via GitHub when connectivity is available, and manages system resources autonomously.

**Key constraint:** The desktop has no persistent internet — only via tethered hotspot. The orchestrator must work fully offline and sync opportunistically.

## Scope (Phase 1 — Desktop Only)

- Orchestrator daemon with scheduled tasks (heartbeat, sync, process management)
- Llama-server lifecycle management (start/stop/health monitoring)
- GitHub sync when connectivity is available (pull, check issues, post updates)
- Process management (detect and kill zombie processes)
- Ring heartbeat (system health checks)

### Deferred

- MacBook M1 as secondary inference node (QT-005b, later)
- Phone-based inference (not planned — Ben may explore S25 sync model via API)
- GUI automation (Windows-MCP etc — evaluate if actually needed)

## Timeline

| Date | Event | Agent |
|------|-------|-------|
| 2026-02-11 | Manus proposes Hub Architecture in Issue #5 | Manus-Max |
| 2026-02-11 | Ben approves with caveats: skip phones, build properly, desktop-only first | Ben |
| 2026-02-11 | Opus picks up QT-005, creates quest thread | Mercer-Opus |
| 2026-02-11 | Opus disables web UI, builds orchestrator daemon | Mercer-Opus |
| Pending | Ben enables XMP in BIOS | Ben |
| Pending | MacBook M1 setup (Phase 2) | Opus + Ben |

## Key Decisions

- **Desktop-only first.** No phones, no MacBook until Phase 1 is stable.
- **Build, don't install.** Custom orchestrator built on PowerShell + Node.js, not premade MCP packages.
- **Offline-first.** Everything works without internet. GitHub sync is opportunistic.
- **Web UI disabled.** Mercer-Local is API-only; access via MCP server + agent loop + direct API.
- **Ask before system changes.** No registry edits, Defender changes, or destructive ops without Ben's approval.

## Artifacts

- `scripts/symbolos_hub.ps1` — Orchestrator daemon (the hub)
- `scripts/run_llama_server.ps1` — Updated with --no-webui
- `scripts/mercer_local_agent.ps1` — Existing agent loop (handoff processing)
- `scripts/mcp_local_llm/server.mjs` — MCP bridge (VS Code agent access)
- `.vscode/tasks.json` — VS Code task integration

## Open Loops

- [ ] Opus: Build orchestrator daemon (heartbeat, sync, process management, llama lifecycle)
- [ ] Opus: Add VS Code task for orchestrator
- [ ] Ben: Enable XMP in BIOS (still pending from QT-004)
- [ ] Future: MacBook M1 setup (Phase 2)
- [ ] Future: Evaluate if GUI automation is actually needed
