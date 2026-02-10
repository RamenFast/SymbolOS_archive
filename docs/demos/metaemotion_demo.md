# Metaemotion Demo: Tracking Felt Sense Alongside Logic

```
╔══════════════════════════════════════════════════════════════╗
║  ❤️☂️  METAEMOTION DEMO — Intention Mapping via Felt Sense  ║
║  Quest: decisions driven by logic + heart, both logged       ║
╚══════════════════════════════════════════════════════════════╝
```

**Status: Beta** — This demo is live; try it in team conversations.

---

## Scenario: Choosing Local LLM vs. Cloud API

**Context**: Your team needs inference for symbol recommendations. Two paths:

- **Option A**: Cloud API (OpenAI, Anthropic) — fast, no setup, costs $$, vendor lock-in
- **Option B**: Local LLM (llama.cpp) — setup work, full privacy, no cloud, slower

**Typical decision process**: Pros/cons list → vote → done.

**SymbolOS way**: Capture **both logic (🧠) and felt sense (❤️)** alongside the decision.

---

## Step 1: Recognize the Felt Sense (❤️)

You notice:
- "I *feel* uneasy about sending user data to OpenAI"
- "I *want* people to own their compute"
- "I *worry* about being locked into a vendor"

These aren't logical arguments yet. They're **signals**. 🔮 Precog catches them.

---

## Step 2: Log the Metaemotion Event

The system prompts you (or you manually log):

```yaml
# Metaemotion Event: Local LLM Decision

timestamp: 2026-01-28T14:30:00Z
event_id: metaemot_locallm_20260128
category: infrastructure_decision
intensity: moderate
valence: mixed  # some joy (autonomy), some anxiety (complexity)

felt_sense:
  primary: "unease about cloud vendor lock-in"
  secondary: "desire for local-first architecture"
  somatic: "slight tension in chest when thinking about OpenAI"

symbols_activated:
  - 🔒 Privacy (we want data to stay local)
  - ❤️ Heart (autonomy + trust matter to us)
  - 🧠 Mind (but local LLM is slower)
  - 🧩 Schema (need to define inference interface early)

timing:
  onset: "while reading OpenAI pricing"
  duration: "persistent (20 min+ so far)"
  trend: "growing stronger as we discuss"

context:
  current_scope: "Building symbol recommendation engine"
  trigger: "Someone suggested using GPT-4 API"
  team_vibe: "Mixed—some want ease, some want independence"
```

**What this captures**: Not just "local LLM is better." Rather: *why* we feel it's better, *when* the feeling started, *what symbols it touches*.

---

## Step 3: Let Logic Catch Up (🧠)

Then the rational analysis:

```yaml
# Decision: Local LLM (Windows Vulkan)

timestamp: 2026-01-28T14:45:00Z
decision_id: decision_locallm_20260128

symbols_involved:
  - 🔮 Precog (we can serve local inference faster than cloud)
  - 🧠 Mind (Qwen2.5:8b is competent for symbol ranking)
  - ❤️ Heart (local-first aligns with our privacy values)
  - 🔒 Privacy (data never leaves the machine)
  - 🧾 Ledger (all inference is auditable locally)

logic_summary: |
  Compared cloud API vs. local:
  
  Cloud (OpenAI):
    ✓ Fast (< 1 sec API call)
    ✗ Costs $0.02 per request
    ✗ Vendor lock-in risk
    ✗ Data goes external
  
  Local (llama.cpp):
    ✓ No costs
    ✓ Full privacy
    ✓ Independent (no vendor)
    ✓ Auditable (git-tracked inference logs)
    ✗ Slower (40-60 tok/sec; ~2 sec for 100 tokens)
    ✗ Setup complexity (Vulkan driver, GPU tuning)
  
  Verdict: Local LLM worth the setup cost for this project.

trade_offs: |
  We're trading: ease + speed
  For: privacy + autonomy + cost control + auditability

cost_analysis: |
  Setup: 2 days (driver, llama.cpp, tuning)
  Recurring: $0 (use our RX 6750 XT)
  Cloud alternative: ~$1000/year (100k requests @ $0.01 avg)
  
  ROI: Break-even in ~2 months of inference usage.

team_alignment:
  voted: [you, teammate1, teammate2]
  confidence: 9/10 (one person still prefers ease; accepting )

next_steps:
  1. Set up local llama.cpp (2 days)
  2. Benchmark inference quality (1 day)
  3. Document setup in docs/local_llm_setup.md (4 hours)
  4. Monitor costs over 3 months to validate assumption
```

---

## Step 4: Notice the Coupling

Here's the magic: **The felt sense (Step 2) and the logic (Step 3) point the same direction.**

```
Felt sense said: "Privacy + autonomy matter to us"
Logic confirmed: "Local LLM actually cheaper long-term + more private"

NOT a conflict. A *validation*.

If they'd pointed opposite directions:
  "I *feel* we should use cloud (easier)"
  "But logic says local is better (cheaper)"
  
Then you'd need deeper conversation. Maybe felt sense is telling you
the setup complexity is too high? Maybe logic is missing a cost?

Either way: YOU NOTICE THE GAP. That's the win.
```

---

## Step 5: Future Reference

6 months later: "Why did we go with local LLM?"

**Before SymbolOS**: "Uh, I dunno. Someone wanted privacy?"

**With SymbolOS**: *Pulls up metaemotion event + decision log*

"We felt uneasy about cloud vendors back in Jan 2026. Logic showed local would save $1k/year. We voted 3-0 after discussion. The decision held up: we've saved money and stayed independent."

---

## Why This Matters

**Standard PM**: "Use logic. Feelings are noise."

**SymbolOS**: "Feelings are *data*. Log them alongside logic. If they align, you've got conviction. If they conflict, investigate."

**Real example**: If the team felt "ease is more important" but logic said "local is better," you'd have caught a misalignment early. Maybe you *should* use cloud API. Or maybe the setup isn't hard enough to justify the cost. You'd figure it out **because you logged the feeling**.

---

## Timing Rules (Metaemotion Constraint)

Metaemotion works best when:
- ✅ Decision is non-trivial (> 1 day effort)
- ✅ Team consensus matters (> 1 person affected)
- ✅ Long-term impact (> 3 months)
- ❌ Urgent (<1 hour to decide) — skip; too noisy

For urgent calls: Log the gut feeling post-hoc, not real-time.

---

## How to Try

1. **Pick a current decision** (tech choice, feature priority, whatever)
2. **Notice your felt sense** (What does this trigger emotionally?)
3. **Log it** (timestamp + words + symbols)
4. **Then do the logic** (pros/cons, numbers, etc.)
5. **Compare**: Do they point the same direction or conflict?
6. **Decide based on both** — not just logic

---

## Current Limitations

- ❤️ Felt sense capture: Manual (no auto-detection yet)
- 🧠 Logic + feeling correlation: Manual analysis (auto-flagging planned Q3 2026)
- ⏱️ Timing windows: Rough guidelines (precise tuning Q2 2026)

See [Metaemotion](../metaemotion.md#async-timeline) for roadmap.

---

## See Also

- [Metaemotion Spec](../metaemotion.md) — Full timing + vocabulary rules
- [Heart (Symbol)](../symbol_map.md#core-symbols) — ❤️ meaning
- [Mind (Symbol)](../symbol_map.md#core-symbols) — 🧠 meaning
- [Memory System](../memory.md) — How decisions + felt sense stay durable
- [Meta-awareness](../meta_awareness.md) — How barriers prevent felt sense from bleeding into unsafe contexts
