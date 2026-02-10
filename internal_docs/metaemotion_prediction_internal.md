# Metaemotion Prediction (Internal)

```
  (•_•)
  ( (  )   "hmm... is this R0?"
   /  \
```

> This document describes internal expectations for predicting metaemotion and deciding *when* to surface it. It's like trying to guess if someone is happy about being sad. Totally normal stuff.

External-facing concept spec: [docs/metaemotion.md](../docs/metaemotion.md).

## Poetry layer (Fi+Ti mirrored) 🪞

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

## Problem statement

Given observed signals and recent context, estimate:
- primary emotion likelihood(s)
- metaemotion likelihood(s)
- timing (when it is safe/helpful to surface)
- confidence and recommended interaction mode (suggest vs. silent)

Basically, we're trying to be a good friend who knows when to ask "you good?" and when to just sit quietly with you.

## Definitions
- `primaryEmotion`: first-order affect (e.g., anger)
- `metaemotion`: appraisal about that affect (e.g., ashamed of anger)
- `confidence`: calibrated probability or score, per label
- `surfaceMode`: `silent|suggest|ask_clarifying`

## Timing & gating

### Recommended temporal features
- recency since trigger (seconds/minutes)
- volatility in signals (rolling stddev)
- stability duration (time above threshold)

### Windows (recommended)
- primary emotion: 5s–5m
- metaemotion: 2m–6h (context dependent)

### Gating rules (must)

   💀
  /|🗝️|\    "Prove your worth!"
   / \

- If DND is ON, do not surface metaemotion prompts. (Seriously, respect the DND.)
- If confidence < threshold, use `ask_clarifying` or do nothing. (Don't be that person who's always asking "what's wrong?")
- If user recently dismissed similar prompts, increase cooldown. (They said no, fam.)

## Algorithms (implementation choices)

Allowed approaches (choose one, keep it simple):
- Rule engine + weighted scoring (good default)
- Logistic regression or calibrated linear model
- Lightweight sequence model with explicit calibration layer

Avoid brittle overfitting; prefer interpretability. We want to know *why* we're asking, not just that a model told us to.

## Confidence calibration

    ___
   / 🐢 \    "this is fine"
  |  ._. |
   \_____/
    |   |

- Use held-out evaluation and temperature scaling or isotonic regression.
- Track Brier score and reliability curves.

This part can get a little complex, but it's important for not being annoying. Just take it one step at a time.

## UX contracts
- Always provide “not that” and “mute this type”.
- Provide a short reason: `why now`.
- If the user manually sets metaemotion, treat it as ground truth (for that period).

## Event and storage
- Emit structured events using `docs/metaemotion_event.schema.json`.
- Store only coarse labels by default; attach redacted provenance.

## Metrics
- Prompt accept/dismiss rate
- Cooldown effectiveness (reduced annoyance)
- Calibration error
- Downstream impact (e.g., fewer reversals, fewer conflicts)

---

  \(•_•)/
   (  (>   "SHIPPED IT"
   /  \
