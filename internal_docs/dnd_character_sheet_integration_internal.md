# Heart + Mind Integration for DND Character Sheets (Internal)

This document describes internal implementation expectations for integrating heart/mind state into DND character sheets in SymbolOS.

It complements the external-facing interface spec: [docs/dnd_character_sheet_integration.md](../docs/dnd_character_sheet_integration.md).

## Poetry layer (Fi+Ti mirrored) 🪞

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

## Non-negotiables
- Player agency: never force decisions or change mechanics.
- Consent: explicit opt-in to track; explicit opt-in to share.
- Separation of concerns: sheet rendering != inference; inference != storage.
- DND safety: DND disables proactive suggestion cards; prefetch only if enabled.

## Data model (recommended)

### HeartMindSnapshot
- `timestamp` (RFC3339)
- `heartLabel` (string)
- `heartIntensity` (0..100)
- `mindLabel` (string)
- `mindClarity` (0..100)
- `metaemotionLabel` (string|null)
- `needs` (array, max 2)
- `shareLevel` (`private|party|dm|public`)
- `provenance`
  - `source` (`user_manual|rule_engine|model_inference`)
  - `reason` (short string)
  - `inputs` (redacted summary)

### Constraints
- Snapshots MUST be cheap to compute and store.
- Prefer “last known good” with TTL for UI.

## Inference pipeline (suggested)

### Inputs (examples)
- Player actions and choices (in-session journaling, prompts)
- DM notes (only if shareLevel includes DM)
- Dialogue tone classifiers (optional)
- Task context (e.g., repeated confusion in planning)

### Timing windows
- Short window: 2–5 minutes (moment-to-moment)
- Medium window: 30–90 minutes (session arc)
- Long window: 1–7 days (campaign arc)

Implementations SHOULD use smoothing (EMA) for intensity/clarity to avoid oscillation.

## Safety gates
- If `shareLevel=private`, no external rendering beyond the player.
- If data classification is higher than allowed in the current environment, drop to coarse labels.
- If confidence is below threshold, do not auto-update; suggest manual set.

## Integration with Precog
- Prefetch: load last snapshot + relevant notes; never writes.
- Suggest: propose 1–3 roleplay aids, with clear “why”.
- Act: only after confirmation (e.g., “apply this sheet patch”).

## Logging and audit
- Log updates with `who`, `when`, `source`, and `reason`.
- Support rollback: keep last N snapshots (N configurable).

## Schema references
- Suggested patch schema: `docs/dnd_character_sheet_patch.schema.json`
- Metaemotion event schema: `docs/metaemotion_event.schema.json`
- Memory record schema: `docs/memory_record.schema.json`
