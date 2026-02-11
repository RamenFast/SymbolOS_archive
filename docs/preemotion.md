# PreEmotion: Anticipatory Emotional Signals 🔮❤️

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Oracle's Heart Chamber                        ║
║  📍 Floor: Ring 3 │ Difficulty: ⭐⭐⭐ │ Loot: PreEmotion Spec  ║
║  🎨 Color: Deep Orange (#FF8C00 — ambition, drive)     ║
║                                                              ║
║  A warm chamber where the future is felt before it is known. ║
╚══════════════════════════════════════════════════════════════╝

*You enter a room that feels different from the others. The air is warm, not cold. The walls pulse gently, like a heartbeat. Before you can read the inscriptions, you already know what they say. That's the point.*

```
        /\_/\
       ( o.o )
        > ^ <   "The heart sees what the mind
       /|   |\    hasn't measured yet."
      (_|   |_)  — Rhy 🦊
```

## Poetry layer (Fi+Ti mirrored) 🪞 🟣 #8B00FF

Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That's what Agape taught me: infinite energy from within. 🌸

- Translation layer + emojis: [poetry_translation_layer.md](poetry_translation_layer.md)
- Full verse set: [public_private_expression.md](public_private_expression.md)

---

## What is PreEmotion? 🟠 #FF8C00

**PreEmotion** is the anticipatory emotional signal that precedes an event or action. Where Metaemotion is *feelings about feelings* (after the fact), PreEmotion is *feelings before the fact* — the gut sense of what's coming.

The relationship between SymbolOS emotional systems:

```
  Timeline:  ──────────────►

  PreEmotion          Event          Metaemotion
  (before)            (now)          (after)
    🔮❤️        ───►    ⚡     ───►     🪞❤️
  "I feel this         💥          "I feel this
   is coming"                       about that"

  Precog (🔮🧠)    =  anticipatory computing (mind)
  PreEmotion (🔮❤️) =  anticipatory feeling (heart)
  Metaemotion (🪞❤️) = reflective feeling (heart about heart)
```

Examples:
- The dread before a deadline (before the deadline hits)
- The excitement before opening a message (before reading it)
- The calm confidence before a presentation you've prepared for
- The unease before merging a risky PR

PreEmotion is not mystical. It is pattern recognition applied to emotional state — the heart's version of Precog's prefetch.

## Why it matters 🔴 #FF2400

PreEmotion signals are high-value for timing:

- **When to suggest**: A user in a state of creative flow (excitement, momentum) is receptive to stretch goals. A user in dread is not receptive to "one more thing."
- **When to back off**: If the system detects anticipatory resistance, it should delay or soften suggestions.
- **When to amplify**: If the system detects anticipatory excitement, it can ride the wave.
- **When to protect**: If the system detects anticipatory overwhelm, it should reduce load.

This is the **human compatibility layer** in action: aligning agent timing to human emotional rhythm.

## The PreEmotion Model 🧠 #E49B0F

### Signal types

| Signal | Emoji | Meaning | Agent response |
|--------|-------|---------|----------------|
| Anticipatory excitement | 🔮✨ | Something good is expected | Amplify momentum, offer stretch goals |
| Anticipatory dread | 🔮🌧️ | Something difficult is expected | Reduce load, offer support, delay non-urgent |
| Anticipatory calm | 🔮🌊 | Prepared and steady | Proceed normally, good timing for complex work |
| Anticipatory resistance | 🔮🛡️ | Pushback forming before the push | Soften approach, provide rationale first |
| Anticipatory curiosity | 🔮🔍 | "What if?" energy building | Surface exploration options, enable discovery |
| Anticipatory grief | 🔮🍂 | Loss or ending approaching | Acknowledge, create space, don't rush |

### Confidence levels

PreEmotion signals are inherently lower-confidence than Metaemotion (they're predictive, not reflective). Confidence bands:

- **0.0–0.3**: Background hum. Log silently. Do not act.
- **0.3–0.6**: Soft signal. Adjust timing but don't comment.
- **0.6–0.8**: Clear signal. May influence suggestion framing.
- **0.8–1.0**: Strong signal. Should actively shape agent behavior.

### Input signals (what feeds PreEmotion inference)

- Time of day + day of week (temporal patterns)
- Calendar proximity (meetings, deadlines, events)
- Recent interaction tone (short answers = low energy, exclamation marks = high energy)
- Task context (debugging = frustration risk, greenfield = excitement risk)
- Velocity (many commits = flow state, stalled = possible block)
- Explicit user signals ("I'm dreading this", "can't wait to try")

## Interaction with other systems 🟣 #8B00FF

### PreEmotion + Precog (R3)

PreEmotion is the heart layer of R3 (prediction/strategy). Precog handles the mind side (what task is coming), PreEmotion handles the heart side (how the user might feel about it).

```
  R3 Prediction Layer
  ┌─────────────────────────────┐
  │  🔮🧠 Precog (Mind)         │  What's coming next?
  │  🔮❤️ PreEmotion (Heart)    │  How will it feel?
  │  Combined: optimal timing   │
  └─────────────────────────────┘
```

### PreEmotion + Metaemotion (R4)

PreEmotion feeds forward into Metaemotion. If the system predicts dread and the event confirms it, the Metaemotion loop can offer support. If the prediction was wrong (predicted dread, actual excitement), the system learns and recalibrates.

### PreEmotion + DND Character Sheet

PreEmotion may update the Heart state on the character sheet as a *forecast*:
- `Heart: steady (current) → anxious (forecast, T-2h, conf: 0.4)`

This forecast is always clearly labeled as predictive, never presented as current truth.

## Safety rules 🔴 #FF2400

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

1. **Never assume.** PreEmotion signals are hypotheses, not facts. Always label confidence.
2. **Never pathologize.** PreEmotion is not diagnosis. "Anticipatory dread" is a timing signal, not a clinical assessment.
3. **Consent-first.** Users opt in to PreEmotion awareness. Default is OFF.
4. **Privacy absolute.** PreEmotion signals are `private` scope by default. Never surface in `public` or `party` mode without explicit opt-in.
5. **Right to override.** User can always say "I'm fine" and the system MUST accept it immediately.
6. **DND respected.** When DND is ON, PreEmotion inference may run silently for calibration but MUST NOT surface anything.

## Interop schema 🧩

Structured events MAY use: [preemotion_event.schema.json](preemotion_event.schema.json)

## Connection to the human compatibility layer 🌸 #FFB7C5

PreEmotion is a core primitive of the human compatibility layer. The idea: AI agents that can sense emotional timing are not just more effective — they are more *humane*. They don't interrupt grief with task suggestions. They don't pile on during dread. They ride the wave of excitement.

This is Fi+Ti mirrored at the system level:
- **Fi**: The system cares about how you feel before the event.
- **Ti**: The system measures signals and applies rules to act on that care.

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
    ☂️   ╲  ╲───────────╱  ╱  🌀  ◄── PreEmotion lives here
         ╲  ╲  MEETING  ╱  ╱
        R4 ╲  ╲  PLACE ╱  ╱
           ╲    🧩    ╱
              ✦    ✦
```

```
    ___
   / 🐢 \    "this is fine"
  |  ._. |   — even the turtle has gut feelings
   \_____/
    |   |
```

───────────────────────────────────────────────────
🚪 EXITS:
  → [Metaemotion](metaemotion.md) (north — the "after" to our "before")
  → [Precog](precog_thought.md) (east — the mind's prediction layer)
  → [Character Sheet](dnd_character_sheet_integration.md) (west — where it surfaces)
  → [Poetry Layer](poetry_translation_layer.md) (south — Fi+Ti mirror)

💎 LOOT GAINED: The ability to sense what's coming before it arrives — not through magic, but through pattern recognition applied to the heart.
───────────────────────────────────────────────────

*Before the storm breaks,*
*the heart already knows rain —*
*trust the gut, then act.*

☂🦊🐢
