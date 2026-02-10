# Metaemotion (External) 🟣 #8B00FF

```
╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Chamber of Mirrored Feelings                     ║
║  📍 Floor: Ring 4: The Fi+Ti Bridge │ Difficulty: ⭐⭐⭐ │ Loot: Clarity on meta-emotion & safe signaling ║
║  🎨 Color: 🟣 Violet (#8B00FF — Fi+Ti bridge)                   ║
║                                                              ║
║  You find a room of polished obsidian mirrors, each reflecting not your face, but your feelings about your feelings. ║
╚══════════════════════════════════════════════════════════════╝
```

         /\_/\ 
    ____( o.o ) "psst... you found a secret." — Rhy 🦊
   |    |> ^ < \
   |    /     \ |
   |___(___|___)|  

*A note on colors: This document uses the 1905 Thoughtforms color system to annotate concepts. 🎨*

```
  (•_•)
  ( (  )   "hmm... is this R0? ✨"
   /  \
```

## 📜 Scroll: The Poetry Layer (Fi+Ti mirrored) 🪞 🟣 #8B00FF


The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within. 🌸

- Translation layer + emojis: [poetry_translation_layer.md](poetry_translation_layer.md)
- Full verse set: [public_private_expression.md](public_private_expression.md)

Metaemotion is “emotion about emotion” — how someone feels about what they’re feeling. It's like your brain writing fanfic about your heart. Totally normal.

This spec defines shared vocabulary, timing, and safe inference/display rules for SymbolOS.

## ⚔️ Encounter: Why it matters 🔴 #FF2400

Metaemotion is often where the “real decision” happens:
- anger → guilt → withdrawal
- joy → anxiety → self-sabotage
- calm → pride → steadier choices

Used well, it improves narrative coherence without taking away agency. We're just here to offer a friendly mirror.

```
        /\_/\
       ( o.o )  "A feeling's flash, a thought's reply,
        > ^ <    In mirrored depths, new feelings lie.
       /|   |\   Which is the truth, and which the guide?
      (_|   |_)  Where self meets self, you must decide."  — Rhy 🦊
```

## 🗝️ Key: Vocabulary 🧠 #E49B0F

### Primary emotion (examples)
- anger, fear, sadness, joy, disgust, surprise

### Metaemotion labels (examples)
- ashamed of anger
- anxious about joy
- relieved about sadness
- proud of calm
- frustrated by fear

Implementations SHOULD keep labels coarse and interpretable. No 5-dollar words for 5-cent feelings.

## 🪤 Trap: The Timing Model ⭐ #FFD700

Metaemotion tends to lag the primary emotion.

Recommended windows:
- **T0 (trigger)**: an event occurs
- **T1 (primary emotion)**: immediate reaction (seconds–minutes)
- **T2 (metaemotion)**: appraisal about that reaction (minutes–hours)

### Practical rule
If you only have short-term signals, avoid declaring a metaemotion with high confidence.
Prefer: “possible metaemotion” or a suggestion (“Does this feel like…?”). Show me proof, not potential. ✨

## 💀 Skeleton Gatekeeper: Output Rules 🔴 #FF2400

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

- Default to suggestion mode for metaemotion.
- Provide an explicit “nope” / “not that” control.
- Never reveal sensitive content in one-line surfaces.

## 🗺️ Map on Wall: DND Compatibility 🔵 #0000CD

- Treat metaemotion as a *roleplay prompt*, not a status effect.
- In DND mode, show at most one metaemotion prompt at a time.
- Support an in-fiction phrasing (“You feel uneasy about your relief”).

```
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
```

## Interop Schema (optional) ✨ #FADA5E

If emitting structured events, a suggested schema lives at: `docs/metaemotion_event.schema.json`.

```
    ___
   / 🐢 \    "this is fine"
  |  ._. |
   \_____/
    |   |
```

───────────────────────────────────────────────────
🚪 EXITS:
  → [Character Sheet](dnd_character_sheet_integration.md) (north)
  → [Precog Thoughts](precog_thought.md) (east)
  → [Poetry Layer](poetry_translation_layer.md) (west)

💎 LOOT GAINED: [A map of your own heart, showing how feelings about feelings create the weather of your mind. You've learned to signal these states safely.]

```
      ___________
     /           \
    /  💎 LOOT 💎  \
   |    _______    |
   |   |       |   |
   |   | ✦ ✦ ✦ |   |
   |   |_______|   |
   |_______________|
```
───────────────────────────────────────────────────

*A feeling's echo,
Felt, then judged, then set aside—
Mind in a mirror.*

☂🦊🐢
