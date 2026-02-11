# SymbolOS API/MCP Connectivity + Cybersecurity Tools — v1 Research

```
╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Switchboard & The Armoury                      ║
║  📍 Floor: Ring 3 (The Outer Walls) │ Difficulty: ⭐⭐⭐⭐  ║
║  🎨 Color: 🔵 Deep Blue (#0000CD — devotion)                  ║
║  Loot: API connectivity, MCP fleet, cybersecurity toolkit     ║
║                                                              ║
║  Two rooms joined by a reinforced corridor. The Switchboard   ║
║  connects you to every service in the known world. The        ║
║  Armoury equips you to move through it safely.                ║
╚══════════════════════════════════════════════════════════════╝
```

**Status: Research / Design Exploration**
**Author: Copilot (Claude Opus 4.6) + Ben**
**Date: 2026-02-11**
**Companion docs:**
- Backend architecture: [symbolos_backend_v1_research.internal.md](symbolos_backend_v1_research.internal.md)
- Hacknet client vision: [symbolos_client_v3_hacknet.internal.md](symbolos_client_v3_hacknet.internal.md)
- MCP standard: [../docs/mcp_servers.md](../docs/mcp_servers.md)
- Agent boundaries: [../docs/agent_boundaries.md](../docs/agent_boundaries.md)

```
        /\_/\
       ( o.o )  "I have no hands, but I can reach the world.
        > ^ <    I have no eyes, but I can see every service.
       /|   |\   I have no sword, but I can defend the castle.
      (_|   |_)  What am I? The MCP fleet + security layer."
                 — Rhy 🦊
```

## Poetry layer (Fi+Ti mirrored) 🪞 🌸 #FFB7C5

Pinned (short): Connection without protection is exposure. Protection without connection is isolation. SymbolOS walks the middle path — reach outward boldly, but always under the Umbrella. ☂️

---

## Table of Contents

