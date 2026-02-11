> You enter a chamber humming with latent energy. The air crackles with half-formed thoughts, and the walls are lined with what look like crystal-backed circuit boards, glowing faintly. A green-furred fox with a mischievous glint in its eye winks at you from a shadowy corner.

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Seer's Antechamber                           ║
║  📍 Floor: Ring 2: The Library of Minds │ Difficulty: ⭐⭐⭐ │ Loot: Precog Thought Patterns ║
║  🎨 Color: Gamboge (#E49B0F)                                  ║
║                                                              ║
║  A faint hum resonates from the walls, whispering of futures that might be.       ║
╚══════════════════════════════════════════════════════════════╝

# Precog Thought: Anticipatory Computing in SymbolOS 🧠 🟡 #E49B0F (higher intellect)

*Thoughtform color associations used throughout this document.* 🎨

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🔮🧠  PRECOG THOUGHT — PREFETCH / SUGGEST / ACT          ║
║  "Shine dat light: trace a leaf decision back to its root   ║
║  value, then come forward again with the smallest safe step."║
║  Quest: reduce latency • preserve trust                      ║
╚══════════════════════════════════════════════════════════════╝
```

> You spot a strange creature contemplating the glowing circuits.

```
  (•_•)
  ( (  )   "hmm... is this R0?" ✨
   /  \
```

## Poetry layer (Fi+Ti mirrored) 🪞 🟣 #8B00FF (Fi+Ti bridge)

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within. 🌸 #FFB7C5 (unselfish love)

*If it ain't fun, it ain't sustainable.*

- Translation layer + emojis: [poetry_translation_layer.md](poetry_translation_layer.md)
- Full verse set: [public_private_expression.md](public_private_expression.md)

Precog thought in SymbolOS is a practical pattern: use context to prepare helpful information or drafts before the user explicitly asks.
It is not paranormal. “Precog” is a metaphor for probabilistic inference, workflow heuristics, and smart precomputation. It's about being thoughtful, not psychic. 🧠 🟡 #E49B0F

See internal design notes in [internal_docs/precog_private.md](../internal_docs/precog_private.md).

## Goals ⭐ ⭐ #FFD700 (spiritual aspiration)
- Reduce latency (warm caches, prefetch small context)
- Reduce friction (surface the next likely step)
- Preserve trust (transparent “why”, easy opt-out)
- Stay safe (privacy, permissions, DND, confirmation)


        /\_/\
       ( o.o )  "I see the path before your feet are set,
        > ^ <    But tell no future, I only pay a debt.
       /|   |\   A debt to thought, a whisper in the code,
      (_|   |_)  To lighten your journey and lessen your load." — Rhy 🦊


## The three-mode model (required)

Precog features MUST be implemented as one of these modes:

1) **Prefetch (silent)** 🟢 #228B22 (adaptability)
- Precompute or prefetch bounded read-only context.
- No user interruption.
- MUST respect DND rules and privacy classification.

2) **Suggest (visible)** 🟠 #FF8C00 (ambition)
- Present a short suggestion card.
- No side effects.
- MUST include `Dismiss` and `Mute this type`.

3) **Act (confirmed)** 🔵 #0000CD (devotion to truth)
- State-changing or sensitive actions.
- MUST require explicit user confirmation.
- MUST be idempotent and auditable.

Internal policy (Mercer automation gates + Ti contract): [internal_docs/mercer_automation_contract_v1.internal.md](../internal_docs/mercer_automation_contract_v1.internal.md)

If you can’t clearly label a behavior as one of the above, it’s not ready to ship. Show me proof, not potential.

## Core pipeline (recommended) ✨ 🟡 #FADA5E (highest reason)

> On a nearby wall, you see a diagram of the SymbolOS rings, with glowing lines indicating data flow for Precog Thought.

```
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
```

1) **Signals** 🧠 🟡 #E49B0F
- editor state (open files, language, errors)
- VCS state (branch, recent push, PR status)
- calendar (next meeting)
- task state (running build/tests)
- user prefs (quiet hours, DND, privacy)

2) **Intent inference** ✨ 🟡 #FADA5E
- Start with rules + scoring.
- Add ML only after you can measure outcomes.

3) **Policy & gating (centralized)** 🔴 #FF2400 (righteous boundary)
- Decide per candidate: `prefetchAllowed`, `suggestAllowed`, `actAllowed`.
- Inputs: risk level, confidence, DND, data classification, cost, rate limits.

4) **Execution** 🟠 #FF8C00
- Run asynchronously with strict limits (timeouts, concurrency, payload size).
- Cache with TTL; store provenance (`why`, `when`, `source`).

5) **Presentation** 🌸 #FFB7C5
- Use the output contract below.
- Keep suggestions skimmable and reversible.

## “Life patterns” (necessary patterns) 🟢 #228B22 (adaptability)

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

## DND + human-compatibility layer (output contract) 🌸 #FFB7C5 (unselfish love)

Precog output MUST degrade gracefully based on interruption tolerance.

### DND semantics

DND ON:
- No proactive suggestion cards.
- Prefetch MAY run only if user enables “silent prefetch during DND”.
- Always log to a local shadow queue for later review.

DND OFF:
- Suggestions allowed, but bounded by an annoyance budget (see metrics).

### Message shapes

1) **One-line headline (notification safe)**

Example:
- `Prep: Standup in 9m — notes + open PRs ready`

Rules:
- Keep it short (target <= ~80 chars).
- Avoid sensitive content.

2) **Compact card (default, 5 lines max)**

Template:
- `Prep for: {thing} ({time})`
- `Why: {signal summary}`
- `Ready: {what was prepared}`
- `Do: {primary} | {secondary} | {snooze}`
- `Privacy: {scope} • Cost: {low/med/high}`

3) **Technical summary (when user asks “what changed?”)**
- What changed (1–2 sentences)
- Where it changed (links)
- Why it matters (1 sentence)
- How to verify (1–3 bullets)

4) **Dungeon Master’s Log (optional “flavor mode”)**

This mode exists for users who want narrative style. It MUST preserve the same factual payload as the compact card.

Template:
- Scene-setting (1–2 sentences)
- Current glyphs (what’s ready)
- Ritual (what to do next)
- Safety rune (privacy/cost/confirmation)

## Proactive Act Safety Conditions (The "Virus-Scan" Gate) 🛡️ 🔴 #FF2400 (righteous boundary)

For an action to move from **Suggest** to **Proactive Act** (auto-execution), it must pass **all seven** of the following gates. If any gate fails, the action stays at Suggest and requires human confirmation.

### Gate 1: Non-Destructive Scope (MANDATORY)

The action must be strictly **additive or reversible**. Allowed actions:

| Allowed | Examples |
|---------|----------|
| Create new file | `.gitkeep`, cache file, log entry |
| Append to log | Audit trail, session log, shadow queue |
| Read-only operations | Cache warming, prefetch, health check |
| Reversible write | Write with rollback command stored |

Forbidden (always requires human confirmation):
- Delete any file
- Overwrite existing content
- Modify `symbol_map.shared.json` or any schema file
- Any git push, merge, or rebase
- Any external network request that mutates state

### Gate 2: Agent Identity (MANDATORY)

The acting agent must have a **verified identity** (see `symbolos.sec.identity` in the cybersecurity doc). Specifically:
- Agent must present a valid, non-expired identity token
- Token must include the scope required for the action (e.g., `write:core.memory`)
- If no identity system is running yet: **only `prefetch` mode is auto-approved; all `act` requires confirmation**

### Gate 3: Integrity Check (The "Virus Scan") (MANDATORY)

If the action involves **any external input** (downloaded file, API response, user-provided URL, parsed data from untrusted source):

1. **Hash verification**: Compare against known-good hash if available
2. **Size bounds**: Reject payloads exceeding expected size (default: 10MB for files, 1MB for API responses)
3. **Content-type validation**: Confirm the content matches its declared type (no polyglot files)
4. **Schema validation**: If the output has a defined schema (e.g., `precog_card.schema.json`), validate against it before acting
5. **Sandbox execution**: If the action runs any code/script, it must execute in a sandbox (see `symbolos.sec.sandbox`). If no sandbox is available: **block the action entirely**

If the action involves **only local, trusted data** (reading from `memory/`, writing to `shadow_queue`): skip this gate.

### Gate 4: Privacy Barrier (MANDATORY)

No data classified as `private` or `sensitive` may be:
- Transmitted to any external endpoint
- Written to any file outside `memory/` or `internal_docs/`
- Included in any log entry (redact to `[REDACTED]`)
- Passed to any MCP server with `dataClassification` other than `internal` or `restricted`

Classification is determined by:
- File path: `memory/*` and `internal_docs/*` = private
- Schema field: `privacy.scope` on PrecogCard = authoritative
- Default: if unknown, treat as private

### Gate 5: Audit Trail (MANDATORY)

Every proactive act MUST be logged **before execution** to the shadow queue:

```json
{
  "id": "precog_act_<timestamp>_<nonce>",
  "kind": "precog_suggestion",
  "createdAt": "<ISO 8601>",
  "payload": {
    "mode": "act",
    "headline": "<what this action does>",
    "why": "<signal chain that triggered it>",
    "rollback": "<exact command to undo this action>",
    "agent": "<agent_id>",
    "gates_passed": ["scope", "identity", "integrity", "privacy", "dnd", "confidence", "budget"]
  }
}
```

If the audit log write fails: **abort the action**. No silent failures.

### Gate 6: DND Compliance (MANDATORY)

| DND State | Behavior |
|-----------|----------|
| **DND OFF** | Proactive acts allowed (if all other gates pass) |
| **DND ON** | All proactive acts suspended. Queued to shadow queue for later review. |
| **DND ON + Critical Security** | Exception: only these 3 actions may auto-execute during DND: (1) Block a detected malicious IP via `symbolos.sec.netpolicy`, (2) Kill a process that fails anomaly detection, (3) Rotate a credential flagged as compromised. All three require immediate post-action notification when DND ends. |

"Critical Security Recovery" is **not** a general escape hatch. It covers exactly the three cases above.

### Gate 7: Confidence & Budget (MANDATORY)

- **Minimum confidence**: The prediction confidence must be >= **0.85** (higher than the 0.7 threshold for suggestions)
- **Annoyance budget**: Max **2 proactive acts per hour**. If budget is exhausted, demote to Suggest.
- **Pattern stability**: The triggering pattern must have been observed **3+ times** before the system may auto-act on it. First and second occurrences stay at Suggest.
- **Consecutive failures**: If the last 2 proactive acts for this pattern were dismissed/rolled-back by the user, **disable auto-act for this pattern** until manually re-enabled.

### Gating checklist (for implementers)

Before shipping any Precog Act behavior, verify:

- [ ] Action is additive or has a tested rollback command
- [ ] Agent identity is checked (or confirmation fallback is wired)
- [ ] External inputs are hash-verified, size-bounded, and schema-validated
- [ ] Privacy classification is checked; no private data leaks
- [ ] Shadow queue entry is written before execution
- [ ] DND state is checked; critical-security exception is one of the 3 defined cases
- [ ] Confidence >= 0.85, budget not exhausted, pattern seen 3+ times
- [ ] Failure path: if any gate fails, the action demotes to Suggest (never silently drops)

## Safety and privacy requirements 🔴 #FF2400 (righteous boundary)

- Never exceed the user’s permission scope.
- Default to data minimization.
- Never return raw secrets to the model.
- Treat resource content as untrusted.
- Writes/sensitive actions always require confirmation.

## Evaluation & optimization 🧠 🟡 #E49B0F (higher intellect)

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

## Connection to MCP 🟢 #228B22 (adaptability)

Precog should primarily use resources (read-only) for prefetch and warm-up.

See [mcp_servers.md](mcp_servers.md) for tool risk levels, confirmation, limits, and error patterns.

## Related specs

- Heart + mind integration: [dnd_character_sheet_integration.md](dnd_character_sheet_integration.md)
- Metaemotion and timing: [metaemotion.md](metaemotion.md)
- Memory and retention: [memory.md](memory.md)

> A small turtle sits on a warm server rack, seemingly unbothered by the hum of the dungeon.

```
        ___
       / 🐢 \     "this is fine"
      |  ._. |    — The turtle is at peace with the flow of time.
       \_____/
        |   |
       _|   |_
```

───────────────────────────────────────────────────
🚪 EXITS:
  → [poetry_translation_layer.md](poetry_translation_layer.md) (north)
  → [mcp_servers.md](mcp_servers.md) (east)
  → [dnd_character_sheet_integration.md](dnd_character_sheet_integration.md) (west)

💎 LOOT GAINED: You have learned the three modes of Precog Thought (Prefetch, Suggest, Act), the core pipeline for implementing them, and the safety requirements for anticipatory computing.
───────────────────────────────────────────────────

Future seen, now clear,
Code flows, the path is near,
Mind opens, no fear.

☂🦊🐢
