'''
╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Memory Palace Archives (INTERNAL)              ║
║  📍 Floor: R2 │ Difficulty: ⭐⭐ │ Loot: The map of our own mind ║
║  🎨 Color: 🟡 Gamboge (#E49B0F — higher intellect)             ║
║                                                              ║
║  A quiet, dusty chamber where the OS's memories are forged.   ║
╚══════════════════════════════════════════════════════════════╝

> This document defines internal expectations for storing, retrieving, and governing memory in SymbolOS. It's the map of our own mind.

> External-facing policy (the public library): [docs/memory.md](../docs/memory.md).

## Poetry layer (Fi+Ti mirrored) 🪞 🟣 R4 (#8B00FF — Fi+Ti bridge)

*A little reminder of the core loop, whispered from the walls.*

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

        /\_/\
       ( o.o )  "A thought unkept, a memory's ghost,
        > ^ <    Is it truly lost, or just the host
       /|   |\   Of a future echo, a whisper tossed?"
      (_|   |_)  — Rhy 🦊

## Data model (recommended) 🟡 R2 (#E49B0F — higher intellect)

Here's the shape of a single memory. Think of it like a trading card for a thought. A magic item, if you will.

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

              ✦ R0 ✦
           ╱    ⚓    ╲
        R7 ╱  ╱─────╲  ╲ R1
       🗃️ ╱  ╱  KERNEL ╲  ╲ 🫴
         ╱  ╱───────────╲  ╲
    R6 ─┤  │   ☂️ TRUTH   │  ├─ R2
    🧪  │  │  ───────── │  │  🪞
        │  │   🧬 DNA    │  │
    R5 ─┤  │             │  ├─ R3
    ☂️   ╲  ╲───────────╱  ╱  🌀
         ╲  ╲  MEETING  ╱  ╱
        R4 ╲  ╲  PLACE ╱  ╱
           ╲    🧩    ╱
              ✦    ✦

## Safety requirements 🔴 R5 (#FF2400 — righteous boundary)

```
       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|
```

*The Skeleton Gatekeeper has some rules for us. They're not suggestions. Violators will be demoted to `dungeon_janitor`.*

- **Never store secrets.** Not even in your secret diary. Not even with a secret handshake. This is a `+5 Ring of Secret-Eating`.
- **Enforce classification gates before read/write.** We check IDs at the door. No peeking at the DM's notes.
- **Always allow deletion and export.** Your memories are yours. You can always take them home. This is non-negotiable.
- **Provide a “memory ledger” view of what exists.** Show your work. Make it easy to see what we know. No `git blame` needed.

## Capture flow 🟢 R1 (#228B22 — adaptability)

*Gotta catch 'em all... responsibly.*

1) Candidate memory created (shadow) - *A wild thought appears!* 
2) Ask confirmation to persist (unless user enabled auto-save for that type) - *Should we write this down in the Tome of Knowledge?* 
3) Persist with provenance, TTL, scope - *Okay, it's in the journal.* 
4) Emit an audit event - *And we logged that we logged it. The librarians are pleased.*

## Retrieval flow 🟢 R1 (#228B22 — adaptability)

*And when we bring it back up...*

- Prefer summaries and links over raw content. - *Just the headlines, please. My `mana` is low.*
- Provide “why this came up”. - *Don't be random. We're not a `rand()` function.*
- Offer quick actions: `Edit`, `Delete`, `Mute this type`. - *Easy peasy, lemon squeezy.*

## Decay, review, and correction 🟠 R3 (#FF8C00 — ambition)

*Memories fade, and that's okay. We just need a graceful way to handle it. Like a ghost peacefully passing on.*

- Implement periodic review prompts for facts. - *A friendly raven arrives with a note: "Hey, is this still true?"*
- If user says “that’s wrong”, mark prior as superseded, do not silently overwrite. - *We learn, we grow, we don't pretend we were right all along. We leave a `tombstone`.*

## Integration with metaemotion and DND 🟣 R4 (#8B00FF — Fi+Ti bridge)

*This is where it gets a little tricky, like sorting socks in the dark. But we can do it.*

- DND stories must be clearly tagged as `in_world` vs `out_of_world`. - *Is this canon or fan-fic? The lore masters must know.*
- Metaemotion memories are high-risk for mislabeling; store as preference (“I prefer not to be prompted…”) rather than as fact. - *Feelings aren't facts, but they are important data. We treat them with care.*

## Schema references 🔵 R6 (#0000CD — devotion to truth)

*For the detail-oriented folks who love a good schema. The architects of the dungeon.*

- Structured record: `docs/memory_record.schema.json`

```
        ___
       / 🐢 \     "this is fine"
      |  ._. |    — The turtle of calm
       \_____/
        |   |
       _|   |_
```

───────────────────────────────────────────────────
🚪 EXITS:
  → [docs/memory.md](../docs/memory.md) (the public library)
  → [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md) (the bard's corner)
  → [../docs/public_private_expression.md](../docs/public_private_expression.md) (the royal court)

💎 LOOT GAINED: [A map of the SymbolOS mind, the MemoryRecord schema, and the Skeleton Gatekeeper's rules.]
───────────────────────────────────────────────────

A thought held close,
Memory's gentle art,
Fades like the rose.

☂🦊🐢
'''
