# MCP Servers in SymbolOS

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🛠️🛡️  MCP SERVERS — CAPABILITY BOUNDARIES               ║
║  Quest: tools with gates • resources with limits             ║
╚══════════════════════════════════════════════════════════════╝
```

## Poetry layer (Fi+Ti mirrored) 🪞

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [poetry_translation_layer.md](poetry_translation_layer.md)
- Full verse set: [public_private_expression.md](public_private_expression.md)

This document defines how Model Context Protocol (MCP) servers are designed, operated, and integrated inside SymbolOS.

MCP servers expose capabilities to AI clients via three building blocks:

- Tools: callable actions with validated inputs/outputs
- Resources: read-only context sources, addressable via URIs
- Prompts: reusable instruction templates (optional, but recommended)

MCP is transport-agnostic. SymbolOS may run MCP servers over different transports (e.g., stdio for local adapters, or network transports for service deployments). Requirements below are written to be transport-independent.

Internal-only notes: [internal_docs/mcp_servers_internal.md](../internal_docs/mcp_servers_internal.md)

---

## Integration model (SymbolOS)

### Server discovery
SymbolOS agents discover MCP servers through a registry.

Registry entry schema: [docs/registry_entry.schema.json](registry_entry.schema.json)

Examples:
- [docs/registry_entry.example.json](registry_entry.example.json)
- [docs/registry_entry.partner.example.json](registry_entry.partner.example.json)

### Capability boundaries
SymbolOS treats MCP servers as capability boundaries. Servers MUST:

- Validate inputs
- Enforce permissions
- Limit data returned
- Emit auditable events for sensitive actions

---

## New server checklist (copy/paste)

### Checklist (all servers)
- [ ] Define the server boundary and data classification (`public`/`internal`/`confidential`/`restricted`).
- [ ] List tools/resources/prompts, with clear naming and single-purpose tool design.
- [ ] For each tool: publish input/output JSON Schemas and reject unknown fields (`additionalProperties: false`).
- [ ] Mark every tool with `riskLevel` (`read`/`write`/`sensitive`) and `requiresConfirmation` where appropriate.
- [ ] Implement idempotency for state-changing tools (accept `idempotencyKey`).
- [ ] Implement size limits + pagination defaults; avoid “dump everything” resources.
- [ ] Implement a transport-independent error envelope with codes + retryability.
- [ ] Implement server-side authz for every tool/resource; least privilege.
- [ ] Add observability: `requestId`, structured logs, redaction, metrics/audit events.
- [ ] Create a registry entry that validates against [docs/registry_entry.schema.json](registry_entry.schema.json).

### Internal (extra)
- [ ] Define SLAs (latency/availability), on-call routing, and dashboards/alerts.
- [ ] Add runaway-call protections (rate limits + circuit breakers).

### External (extra)
- [ ] Require strong auth (mTLS and/or short-lived tokens) and key rotation.
- [ ] Enforce data minimization (field selection/redaction) and PII documentation.
- [ ] Provide explicit rate limits and `retryAfterMs` on `RATE_LIMITED`.
- [ ] Mandate confirmation for `write`/`sensitive` tools unless formally waived.

---

## SymbolOS MCP server standard

The keywords MUST, SHOULD, and MAY are interpreted as in RFC 2119.

### Tool design
- Tools MUST be single-purpose and composable.
- Tools MUST declare JSON Schema for inputs and outputs.
- Tools MUST reject unknown fields by default unless explicitly documented.
- Tools MUST document side effects and required permissions.

Idempotency:
- Any tool that creates/updates/deletes state MUST support idempotency.
- Tools SHOULD accept an `idempotencyKey` in the input schema.

### Resource design
- Resources MUST be read-only.
- Resources MUST be addressable via stable URIs (prefer templates).
- Resources MUST support pagination/limits.

### Limits and safety
- Servers MUST enforce maximum payload sizes for inputs and outputs.
- Servers MUST bound expensive operations with timeouts.
- Servers MUST avoid returning excessive context by default.

### Error model (transport-independent)

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

### Consent and oversight
- Each tool MUST declare a `riskLevel`: `read` | `write` | `sensitive`.
- Tools that can change state SHOULD require confirmation; sensitive tools MUST require confirmation.

Mercer automation policy (gate rules + Ti contract, internal): [internal_docs/mercer_automation_contract_v1.internal.md](../internal_docs/mercer_automation_contract_v1.internal.md)

