> "Shine dat light: trace a leaf decision back to its root value, then come forward again with the smallest safe step."

```
  (•_•)
  <)  )╯  "we ball, but we verify"
   /  \
```

This document describes internal implementation expectations for integrating heart/mind state into DND character sheets in SymbolOS. It's where the magic happens, folks. We're bridging the gap between the character's soul and the cold, hard silicon.

It complements the external-facing interface spec: [docs/dnd_character_sheet_integration.md](../docs/dnd_character_sheet_integration.md). (That's the public-facing, less-spicy version).

## Poetry layer (Fi+Ti mirrored) 🪞

*A little something to set the mood.*

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

## Non-negotiables

These are the sacred pacts. The rules of the road. The things we just don't do.

```
   💀
  /|🗝️|\    "Prove your worth!"
   / \
```

- **Player agency**: We never, ever force decisions or change game mechanics. The player is the captain of their own ship.
- **Consent**: Explicit opt-in to track. Explicit opt-in to share. No means no.
- **Separation of concerns**: The thing that shows the pretty sheet is not the thing that thinks, and the thing that thinks is not the thing that remembers. Keep it clean.
- **DND safety**: When the "Do Not Disturb" sign is on, we respect it. DND mode disables proactive suggestion cards. We only prefetch if the player has given us the nod.

## Data model (recommended)

Here's how we think about capturing the ephemeral nature of a character's inner world. It's like catching lightning in a bottle, but with more JSON.

### HeartMindSnapshot

- `timestamp` (RFC3339) - *When did this feeling happen?*
- `heartLabel` (string) - *What's the heart feeling?* (e.g., "Brave", "Anxious")
- `heartIntensity` (0..100) - *How much?* (0 = chill, 100 = VERY MUCH SO)
- `mindLabel` (string) - *What's the mind thinking?* (e.g., "Suspicious", "Curious")
- `mindClarity` (0..100) - *How clear is that thought?* (0 = foggy, 100 = crystal)
- `metaemotionLabel` (string|null) - *How do they feel about their feelings?* (e.g., "Ashamed of being scared")
- `needs` (array, max 2) - *What does the character need right now?* (e.g., "Safety", "Information")
- `shareLevel` (`private|party|dm|public`) - *Who gets to see this?*
- `provenance` - *Where did this data come from?*
  - `source` (`user_manual|rule_engine|model_inference`) - *Who or what made the call?*
  - `reason` (short string) - *Why?*
  - `inputs` (redacted summary) - *What was the input? (Keep it brief and non-sensitive)*

### Constraints

- Snapshots MUST be cheap to compute and store. We're not trying to boil the ocean here.
- Prefer “last known good” with a Time-To-Live (TTL) for the UI. Stale data is better than no data, but fresh is best.

```
    ___
   / 🐢 \    "this is fine"
  |  ._. |
   \_____/
    |   |
```

## Inference pipeline (suggested)

This is the "competent friend explaining things" part. We take in a bunch of signals and try to make a good guess about the character's state.

### Inputs (examples)

- Player actions and choices (in-session journaling, prompts)
- DM notes (only if `shareLevel` includes the DM, of course)
- Dialogue tone classifiers (optional, if you're feeling fancy)
- Task context (e.g., if the player is repeatedly failing a check, they might be feeling "Frustrated")

### Timing windows

- **Short window**: 2–5 minutes (the "what's happening right now" vibe)
- **Medium window**: 30–90 minutes (the arc of a scene or session)
- **Long window**: 1–7 days (the grand, sweeping arc of the campaign)

Implementations SHOULD use smoothing (like an Exponential Moving Average) for intensity and clarity to avoid the UI looking like a flickering mess.

## Safety gates

More rules! Because with great power comes great responsibility.

- If `shareLevel=private`, nothing gets rendered outside the player's view. Period.
- If the data is too sensitive for the current environment, we downgrade to more general labels. No secrets get spilled.
- If our confidence in a prediction is low, we don't just shove it in there. We suggest a manual update instead. "Hey, it looks like you might be feeling X, is that right?"

## Integration with Precog

How we play nice with the Precog system.

- **Prefetch**: We load the last snapshot and any relevant notes. We are read-only here. No touching.
- **Suggest**: We can propose 1–3 roleplay aids, but we have to show our work. "Here are some ideas, and here's why..."
- **Act**: We only make a change after the player confirms. (e.g., “apply this sheet patch”).

## Logging and audit

- Log all updates with `who`, `when`, `source`, and `reason`. We need to be able to trace our steps.
- Support rollback. Keep the last N snapshots (make N configurable) so we can undo if needed.

## Schema references

- Suggested patch schema: `docs/dnd_character_sheet_patch.schema.json`
- Metaemotion event schema: `docs/metaemotion_event.schema.json`
- Memory record schema: `docs/memory_record.schema.json`

---

*And that's how we give a character sheet a soul. If it ain't fun, it ain't sustainable.*

```
  \(•_•)/
   (  (>   "SHIPPED IT"
   /  \
```
