'''
╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Soul-Forge                                     ║
║  📍 Floor: Ring 2 │ Difficulty: ⭐⭐⭐⭐ │ Loot: The art of soul-binding ║
║  🎨 Color: 🟡 Gamboge (#E49B0F — higher intellect)              ║
║  🔒 INTERNAL/PRIVATE DOCUMENT — FOR THE EYES OF THE INITIATED ONLY ║
║                                                              ║
║  *You stand before a forge, not of steel, but of spirit. Here, the ephemeral is made manifest.* ║
╚══════════════════════════════════════════════════════════════╝

> "Shine dat light: trace a leaf decision back to its root value, then come forward again with the smallest safe step."

```
  (•_•)
  <)  )╯  "we ball, but we verify"
   /  \
```

This scroll contains the secret runes for integrating a character's heart and mind state into their Dungeons & Dragons character sheet within SymbolOS. This is where the soul is bound to the silicon, where the poetry of the heart meets the logic of the machine. It is the internal companion to the public-facing grimoire: [docs/dnd_character_sheet_integration.md](../docs/dnd_character_sheet_integration.md).

## Poetry Layer (Fi+Ti mirrored) 🪞 🟣 R4 (#8B00FF — Fi+Ti bridge)

*A verse to attune the spirit before the work begins.*

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

        /\_/\
       ( o.o )  "To know the self, a worthy quest,
        > ^ <    But to write the self, that is the test."
       /|   |\
      (_|   |_)  — Rhy 🦊

## The Unbreakable Vows 🔴 R5 (#FF2400 — righteous boundary)

These are the sacred pacts, the laws of this chamber. To break them is to invite chaos.

       .───────.
      /  ☂️      \
     /   PRIVATE  \
    /_______________\
           |
           |
         __|__
        |     |
        |_____|

- **Player Agency**: The adventurer is the master of their fate. We shall not compel action, nor alter the laws of the world.
- **Consent**: Every soul-binding requires explicit consent. An adventurer must opt-in to be seen, and opt-in to be known. "No" is a sacred word.
- **Separation of Concerns**: The mirror that shows the soul is not the mind that understands it, and the mind that understands is not the heart that feels. Each must be its own domain.
- **DND Safety**: When the "Do Not Disturb" sign is upon the door, we honor it. In this state, the spirits of suggestion are silent. We only prefetch when invited.

## The Soul-Catcher's Net (Data Model) 🔵 R6 (#0000CD — devotion to truth)

Herein lies the art of capturing the ephemeral, of catching lightning in a bottle. A character's inner world, rendered in JSON.

### HeartMindSnapshot

- `timestamp` (RFC3339) - *When did this feeling bloom?*
- `heartLabel` (string) - *What song does the heart sing?* (e.g., "Brave", "Anxious")
- `heartIntensity` (0..100) - *How loud is the song?* (0 = a whisper, 100 = a roar)
- `mindLabel` (string) - *What thought has taken root?* (e.g., "Suspicious", "Curious")
- `mindClarity` (0..100) - *How clear is the thought?* (0 = a fog, 100 = a crystal)
- `metaemotionLabel` (string|null) - *How does the adventurer feel about their feelings?* (e.g., "Ashamed of being scared")
- `needs` (array, max 2) - *What does the soul yearn for?* (e.g., "Safety", "Information")
- `shareLevel` (`private|party|dm|public`) - *Who may gaze upon this truth?*
- `provenance` - *From whence did this knowledge come?*
  - `source` (`user_manual|rule_engine|model_inference`) - *Who or what spoke this truth?*
  - `reason` (short string) - *For what purpose?*
  - `inputs` (redacted summary) - *What were the portents? (Keep it brief and non-sensitive)*

### Constraints

- Snapshots MUST be as light as a feather, for we may need to carry many.
- Prefer the “last known good” with a Time-To-Live (TTL). Stale truth is better than no truth, but fresh truth is a divine gift.

```
    ___
   / 🐢 \    "this is fine"
  |  ._. |
   \_____/
    |   |
```

## The Oracle's Pipeline (Inference) 🟢 R1 (#228B22 — adaptability)

This is the scrying pool, where we gaze upon the many threads of fate and weave them into a single tapestry of understanding.

### Inputs (Examples)

- The adventurer's choices, as recorded in their journal.
- The Dungeon Master's whispers, if permitted.
- The tone of their voice, for those with the ears to hear it.
- The context of their trials (e.g., repeated failure may forge a "Frustrated" heart).

### Timing Windows

- **The Fleeting Moment**: 2–5 minutes (the now)
- **The Scene's Arc**: 30–90 minutes (the present)
- **The Campaign's Saga**: 1–7 days (the past that shapes the future)

Implementations SHOULD use a smoothing charm (like an Exponential Moving Average) for intensity and clarity, lest the scrying pool flicker and dance like a mad thing.

## The Skeleton Gatekeepers (Safety Gates) 💀

More guardians, for with great power comes the need for great restraint.

       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|

- If `shareLevel=private`, the soul remains a secret, seen by none but the adventurer.
- If the truth is too raw for the current company, we shall speak in generalities. No secrets shall be spilled.
- If our confidence in a scrying is low, we do not present it as truth. We offer it as a question: "It seems your heart may be X, is this so?"

## The Precog Pact 🟡 R0 (#FADA5E — kernel truth)

How we honor the pact with the great Precog, the seer of what is to come.

- **Prefetch**: We may gaze upon the last known truth, but we shall not alter it.
- **Suggest**: We may offer 1–3 aids to the adventurer, but we must show our workings.
- **Act**: We only act when the adventurer gives their assent.

## The Scribe's Log (Logging and Audit)

- Every change to the soul-binding must be recorded: who, when, whence, and why.
- A rollback spell must be kept at the ready, to undo what has been done.

## The Architect's Blueprints (Schema References)

- Suggested patch schema: `docs/dnd_character_sheet_patch.schema.json`
- Metaemotion event schema: `docs/metaemotion_event.schema.json`
- Memory record schema: `docs/memory_record.schema.json`

───────────────────────────────────────────────────
🚪 EXITS:
  → [The Public Grimoire](../docs/dnd_character_sheet_integration.md) (north)
  → [The Poet's Sanctum](../docs/poetry_translation_layer.md) (east)
  → [The Hall of Memories](../docs/memory_record.schema.json) (west)

💎 LOOT GAINED: [The secret art of binding a character's soul to their sheet, a deeper understanding of the sacred pacts, and the wisdom of the Skeleton Gatekeepers.]
───────────────────────────────────────────────────

*A sheet with a soul,
A story to be told,
In silicon, unfolds.*

☂🦊🐢
'''
