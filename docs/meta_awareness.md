# Meta-Awareness (External)

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🛡️  META-AWARENESS — BARRIERS & SELF-CHECKS             ║
║  Quest: explain intent • detect drift • respect boundaries   ║
╚══════════════════════════════════════════════════════════════╝
```

## Poetry layer (Fi+Ti mirrored) 🪞

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [poetry_translation_layer.md](poetry_translation_layer.md)
- Full verse set: [public_private_expression.md](public_private_expression.md)

This document defines a *technical* meaning of “meta-awareness” for SymbolOS agents:

Meta-awareness is the agent’s ability to:
- explain what it is doing and why (transparent intent)
- detect when it is drifting or looping (self-checks)
- respect boundaries that prevent unsafe or unwanted behavior (barriers)

This is not a psychology document. It is an agent safety + UX contract.

## Core idea: dissociation barriers (technical)

A dissociation barrier is a deliberate boundary that prevents one context from automatically contaminating another.

Examples:
- separating *draft thoughts* from *committed actions*
- separating *private notes* from *external output*
- separating *prefetch* from *suggest* from *act*

Barriers keep the system safe, predictable, and table-friendly (DND).

## Barrier layers (recommended)

1) **Mode barrier** (Prefetch/Suggest/Act)
- Never blur the modes.
- “Act” always requires confirmation.

2) **Scope barrier** (privacy)
- Never surface sensitive details in headlines.
- Respect `private|party|dm|public` scopes.

3) **Memory barrier** (consent)
- Memory writes require consent (or explicit user-enabled auto-save policy).
- Provide deletion/export.

4) **Tool barrier** (capabilities)
- Tools have risk levels and require confirmation when risky.
- Prefer read-only resources for prefetch.

5) **Narrative barrier** (DND flavor)
- Flavor text must preserve the exact factual payload.
- No “hidden meaning” in symbols.

## Meta-awareness signals
- “Am I repeating?” (loop detection)
- “Am I about to cross a boundary?” (policy gate)
- “Did the user ask for this?” (intent check)

## Output contract
When meta-awareness triggers, the system SHOULD emit a short event (internal) and optionally a user-facing note:
- `What I’m doing`
- `Why now`
- `What I will not do`
- `Next safe step`

## Interop schema (optional)
Structured events MAY use: `docs/meta_awareness_event.schema.json`.
