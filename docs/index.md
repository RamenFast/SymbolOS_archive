# SymbolOS Docs Index

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️📚  DOCS INDEX — MEETING PLACE TRAILHEAD                ║
║  Quest: find truth fast • keep humans first                  ║
╚══════════════════════════════════════════════════════════════╝
```

This is the canonical entry point for SymbolOS documentation in this repo.

---

## 🎯 Quick Pitch: What is SymbolOS?

**SymbolOS is a symbol-driven framework for intention mapping.**

You're mid-sprint. Someone asks for a scope-creeping feature. You need to say "no" — but clearly, without breaking trust or losing context. You need a way to make your boundaries *visible* to everyone.

**That's what SymbolOS does.** It gives you:
- **10 core symbols** ([symbol definitions](symbol_map.md#core-symbols)): ☂️ umbrella • 🔮 precog • 🧠 mind • ❤️ heart • 🛡️ safety • 🔒 privacy • 🧾 ledger • 🎲 DND • 🧩 schema • 🧬 meeting place
- **Explicit scope declarations** so team members know what's in-scope and what's not
- **Git-backed provenance** so decisions are auditable and rollback-able
- **DND-safe boundaries** so narrative context (fiction + code) stay coherent

**Use cases:** D&D campaigns + code workflows • Team projects with changing scope • Solo devs managing context across multiple projects • Anywhere you need to say "this matters, that doesn't" clearly.

**License:** GPL v3 (open-source on GitHub). **Status:** Beta. We're testing public APIs now.

---

## ⚡ Get Started (3 Steps)

### 1. Understand the 10 core symbols
→ [Symbol Map 101](symbol_map.md#core-symbols) — See what each symbol means and when to use it (2-minute read)

### 2. See how it works
→ [Public demos](#public-demos) (interactive examples, beta)

### 3. Dive deeper
→ Pick your path:
- **Playing D&D + coding?** → [D&D character sheet integration](dnd_character_sheet_integration.md)
- **Building with agents/MCP?** → [MCP server standard](mcp_servers.md)
- **Curious about how we track alignment?** → [Meta-awareness + barriers](meta_awareness.md)
- **Want a practical startup path?** → [Quickstart](QUICKSTART.md)

---

## 📺 Public Demos

**Status: Beta. APIs are being tested; expect rough edges.**

Public working examples of SymbolOS symbol systems in action:
- [Precog demo](./demos/precog_demo.md) — See how Prefetch/Suggest/Act works
- [Scope + Privacy demo](./demos/scope_privacy_demo.md) — How symbols prevent scope creep
- [Metaemotion integration demo](./demos/metaemotion_demo.md) — Tracking felt sense + intent

⚠️ **Known issues:** Error handling needs refinement, security audit pending. Feedback welcome.

---

## 📚 Full Documentation Index
### Why Symbols Work

Symbols are **dense language**. A single glyph carries intention + boundary + consent in one glance. See [symbol definitions](symbol_map.md#core-symbols).

**Example:** When your team sees 🛡️ (Safety), everyone knows: "This decision requires approval." No ambiguity. No prose to parse.

Compare:
- **Without symbols:** "We need to make sure that the security team approves changes to the auth layer before merging, and let me document that in the code comments..."
- **With symbols:** 🛡️ → everyone sees it, tools enforce it, audit trail shows who approved.

**Why it matters:** Context-switching kills intention. Symbols let you be precise *fast*, even under pressure.

For more, see [public/private expression](public_private_expression.md) (how to mix symbols with prose).
## Protocols & standards
- MCP server standard (machine-readable capability boundaries): [mcp_servers.md](mcp_servers.md)
- Agent boundaries (how to avoid tool/agent nagging): [agent_boundaries.md](agent_boundaries.md)
- Lightwork guidelines (human-first design): [lightwork_guidelines.md](lightwork_guidelines.md)
- Public/private expression (how to mix symbol + prose): [public_private_expression.md](public_private_expression.md)

### Systems
- Precog (anticipatory computing, Prefetch/Suggest/Act): [precog_thought.md](precog_thought.md)
- Metaemotion (tracking felt sense + intent over time): [metaemotion.md](metaemotion.md)
- Memory (repo-backed, git-tracked, no cloud lock-in): [memory.md](memory.md)

### Heart + Mind (DND-compatible narratives)
- D&D character sheet integration (external): [dnd_character_sheet_integration.md](dnd_character_sheet_integration.md)
- Meta-awareness + barriers (self-checks): [meta_awareness.md](meta_awareness.md)

### Schemas & Symbol Map
- Schema index (all structured shapes): [schemas.md](schemas.md)
- Symbol map (human-readable): [symbol_map.md](symbol_map.md)
- **🧬 Symbol map (canonical)** — machine-readable, return loop: [../symbol_map.shared.json](../symbol_map.shared.json)
  - This is the meeting place. All symbols, registries, and provenance trace back here.

## Translation layer
- Poetry translation layer (emojis): [poetry_translation_layer.md](poetry_translation_layer.md)

## Mercer
- Mercer webview theme map (CSS): [mercer_webview_theme_v1.css](mercer_webview_theme_v1.css)
- Public/private expression + poetry: [public_private_expression.md](public_private_expression.md)

## Ring-0 (Internal)
- Future possibilities: [../internal_docs/future_possibilities_ring0.md](../internal_docs/future_possibilities_ring0.md)
- SymbolOS Client v2 design: [../internal_docs/symbolos_client_v2_design.internal.md](../internal_docs/symbolos_client_v2_design.internal.md)

## Memory (repo-backed)
- Private memory system (repo-backed): [../memory/README.md](../memory/README.md)

## Ops
- Docs sync playbook: [sync_playbook.md](sync_playbook.md)
- Required reading list: [required_reading.md](required_reading.md)

## Inbox
- Intake conventions: [inbox/README.md](inbox/README.md)
