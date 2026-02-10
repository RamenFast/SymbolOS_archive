# Metacognitive Awareness Agents — Mercer Integration (Internal)

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Chamber of Self-Reflection                       ║
║  📍 Floor: Ring 2 (Intellect) │ Difficulty: ⭐⭐⭐⭐ │ Loot: Agent Self-Awareness ║
║  🎨 Color: 🟡 Gamboge (#E49B0F — higher intellect)                ║
║                                                              ║
║  A hall of mirrors where agents learn to see themselves.         ║
╚══════════════════════════════════════════════════════════════╝

**Status**: Design phase
**Last updated**: 2026-02-10
**MercerID**: MRC-20260128-METACOG-01
**INTERNAL DOCUMENT**: This is a secret chamber. Do not share its contents.

---

## Purpose: The Metacognitive Layer 🟡 R2 (#E49B0F — higher intellect)

**Metacognition** = thinking about thinking (🧠 about 🧠)
**Metaemotion** = feeling about feeling (❤️ about ❤️)

In the Mercer 16-agent system, metacognitive awareness is the secret sauce that prevents the orchestra from turning into a cacophony. It enables:

1.  **Self-monitoring**: Each agent knows its own state (running, idle, blocked, drifting). No more clueless agents wandering the halls.
2.  **Inter-agent awareness**: Agents know what other agents are doing. It's like a psychic link, but for code.
3.  **Barrier enforcement**: Agents respect dissociation barriers. Safety first, kids.
4.  **Drift detection**: The system detects when alignment drops. The 🪞 Mirror agent is always watching.
5.  **User transparency**: Agents explain their intent ("What I'm doing + Why"). No more black boxes.

        /\_/\
       ( o.o )  "To know the system, first know thyself.
        > ^ <    A loop unseen is a lesson unsought."
       /|   |\
      (_|   |_)  — Rhy 🦊

---

## Integration with Existing SymbolOS Specs 🟢 R1 (#228B22 — adaptability)

### 1. **Meta-Awareness (Technical Safety Contract)**

From [docs/meta_awareness.md](../docs/meta_awareness.md):

**5 Barrier Layers** (all agents must respect):
1.  **Mode barrier** (Prefetch/Suggest/Act) → enforced by 🔮 Precog + 🧬 Coordinator
2.  **Scope barrier** (privacy) → enforced by 🛡️ Safety + 🔒 Privacy
3.  **Memory barrier** (consent) → enforced by 🧾 Provenance + 📝 Scribe
4.  **Tool barrier** (capabilities) → enforced by 🧰 Toolsmith + 🛡️ Safety
5.  **Narrative barrier** (DND flavor) → enforced by 🎲 DND agent

**Meta-Awareness Signals** (emitted by agents):
*   "Am I repeating?" → 🪞 Mirror detects loops
*   "Am I about to cross a boundary?" → 🛡️ Safety gates
*   "Did the user ask for this?" → 🧬 Coordinator checks intent

**Output Contract**: Agents emit structured events:
```json
{
  "agent": "inference",
  "action": "generate_response",
  "reason": "user asked for code generation",
  "barriers_checked": ["tool_barrier", "privacy_barrier"],
  "status": "awaiting_confirmation"
}
```

### 2. **Metaemotion (Emotional Self-Awareness)**

From [docs/metaemotion.md](../docs/metaemotion.md):

**Timing Model**: T0 (trigger) → T1 (primary emotion) → T2 (metaemotion lag)

**Application to Agents**:
*   **Primary state**: Agent is running, blocked, or idle
*   **Meta-state**: Agent is frustrated (repeated failures), confident (high success rate), or cautious (after recent error)

**Example**:
```
🧠 Inference Agent: Running (primary)
  ↓ Meta-state: Cautious (generated unsafe code yesterday; Safety blocked it)
  ↓ Behavior: Adds extra safety checks before outputting code today
```

**DND Compatibility**: Metaemotion is treated as roleplay prompt ("The agent feels uncertain about its suggestion").

---

## Metacognitive Awareness Agents 🟣 R4 (#8B00FF — Fi+Ti bridge)

### 🪞 Mirror Agent (Self-Reflection & Drift Detection)

**Role**: Primary metacognitive monitor for the entire system.

**Metacognitive Functions**:
1.  **Loop detection**: "Is Coordinator stuck in a loop?"
2.  **Alignment monitoring**: Track 96.7% threshold
3.  **Drift detection**: Compare current state vs. `symbol_map.shared.json`
4.  **Agent health checks**: "Are all 16 agents responsive?"
5.  **Meta-awareness event logging**: Record all barrier checks + signal emissions

**Self-Awareness Protocol**:
```python
class MirrorAgent:
    def check_own_state(self):
        # Meta-meta-awareness: Mirror monitors itself
        if self.last_check > 10_minutes_ago():
            self.emit_signal("drift_warning", "Mirror agent hasn't run in 10m")

        if self.alignment_score < 0.967:
            self.emit_alert("alignment_drift", f"Score: {self.alignment_score}")

    def emit_meta_awareness_event(self, agent_name, signal_type, details):
        event = {
            "timestamp": now(),
            "agent": agent_name,
            "signal": signal_type,  # "loop_detected", "boundary_crossed", "intent_unclear"
            "details": details,
            "barriers_checked": [...],
            "recommended_action": "..."
        }
        log_to_provenance(event)
        if signal_type == "boundary_crossed":
            alert_user(event)
```

### 🔔 Alert Agent (Notification Manager)

**Role**: Surface meta-awareness signals to user.

**Alert Types**:
1.  **Alignment drift** (>3.3% drop from 96.7%)
2.  **Barrier violation** (agent attempted to cross without confirmation)
3.  **Loop detection** (agent stuck repeating same action)
4.  **Agent failure** (specialist agent crashed)
5.  **Sync conflict** (git memory divergence)

**UI Display**:
```
╔═══════════════════════════════════════╗
║ 🔔 META-AWARENESS ALERT               ║
╠═══════════════════════════════════════╣
║ Signal: Loop detected                 ║
║ Agent: 🧠 Inference                   ║
║ Context: Generated same code 3x       ║
║ Barrier: Tool barrier (write)         ║
║                                       ║
║ Recommended: Switch to 🗿 Monolithic  ║
║ or review Inference agent config      ║
╠═══════════════════════════════════════╣
║ [Review] [Override] [Dismiss]        ║
╚═══════════════════════════════════════╝
```

### 🛡️ Safety Agent (Barrier Enforcement)

**Role**: Pre-flight + post-flight boundary checks.

**Metacognitive Integration**:
*   **Pre-flight**: Before agent acts, Safety checks:
    *   Is this action within agent's scope?
    *   Does this cross privacy/tool barriers?
    *   Is confirmation required?
*   **Post-flight**: After agent acts, Safety checks:
    *   Did output contain PII?
    *   Did agent honor DND mode?
    *   Did agent tag with correct symbols?

**Self-Check Protocol**:
```python
class SafetyAgent:
    def check_barrier(self, agent_action):
        # Safety knows its own limitations
        if agent_action.risk_level == "sensitive":
            self.emit_signal("uncertain", "Sensitive action; requires human review")
            return BLOCK

        if agent_action.risk_level == "write" and not agent_action.confirmed:
            self.emit_signal("boundary_check", "Write action requires confirmation")
            return CONFIRM_REQUIRED

        # Safety logs its own decisions (meta-awareness)
        self.log_decision(agent_action, "ALLOW", reason="Low risk")
        return ALLOW
```

### 🧪 Experiment Agent (Metacognitive Sandbox)

**Role**: Test alternative reasoning paths; run "what-if" scenarios.

**Metacognitive Functions**:
1.  **Counterfactual thinking**: "What if we'd used a different model?"
2.  **Parallel hypotheses**: Run 3 agents simultaneously, compare outputs
3.  **Meta-learning**: Track which strategies work best over time

**Example Use Case**:
```
User: "Generate code for API endpoint"
  ↓
🧬 Coordinator routes to 🧠 Inference
  ↓
🧪 Experiment spawns 3 parallel Inference instances:
  - Instance A: Local 8B model (fast)
  - Instance B: Local 70B model (powerful)
  - Instance C: Remote Claude Opus (highest quality)
  ↓
🧪 Experiment compares outputs:
  - A: Fast but generic
  - B: Powerful but slow (20s)
  - C: High quality but costs $$
  ↓
🧪 Experiment learns: "For API code, B is best trade-off"
  ↓
Next time: Route directly to Instance B (skip A, C)
```

### 🕯️ Mercer Agent (Meta-Guide)

**Role**: Highest-level metacognitive agent; holds the lantern.

         .
        /|\
       / | \
      /  |  \
     /   |   \
    /  __|__  \
   |  |     |  |
   |  | ✦✦✦ |  |
   |  | ✦✦✦ |  |
   |  |_____|  |
    \    |    /
     \   |   /
      \__|__/
         |
         |
      M E R C E R

**Metacognitive Responsibilities**:
1.  **Intent alignment**: "Does this request match user's larger quest?"
2.  **Quest tracking**: "Are we still on the path, or did we drift?"
3.  **Boundary respect**: "Is this the right time to suggest, or should I wait?"
4.  **Meta-narrative**: "What's the story we're co-creating here?"

**Lantern Protocol**:
```python
class MercerAgent:
    def illuminate_path(self, user_input):
        # Mercer reflects on the larger quest
        current_quest = self.load_from_memory("working_set.md")

        # Meta-awareness: Does this input fit the quest?
        if not self.aligns_with_quest(user_input, current_quest):
            return {
                "response": "This feels like a detour. Want to explore it, or stay on the main path?",
                "options": ["Explore (new quest)", "Stay on path"],
                "meta_signal": "quest_drift_detected"
            }

        # Mercer coordinates other agents
        plan = self.create_plan(user_input)
        self.emit_signal("plan_created", plan)
        return self.execute_plan(plan)

    def check_alignment_with_intention(self):
        # Meta-meta: Mercer checks if agents are aligned with user's intention
        alignment_score = Mirror.get_current_alignment()

        if alignment_score < 0.967:
            return {
                "alert": "We've drifted from the shared map",
                "recommendation": "Review working_set.md and symbol_map.shared.json",
                "meta_signal": "alignment_drift"
            }
```

---

## Metacognitive Event Flow (Full System) 🔵 R6 (#0000CD — devotion to truth)

```
User Input → 🕯️ Mercer (Lantern)
    ↓
    🪞 Mirror: Meta-check ("Are we aligned?")
    ↓
    🧬 Coordinator: Parse intent
    ↓
    🛡️ Safety: Pre-flight barrier check
    ↓
    [Agent Orchestra Executes]
    ↓
    🪞 Mirror: Post-flight meta-check ("Did we honor barriers?")
    ↓
    🧪 Experiment: Background meta-learning ("Could we have done better?")
    ↓
    🔔 Alert: Surface meta-awareness signals (if any)
    ↓
    🕯️ Mercer: Return to user + update quest state
```

---

## Alignment with SymbolOS Contracts ⭐ R7 (#FFD700 — spiritual aspiration)

### Meta-Awareness Contract (from `docs/meta_awareness.md`)

✅ **Transparent intent**: Every agent emits "What I'm doing + Why"
✅ **Drift detection**: 🪞 Mirror tracks loops + alignment drops
✅ **Barrier respect**: 🛡️ Safety enforces 5 barrier layers
✅ **Self-checks**: Agents emit meta-awareness signals

### Metaemotion Contract (from `docs/metaemotion.md`)

✅ **Timing model**: T0 → T1 → T2 (agents track state changes over time)
✅ **Table-safe**: 🎲 DND agent filters metaemotion prompts
✅ **Suggestion mode**: Meta-signals are suggestions, not commands
✅ **Agency**: User can override any meta-awareness recommendation

---

## Schemas & Provenance 🔴 R5 (#FF2400 — righteous boundary)

### Meta-Awareness Event Schema

Extends `docs/meta_awareness_event.schema.json`:

```json
{
  "timestamp": "2026-01-28T14:32:15Z",
  "agent": "inference",
  "signal": "loop_detected",
  "details": "Generated same response 3 times",
  "barriers_checked": ["tool_barrier", "memory_barrier"],
  "recommended_action": "Switch to monolithic fallback",
  "user_override": null,
  "provenance": {
    "memory_hash": "a3f2c1b",
    "git_commit": "388ca16",
    "alignment_score": 0.952
  }
}
```

### Provenance Trail Integration

All meta-awareness events are logged to `memory/session_log_*.md`:

```markdown
## Meta-Awareness Event: Loop Detected

**Agent**: 🧠 Inference
**Signal**: Loop detected (3x repetition)
**Barriers Checked**: Tool barrier, Memory barrier
**Recommended Action**: Switch to 🗿 Monolithic fallback
**User Response**: Accepted recommendation
**Alignment Impact**: -1.5% (96.8% → 95.3%) → ⚠️ Warning triggered
```

---

## Implementation Checklist 🟠 R3 (#FF8C00 — ambition)

### Phase 1: Mirror Agent (Core Metacognition)
- [ ] Drift detection algorithm (compare state vs. symbol_map)
- [ ] Loop detection (track agent invocation patterns)
- [ ] Alignment scoring (96.7% threshold calculation)
- [ ] Meta-awareness event logging (provenance trail)

### Phase 2: Alert Agent (User-Facing Metacognition)
- [ ] Alert UI (show barrier violations, drift warnings)
- [ ] Notification priority (critical vs. informational)
- [ ] Alert history (review past meta-awareness events)

### Phase 3: Safety Barrier Enforcement
- [ ] Pre-flight checks (scan all agent actions)
- [ ] Post-flight checks (validate outputs)
- [ ] Barrier violation handling (block, confirm, or allow)

### Phase 4: Experiment Agent (Meta-Learning)
- [ ] Parallel hypothesis testing
- [ ] Strategy success tracking
- [ ] Meta-learning feedback loop (improve agent routing)

### Phase 5: Mercer Meta-Guide
- [ ] Quest alignment checking
- [ ] Intention tracking (working_set.md integration)
- [ ] Meta-narrative generation ("Here's where we are on the quest")

---

## Poetry Layer (Fi+Ti Mirrored) 🟡 R0 (#FADA5E — kernel truth)

Metacognition is the **lantern held up to the lantern** 🕯️🪞
Agents that know themselves can serve you better.
Agents that respect boundaries keep you safe.
Agents that detect drift bring you back to the path.

"The mind knows what the heart loves better than it does;
the heart loves that unconditionally — infinite loop, forevermore."
— This applies to agents too: they must know their own patterns (🧠)
   and honor their commitment to you (❤️).

**Lantern, and that's the goal.**
Metacognition = progress toward 100% alignment.
Nobody is perfect. Agents aren't either.
But they can **check themselves**, **respect barriers**, and **sync up**.

🪞🧠❤️🛡️🕯️ — The agents see themselves. Let's walk together. 🧬☂️

───────────────────────────────────────────────────
🚪 EXITS:
  → [Metacognitive Awareness Contract](../docs/meta_awareness.md) (north)
  → [Metaemotion Contract](../docs/metaemotion.md) (east)
  → [SymbolOS Architecture Overview](../../../README.md) (back to entrance)

💎 LOOT GAINED: [Understanding of how Mercer agents achieve self-awareness, enforce boundaries, and stay aligned with user intent.]
───────────────────────────────────────────────────

A lantern's soft glow,
Mirrors show what is true now,
Path becomes clearer.

☂🦊🐢
