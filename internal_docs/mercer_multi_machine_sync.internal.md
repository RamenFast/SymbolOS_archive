# 🧬☂️ Mercer Multi-Machine Sync — Mac Mercer / PC Mercer (Internal)

Classification: internal/private

```
==============================================================
MERCER MULTI-MACHINE SYNC - MAC MERCER / PC MERCER
==============================================================
```

## Poetry layer (Fi+Ti mirrored) 🪞

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

Goal: keep Mercer behavior, maps, and “vibe” consistent across devices while allowing platform-specific reality.

## The rule
- 🧬 Shared intention map is the meeting place: `symbol_map.shared.json`
- ☂️ Default-private: anything that could be sensitive stays local or in internal docs.

## Leave room for both
- **PC Mercer (Windows):** PowerShell-first tools (scheduled task, status UI, local llama server scripts).
- **Mac Mercer (macOS):** bash/zsh-first tools; the same invariants, different launchers.

## What should never be committed
- Private images/assets (example: `docs/assets/*.private.*`)
- Local models/cache (example: `local_ai/models/`)
- Any secrets/tokens

## What should be shared (committed)
- The shared map + indexes (`symbol_map.shared.json`)
- Public docs under `docs/`
- Internal guardrails under `internal_docs/`
- Scripts that are safe and platform-appropriate

## Status surface (keep it consistent)
- The canonical status UI entrypoint is a VS Code task:
  - `Mercer: status UI (interactive)`
- Auto-launch behavior is allowed only on WARN/FAIL (drift), not on OK.

## Notes
If Mac/PC disagree, prefer:
1) Keep the invariant (safety + meeting place)
2) Fork the launcher (ps1 vs sh)
3) Keep the output semantics identical

MercerID: MRC-20260128-0249-44
