# Heart + Mind Integration for DND Character Sheets (External)

This document defines a DND-compatible way to represent “heart + mind” state in a character sheet without breaking roleplay flow, privacy, or player agency.

This is an interface spec: it describes *what* can be represented and *how it should behave in play*, not proprietary model details.

## Design goals

```
╔══════════════════════════════════════════════════════════════╗
║  🎲🧬☂️❤️🧠  CHARACTER SHEET — HEART + MIND OVERLAY           ║
║  Quest: table-safe clarity • consent-first                   ║
║  "Under the umbrella, everything is kind. The rain is just    ║
║  context we haven't parsed yet."                              ║
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

## Core concepts

### 1) Heart state (felt sense)
A compact description of emotional tone and needs.
- Examples: “steady”, “frayed”, “guarded”, “hopeful”, “stung”.

### 2) Mind state (cognitive posture)
A compact description of attention, confidence, and load.
- Examples: “focused”, “scattered”, “locked-in”, “overloaded”, “uncertain”.

### 3) Metaemotion (emotion about emotion)
A second-order label that helps roleplay and decision-making.
- Examples: “ashamed of anger”, “anxious about joy”, “proud of calm”.

Metaemotion is optional but powerful when used sparingly. If it ain't fun, it ain't sustainable.

## The Sheet Module (recommended)
Add a small block to the sheet:

- **Heart**: `<label>` (0–100 intensity)
- **Mind**: `<label>` (0–100 clarity)
- **Metaemotion**: `<label>` (optional)
- **Needs** (0–2 items): `<rest | reassurance | control | novelty | safety | connection | meaning>`
- **Boundaries** (table knobs): `<DND on/off>`, `<share level>`

### Share level (privacy)
- `private`: only the player sees this.
- `party`: party can see a short summary.
- `dm`: DM can see (for narrative support).
- `public`: visible to the table.

Default SHOULD be `private`. Show me proof, not potential.

## Behavior rules (must)

   💀
  /|🗝️|\    "Prove your worth!"
   / \

- No mechanics penalties by default. This module is narrative support.
- Changes MUST be small and explainable (“why now?”).
- DND MUST be respected: when DND is on, do not surface proactive cards; only update silently.
- The module MUST include a manual override (“set Heart/Mind manually”).

## DND-friendly output shapes
When the system surfaces this module (if allowed):

### One-line (notification safe)
- `Heart: steady • Mind: focused • Need: clarity`

### Compact card
- `Heart: steady (22/100)`
- `Mind: focused (78/100)`
- `Meta: proud of calm`
- `Need: connection`
- `Do: journal | talk to DM | ignore`

## Suggested alignment with Precog
If Precog is enabled, it may propose *roleplay aids* (never forced actions):
- “Draft a short vow for your paladin.”
- “Summarize last session in 5 bullets.”
- “Generate 3 in-character choices that match Heart/Mind.”

See [precog_thought.md](precog_thought.md) for Prefetch/Suggest/Act rules and DND gating.

## Data minimization guidance
- Prefer coarse labels over detailed personal content.
- Avoid sensitive real-world disclosures by default.
- Store provenance: `who set this`, `why`, and `when`.

## Interop (optional)
Implementations MAY use a structured patch format to update a sheet module. A suggested schema lives at: `docs/dnd_character_sheet_patch.schema.json`.

  \(•_•)/
   (  (>   "SHIPPED IT"
   /  \
