# SymbolOS Memory (External)

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🧾  MEMORY — CONSENT + PROVENANCE                        ║
║  Quest: remember well • never store secrets                  ║
║  "Always return to the meeting place. The map is steady."    ║
╚══════════════════════════════════════════════════════════════╝
```

    ___
   / 🐢 \    "this is fine"
  |  ._. |
   \_____/
    |   |

## Poetry layer (Fi+Ti mirrored) 🪞

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

"Shine dat light: trace a leaf decision back to its root value, then come forward again with the smallest safe step."

- Translation layer + emojis: [poetry_translation_layer.md](poetry_translation_layer.md)
- Full verse set: [public_private_expression.md](public_private_expression.md)

This document defines a safe, consent-driven approach to “memory” in SymbolOS. It's about remembering the little things that make our dance together smoother.

Memory here means: durable, retrievable notes and preferences that help future interactions. Think of it as our shared notebook.

## Principles
- **Consent first**: You are the captain of this ship. You choose what is stored.
- **Minimum necessary**: We store the smallest useful representation. No hoarding.
- **Provenance**: Every memory includes why/when/source. We show our work.
- **Correctability**: Users can view, edit, and delete memories. Your memory, your rules.
- **DND compatibility**: Memory capture should not interrupt the flow. We're not paparazzi.

  (•_•)
  ( (  )   "hmm... is this R0?"
   /  \

## What counts as memory

### Allowed (typical)
- Preferences (tone, formatting, reminders)
- Project facts (repo names, active branches, conventions)
- DND campaign aids (session recap bullets, NPC names)
- Stable “life patterns” the user explicitly enables

### Avoid by default
- Secrets (API keys, passwords) - No, just no.
- Sensitive personal info (health, finances) unless explicitly requested and protected
- Unverified claims about real people

## Memory types
- **Fact**: stable truth with sources (e.g., “Project uses trunk-based workflow”).
- **Preference**: user likes/dislikes (e.g., “Use concise bullets”).
- **Plan**: short-lived intent with TTL.
- **Story**: narrative recap (for DND), marked as “in-world” or “out-of-world”.

## Retention (recommended defaults)
- Preference: until changed
- Fact: until invalidated, with review prompts
- Plan: 7–30 days TTL
- Story: campaign-defined TTL

## Access and privacy
- Default visibility: private to the user.
- Optional share scopes: party/DM/public (for DND), with explicit opt-in.

## Interaction patterns
- Capture: user confirms saving (“Save this as a memory?”)
- Retrieval: show short summaries with “source” and “last updated”
- Correction: allow “That’s wrong” and rewrite with provenance

## Integration points
- Precog uses memory to propose suggestions: [precog_thought.md](precog_thought.md)
- Character sheet overlays can reference memory: [dnd_character_sheet_integration.md](dnd_character_sheet_integration.md)

## Interop schema (optional)
If emitting structured memory records, a suggested schema lives at: `docs/memory_record.schema.json`.

```
  \(•_•)/
   (  (>   "SHIPPED IT"
   /  \
```
