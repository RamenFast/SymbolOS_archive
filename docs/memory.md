# SymbolOS Memory (External)

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🧾  MEMORY — CONSENT + PROVENANCE                        ║
║  Quest: remember well • never store secrets                  ║
╚══════════════════════════════════════════════════════════════╝
```

## Poetry layer (Fi+Ti mirrored) 🪞

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [poetry_translation_layer.md](poetry_translation_layer.md)
- Full verse set: [public_private_expression.md](public_private_expression.md)

This document defines a safe, consent-driven approach to “memory” in SymbolOS.

Memory here means: durable, retrievable notes and preferences that help future interactions.

## Principles
- Consent first: users choose what is stored.
- Minimum necessary: store the smallest useful representation.
- Provenance: every memory includes why/when/source.
- Correctability: users can view, edit, and delete memories.
- DND compatibility: memory capture should not interrupt.

## What counts as memory

### Allowed (typical)
- Preferences (tone, formatting, reminders)
- Project facts (repo names, active branches, conventions)
- DND campaign aids (session recap bullets, NPC names)
- Stable “life patterns” the user explicitly enables

### Avoid by default
- Secrets (API keys, passwords)
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
