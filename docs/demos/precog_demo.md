# Precog Demo: Prefetch/Suggest/Act in Action

```
╔══════════════════════════════════════════════════════════════╗
║  🔮☂️  PRECOG DEMO — Anticipatory Computing Pipeline         ║
║  Quest: see how symbols predict + guide next steps           ║
╚══════════════════════════════════════════════════════════════╝
```

**Status: Beta** — This demo is live; you can try it now.

---

## Scenario: Adding a new MCP server

**Context**: You're in the middle of building a feature. Someone asks, "Can we integrate with Slack?" You have 3 seconds to decide: do you say yes, no, or "let me think"?

**Without Precog**: You hesitate. Context-switch. Check docs. Check dependencies. 5 minutes later: "Uh, maybe?"

**With Precog (🔮)**: System runs 3 modes in parallel:

### 1️⃣ Prefetch (Background)

Before you finish typing "Slack", the system is already:

```
Prefetch runs silently (no UI):
  ✓ Check existing MCP servers (what integrations exist?)
  ✓ Scan symbol_map (what constraints apply?)
  ✓ Read working_set (what's the current scope?)
  ✓ Build 3 candidate shapes (async, webhook, polling)
  ✓ Cache results locally (ready to show in <100ms)
```

**Result**: System has fetched all context before you finish the sentence.

---

### 2️⃣ Suggest (Visible, DND-gated)

You type: "I want to integrate Slack"

System shows (unless 🎲 DND is on):

```
🔮 PRECOG SUGGESTION CARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title: Slack Integration Options

🧠 Analysis:
  • Existing servers: 🧩 git, 🧩 filesystem, 🧩 memory
  • New server would need: 🔒 auth token, 🛡️ scope gate, 🧾 audit log
  
❤️ Gut check:
  • This feels like scope creep (current sprint: D&D campaign docs)
  • But Slack notifications could help team alignment
  
🎲 Table-safe options:
  1. Webhook proxy (async, low-risk) — requires 🔒 privkey
  2. Scheduled sync (polling, delayed) — requires 🧾 audit trail
  3. Mention-based trigger (reactive, explicit) — cleanest for DND

⚡ Quick decision:
  → "Use option 3; add to open_loops as future work"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[🎲 DND mode: OFF (suggestions visible)]
[👍 ACCEPT] [❌ DISMISS] [💭 SAVE FOR LATER]
```

**What happened**: System predicted your exact question and pre-fetched the answers. You didn't ask for this—it arrived before you needed it. That's 🔮.

---

### 3️⃣ Act (User Confirmation)

You click `[💭 SAVE FOR LATER]`

System immediately:

```
✅ Action taken:
  1. Added "Slack integration (mention-based)" to 🔓 open_loops
  2. Logged decision: 
     - timestamp: 2026-01-28T15:45:00Z
     - symbols: [🔮, 🎲, 🧬]
     - decision: "defer; use webhook option 3 if needed"
  3. Staged memory file for git commit
  4. Returned to work (no context-switch)

🧾 Audit trail:
  → memory/open_loops.md updated
  → memory/decisions.md appended
  → git status shows 2 files ready to commit
```

---

## Why This Matters

**Before Precog**: "Can we integrate Slack?" → 5min decision → maybe the wrong call

**With Precog**: "Can we integrate Slack?" → 100ms card → clear options → 30sec decision → logged + auditable

**Symbol payoff**: The suggestion card uses 🔮🧠❤️🎲🧾🔒 to explain **why** each option works or doesn't. Not just "here are 3 choices." More like "here's the intention map."

---

## How to Try

1. Open [Precog Thought Spec](../precog_thought.md) — understand Prefetch/Suggest/Act
2. Look at [Symbol Map](../symbol_map.md) — see which symbols appear in cards
3. Check [Meta-awareness Barriers](../meta_awareness.md) — see how 🎲 DND gates suggestions
4. Read [DND Character Sheet](../dnd_character_sheet_integration.md) — see table-safe output rules

**Live test**: Enable precog in your workflow, then make a decision. Note how long it took to collect context before. Now it should be near-instant.

---

## Current Limitations

- 🔮 Prefetch: limited to local cache (no live API polling yet)
- 🎲 Suggest: DND gating works; card styling incomplete
- 📍 Act: logging works; git integration pending Q2 2026

See [Precog Thought (Main Spec)](../precog_thought.md#async-timeline) for roadmap.

---

## See Also

- [Precog System](../precog_thought.md) — Full specification
- [Symbol Map](../symbol_map.md) — What each symbol means
- [Meta-awareness](../meta_awareness.md) — How barriers prevent unsafe suggestions
- [Metaemotion Integration](metaemotion_demo.md) — How felt sense feeds precog
