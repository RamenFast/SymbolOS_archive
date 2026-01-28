# SymbolOS Memory (Internal)

This document defines internal expectations for storing, retrieving, and governing memory in SymbolOS.

External-facing policy: [docs/memory.md](../docs/memory.md).

## Poetry layer (Fi+Ti mirrored) 🪞

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

## Data model (recommended)

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
- Never store secrets.
- Enforce classification gates before read/write.
- Always allow deletion and export.
- Provide a “memory ledger” view of what exists.

## Capture flow
1) Candidate memory created (shadow)
2) Ask confirmation to persist (unless user enabled auto-save for that type)
3) Persist with provenance, TTL, scope
4) Emit an audit event

## Retrieval flow
- Prefer summaries and links over raw content.
- Provide “why this came up”.
- Offer quick actions: `Edit`, `Delete`, `Mute this type`.

## Decay, review, and correction
- Implement periodic review prompts for facts.
- If user says “that’s wrong”, mark prior as superseded, do not silently overwrite.

## Integration with metaemotion and DND
- DND stories must be clearly tagged as `in_world` vs `out_of_world`.
- Metaemotion memories are high-risk for mislabeling; store as preference (“I prefer not to be prompted…”) rather than as fact.

## Schema references
- Structured record: `docs/memory_record.schema.json`
