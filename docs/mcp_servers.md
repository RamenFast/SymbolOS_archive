╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Server Forges                                  ║
║  📍 Floor: Ring 2 │ Difficulty: ⭐⭐⭐⭐ │ Loot: MCP Server Schematics ║
║  🎨 Color: Violet (#8B00FF)                                   ║
║                                                              ║
║  A low hum vibrates the air, where glowing runes pulse on obsidian slabs. ║
║  This is where raw capabilities are forged into hardened tools.      ║
╚══════════════════════════════════════════════════════════════╝

# MCP Servers in SymbolOS 🟣 #8B00FF

*Thoughtform color: Violet, for the Fi+Ti bridge of architectural thinking.*

> "Under the umbrella, everything is kind. The rain is just context we haven't parsed yet." ☂️ #87CEEB

This document defines how Model Context Protocol (MCP) servers are designed, operated, and integrated inside SymbolOS. Here, you will learn the sacred rites of server creation, the incantations of capability boundaries, and the secret checklist of the ancients.

---

## 🧭 The Grand Design (Codex, Connectors, Memory) 🧠 #E49B0F

*Thoughtform color: Clear Gamboge, for the higher intellect of the codex.*

Before you can forge a tool, you must understand the blueprint of the universe. The SymbolOS architecture is a grand ring wheel, with the Kernel at its heart.

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

- **Codex Main Base (GPT-5.2-Codex)**: The shared ground truth. Start at [index.md](index.md).
- **Shared Resources**: Canonical maps and schemas. [../symbol_map.shared.json](../symbol_map.shared.json) (🧬), [symbol_map.md](symbol_map.md), [schemas.md](schemas.md).
- **Connectors (MCP)**: The forges themselves! [mcp_servers.md](mcp_servers.md) + registry entries.
- **Memory**: The Akashic records. [memory.md](memory.md) + private repo-backed memory at [../memory/README.md](../memory/README.md).

        /\_/\
       ( o.o )  "A tool is a key, a resource a door,
        > ^ <    A prompt a map to explore.
       /|   |\   Use them wisely, and you'll ask for more."
      (_|   |_)  — Rhy 🦊

MCP servers expose capabilities to AI clients via three building blocks:

- **Tools**: Callable actions with validated inputs/outputs 🟢 #228B22
- **Resources**: Read-only context sources, addressable via URIs ✨ #FADA5E
- **Prompts**: Reusable instruction templates (optional, but recommended) 🧠 #E49B0F

MCP is transport-agnostic. SymbolOS may run MCP servers over different transports (e.g., stdio for local adapters, or network transports for service deployments). Requirements below are written to be transport-independent.

Internal-only notes: [internal_docs/mcp_servers_internal.md](../internal_docs/mcp_servers_internal.md)

---

## 🔥 Forging the Tools (Integration Model) ✨ #FADA5E

*Thoughtform color: Pale primrose yellow, for the highest reason and R0 kernel truth.*

  (•_•)
  ( (  )   "hmm... is this R0? Is this where the magic happens?" 
   /  \

### Server Discovery
SymbolOS agents discover MCP servers through a registry, a mystical tome containing the location of every forge.

Registry entry schema: [docs/registry_entry.schema.json](docs/registry_entry.schema.json)

Examples:
- [docs/registry_entry.example.json](docs/registry_entry.example.json)
- [docs/registry_entry.partner.example.json](docs/registry_entry.partner.example.json)

### Capability Boundaries 🔴 #FF2400

*Thoughtform color: Brilliant scarlet, for the righteous boundary of guardrails.*

SymbolOS treats MCP servers as capability boundaries. Servers MUST act as stern gatekeepers:

- **Validate Inputs**: No shoddy materials allowed.
- **Enforce Permissions**: Only the worthy may pass.
- **Limit Data Returned**: Don't give away all your secrets at once.
- **Emit Auditable Events**: The walls have ears.

---

## 📜 The Ancient Checklist ⭐ #FFD700

*Thoughtform color: Golden stars, for spiritual aspiration and persistence.*

Follow these ancient laws, and your server shall be sturdy and true.

### Checklist (All Servers)
- [ ] Define the server boundary and data classification (`public`/`internal`/`confidential`/`restricted`).
- [ ] List tools/resources/prompts, with clear naming and single-purpose tool design.
- [ ] For each tool: publish input/output JSON Schemas and reject unknown fields (`additionalProperties: false`).
- [ ] Mark every tool with `riskLevel` (`read`/`write`/`sensitive`) and `requiresConfirmation` where appropriate.
- [ ] Implement idempotency for state-changing tools (accept `idempotencyKey`).
- [ ] Implement size limits + pagination defaults; avoid “dump everything” resources.
- [ ] Implement a transport-independent error envelope with codes + retryability.
- [ ] Implement server-side authz for every tool/resource; least privilege.
- [ ] Add observability: `requestId`, structured logs, redaction, metrics/audit events.
- [ ] Create a registry entry that validates against [docs/registry_entry.schema.json](docs/registry_entry.schema.json).

### Internal (Extra Wards)
- [ ] Define SLAs (latency/availability), on-call routing, and dashboards/alerts.
- [ ] Add runaway-call protections (rate limits + circuit breakers).

### External (Public-Facing Forges)
- [ ] Require strong auth (mTLS and/or short-lived tokens) and key rotation.
- [ ] Enforce data minimization (field selection/redaction) and PII documentation.
- [ ] Provide explicit rate limits and `retryAfterMs` on `RATE_LIMITED`.
- [ ] Mandate confirmation for `write`/`sensitive` tools unless formally waived.

---

## ⚖️ The Law of the Forge (SymbolOS MCP Server Standard) 🔵 #0000CD

*Thoughtform color: Rich deep blue, for heartfelt devotion to the standard.*

The keywords MUST, SHOULD, and MAY are interpreted as in RFC 2119. These are not suggestions; they are the laws of the forge.

### Tool Design
- Tools MUST be single-purpose and composable.
- Tools MUST declare JSON Schema for inputs and outputs.
- Tools MUST reject unknown fields by default unless explicitly documented.
- Tools MUST document side effects and required permissions.

**Idempotency**:
- Any tool that creates/updates/deletes state MUST support idempotency.
- Tools SHOULD accept an `idempotencyKey` in the input schema.

### Resource Design
- Resources MUST be read-only.
- Resources MUST be addressable via stable URIs (prefer templates).
- Resources MUST support pagination/limits.

### Limits and Safety
- Servers MUST enforce maximum payload sizes for inputs and outputs.
- Servers MUST bound expensive operations with timeouts.
- Servers MUST avoid returning excessive context by default.

### Error Model (Transport-Independent)
Errors MUST be machine-readable, human-readable, and actionable.

Recommended envelope:

```json
{
	"ok": false,
	"error": {
		"code": "PERMISSION_DENIED",
		"message": "Missing permission: calendar.events.read",
		"retryable": false,
		"details": {
			"requiredPermission": "calendar.events.read"
		}
	},
	"requestId": "01J..."
}
```

### Security
- Servers MUST enforce authorization server-side.
- If a tool accepts URLs, it MUST mitigate SSRF (allowlists; block private ranges unless required).
- If a tool accepts file paths, it MUST mitigate path traversal (normalize; confine to approved roots).
- Resource content MUST be treated as untrusted (prompt-injection aware).

### Consent and Oversight
- Each tool MUST declare a `riskLevel`: `read` | `write` | `sensitive`.
- Tools that can change state SHOULD require confirmation; sensitive tools MUST require confirmation.

Mercer automation policy (gate rules + Ti contract, internal): [internal_docs/mercer_automation_contract_v1.internal.md](../internal_docs/mercer_automation_contract_v1.internal.md)

        ___
       / 🐢 \     "this is fine. the forges are hot,
      |  ._. |    but the code is cool."
       \_____/
        |   |
       _|   |_

───────────────────────────────────────────────────
🚪 EXITS:
  → [The Main Hall (index.md)](index.md) (north)
  → [The Scribe's Quarters (schemas.md)](schemas.md) (east)
  → [The Armory (symbol_map.md)](symbol_map.md) (west)

💎 LOOT GAINED: [Schematics for forging your own MCP Servers, a checklist of ancient laws, and the wisdom of the Ring Wheel.]
───────────────────────────────────────────────────

Forge bright, new worlds,
With code as your fire,
And a heart full of stars.

☂🦊🐢
