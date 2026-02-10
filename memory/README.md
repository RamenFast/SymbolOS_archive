# Repo-backed Memory System (Private)
> "Always return to the meeting place. The map is steady. The hands are open."

  (•_•)
  <)  )╯  "we ball, but we verify"
   /  \

Welcome, traveler. You've found the **durable memory layer** for all things SymbolOS/UmbrellaOS. Think of this as our shared journal, our institutional memory, our single source of truth.

It's all file-backed, which is a fancy way of saying we're using the power of git (and its glorious history and diffs) to keep track of everything. We don't rely on ephemeral chat logs or the whims of a model's short-term memory. This is real, this is durable, this is ours.

## The Poetry Layer 🪞
> "The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within."

This is the heart of the system, the Fi+Ti mirror. It's where we keep the deepest truths.

- For a translation of our poetic sensibilities (with emojis!): [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- For the full firehose of verses: [../docs/public_private_expression.md](../docs/public_private_expression.md)

## Our Guiding Principles

- **Default-private:** What happens in memory, stays in memory. Treat everything here as sacred and private unless you're explicitly sharing it with the world.
- **No secrets:** Seriously, none. No credentials, no seed phrases, no API keys, no tokens, no private keys. We store **references**, not the keys to the kingdom. (e.g., "Seed vault stored in <system>, last rotated YYYY-MM-DD").
- **Provenance is everything:** Every decision should be a breadcrumb trail. Link back to the artifacts (docs, schemas, commits) that led you here. "Show me proof, not potential."
- **Resist the bitrot:** Keep it clean, keep it current. Content should be short, dated, and pruned with the loving care of a bonsai master.

## The Lay of the Land (The Files)

- `working_set.md`: What's on our minds *right now*. The purpose, the constraints, the next glorious step.
- `decisions.md`: The big choices, the points of no return, and the "why" behind them.
- `open_loops.md`: Our sacred quest log. The promises we've made, the tasks we've undertaken, the questions that keep us up at night. Nothing gets dropped.
- `glossary.md`: The dictionary of our shared language. Stable meanings for our most important terms. (Plays nicely with `symbol_map.shared.json`).
- `session_log_YYYY-MM-DD.md`: The daily journal. An append-only log of our adventures.

## The Rhythm of the Work (The Operating Loop)

1.  First, we return to the meeting place: `../symbol_map.shared.json`.
2.  Then, we declare our intentions: update `working_set.md` before diving into the work.
3.  As we make our way, we record the irreversible and important choices in `decisions.md`.
4.  We track our quests and promises in `open_loops.md`.
5.  And at the end of a long day, we write a short entry in our `session_log_YYYY-MM-DD.md`.

## Drift Tracking (Are we still us?)

If you're tracking an "alignment/drift" score, jot it down in `working_set.md` and tell us how you got there. We don't hide our failures here. We build a workflow that's resilient, non-blocking, and honest. Unless it's a "stop the world" kind of critical, we keep moving.

    ___
   / 🐢 \
  |  ._. |   "this is fine"
   \_____/
    |   |
