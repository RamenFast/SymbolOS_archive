# Unified Architecture — Lantern + Backend + MCP Gateway (Draft v0.1)

This document stitches together the three design threads that currently live separately:
- **The Lantern** (human-facing client UX + panels)
- **Backend services** (state, sync, orchestration)
- **API/MCP** (gateway + servers + registry)

Goal: a single "shape of the system" that keeps interfaces, transport, and security boundaries obvious.

## High-level system diagram

```mermaid
flowchart LR
  subgraph Client["Lantern Client (Tauri shell + Web UI)"]
    UI[Web UI Panels<br/>1) Chat / Quest<br/>2) Memory / Map<br/>3) Tools / Logs]
    LocalRuntime[Local Runtime<br/>(Rust + JS bridge)]
    UI --> LocalRuntime
  end

  subgraph Gateway["MCP Gateway (Local-first)"]
    GW[MCP Gateway Server<br/>(single entrypoint)]
    Reg[Registry<br/>docs/mcp_servers.md + registry_entry*.json]
    GW --- Reg
  end

  subgraph MCP["MCP Servers (Phase 1 minimal)"]
    LLM[local_llm<br/>llama.cpp / local inference]
    MEM[memory<br/>git-backed + retrieval]
    FS[filesystem<br/>scoped read/write]
  end

  subgraph Backend["Backend Services (Phase 1 minimal)"]
    Sync[symbolos-sync<br/>(git / CRDT-lite later)]
    State[session state<br/>working_set + open_loops]
  end

  subgraph Security["Security Layer (cross-cutting)"]
    Policy[Policy + Scopes<br/>(prefetch/suggest/act + privacy)]
    Vault[Secrets / Key mgmt<br/>(vault, derivation, rotation)]
    Sandbox[Sandbox boundary<br/>(tool execution + FS)]
  end

  Client -->|mcp:// local| GW
  GW --> LLM
  GW --> MEM
  GW --> FS

  MEM --> Sync
  Sync --> State

  Policy -. gates .-> GW
  Policy -. gates .-> Client
  Vault -. creds .-> GW
  Sandbox -. constrains .-> FS

  %% optional: remote
  GW -->|https (optional)| Remote[Remote MCP servers<br/>(later / partner)]
```

## Boundary rules (the point of the diagram)

1) **One entrypoint for tools:** the client never talks to MCP servers directly; it talks to the gateway.
2) **Security is not a module:** it is a set of gates that wrap *every* boundary crossing:
   - UI → tool call (mode barrier)
   - tool call → filesystem (scope barrier)
   - tool call → network (egress barrier)
   - memory write (consent barrier)
3) **Phase 1 local-first:** everything above can run on localhost without external dependencies.

## Phase 1: absolute minimum working Lantern prototype

See: `docs/phases/phase1_lantern_minimal.md`

## Open questions (security + platform)

See: `docs/security/open_questions_resolutions.md`
