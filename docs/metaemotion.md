# Metaemotion (External)

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️❤️🧠  METAEMOTION — TIMING + TABLE-SAFE SIGNALS          ║
║  Quest: feel clearly • act safely                            ║
╚══════════════════════════════════════════════════════════════╝
```

Metaemotion is “emotion about emotion” — how someone feels about what they’re feeling.

This spec defines shared vocabulary, timing, and safe inference/display rules for SymbolOS.

## Why it matters
Metaemotion is often where the “real decision” happens:
- anger → guilt → withdrawal
- joy → anxiety → self-sabotage
- calm → pride → steadier choices

Used well, it improves narrative coherence without taking away agency.

## Vocabulary

### Primary emotion (examples)
- anger, fear, sadness, joy, disgust, surprise

### Metaemotion labels (examples)
- ashamed of anger
- anxious about joy
- relieved about sadness
- proud of calm
- frustrated by fear

Implementations SHOULD keep labels coarse and interpretable.

## Timing model
Metaemotion tends to lag the primary emotion.

Recommended windows:
- **T0 (trigger)**: an event occurs
- **T1 (primary emotion)**: immediate reaction (seconds–minutes)
- **T2 (metaemotion)**: appraisal about that reaction (minutes–hours)

### Practical rule
If you only have short-term signals, avoid declaring a metaemotion with high confidence.
Prefer: “possible metaemotion” or a suggestion (“Does this feel like…?”).

## Output rules (must)
- Default to suggestion mode for metaemotion.
- Provide an explicit “nope” / “not that” control.
- Never reveal sensitive content in one-line surfaces.

## DND compatibility
- Treat metaemotion as a *roleplay prompt*, not a status effect.
- In DND mode, show at most one metaemotion prompt at a time.
- Support an in-fiction phrasing (“You feel uneasy about your relief”).

## Integration points
- Character sheet module: [dnd_character_sheet_integration.md](dnd_character_sheet_integration.md)
- Precog output contract: [precog_thought.md](precog_thought.md)

## Interop schema (optional)
If emitting structured events, a suggested schema lives at: `docs/metaemotion_event.schema.json`.
