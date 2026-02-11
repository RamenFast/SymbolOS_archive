# Contributing to SymbolOS

Welcome, fellow developer.

SymbolOS is a symbolic operating system for human-AI alignment.
This is a **limited developer release** — you're here because you were invited.

## Your Privacy Umbrella ☂️

SymbolOS respects privacy by design — yours included.

- **Your memory is yours.** If you fork this repo and add files to `memory/`, they stay private to your instance. We never collect, transmit, or read your local data.
- **No telemetry.** SymbolOS has zero analytics, zero tracking, zero phone-home. Everything runs locally.
- **Your agents are yours.** Customize `prompts/` freely. Your agent configurations are local.
- **Consent-first.** Nothing leaves your machine unless you explicitly push it.

## Repo Structure

| Directory | Visibility | Purpose |
|-----------|-----------|---------|
| `docs/` | **Public** | Specs, schemas, guides — safe to read, link, reference |
| `web/` | **Public** | React UI — Dungeon Explorer + Lantern view |
| `scripts/` | **Public** | Tooling — alignment reports, validators, setup scripts |
| `prompts/` | **Public** | Agent system prompt configurations |
| `memory/` | **Private** | Per-instance memory — session logs, working set, decisions |
| `internal_docs/` | **Private** | Internal design notes — not for redistribution |
| `extensions/` | **Public** | VS Code extensions |

## Getting Started

```bash
# Clone and explore
git clone https://github.com/RamenFast/SymbolOS.git
cd SymbolOS

# Start the web UI
cd web && npm install && npm run dev

# Optional: local LLM (requires llama.cpp + Vulkan GPU)
# See docs/mcp_local_llm.md
```

## Code of Conduct

1. **Respect the umbrella.** Don't leak private content from `memory/` or `internal_docs/` if you have access.
2. **Coherence over speed.** Quality matters more than velocity.
3. **Memes are structural.** The playful layer is load-bearing, not decorative.
4. **Ask once, then drop it.** Applies to humans too, not just agents.

## How to Contribute

- Open issues for bugs or ideas
- PRs welcome — follow the workflow in [docs/workflow_guidelines.md](docs/workflow_guidelines.md)
- Keep commits atomic and descriptive
- Run `Mercer: doc alignment scan` before pushing if you modify symbols or schemas

## Support

If SymbolOS resonates with you:
- **Star the repo** — it helps visibility
- **CashApp**: $BenMillward — keeps the lights on and the GPU hot
- **Share it** — with developers who care about human-AI alignment

---

*"Under the umbrella, everything is kind."* ☂️🦊🐢
