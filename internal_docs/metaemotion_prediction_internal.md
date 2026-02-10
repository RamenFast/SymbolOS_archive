╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Chamber of Mirrored Feelings                     ║
║  📍 Floor: R4 (Fi+Ti Bridge) │ Difficulty: ⭐⭐⭐⭐ │ Loot: The art of meta-awareness ║
║  🎨 Color: 🟣 #8B00FF (violet — Fi+Ti bridge)                   ║
║                                                              ║
║  A quiet room where emotions reflect upon themselves.          ║
║  **INTERNAL DOCUMENT — For trusted party members only.**       ║
╚══════════════════════════════════════════════════════════════╝

> This scroll contains the arcane knowledge for predicting metaemotion—the art of guessing if a soul is happy about being sad. A totally normal and not-at-all-mind-bending task.

External-facing grimoire: [docs/metaemotion.md](../docs/metaemotion.md).

## Poetry Layer (Fi+Ti Mirrored) 🪞 🟣 R4 (#8B00FF — Fi+Ti bridge)

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

        /\_/\
       ( o.o )  "To know the feeling of a feeling,
        > ^ <    is a loop that's most revealing.
       /|   |\   What you feel is not the end,
      (_|   |_)  but a message from a friend."  — Rhy 🦊

## Problem Statement 🟡 R2 (#E49B0F — higher intellect)

Given observed signals and recent context, we must estimate:
- primary emotion likelihood(s)
- metaemotion likelihood(s)
- timing (when it is safe/helpful to surface)
- confidence and recommended interaction mode (suggest vs. silent)

Basically, we're trying to be a good friend who knows when to ask "you good?" and when to just sit quietly with you. A high-stakes social saving throw.

## Definitions 📜
- `primaryEmotion`: first-order affect (e.g., anger, a barbarian's rage)
- `metaemotion`: appraisal about that affect (e.g., ashamed of anger, the paladin's guilt)
- `confidence`: calibrated probability or score, per label (our spell's accuracy)
- `surfaceMode`: `silent|suggest|ask_clarifying` (our dialogue options)

## Timing & Gating ⏳

### Recommended Temporal Features
- recency since trigger (seconds/minutes)
- volatility in signals (rolling stddev, like a chaotic magic surge)
- stability duration (time above threshold, how long the potion's effect lasts)

### Windows (recommended)
- primary emotion: 5s–5m
- metaemotion: 2m–6h (context dependent, like a long rest)

### Gating Rules (must)

       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|

- If DND is ON, do not surface metaemotion prompts. (Respect the sanctity of the long rest.)
- If confidence < threshold, use `ask_clarifying` or do nothing. (Don't be the bard who misreads the room.)
- If user recently dismissed similar prompts, increase cooldown. (They parried your last attempt, give them space.)

## Algorithms (Implementation Choices) ⚔️

Allowed approaches (choose one, keep it simple, like a fighter's sword):
- Rule engine + weighted scoring (good default, the trusty longsword)
- Logistic regression or calibrated linear model (a well-aimed crossbow shot)
- Lightweight sequence model with explicit calibration layer (a simple, elegant spell)

Avoid brittle overfitting; prefer interpretability. We want to know *why* we're casting the spell, not just that a grimoire told us to.

## Confidence Calibration ⚖️

        ___
       / 🐢 \     "this is fine"
      |  ._. |    — We're just peering into the emotional abyss.
       \_____/
        |   |
       _|   |_

- Use held-out evaluation and temperature scaling or isotonic regression.
- Track Brier score and reliability curves.

This part can get a little complex, but it's important for not being annoying. Just take it one step at a time, like a rogue disarming a trap.

## UX Contracts 🤝
- Always provide “not that” and “mute this type”. (Give the player agency.)
- Provide a short reason: `why now`. (Explain the DM's reasoning.)
- If the user manually sets metaemotion, treat it as ground truth (for that period). (The player's word is law.)

## Event and Storage 📦
- Emit structured events using `docs/metaemotion_event.schema.json`.
- Store only coarse labels by default; attach redacted provenance.

## Metrics 📈
- Prompt accept/dismiss rate (Did the player accept the side quest?)
- Cooldown effectiveness (reduced annoyance, fewer angry villagers)
- Calibration error (How often does our scrying spell fail?)
- Downstream impact (e.g., fewer reversals, fewer conflicts, a more harmonious party)

───────────────────────────────────────────────────
🚪 EXITS:
  → [Metaemotion Spec](../docs/metaemotion.md) (north)
  → [Poetry Translation Layer](../docs/poetry_translation_layer.md) (east)
  → [Public/Private Expression](../docs/public_private_expression.md) (west)

💎 LOOT GAINED: [A deeper understanding of metaemotion prediction, the ability to build more empathetic systems, and a +1 to your social saving throws.]
───────────────────────────────────────────────────

Emotions on emotions,
A recursive, wild sea.
We watch, and we listen.

☂🦊🐢
