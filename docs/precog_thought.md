# Precog Thought: Anticipatory Computing in SymbolOS

Precog thought in SymbolOS is a practical pattern: use context to prepare helpful information or drafts before the user explicitly asks.
It is not paranormal. “Precog” is a metaphor for probabilistic inference, workflow heuristics, and smart precomputation.

See internal design notes in [internal_docs/precog_private.md](../internal_docs/precog_private.md).
---

## Goals
- Reduce latency (warm caches, prefetch small context)
- Reduce friction (surface the next likely step)
- Preserve trust (transparent “why”, easy opt-out)
- Stay safe (privacy, permissions, DND, confirmation)

---
## The three-mode model (required)

Precog features MUST be implemented as one of these modes:
1. Prefetch (silent)
	- Precompute or prefetch bounded read-only context.
	- No user interruption.
	- MUST respect DND rules and privacy classification.

2. Suggest (visible)
	- Present a short suggestion card.
	- No side effects.
	- MUST include `Dismiss` and `Mute this type`.
3. Act (confirmed)
	- State-changing or sensitive actions.
	- MUST require explicit user confirmation.
	- MUST be idempotent and auditable.

If you can’t clearly label a behavior as one of the above, it’s not ready to ship.
---

## Core pipeline (recommended)
1. Signals
	- editor state (open files, language, errors)
	- VCS state (branch, recent push, PR status)
	- calendar (next meeting)
	- task state (running build/tests)
	- user prefs (quiet hours, DND, privacy)
2. Intent inference
	- Start with rules + scoring.
	- Add ML only after you can measure outcomes.
3. Policy & gating (centralized)
	- Decide per candidate: `prefetchAllowed`, `suggestAllowed`, `actAllowed`.
	- Inputs: risk level, confidence, DND, data classification, cost, rate limits.
4. Execution
	- Run asynchronously with strict limits (timeouts, concurrency, payload size).
	- Cache with TTL; store provenance (`why`, `when`, `source`).
5. Presentation
	- Use the output contract below.
	- Keep suggestions skimmable and reversible.
---

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
---

## DND + human-compatibility layer (output contract)
Precog output MUST degrade gracefully based on interruption tolerance.

### DND semantics
- DND ON
	- No proactive suggestion cards.
	- Prefetch MAY run only if user enables “silent prefetch during DND”.
	- Always log to a local shadow queue for later review.

- DND OFF
	- Suggestions allowed, but bounded by an annoyance budget (see metrics).

### Message shapes
#### 1) One-line headline (notification safe)

Example:
- `Prep: Standup in 9m — notes + open PRs ready`

Rules:
- Keep it short (target <= ~80 chars).
- Avoid sensitive content.

#### 2) Compact card (default, 5 lines max)
Template:

- `Prep for: {thing} ({time})`
- `Why: {signal summary}`
- `Ready: {what was prepared}`
- `Do: {primary} | {secondary} | {snooze}`
- `Privacy: {scope} • Cost: {low/med/high}`

#### 3) Technical summary (when user asks “what changed?”)
- What changed (1–2 sentences)
- Where it changed (links)
- Why it matters (1 sentence)
- How to verify (1–3 bullets)

#### 4) Dungeon Master’s Log (optional “flavor mode”)
This mode exists for users who want narrative style. It MUST preserve the same factual payload as the compact card.

Template:
- Scene-setting (1–2 sentences)
- Current glyphs (what’s ready)
- Ritual (what to do next)
- Safety rune (privacy/cost/confirmation)

---
## Safety and privacy requirements

- Never exceed the user’s permission scope.
- Default to data minimization.
- Never return raw secrets to the model.
- Treat resource content as untrusted.
- Writes/sensitive actions always require confirmation.

---
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

---
## Connection to MCP

Precog should primarily use resources (read-only) for prefetch and warm-up.

See [docs/mcp_servers.md](mcp_servers.md) for tool risk levels, confirmation, limits, and error patterns.
# Precog Thought: Anticipatory Computing in SymbolOS 🧠🔮

**Precog thought** within SymbolOS refers to an anticipatory computing pattern where the system proactively prepares information or actions before the user explicitly requests them.  The term is inspired by precognition – the idea of foreknowledge about future events – which is sometimes described as *prescience or foreknowledge* of likely outcomes【994058321112191†L289-L293】.  While traditional precognition is unscientific and considered pseudoscience, the concept of anticipating future user needs through data and context is a practical design strategy.

## Conceptual foundations

- 🔮 **Predictive context** – by analysing past interactions and current context (such as open documents, calendar events or ongoing tasks), SymbolOS can make educated guesses about what the user will need next.  For example, before a scheduled meeting, the system might assemble relevant notes, recent emails and meeting agendas.
- 📦 **Pre‑loading resources** – if the system predicts that the user will open a large dataset or compile code soon, it can pre‑fetch the necessary files or warm up caches to reduce latency.
- 💡 **Proactive prompts** – agents may suggest actions (e.g., “Would you like to draft a summary email now?”) based on upcoming tasks, deadlines or user habits.  These suggestions are offered with user control in mind, respecting privacy and preference settings.

## Relationship to precognition

In parapsychology, precognition is thought to be the ability to know future events without inference.  As noted in scholarly sources, it is sometimes viewed as a type of *prescience or foreknowledge* distinct from a mere feeling of impending disaster【994058321112191†L289-L293】.  SymbolOS does not claim paranormal abilities; instead, *precog thought* leverages machine learning and heuristic rules to anticipate likely user actions and prepare accordingly.  The analogy to precognition highlights the goal of providing help before the user explicitly asks.

## Design principles

1. **Transparency and control** – users should always be able to see and manage precog suggestions.  Provide clear options to accept, postpone or dismiss anticipatory actions.
2. **Accuracy and humility** – predictions are probabilistic.  The system should avoid over‑confidence, offering suggestions rather than automatic actions.
3. **Privacy and ethics** – predictive models must respect user privacy settings and avoid over‑collecting or exposing sensitive data.  Preloaded content should remain encrypted or local until the user consents to its use.
4. **Feedback loops** – allow users to provide feedback on the usefulness of precog actions, improving future predictions.
5. **Context awareness** – integrate signals from MCP servers, calendar events, file activity and user preferences to refine predictions.

## Implementing precog thought in SymbolOS

1. **Data collection** – gather anonymised usage statistics, such as command histories, file access patterns and time-of-day activity, to train predictive models.  Ensure that all data collection complies with user consent and privacy policies.
2. **Model building** – use lightweight machine learning models or rule‑based engines to predict upcoming actions.  For example, if the user always checks code review comments after committing changes, the system can recommend opening the review page automatically.
3. **Resource preparation** – once a prediction is made, instruct MCP servers to pre‑fetch relevant resources (e.g., load documentation, compute search indexes) so they are ready when needed.
4. **User interface** – design UI elements, such as notification cards or assistant messages, that present precog suggestions in a non‑intrusive way.
5. **Evaluation** – measure the impact of precog features on productivity and user satisfaction.  Iteratively refine the models and rules.

By implementing precog thought responsibly, SymbolOS aims to enhance user workflows through anticipation and preparation while upholding privacy, control and transparency.