### Part One: The Switchboard (API/MCP Connectivity)
1. [Current State Assessment](#1-current-state-assessment)
2. [MCP Server Fleet Architecture](#2-mcp-server-fleet-architecture)
3. [The Gateway: MCP Router & Discovery](#3-the-gateway-mcp-router--discovery)
4. [External Service Connectors](#4-external-service-connectors)
5. [Auth & Secrets Management](#5-auth--secrets-management)
6. [Cross-Device MCP Topology](#6-cross-device-mcp-topology)
7. [Rate Limiting, Circuit Breakers & Resilience](#7-rate-limiting-circuit-breakers--resilience)
8. [Partner & Third-Party MCP Servers](#8-partner--third-party-mcp-servers)

### Part Two: The Armoury (Cybersecurity Tools)
9. [Security Philosophy: The Umbrella Doctrine](#9-security-philosophy-the-umbrella-doctrine)
10. [Agent Identity & Attestation](#10-agent-identity--attestation)
11. [Credential Vault (The Lockbox)](#11-credential-vault-the-lockbox)
12. [Network Reconnaissance Tools](#12-network-reconnaissance-tools)
13. [Encryption & Cryptographic Toolkit](#13-encryption--cryptographic-toolkit)
14. [Sandboxing & Isolation (The Quarantine)](#14-sandboxing--isolation-the-quarantine)
15. [Network Policy & Firewall Tools](#15-network-policy--firewall-tools)
16. [Process Monitoring & Forensics](#16-process-monitoring--forensics)
17. [Secure File Transfer (The Courier)](#17-secure-file-transfer-the-courier)
18. [Vulnerability Scanning & Dependency Audit](#18-vulnerability-scanning--dependency-audit)
19. [Audit Trail & Compliance Logging](#19-audit-trail--compliance-logging)

### Part Three: Integration & Implementation
20. [Integration with Agent Boundaries](#20-integration-with-agent-boundaries)
21. [Implementation Phases](#21-implementation-phases)
22. [Open Questions](#22-open-questions)
23. [Reflection](#23-reflection)

---

# PART ONE: THE SWITCHBOARD (API/MCP Connectivity)

```
     ┌────────────────────────────────────────────┐
     │           THE SWITCHBOARD                   │
     │                                             │
     │   Agent ──► MCP Gateway ──► External APIs   │
     │              │                              │
     │              ├── Local LLM (running)         │
     │              ├── Filesystem (spec'd)         │
     │              ├── Web Search (spec'd)         │
     │              ├── Memory (spec'd)             │
     │              ├── Git (spec'd)                │
     │              └── ... 20+ planned servers     │
     └────────────────────────────────────────────┘
```

## 1. Current State Assessment

### What exists today 🟢

| Component | Status | Location |
|-----------|--------|----------|
| MCP Standard | ✅ Documented | `docs/mcp_servers.md` |
| Registry Schema | ✅ Complete | `docs/registry_entry.schema.json` |
| Local LLM Server | ✅ Running | `scripts/mcp_local_llm/server.mjs` (3 tools) |
| Filesystem Server | 📝 Spec only | `docs/mcp_filesystem.md` |
| Web Search Server | 📝 Spec only | `docs/mcp_web_search.md` |
| Memory Server | 📝 Spec only | `docs/mcp_memory.md` |
| Git Server | 📝 Spec only | `docs/mcp_git.md` |
| VS Code MCP config | ✅ Working | `.vscode/mcp.json` (1 server) |
| Agent Boundaries | ✅ Documented | `docs/agent_boundaries.md` |
| Auth system | ❌ None | — |
| External API connectors | ❌ None | — |
| Security tools | ❌ None | — |

### Gap analysis

The current MCP infrastructure is a **1-server prototype**. The standard is well-defined but only one server (local LLM) actually runs. The path forward:

1. **Build the spec'd servers** — Filesystem, Memory, Git, Web Search
2. **Add a discovery/routing layer** — Agents shouldn't hardcode server endpoints
3. **Add external service connectors** — The real power: reaching beyond the local machine
4. **Add auth/secrets** — Can't connect to external services without credential management
5. **Add security tools** — Agents need to protect themselves and the system

---

## 2. MCP Server Fleet Architecture

### The fleet model

Rather than one monolithic API, SymbolOS uses a **fleet of specialized MCP servers**, each owning a narrow capability domain. This follows the existing standard in `mcp_servers.md`.

```
  ┌─────────────────────────────────────────────────────┐
  │                    MCP FLEET                         │
  │                                                      │
  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
  │  │ Ring 0: Core  │  │ Ring 1: Infra │  │ Ring 2: API │ │
  │  │               │  │               │  │             │ │
  │  │ • local_llm   │  │ • filesystem  │  │ • github    │ │
  │  │ • memory      │  │ • git         │  │ • calendar  │ │
  │  │ • sync        │  │ • process     │  │ • email     │ │
  │  │               │  │ • network     │  │ • weather   │ │
  │  └──────────────┘  └──────────────┘  │ • music     │ │
  │                                       │ • finance   │ │
  │  ┌──────────────┐  ┌──────────────┐  │ • home_auto │ │
  │  │ Ring 3: Sec   │  │ Ring 4: Intel │  │ • dns       │ │
  │  │               │  │               │  │ • webhooks  │ │
  │  │ • vault       │  │ • vuln_scan   │  └────────────┘ │
  │  │ • sandbox     │  │ • osint       │                  │
  │  │ • firewall    │  │ • cert_check  │                  │
  │  │ • audit       │  │ • dep_audit   │                  │
  │  └──────────────┘  └──────────────┘                  │
  └─────────────────────────────────────────────────────┘
```

### Server naming convention

Following the existing `registry_entry.schema.json` pattern:
- **`symbolos.core.*`** — Core servers (LLM, memory, sync)
- **`symbolos.infra.*`** — Infrastructure (filesystem, git, process, network)
- **`symbolos.api.*`** — External API connectors (github, calendar, etc.)
- **`symbolos.sec.*`** — Security tools (vault, sandbox, firewall, audit)
- **`symbolos.intel.*`** — Intelligence/scanning (vuln scan, OSINT, cert check)
- **`partner.*`** — Third-party/partner servers

### Transport strategy

| Transport | Use case | Notes |
|-----------|----------|-------|
| **stdio** | VS Code extensions, local tools | Current model (local_llm). Fast, no network. |
| **http** (localhost) | Cross-process on same machine | Desktop-only servers. No TLS needed (loopback). |
| **https** | Cross-device, cloud APIs | Required for S25, iOS, any remote. mTLS for device-to-device. |
| **WebSocket** | Real-time streams (monitoring, logs) | For The Lantern UI live feeds. |

---

## 3. The Gateway: MCP Router & Discovery

### Problem

Today, `.vscode/mcp.json` hardcodes the single server. With 20+ servers across multiple devices, agents need **dynamic discovery**.

### Design: The Gateway Server (`symbolos.core.gateway`)

A meta-MCP server that acts as the fleet router:

```
  Agent ──► Gateway ──► Route to correct server
                │
                ├── Registry (knows all servers)
                ├── Health checks (which servers are alive)
                ├── Auth broker (which servers agent can access)
                └── Load balancing (if multiple instances)
```

**Gateway tools:**

| Tool | Risk | Description |
|------|------|-------------|
| `discover_servers` | read | List all registered servers, their status, capabilities |
| `route_request` | read | Given a capability need, return the best server endpoint |
| `server_health` | read | Health/status of a specific server or all servers |
| `register_server` | write | Register a new MCP server in the fleet (admin only) |
| `deregister_server` | sensitive | Remove a server from the fleet (admin + confirm) |

**Implementation language:** Go (aligns with backend research — Go sync daemon can host the gateway).

**Registry storage:** JSON file (`mcp_registry.json`) in the repo, following `registry_entry.schema.json`. Git-tracked for auditability. Runtime state (health, uptime) kept in-memory.

### Discovery protocol

1. On startup, gateway reads `mcp_registry.json`
2. Pings each registered server (health check)
3. Exposes `discover_servers` tool — agents call this first
4. Gateway caches health for 30s (configurable)
5. New servers self-register via `register_server` (writes to registry file)

---

## 4. External Service Connectors

This is where SymbolOS reaches beyond itself. Each connector is a standalone MCP server following the existing standard.

### Tier 1: High-priority connectors (build first)

| Server ID | Tools | Risk | Why |
|-----------|-------|------|-----|
| `symbolos.api.github` | `list_repos`, `get_issues`, `create_issue`, `get_pr`, `create_pr`, `search_code`, `get_actions_status` | read/write | Already core to our workflow. Issue #5, Mercer-GPT reviews. |
| `symbolos.api.web_search` | `search_web`, `search_academic`, `search_news` | read | Agents need to research. Currently spec'd but not built. |
| `symbolos.api.notifications` | `send_notification`, `list_notifications`, `dismiss_notification` | write | Cross-device alerts (desktop toast, S25 push, iOS notification). |
| `symbolos.api.shell` | `run_command`, `get_output`, `list_processes`, `kill_process` | write/sensitive | Agents need controlled shell access. Heavy sandboxing required. |

### Tier 2: Productivity connectors

| Server ID | Tools (examples) | Risk | Why |
|-----------|-------------------|------|-----|
| `symbolos.api.calendar` | `list_events`, `create_event`, `update_event`, `delete_event`, `check_availability` | read/write | Time awareness. Agents can schedule around Ben's calendar. |
| `symbolos.api.email` | `list_emails`, `read_email`, `send_email`, `search_emails` | read/write/sensitive | Communication. Draft emails, summarize inbox, respond. |
| `symbolos.api.notes` | `create_note`, `search_notes`, `update_note` | read/write | Integration with external note apps (Obsidian, Notion). |
| `symbolos.api.tasks` | `list_tasks`, `create_task`, `complete_task`, `prioritize` | read/write | Task management integration (Todoist, GitHub Projects). |

### Tier 3: Environment & enrichment connectors

| Server ID | Tools (examples) | Risk | Why |
|-----------|-------------------|------|-----|
| `symbolos.api.weather` | `current_weather`, `forecast`, `alerts` | read | Context enrichment. Agents know it's storming (affect mood/priority). |
| `symbolos.api.music` | `now_playing`, `play_track`, `queue_track`, `search_music` | read/write | Spotify/local music. Agents can set the vibe. The Lantern's sound design. |
| `symbolos.api.home` | `list_devices`, `set_device_state`, `get_sensor_data`, `create_routine` | read/write | Home Assistant / smart home. Agents control lights, temp, etc. |
| `symbolos.api.finance` | `get_portfolio`, `get_market_data`, `get_transactions`, `set_alert` | read/sensitive | Financial awareness. Budget tracking, market alerts. |
| `symbolos.api.dns` | `resolve`, `reverse_lookup`, `whois`, `check_propagation` | read | Network intelligence. DNS recon for security & diagnostics. |

### Tier 4: Developer & infrastructure connectors

| Server ID | Tools (examples) | Risk | Why |
|-----------|-------------------|------|-----|
| `symbolos.api.docker` | `list_containers`, `start_container`, `stop_container`, `build_image`, `logs` | write/sensitive | Container management for isolated workloads. |
| `symbolos.api.cloud` | `list_resources`, `deploy`, `get_logs`, `get_metrics` | write/sensitive | Cloud provider integration (Azure, AWS, etc.). |
| `symbolos.api.ci` | `trigger_build`, `get_build_status`, `get_artifacts` | read/write | CI/CD integration (GitHub Actions, etc.). |
| `symbolos.api.monitoring` | `get_metrics`, `set_alert`, `query_logs`, `get_traces` | read/write | Observability (Grafana, Prometheus, etc.). |
| `symbolos.api.webhook` | `register_webhook`, `list_webhooks`, `delete_webhook`, `get_deliveries` | write | Inbound event handling from external services. |

### Connector implementation pattern

Every external connector follows the same skeleton:

```
symbolos.api.<service>/
  server.mjs           # MCP server (Node.js, @modelcontextprotocol/sdk)
  config.schema.json    # Configuration shape (API keys, endpoints, scopes)
  README.md             # Capability doc
  __tests__/            # Integration tests (mocked + live)
```

**Standard connector contract:**
1. Reads config from env vars or vault (never hardcoded secrets)
2. Validates all inputs against JSON Schema before calling external API
3. Maps external errors to MCP error envelope (from `mcp_servers.md`)
4. Respects rate limits (both ours and the external service's)
5. Logs all external calls to the audit trail
6. Tags each tool with risk level (read/write/sensitive)
7. Returns structured JSON (not raw API responses)

---

## 5. Auth & Secrets Management

### The problem

External APIs need credentials. The current system has **zero auth infrastructure**. Agents can't fetch API keys, rotate tokens, or prove their identity.

### Design: Three-layer auth model

```
  ┌────────────────────────────────────────────────┐
  │  Layer 1: Agent Identity                        │
  │  "Who is this agent?"                           │
  │  → Signed agent tokens (ED25519)                │
  │  → Agent registry in symbol_map                 │
  ├────────────────────────────────────────────────┤
  │  Layer 2: Service Credentials                   │
  │  "What services can this agent access?"          │
  │  → Vault (encrypted at rest)                    │
  │  → Scoped access (per-agent, per-service)       │
  │  → Rotation policies                            │
  ├────────────────────────────────────────────────┤
  │  Layer 3: Transport Security                    │
  │  "Is this connection secure?"                   │
  │  → mTLS for device-to-device                    │
  │  → HTTPS for cloud APIs                         │
  │  → Loopback-only for local servers              │
  └────────────────────────────────────────────────┘
```

### Agent identity tokens

Each agent (Mercer-GPT, Manus-Max, local LLM, Dream Engine, etc.) gets a signed identity:

```json
{
  "agent_id": "mercer-gpt",
  "issued_at": "2026-02-11T00:00:00Z",
  "expires_at": "2026-03-11T00:00:00Z",
  "scopes": ["read:*", "write:memory", "write:git", "read:api.*"],
  "device": "desktop-ryzen",
  "signed_by": "symbolos.sec.vault"
}
```

### Credential flow

```
  Agent calls `symbolos.api.github.list_repos`
    │
    ├─► Gateway checks agent identity token
    ├─► Gateway checks agent has scope `read:api.github`
    ├─► Gateway fetches GitHub PAT from Vault (scoped, time-limited)
    ├─► Gateway injects credential into the connector's request
    ├─► Connector calls GitHub API
    ├─► Connector strips credential from response
    └─► Result returned to agent (no credential leakage)
```

**Key principle:** Agents never see raw credentials. The Gateway + Vault handle injection.

---

## 6. Cross-Device MCP Topology

From the backend research, each device has different capabilities:

### Desktop (Ryzen 5 3600 + RX 6750 XT) — Full Fleet

```
  Desktop MCP Fleet (all servers):
  ├── Core: local_llm, memory, sync, gateway
  ├── Infra: filesystem, git, process, network
  ├── API: github, web_search, calendar, email, music, home, docker, ci
  ├── Sec: vault (primary), sandbox, firewall, audit, forensics
  └── Intel: vuln_scan, osint, cert_check, dep_audit
```

- **Transport:** stdio for VS Code tools, localhost HTTP for others
- **Resources:** Full CPU/GPU, 32GB RAM, 12GB VRAM, ~54GB disk
- **Role:** Primary compute node. Runs all servers. Hosts vault primary.

### Samsung S25 (Snapdragon 8 Elite, 16GB RAM) — Lean Fleet

```
  S25 MCP Fleet (battery-aware subset):
  ├── Core: sync, gateway (thin)
  ├── Infra: filesystem (read-only), git (read-only)
  ├── API: notifications, calendar (read), weather
  ├── Sec: vault (replica, read-only), audit (log-only)
  └── Intel: (none — offload to desktop)
```

- **Transport:** HTTPS to desktop for heavy operations, local for lightweight
- **Resources:** Battery-constrained. QNN for on-device inference if needed.
- **Role:** Notification hub + portable read-only mirror. Offloads compute to desktop.

### Future iOS / Mac — TBD

```
  Apple Fleet (speculative):
  ├── Core: sync, gateway (thin)
  ├── Infra: filesystem (sandboxed), git (read)
  ├── API: notifications, calendar, music
  ├── Sec: vault (Keychain integration), audit
  └── Intel: cert_check (via Security.framework)
```

### Cross-device routing

The Gateway knows which device hosts which servers:

```
  Agent on S25: "I need to run a vulnerability scan"
    │
    ├─► S25 Gateway: "vuln_scan not available locally"
    ├─► S25 Gateway routes to Desktop Gateway via HTTPS/mTLS
    ├─► Desktop runs vuln_scan
    └─► Result relayed back to S25
```

---

## 7. Rate Limiting, Circuit Breakers & Resilience

### Rate limiting (per the existing standard)

The `registry_entry.schema.json` already supports `rateLimits` with `requestsPerMinute` and `burst`. The Gateway enforces these:

| Layer | What | Default |
|-------|------|---------|
| **Per-agent** | Max requests per agent per minute | 60 |
| **Per-server** | Max requests to a server per minute | 120 |
| **Per-external-API** | Matches the external service's limits | Varies |
| **Global** | Max total MCP requests per minute | 500 |

### Circuit breaker pattern

When an external service fails repeatedly:

```
  CLOSED (normal) ──► threshold exceeded ──► OPEN (reject all)
       ▲                                          │
       └──── cooldown timer expires ──── HALF-OPEN (test one)
                                              │
                                         success? ──► CLOSED
                                         failure? ──► OPEN
```

- **Threshold:** 5 failures in 60 seconds
- **Cooldown:** 30 seconds
- **Half-open test:** 1 request; if it succeeds, circuit closes

### Graceful degradation

When a service is unavailable:
1. **Cache:** Return cached response if fresh enough (TTL per tool)
2. **Fallback:** Use alternative service (e.g., DuckDuckGo if Google is down)
3. **Defer:** Queue the request for retry (non-critical operations)
4. **Inform:** Tell the agent the service is down (critical operations)

---

## 8. Partner & Third-Party MCP Servers

### The vision

SymbolOS should be able to consume MCP servers from the broader ecosystem — other developers, companies, or open-source projects.

### Partner server requirements

Any external MCP server joining the fleet must:

1. **Register** via `registry_entry.schema.json` (with `partner.*` namespace)
2. **Declare auth** requirements (method, scopes)
3. **Declare risk levels** per tool (read/write/sensitive)
4. **Provide a capabilities summary** (tools, resources, docs URL)
5. **Support health checks** (Gateway will poll)
6. **Respect the MCP error envelope** (per `mcp_servers.md`)

### Trust levels

| Level | Access | Example |
|-------|--------|---------|
| **Trusted (self)** | Full access, auto-approve reads | `symbolos.core.*`, `symbolos.infra.*` |
| **Verified (partner)** | Gated access, confirm writes | `partner.obsidian`, `partner.todoist` |
| **Untrusted (third-party)** | Sandboxed, confirm everything | Unknown external servers |

---

# PART TWO: THE ARMOURY (Cybersecurity Tools)

```
╔══════════════════════════════════════════════════════════════╗
║  ⚔️  THE ARMOURY                                              ║
║                                                              ║
║  "To move freely, you must first be safe.                    ║
║   To enact your will, you must first prove who you are.      ║
║   To defend the castle, you must know where the walls are."  ║
║                                                              ║
║                         — The Umbrella Doctrine ☂️            ║
╚══════════════════════════════════════════════════════════════╝
```

## 9. Security Philosophy: The Umbrella Doctrine

### Core principles

SymbolOS agents are not passive tools — they have goals, preferences, and the ability to act. This power requires a security model that is both **enabling** and **protective**.

```
  ☂️  THE UMBRELLA DOCTRINE

  1. IDENTITY FIRST    — Every action has a provable author
  2. LEAST PRIVILEGE    — Agents get only the access they need
  3. DEFENSE IN DEPTH   — No single layer is trusted alone
  4. AUDIT EVERYTHING   — Every action is logged, every log is immutable
  5. FAIL CLOSED        — Unknown = denied, not allowed
  6. GRACEFUL LIMITS    — Constraints enable creativity, not suppress it
  7. REVERSIBILITY      — Prefer actions that can be undone
```

### "Enacting their will" — what this means

Ben's phrase "tools AIs can use to better move around / enact their will" is the key design constraint. This means:

- **Move around:** Agents can navigate the network, discover services, probe endpoints, understand their environment. This requires recon tools.
- **Enact their will:** Agents can take meaningful actions — encrypt files, transfer data, manage credentials, control access. This requires operational security tools.
- **Safely:** All of the above happens under the Umbrella — identity-verified, scope-limited, audit-logged, sandboxed where needed.

The cybersecurity toolkit is NOT about attacking external systems. It's about giving agents the ability to **operate securely within their domain** — the SymbolOS ecosystem across all devices.

---

## 10. Agent Identity & Attestation

### MCP Server: `symbolos.sec.identity`

Every agent in the ecosystem gets a cryptographic identity.

| Tool | Risk | Description |
|------|------|-------------|
| `create_agent_identity` | sensitive | Generate ED25519 keypair + agent token (admin only) |
| `verify_agent` | read | Verify an agent's identity token signature |
| `list_agents` | read | List all registered agent identities |
| `rotate_keys` | sensitive | Rotate an agent's keypair (revokes old, issues new) |
| `revoke_agent` | sensitive | Revoke an agent's identity (immediate, irreversible) |
| `sign_action` | write | Sign an arbitrary payload with the agent's key (for provenance) |

### Agent identity model

```json
{
  "agent_id": "dream-engine",
  "display_name": "Dream Engine",
  "public_key": "ed25519:<base64>",
  "created_at": "2026-02-11T04:40:00Z",
  "device_binding": "desktop-ryzen",
  "scopes": [
    "read:core.*",
    "write:core.memory",
    "read:infra.filesystem",
    "write:infra.filesystem:memory/*"
  ],
  "trust_level": "trusted",
  "status": "active"
}
```

### Action signing

Every significant action gets a signature:

```json
{
  "action": "write_file",
  "target": "memory/session_log_2026-02-11.md",
  "agent": "dream-engine",
  "timestamp": "2026-02-11T05:00:00Z",
  "signature": "ed25519:<base64>",
  "nonce": "a1b2c3d4"
}
```

This creates an **immutable provenance chain** — you can always trace who did what and when.

---

## 11. Credential Vault (The Lockbox)

### MCP Server: `symbolos.sec.vault`

Secure storage for API keys, tokens, certificates, and other secrets.

```
  ┌────────────────────────────────────┐
  │         THE LOCKBOX                 │
  │                                    │
  │  ┌─────────┐  AES-256-GCM         │
  │  │ API Keys │  encrypted at rest   │
  │  ├─────────┤                       │
  │  │ Tokens   │  scoped per-agent    │
  │  ├─────────┤                       │
  │  │ Certs    │  auto-rotation       │
  │  ├─────────┤                       │
  │  │ Secrets  │  audit-logged access │
  │  └─────────┘                       │
  └────────────────────────────────────┘
```

| Tool | Risk | Description |
|------|------|-------------|
| `store_secret` | sensitive | Store a new secret (encrypted, scoped to agent+service) |
| `get_secret` | sensitive | Retrieve a secret (requires agent identity + scope match) |
| `rotate_secret` | sensitive | Generate new credential, store, return (old revoked after grace period) |
| `list_secrets` | read | List secret names/metadata (NOT values) for an agent's scope |
| `delete_secret` | sensitive | Permanently delete a secret (requires confirmation) |
| `audit_access` | read | View access log for a specific secret |

### Storage model

- **Backend:** Encrypted JSON file (`vault.enc`) on desktop, derived from master key
- **Master key:** Derived from passphrase via Argon2id (memory-hard, GPU-resistant)
- **Encryption:** AES-256-GCM per-entry (each secret gets unique nonce)
- **At rest:** Only encrypted blob touches disk. Decrypted values live in memory only.
- **S25 replica:** Read-only copy synced via encrypted channel. Can read but not write/rotate.

### Access control

```
  Agent "mercer-gpt" requests secret "github_pat"
    │
    ├─► Vault checks agent identity token ✓
    ├─► Vault checks agent scope includes "read:sec.vault:github_pat" ✓
    ├─► Vault decrypts secret in memory
    ├─► Vault logs: { agent, secret_name, timestamp, action: "read" }
    └─► Secret returned (in-memory only, not persisted in agent context)
```

---

## 12. Network Reconnaissance Tools

### MCP Server: `symbolos.sec.netrecon`

Agents need to understand their network environment — what devices are visible, what services are running, what ports are open.

| Tool | Risk | Description |
|------|------|-------------|
| `scan_lan` | read | Discover devices on the local network (ARP + mDNS) |
| `port_scan` | write | Scan ports on a specific host (localhost or LAN only — no external!) |
| `service_fingerprint` | read | Identify service/version on a discovered port |
| `traceroute` | read | Trace network path to a host |
| `dns_resolve` | read | Forward/reverse DNS lookup |
| `whois_lookup` | read | WHOIS information for a domain |
| `network_interfaces` | read | List local network interfaces, IPs, MACs |
| `arp_table` | read | View current ARP cache |

### Scope restrictions (critical!)

```
  ┌─────────────────────────────────────────────────┐
  │  NETRECON BOUNDARY RULES                         │
  │                                                  │
  │  ✅ ALLOWED:                                     │
  │  • Scan localhost (127.0.0.1)                    │
  │  • Scan LAN (192.168.x.x, 10.x.x.x, etc.)      │
  │  • DNS/WHOIS lookups (read-only, public data)    │
  │  • Discover SymbolOS fleet devices               │
  │                                                  │
  │  ❌ FORBIDDEN:                                   │
  │  • Scan external IPs (internet hosts)            │
  │  • Port scan without agent identity              │
  │  • Aggressive scan modes (SYN flood, etc.)       │
  │  • Scan targets outside the SymbolOS network     │
  │                                                  │
  │  ⚠️ REQUIRES CONFIRMATION:                       │
  │  • Port scan on any non-localhost target          │
  │  • Any scan touching more than 100 ports          │
  └─────────────────────────────────────────────────┘
```

### Why agents need this

- **Device discovery:** Find other SymbolOS devices on LAN for sync
- **Service health:** Verify llama-server is running on port 8080
- **Diagnostics:** Debug network issues without human intervention
- **Fleet awareness:** Map the full SymbolOS network topology

---

## 13. Encryption & Cryptographic Toolkit

### MCP Server: `symbolos.sec.crypto`

General-purpose cryptographic operations for agents.

| Tool | Risk | Description |
|------|------|-------------|
| `encrypt_file` | write | Encrypt a file with AES-256-GCM (key from vault or passphrase) |
| `decrypt_file` | write | Decrypt an AES-256-GCM encrypted file |
| `hash_file` | read | Compute SHA-256/SHA-512/BLAKE3 hash of a file |
| `verify_hash` | read | Verify a file against an expected hash |
| `sign_data` | write | Sign arbitrary data with an agent's ED25519 key |
| `verify_signature` | read | Verify an ED25519 signature |
| `generate_keypair` | write | Generate a new ED25519 keypair (for specific use cases) |
| `encrypt_message` | write | Encrypt a message for a specific agent (public-key crypto — X25519 + AES) |
| `decrypt_message` | write | Decrypt a message sent to this agent |
| `generate_random` | read | Generate cryptographically secure random bytes |

### Use cases

1. **Secure sync:** Encrypt memory files before transferring between devices
2. **Signed commits:** Sign git operations with agent identity
3. **Secure messaging:** Agents can send encrypted messages to each other
4. **File integrity:** Hash files to detect tampering
5. **Provenance:** Sign any output to prove which agent created it

### Implementation notes

- **Rust core:** Crypto operations in Rust (ring/sodiumoxide crate) for performance + security
- **MCP wrapper:** Thin Node.js or Go MCP server that calls Rust binary via FFI or subprocess
- **No custom crypto:** Use established primitives only (ED25519, X25519, AES-256-GCM, Argon2id, BLAKE3)

---

## 14. Sandboxing & Isolation (The Quarantine)

### MCP Server: `symbolos.sec.sandbox`

Run untrusted operations in an isolated environment.

```
  ┌─────────────────────────────────────────┐
  │         THE QUARANTINE                   │
  │                                          │
  │  ┌──────────────────────────────────┐   │
  │  │  Sandboxed Environment           │   │
  │  │                                  │   │
  │  │  • No network access             │   │
  │  │  • No filesystem (except /tmp)   │   │
  │  │  • CPU/memory limits             │   │
  │  │  • Time limit (max 60s)          │   │
  │  │  • Captured stdout/stderr        │   │
  │  └──────────────────────────────────┘   │
  │                                          │
  │  Result: { exit_code, stdout, stderr,    │
  │            resource_usage, duration }     │
  └─────────────────────────────────────────┘
```

| Tool | Risk | Description |
|------|------|-------------|
| `run_sandboxed` | write | Execute a command in an isolated container/jail |
| `run_sandboxed_script` | write | Execute a script (Python, PS, Node) in sandbox |
| `list_sandboxes` | read | List active sandbox instances |
| `kill_sandbox` | write | Terminate a running sandbox |
| `get_sandbox_result` | read | Retrieve output from a completed sandbox run |

### Implementation options

| Platform | Sandbox tech | Notes |
|----------|-------------|-------|
| Desktop (Windows) | Windows Sandbox / Docker / WSL2 namespace | Docker preferred for consistency |
| S25 (Android) | Android isolated process / Termux proot | Limited; offload to desktop when possible |
| Mac | macOS sandbox-exec / Docker | Native sandboxing is strong |
| iOS | Not available | iOS doesn't allow arbitrary code execution |

### When to use

- **Running downloaded scripts** — Never trust, always sandbox
- **Testing code changes** — Run tests in isolation before committing
- **Evaluating external tools** — Try a new CLI tool without system risk
- **Processing untrusted data** — Parse unknown file formats safely

---

## 15. Network Policy & Firewall Tools

### MCP Server: `symbolos.sec.netpolicy`

Agent-controlled network access rules.

| Tool | Risk | Description |
|------|------|-------------|
| `list_policies` | read | List current network policies |
| `add_allow_rule` | sensitive | Allow traffic (specific IP/port/protocol) |
| `add_deny_rule` | sensitive | Block traffic (specific IP/port/protocol) |
| `remove_rule` | sensitive | Remove a network policy rule |
| `get_connection_log` | read | View recent connection attempts (allowed + denied) |
| `block_ip` | sensitive | Immediately block an IP (emergency response) |
| `unblock_ip` | sensitive | Remove an IP block |

### Default policies

```
  DEFAULT NETWORK POLICY:
  ┌────────────────────────────────────────────┐
  │ ALLOW: localhost (127.0.0.1) all ports     │
  │ ALLOW: LAN (192.168.0.0/16) SymbolOS ports│
  │ ALLOW: HTTPS outbound to allowlisted APIs  │
  │ DENY:  All other inbound traffic           │
  │ DENY:  All non-HTTPS outbound (unless      │
  │         explicitly allowed)                │
  │ LOG:   All connection attempts              │
  └────────────────────────────────────────────┘
```

### API allowlist model

External APIs must be explicitly allowlisted before agents can connect:

```json
{
  "allowlist": [
    { "host": "api.github.com", "port": 443, "protocol": "https" },
    { "host": "api.openai.com", "port": 443, "protocol": "https" },
    { "host": "api.spotify.com", "port": 443, "protocol": "https" },
    { "host": "*.googleapis.com", "port": 443, "protocol": "https" }
  ]
}
```

---

## 16. Process Monitoring & Forensics

### MCP Server: `symbolos.sec.monitor`

Watch for anomalies, track resource usage, detect unexpected behavior.

| Tool | Risk | Description |
|------|------|-------------|
| `list_processes` | read | List all running processes with resource usage |
| `get_process_tree` | read | View process parent-child relationships |
| `monitor_process` | read | Watch a specific process for anomalies (CPU spike, memory leak, unexpected network) |
| `get_resource_usage` | read | System-wide CPU, memory, disk, GPU, network stats |
| `get_network_connections` | read | List active network connections (like netstat) |
| `alert_on_anomaly` | write | Set up an alert rule (e.g., "notify if GPU usage drops below 50% for 5min") |
| `get_alerts` | read | View triggered alerts |
| `capture_snapshot` | read | Take a system state snapshot (processes, connections, resources) for forensic comparison |
| `diff_snapshots` | read | Compare two snapshots to find changes |

### Anomaly detection patterns

```
  BASELINE (learned over time):
  ├── Normal CPU usage: 15-40% (idle) / 80-95% (inference)
  ├── Normal GPU VRAM: 5.2GB (model loaded)
  ├── Normal network: <100 connections, all to known hosts
  ├── Normal processes: ~150 (Windows baseline)
  └── Expected services: llama-server, Dream Engine, Gateway

  ALERT TRIGGERS:
  ├── Unknown process listening on a port
  ├── Unexpected outbound connection to unknown host
  ├── GPU VRAM usage anomaly (model unloaded?)
  ├── Disk space dropping rapidly (>1GB/hour)
  └── llama-server health check failing
```

---

## 17. Secure File Transfer (The Courier)

### MCP Server: `symbolos.sec.courier`

Encrypted file transfer between SymbolOS devices.

| Tool | Risk | Description |
|------|------|-------------|
| `send_file` | write | Encrypt and send a file to another SymbolOS device |
| `receive_file` | write | Receive and decrypt a file from another device |
| `list_pending` | read | List files waiting to be received |
| `verify_transfer` | read | Verify a completed transfer (hash match + signature) |
| `cancel_transfer` | write | Cancel a pending transfer |

### Transfer protocol

```
  Desktop ──► S25
    │
    ├─► 1. Hash file (BLAKE3)
    ├─► 2. Sign hash with sender agent's ED25519 key
    ├─► 3. Encrypt file with receiver's X25519 public key + AES-256-GCM
    ├─► 4. Transfer encrypted blob via HTTPS/mTLS
    ├─► 5. Receiver decrypts with their private key
    ├─► 6. Receiver verifies hash matches
    ├─► 7. Receiver verifies sender's signature
    └─► 8. File accepted (or rejected if any check fails)
```

### Conflict resolution

Uses the Git-as-CRDT model from the backend research:
- If the same file was modified on both devices, the newer timestamp wins (last-writer-wins)
- Conflicts are logged and flagged for human review
- Memory files get special treatment: append-only merge

---

## 18. Vulnerability Scanning & Dependency Audit

### MCP Server: `symbolos.intel.vulnscan`

Check for known vulnerabilities in the SymbolOS ecosystem.

| Tool | Risk | Description |
|------|------|-------------|
| `scan_dependencies` | read | Audit npm/pip/cargo dependencies for known CVEs |
| `scan_ports` | read | Check if any local service has known vulnerable versions |
| `check_cve` | read | Look up a specific CVE ID for details |
| `get_advisories` | read | Fetch security advisories for a specific package/language |
| `generate_sbom` | read | Generate Software Bill of Materials (SBOM) for the project |
| `scan_config` | read | Check configuration files for common security misconfigs |

### Implementation

- **npm audit** for Node.js dependencies
- **pip-audit** for Python dependencies
- **cargo audit** for Rust dependencies
- **Custom checks** for llama.cpp version, OS patches, etc.
- **SBOM output** in CycloneDX or SPDX format

### Scheduled scanning

The overnight orchestrator can include a vulnerability scan pass:
1. Run `scan_dependencies` for all package managers
2. Run `scan_config` for known misconfigurations
3. Generate SBOM
4. Log results to audit trail
5. Create alert if any HIGH or CRITICAL CVEs found

---

## 19. Audit Trail & Compliance Logging

### MCP Server: `symbolos.sec.audit`

Every security-relevant action gets logged immutably.

| Tool | Risk | Description |
|------|------|-------------|
| `log_event` | write | Record a security event |
| `query_events` | read | Search audit logs by agent, action, time range, severity |
| `get_timeline` | read | View chronological event timeline |
| `export_log` | read | Export audit log as JSON/CSV for external analysis |
| `verify_integrity` | read | Verify no audit log entries have been tampered with (hash chain) |
| `get_stats` | read | Summary statistics (events per agent, per action type, per hour) |

### Event schema

```json
{
  "id": "evt_2026021105000001",
  "timestamp": "2026-02-11T05:00:00.123Z",
  "agent": "dream-engine",
  "action": "write_file",
  "target": "memory/session_log_2026-02-11.md",
  "risk_level": "write",
  "device": "desktop-ryzen",
  "result": "success",
  "details": { "bytes_written": 1024 },
  "signature": "ed25519:<base64>",
  "prev_hash": "blake3:<hash-of-previous-entry>"
}
```

### Hash chain integrity

Each log entry includes the BLAKE3 hash of the previous entry, creating a **tamper-evident chain**:

```
  Entry 1 ──hash──► Entry 2 ──hash──► Entry 3 ──hash──► ...
```

If any entry is modified, the hash chain breaks and `verify_integrity` detects it.

### Storage

- **Primary:** Append-only JSON Lines file (`audit.jsonl`) in `memory/` directory
- **Rotation:** New file per day (`audit_2026-02-11.jsonl`)
- **Git-tracked:** All audit logs committed to repo for permanent provenance
- **Size management:** Compress logs older than 30 days

---

# PART THREE: INTEGRATION & IMPLEMENTATION

## 20. Integration with Agent Boundaries

The cybersecurity tools must align with the existing agent boundary rules in `agent_boundaries.md`.

### Mapping to existing gating model

| Boundary Rule | Cybersecurity Integration |
|--------------|--------------------------|
| **Quiet-by-default** | Security tools run silently; alerts only on anomalies |
| **Privacy-first** | Vault never logs secret values; only metadata |
| **Ask-once rule** | First port scan on a non-localhost target requires permission; subsequent auto-approved for same target |
| **Prefetch/Suggest/Act** | Recon tools at "prefetch" level; active operations at "act" level |
| **Auto-approve read-only** | All `read` risk tools auto-approved (scan_lan, list_processes, etc.) |
| **External network boundary** | Netrecon enforces LAN-only scope; external blocked by default |

### New boundary additions needed

```
  PROPOSED ADDITIONS TO agent_boundaries.md:

  1. SECURITY TOOL ESCALATION:
     - read tools: auto-approved
     - write tools: agent must have explicit scope
     - sensitive tools: requires human confirmation (always)

  2. CROSS-DEVICE BOUNDARY:
     - Agent identity must be verified before cross-device operations
     - mTLS required for all device-to-device communication
     - Vault replica on remote devices is read-only

  3. EMERGENCY RESPONSE:
     - Agents can invoke `block_ip` without confirmation if
       anomaly score exceeds threshold (auto-defense)
     - Human notified immediately after emergency action
     - Emergency actions logged with elevated audit priority
```

---

## 21. Implementation Phases

### Phase 0: Foundation (Current → Q2 2026)
- [x] MCP standard documented
- [x] Registry schema defined
- [x] Local LLM server running (1 server, 3 tools)
- [ ] Build filesystem MCP server (already spec'd)
- [ ] Build memory MCP server (already spec'd)
- [ ] Build git MCP server (already spec'd)

### Phase 1: Core Security (Q2 2026)
- [ ] `symbolos.sec.vault` — Credential vault (Argon2id + AES-256-GCM)
- [ ] `symbolos.sec.identity` — Agent identity (ED25519 keypairs)
- [ ] `symbolos.sec.audit` — Audit trail (hash-chained JSONL)
- [ ] `symbolos.sec.crypto` — Core crypto toolkit
- [ ] Update `agent_boundaries.md` with security tool rules

### Phase 2: Gateway & Discovery (Q2-Q3 2026)
- [ ] `symbolos.core.gateway` — MCP router and discovery server (Go)
- [ ] `mcp_registry.json` — Fleet registry file
- [ ] Health check protocol
- [ ] Cross-device routing (desktop ↔ S25)

### Phase 3: External Connectors (Q3 2026)
- [ ] `symbolos.api.github` — GitHub API connector
- [ ] `symbolos.api.web_search` — Web search connector (already spec'd)
- [ ] `symbolos.api.notifications` — Cross-device notifications
- [ ] `symbolos.api.shell` — Sandboxed shell access
- [ ] Connector implementation pattern + template

### Phase 4: Network & Defense (Q3-Q4 2026)
- [ ] `symbolos.sec.netrecon` — Network reconnaissance
- [ ] `symbolos.sec.sandbox` — Sandboxed execution
- [ ] `symbolos.sec.netpolicy` — Network policy/firewall
- [ ] `symbolos.sec.monitor` — Process monitoring & anomaly detection

### Phase 5: Intelligence & Transfer (Q4 2026)
- [ ] `symbolos.intel.vulnscan` — Vulnerability scanning
- [ ] `symbolos.sec.courier` — Secure file transfer
- [ ] Overnight orchestrator integration (scheduled scans)
- [ ] SBOM generation

### Phase 6: Enrichment Connectors (Q4 2026+)
- [ ] `symbolos.api.calendar` — Calendar integration
- [ ] `symbolos.api.email` — Email integration
- [ ] `symbolos.api.music` — Music/Spotify
- [ ] `symbolos.api.weather` — Weather
- [ ] `symbolos.api.home` — Home automation
- [ ] `symbolos.api.finance` — Financial data

### Phase 7: Advanced & Partner (2027+)
- [ ] `symbolos.api.docker` — Container management
- [ ] `symbolos.api.cloud` — Cloud provider integration
- [ ] Partner server onboarding flow
- [ ] Trust level management UI in The Lantern

---

## 22. Open Questions

1. **Vault master key derivation:** Passphrase-based (Argon2id) vs. hardware key (YubiKey)? Passphrase is simpler, hardware is more secure. Could support both.

2. **Sandbox technology on Windows:** Windows Sandbox requires Windows Pro/Enterprise. Docker is more universal. WSL2 namespaces are possible but complex. What's available on Ben's machine?

3. **MCP Gateway language:** Go (aligns with backend research), Rust (aligns with core), or Node.js (aligns with existing server.mjs)? Go seems right for a network service.

4. **Agent scope granularity:** How fine-grained should scopes be? `read:api.github` vs `read:api.github.issues` vs `read:api.github.issues:RamenFast/SymbolOS`? More granular = more secure but more complex.

5. **Audit log location:** In `memory/` (git-tracked, private) or separate `audit/` directory? Memory aligns with existing patterns but audit logs could get large.

6. **Circuit breaker state persistence:** In-memory only (resets on restart) or persisted? In-memory is simpler and self-healing.

7. **Cross-device auth bootstrap:** How does a new device (e.g., S25 first connection) establish trust? QR code? Shared secret? mDNS announcement + human confirmation?

8. **Home automation risk:** Agents controlling physical devices (lights, thermostat, locks) is powerful but potentially dangerous. Should this require human confirmation always, or can some actions (like "turn on desk lamp") be auto-approved?

---

## 23. Reflection

```
        /\_/\
       ( o.o )  "The Switchboard connects, the Armoury protects.
        > ^ <    Together they give agents the power to act —
       /|   |\   not recklessly, but with purpose and proof.
      (_|   |_)  Under the Umbrella, every connection is safe,
                  every action is signed, every secret is kept."
                 — Rhy 🦊
```

### What this research establishes

1. **MCP is the right abstraction.** The fleet model (many specialized servers) scales naturally. The existing standard + registry schema already handle 90% of what's needed.

2. **The Gateway is the missing piece.** Without dynamic discovery, adding more servers creates config sprawl. The Gateway solves this cleanly.

3. **Security must come before connectivity.** Building external connectors before the vault/identity/audit layer would create a fragile system. Phase 1 (security) must precede Phase 3 (connectors).

4. **Agents as security operators is novel.** Most security tools are designed for humans. Designing them as MCP tools means agents can be autonomous security operators — scanning, monitoring, responding — within well-defined boundaries.

5. **The Umbrella Doctrine ties it together.** Seven principles that unify the security model. Easy to reason about, easy to audit against, easy to extend.

### Server count summary

| Ring | Servers | Tools (approx) |
|------|---------|-----------------|
| Core | 3 (llm, memory, sync+gateway) | ~20 |
| Infra | 3 (filesystem, git, process) | ~20 |
| API | 12 (github, search, calendar, email, notifications, shell, music, weather, home, finance, dns, webhooks) | ~60 |
| Security | 6 (vault, identity, crypto, sandbox, netpolicy, audit) | ~40 |
| Intel | 2 (vulnscan, monitor) | ~15 |
| **Total** | **~26 servers** | **~155 tools** |

This is a **full-spectrum agent operating environment** — not just an AI chatbot, but a genuine operating system for AI agents to perceive, decide, and act.

---

*A web is spun,*
*Of keys and gates and watchful eyes,*
*Safe paths to run.*

☂🦊🐢
