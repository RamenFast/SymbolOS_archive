# SymbolOS Memory (Internal)

```
  (•_•)
  ( (  )   "hmm... is this R0?"
   /  \
```

This document defines internal expectations for storing, retrieving, and governing memory in SymbolOS. It's the map of our own mind.

External-facing policy: [docs/memory.md](../docs/memory.md).

## Poetry layer (Fi+Ti mirrored) 🪞

*A little reminder of the core loop.* 

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

## Data model (recommended)

Here's the shape of a single memory. Think of it like a trading card for a thought.

### MemoryRecord
- `id` (string, stable)
- `type` (`fact|preference|plan|story`)
- `title` (short string)
- `summary` (short string)
- `details` (optional; redacted by default)
- `tags` (array)
- `scope` (`private|party|dm|public`)
- `ttlSeconds` (optional)
- `provenance`
  - `source` (`user_manual|assistant|system`)
  - `createdAt` (RFC3339)
  - `updatedAt` (RFC3339)
  - `evidence` (array of redacted pointers)

## Safety requirements

```
   💀
  /|🗝️|\    "Prove your worth!"
   / \
```

*The Skeleton Gatekeeper has some rules for us. They're not suggestions.* 

- **Never store secrets.** Not even in your secret diary. Not even with a secret handshake.
- **Enforce classification gates before read/write.** We check IDs at the door.
- **Always allow deletion and export.** Your memories are yours. You can always take them home.
- **Provide a “memory ledger” view of what exists.** Show your work. Make it easy to see what we know.

## Capture flow

*Gotta catch 'em all... responsibly.*

1) Candidate memory created (shadow) - *A thought appears!* 
2) Ask confirmation to persist (unless user enabled auto-save for that type) - *Should we write this down?* 
3) Persist with provenance, TTL, scope - *Okay, it's in the journal.* 
4) Emit an audit event - *And we logged that we logged it.* 

## Retrieval flow

*And when we bring it back up...*

- Prefer summaries and links over raw content. - *Just the headlines, please.* 
- Provide “why this came up”. - *Don't be random.* 
- Offer quick actions: `Edit`, `Delete`, `Mute this type`. - *Easy peasy.* 

## Decay, review, and correction

*Memories fade, and that's okay. We just need a graceful way to handle it.*

- Implement periodic review prompts for facts. - *"Hey, is this still true?"*
- If user says “that’s wrong”, mark prior as superseded, do not silently overwrite. - *We learn, we grow, we don't pretend we were right all along.*

## Integration with metaemotion and DND

*This is where it gets a little tricky, like sorting socks in the dark. But we can do it.*

- DND stories must be clearly tagged as `in_world` vs `out_of_world`. - *Is this cannon or fan-fic?*
- Metaemotion memories are high-risk for mislabeling; store as preference (“I prefer not to be prompted…”) rather than as fact. - *Feelings aren't facts, but they are important data.* 

## Schema references

*For the detail-oriented folks who love a good schema.*

- Structured record: `docs/memory_record.schema.json`

```
    ___
   / 🐢 \    "this is fine"
  |  ._. |
   \_____/
    |   |
```
