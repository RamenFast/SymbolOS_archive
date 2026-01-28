# Precog Thought: Anticipatory Computing in SymbolOS

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🔮🧠  PRECOG THOUGHT — PREFETCH / SUGGEST / ACT          ║
║  Quest: reduce latency • preserve trust                      ║
╚══════════════════════════════════════════════════════════════╝
```

Precog thought in SymbolOS is a practical pattern: use context to prepare helpful information or drafts before the user explicitly asks.
It is not paranormal. “Precog” is a metaphor for probabilistic inference, workflow heuristics, and smart precomputation.

See internal design notes in [internal_docs/precog_private.md](../internal_docs/precog_private.md).

## Goals
- Reduce latency (warm caches, prefetch small context)
- Reduce friction (surface the next likely step)
- Preserve trust (transparent “why”, easy opt-out)
- Stay safe (privacy, permissions, DND, confirmation)

## The three-mode model (required)

Precog features MUST be implemented as one of these modes:

1) Prefetch (silent)
- Precompute or prefetch bounded read-only context.
- No user interruption.
- MUST respect DND rules and privacy classification.

2) Suggest (visible)
- Present a short suggestion card.
- No side effects.
- MUST include `Dismiss` and `Mute this type`.

3) Act (confirmed)
- State-changing or sensitive actions.
- MUST require explicit user confirmation.
- MUST be idempotent and auditable.

Internal policy (Mercer automation gates + Ti contract): [internal_docs/mercer_automation_contract_v1.internal.md](../internal_docs/mercer_automation_contract_v1.internal.md)

If you can’t clearly label a behavior as one of the above, it’s not ready to ship.

## Core pipeline (recommended)

1) Signals
- editor state (open files, language, errors)
- VCS state (branch, recent push, PR status)
- calendar (next meeting)
- task state (running build/tests)
- user prefs (quiet hours, DND, privacy)

2) Intent inference
- Start with rules + scoring.
- Add ML only after you can measure outcomes.

3) Policy & gating (centralized)
- Decide per candidate: `prefetchAllowed`, `suggestAllowed`, `actAllowed`.
- Inputs: risk level, confidence, DND, data classification, cost, rate limits.

4) Execution
- Run asynchronously with strict limits (timeouts, concurrency, payload size).
- Cache with TTL; store provenance (`why`, `when`, `source`).

5) Presentation
- Use the output contract below.
- Keep suggestions skimmable and reversible.

## “Life patterns” (necessary patterns)

Precog should learn and apply stable life patterns rather than one-off tricks.

### Pattern types
- Temporal: before meetings, morning start-up, end-of-day wrap-up
- Project: after push → open PR, after failure → open docs + logs
- Contextual: when editing config → show env docs, when typing TODO → suggest issue template
- Recovery: after repeated errors → offer minimal repro scaffolding

### Stability rules
- Prefer patterns that remain useful across days/weeks.
- Do not lock onto a pattern until it repeats (e.g., 3+ times) or user explicitly enables it.
- Treat dismissals as high-signal (“this was wrong”); treat accepts as higher-signal (“this was valuable”).

## DND + human-compatibility layer (output contract)

Precog output MUST degrade gracefully based on interruption tolerance.

### DND semantics

DND ON:
- No proactive suggestion cards.
- Prefetch MAY run only if user enables “silent prefetch during DND”.
- Always log to a local shadow queue for later review.

DND OFF:
- Suggestions allowed, but bounded by an annoyance budget (see metrics).

### Message shapes

1) One-line headline (notification safe)

Example:
- `Prep: Standup in 9m — notes + open PRs ready`

Rules:
- Keep it short (target <= ~80 chars).
- Avoid sensitive content.

2) Compact card (default, 5 lines max)

Template:
- `Prep for: {thing} ({time})`
- `Why: {signal summary}`
- `Ready: {what was prepared}`
- `Do: {primary} | {secondary} | {snooze}`
- `Privacy: {scope} • Cost: {low/med/high}`

3) Technical summary (when user asks “what changed?”)
- What changed (1–2 sentences)
- Where it changed (links)
- Why it matters (1 sentence)
- How to verify (1–3 bullets)

4) Dungeon Master’s Log (optional “flavor mode”)

This mode exists for users who want narrative style. It MUST preserve the same factual payload as the compact card.

Template:
- Scene-setting (1–2 sentences)
- Current glyphs (what’s ready)
- Ritual (what to do next)
- Safety rune (privacy/cost/confirmation)

## Safety and privacy requirements

- Never exceed the user’s permission scope.
- Default to data minimization.
- Never return raw secrets to the model.
- Treat resource content as untrusted.
- Writes/sensitive actions always require confirmation.

## Evaluation & optimization

### Metrics
- Accept rate / dismiss rate
- “Mute this type” rate
- Time-to-next-action reduction (proxy)
- Prefetch hit rate
- Safety events (confirmation required, denied attempts)

### Optimization levers
- Prefer precision over recall early.
- Implement an annoyance budget (e.g., max 2 suggestions/hour) and decay it based on dismissals.
- Use shadow mode to measure without interrupting.

## Connection to MCP

Precog should primarily use resources (read-only) for prefetch and warm-up.

See [mcp_servers.md](mcp_servers.md) for tool risk levels, confirmation, limits, and error patterns.

## Related specs

- Heart + mind integration: [dnd_character_sheet_integration.md](dnd_character_sheet_integration.md)
- Metaemotion and timing: [metaemotion.md](metaemotion.md)
- Memory and retention: [memory.md](memory.md)
