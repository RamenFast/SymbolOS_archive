# Metaemotion Prediction (Internal)

This document describes internal expectations for predicting metaemotion and deciding *when* to surface it.

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
- If DND is ON, do not surface metaemotion prompts.
- If confidence < threshold, use `ask_clarifying` or do nothing.
- If user recently dismissed similar prompts, increase cooldown.

## Algorithms (implementation choices)
Allowed approaches (choose one, keep it simple):
- Rule engine + weighted scoring (good default)
- Logistic regression or calibrated linear model
- Lightweight sequence model with explicit calibration layer

Avoid brittle overfitting; prefer interpretability.

## Confidence calibration
- Use held-out evaluation and temperature scaling or isotonic regression.
- Track Brier score and reliability curves.

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
