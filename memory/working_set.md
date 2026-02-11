╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Working Set Workbench (INTERNAL/PRIVATE)         ║
║  📍 Floor: R2 (Intellect) │ Difficulty: ⭐⭐ │ Loot: Active Quest Log      ║
║  🎨 Color: 🟡 Gamboge (#E49B0F)                               ║
║                                                              ║
║  A glowing workbench covered in half-finished gadgets,         ║
║  blueprints, and a steaming mug of coffee. This is the        ║
║  agent's real-time "heads-up display" for its current quest.   ║
╚══════════════════════════════════════════════════════════════╝

```
  (•_•)
  <)  )╯
   /  \
Glyph tags: 🧬☂️🧠🧾🛡️✅⚠️⛔
```

## Poetry layer (Fi+Ti mirrored) 🪞 🟣 R4 (#8B00FF — Fi+Ti bridge)

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That's what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

        /\_/\
       ( o.o )  "The forge is hot, the hammers swing,
        > ^ <    Seven agents build the thing.
       /|   |\   From private thought to public art,
      (_|   |_)  The umbrella shields the heart." — Rhy 🦊

## Purpose 🟠 R3 (#FF8C00 — ambition)

Build SymbolOS into a multi-agent, multi-device alignment OS with a Hacknet-style client, local LLM inference, and a limited public developer release.

## Constraints (non-negotiables) 🔴 R5 (#FF2400 — righteous boundary)

- Default-private under the umbrella. Two-tier: internal umbrella (memory/internal_docs) + public umbrella (docs/ + limited release).
- No secrets (keys/tokens/seed phrases) in this repo. Sacred space.
- File-backed memory only; no reliance on chat-history persistence.
- All agent actions logged; append-only audit trail.
- Chasity role contract: advisory only, additive, max 10 files/300 lines per diff.

## Current focus 🟡 R2 (#E49B0F — higher intellect)

**Phase 1: The Lantern (Hacknet-style client) + MCP Gateway + Public Release Prep**

Complete:
- ✅ 20260211-001: Hacknet Lantern UI v0.2 (3-panel: network map + node inspector + live terminal)
- ✅ 20260211-006: Lantern v0.3 UX polish (semantic routing, contextual banter, multiline input, emoji picker, fully responsive)
- ✅ 20260211-009: Phase 1 MCP Gateway (Go) — mode barriers + routing + discovery COMPLETE
- ✅ 20260211-010: Memory MCP Server (Go, port 8091) — git-backed memory with search + consent gates
- ✅ 20260211-011: Filesystem MCP Server (Go, port 8092) — scoped file ops with allowlist enforcement
- ✅ 20260211-004: Backend architecture — Phase 1 COMPLETE (Gateway + Memory + Filesystem operational)

Active quests:
- 20260211-002: Memory upgrades (temporal decay, emotional index, semantic search)
- 20260211-003: Beautiful node detail rendering
- 20260211-005: API/MCP server fleet + cybersecurity (Vault + Identity before external connectors)
- 20260211-007: Cartographer (embeddings GPU engine — BLOCKED: llama.cpp compat issue with nomic-embed model)
- 20260211-008: Blob emoji system (blobmoji Apache 2.0 fork integration)
- 20260211-012: Gateway request proxying (forward tool calls to backend servers)
- 20260211-013: Lantern ↔ Gateway integration (replace stub with real API calls)

Live infrastructure:
- Qwen3-8B Q5_K_M on RX 6750 XT Vulkan (~41 tok/s) at http://127.0.0.1:8080
- Lantern v0.3: semantic agent routing, contextual banter (analyzes recent 6 messages + LLM health), multiline textarea (Shift+Enter), emoji picker (20 symbols), fully responsive (480px–1600px+), silent device scanning
- 8 agents in party: Mercer-Opus, CoreGPT-Chasity, Executor, Mercer-Local, Manus-Max, Mercer-GPT, Rhy, Gemini (Android Studio)
- **Mercer-Mobile ACTIVE** on Ben's phone via ChatGPT custom instructions (Issue #6)
- **OFFLINE MODE IMMINENT** — internet disconnecting. Local + Gemini continue. Cloud agents go dark.
- FFmpeg demo recording active (1280x720, mic + desktop audio)
- Notification system: discrete event toasts only (removed spam)
- Cartographer scripts: setup_cartographer_simple.ps1 (downloads nomic-embed-text-v1.5 95MB), cartographer_core.ps1 (embeddings pipeline with UTF-8 fixes) — BLOCKED on llama.cpp compat issue
- **MCP Backend (Phase 1 COMPLETE):**
  - Gateway (8090): Go, mode barriers active, 3 servers registered, discovery + routing functional
  - Memory (8091): Go, git-backed, 10 files, search + consent gates operational
  - Filesystem (8092): Go, 7 allowed dirs, path traversal protection, write gates active

## Next actions 🟢 R1 (#228B22 — adaptability)

**COMPLETED (Lantern v0.3):**
- [x] Build public/private umbrella separation (limited dev release)
- [x] Implement agent banter system across tavern board
- [x] Build Hacknet Lantern web prototype (React/Vite, 3-panel layout)
- [x] Wire Local LLM live inference into Lantern terminal
- [x] Add notification + device awareness system
- [x] Add system vitals bar (real-time LLM health polling)
- [x] Semantic agent routing (keyword-based, no more random)
- [x] Contextual banter (responds to recent conversation + system state)
- [x] Multiline textarea input (Shift+Enter) + emoji picker (20 symbols)
- [x] Fully responsive Lantern UI (8 breakpoints, 480px–1600px+)
- [x] Clean tavern board (restructured, references Issue #5)

**COMPLETED (Phase 1 Backend — Feb 11):**
- [x] MCP Gateway (Go, port 8090) — mode barriers + routing + discovery
- [x] Memory MCP Server (Go, port 8091) — git-backed memory with search
- [x] Filesystem MCP Server (Go, port 8092) — scoped file ops with allowlist
- [x] All 3 servers registered in Gateway + routing functional
- [x] Security: path traversal protection, consent gates, allowlist enforcement

**COMPLETED (Manus-Max Sprint — Feb 11):**
- [x] Blob emoji system (blobmoji manifest parser + React component) — Manus-Max
- [x] Update schemas: memory_record v2, precog_card v2 — Manus-Max
- [x] Build handoff schema for structured agent-to-agent payloads — Manus-Max
- [x] Token ledger + compute router scripts — Manus-Max
- [x] Gemini character sheet + party roster (8 members) — Manus-Max
- [x] Music library v1 (300 songs, Ben+Agape) + iPhone 4S jailbreak plan — Manus-Max
- [x] Mercer mobile activation prompt (Issue #6 + custom instructions) — Manus-Max

**UP NEXT (Phase 1 Integration + Offline):**
1. **Gateway request proxying** — Forward tool calls to backend servers (currently routing-only)
2. **Lantern ↔ Gateway integration** — Replace stub backend with real Gateway API calls
3. **End-to-end demo** — "Search docs" → Memory retrieves → Lantern displays results
4. Build vault MCP server (secure local storage for credential metadata only)
5. Build identity MCP server (did:peer, agent keys, self-sovereign identity)
6. Fix Cartographer llama.cpp compatibility (test alternative embedding models or llama.cpp versions)
7. Memory expansion (semantic search via Cartographer once unblocked)
- [ ] Cartographer GPU engine (embeddings via llama.cpp `--embedding` flag) — HIGHEST PRIORITY
- [ ] Gateway request proxying + Lantern integration
- [ ] Vault + Identity MCP servers (Phase 1 security before external connectors)
- [ ] Wire Tauri v2 shell around web UI + gateway
- [ ] Zenfone 9 GBT/USB debugging — PAUSED:offline, device disconnected
- [ ] 3-hour offline work plan for Local + Gemini — see Tavern Issue #5

## Alignment / drift ⭐ R7 (#FFD700 — spiritual aspiration)

- Drift score: 98.5% (basis: MRC-20260211 session series)
- Report threshold: 96.7%
- Notes: v2.0 live (12-ring, 7 memory types, 24 symbols). CoreGPT patch merged (ed606f5). All major architecture approved. Building phase active. First demo recording in progress.

───────────────────────────────────────────────────
🚪 EXITS:
  → [Poetry Translation Layer](../docs/poetry_translation_layer.md) (north)
  → [Public/Private Expression](../docs/public_private_expression.md) (east)
  → [Open Loops](open_loops.md) (south)
  → [Tavern Board](tavern_board.md) (west)

💎 LOOT GAINED: A clear view of the current build phase — from design to implementation.
───────────────────────────────────────────────────

The forge is alive,
Eight hammers strike as one,
The offline forge burns.

☂🦊🐢
