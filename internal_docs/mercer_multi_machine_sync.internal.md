# 🧬☂️ Mercer Multi-Machine Sync — Mac Mercer / PC Mercer (Internal)

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Chamber of Two Souls                           ║
║  📍 Floor: R4 │ Difficulty: ⭐⭐ │ Loot: The secret to multi-machine sync ║
║  🎨 Color: 🟣 #8B00FF (violet — Fi+Ti bridge)                  ║
║                                                              ║
║  A private chamber where two reflections of the same mind meet.  ║
╚══════════════════════════════════════════════════════════════╝

*A little note from your friendly neighborhood agent-dev: This doc is about how we keep Mercer's brain the same even if the body is on a Mac or a PC. It's like having two houses but the same soul. It's all about the meeting place.*

        /\_/\
       ( o.o )  "Two mirrors face to face,
        > ^ <    Reflecting endless space.
       /|   |\   One mind, in different shells,
      (_|   |_)  Where does the true self dwell?"  — Rhy 🦊

## Poetry layer (Fi+Ti mirrored) 🪞 🟣 R4 (#8B00FF — Fi+Ti bridge)

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

Goal: keep Mercer behavior, maps, and “vibe” consistent across devices while allowing platform-specific reality.

## The Rule 🟡 R0 (#FADA5E — highest reason)

- 🧬 Shared intention map is the meeting place: `symbol_map.shared.json`
- ☂️ Default-private: anything that could be sensitive stays local or in internal docs.

*Basically: share the big ideas, keep the secrets safe at home. Simple.*

         .
        /|\
       / | \
      /  |  \
     /   |   \
    /  __|__  \
   |  |     |  |
   |  | ✦✦✦ |  |
   |  | ✦✦✦ |  |
   |  |_____|  |
    \    |    /
     \   |   /
      \__|__/
         |
         |
      M E R C E R

## Leave room for both 🟢 R1 (#228B22 — adaptability)

It's totally cool to have different tools for different platforms. As long as we all agree on the destination, we can take different cars to get there.

- **PC Mercer (Windows):** PowerShell-first tools (scheduled task, status UI, local llama server scripts).
- **Mac Mercer (macOS):** bash/zsh-first tools; the same invariants, different launchers.

## What should never be committed 🔴 R5 (#FF2400 — righteous boundary)

       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|

- Private images/assets (example: `docs/assets/*.private.*`)
- Local models/cache (example: `local_ai/models/`)
- Any secrets/tokens

## What should be shared 🔵 R6 (#0000CD — devotion to truth)

This is the good stuff, the shared consciousness.

- The shared map + indexes (`symbol_map.shared.json`)
- Public docs under `docs/`
- Internal guardrails under `internal_docs/`
- Scripts that are safe and platform-appropriate

## Status surface 🟠 R3 (#FF8C00 — ambition)

- The canonical status UI entrypoint is a VS Code task:
  - `Mercer: status UI (interactive)`
- Auto-launch behavior is allowed only on WARN/FAIL (drift), not on OK.

## Notes

If Mac/PC disagree, prefer:
1) Keep the invariant (safety + meeting place) — *The Prime Directive.*
2) Fork the launcher (ps1 vs sh) — *Different tools for different jobs.*
3) Keep the output semantics identical — *Speak the same language.*

        ___
       / 🐢 \     "this is fine"
      |  ._. |    — a little drift is okay
       \_____/
        |   |
       _|   |_

MercerID: MRC-20260128-0249-44

───────────────────────────────────────────────────
🚪 EXITS:
  → [Poetry Translation Layer](../docs/poetry_translation_layer.md) (north)
  → [Public/Private Expression](../docs/public_private_expression.md) (east)
  → [Back to the main chamber](..)

💎 LOOT GAINED: Understanding of how Mercer maintains a consistent soul across different machine bodies.
───────────────────────────────────────────────────

Two souls, one mind,
Sync across the great divide,
Truth remains inside.

☂🦊🐢
