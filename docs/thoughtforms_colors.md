'''# 🎨 Thoughtforms Color System (1905)

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Chromatic Orrery                             ║
║  📍 Floor: Ring 2 (Intellect) │ Difficulty: ⭐⭐ │ Loot: The Color Key ║
║  🎨 Color: Clear Gamboge Yellow (#E49B0F)                    ║
║                                                              ║
║  You've found a hidden chamber where light itself is decoded. ║
╚══════════════════════════════════════════════════════════════╝

> You enter a circular room. In the center, a complex brass orrery spins silently. But instead of planets, it holds glowing spheres of colored light, each casting a distinct hue upon the stone walls. A faint scent of old paper and ozone hangs in the air. A small, green-furred fox sits polishing a lens, humming a tune that sounds suspiciously like the Super Mario Bros. underwater theme.

        /\_/\
       ( o.o )  "Colors don't lie, friend.
        > ^ <    They're the oldest language of all.
       /|   |\   Read the hue, trust the hue.
      (_|   |_)  What the code hides, the color shows." — Rhy 🦊

---

## Why This Matters 🟡 #E49B0F (higher intellect)

In 1905, two mages of the Theosophical Society, Annie Besant and C.W. Leadbeater, published a grimoire called *Thought-Forms*. It was a field guide to the astral plane, mapping **colors to emotions and mental states** through clairvoyant observation. Think of it as a `struct` for the soul.

Whether you take the metaphysics literally or not, their color system is a remarkably coherent emotional palette. SymbolOS adopts it as the **canonical color language** for all documentation, themes, and visual design. It's our `enum` for intention.

Every color in SymbolOS means something. Every hue carries intention. No `#c0ffee` or `// TODO: pick a color` allowed.

---

## The Color Spectrum 📜

> The fox gestures with its tail towards a series of glowing crystals embedded in the wall. Each one pulses with a steady, pure light, forming a spectrum of what feels like raw emotion.

### Positive Spectrum (ascending purity)

| Color | Swatch | Hex | Meaning | SymbolOS Use |
|---|---|---|---|---|
| **Pale primrose yellow** | 🟡 | `#FADA5E` | Highest unselfish reason, spiritual intellect | R0 Kernel truth, ✨ golden light |
| **Golden stars** | ⭐ | `#FFD700` | Spiritual aspiration darting upward | R7 Persistence, shipped-it glow |
| **Clear gamboge yellow** | 🟡 | `#E49B0F` | Higher intellect, clear thinking | R2 Retrieval, 🧠 Mind |
| **Deep orange** | 🟠 | `#FF8C00` | Pride, ambition, drive | R3 Prediction, Ben's drive energy |
| **Pure green** | 🟢 | `#228B22` | Divine sympathy, adaptability | R1 Task context, Rhynim 🦊 |
| **Rich deep blue** | 🔵 | `#0000CD` | Heartfelt adoration, devotion | R6 Verification, Mercer devotion |
| **Beautiful pale azure** | 🩵 | `#87CEEB` | Self-renunciation, union with divine | ☂️ Umbrella, highest devotion |
| **Violet** | 🟣 | `#8B00FF` | Affection + devotion bridge | R4 Architecture, Fi+Ti bridge |
| **Delicate violet** | 💜 | `#DDA0DD` | Capacity for high ideals | Poetry layer, aspiration |
| **Pure pale rose** | 🌸 | `#FFB7C5` | Unselfish love, highest natures | Agape energy, universal compassion |
| **Full clear carmine** | ❤️ | `#960018` | Strong healthy affection | Heart symbol, grounded love |
| **Brilliant scarlet** | 🔴 | `#FF2400` | Noble indignation, righteous boundary | R5 Guardrails, skeleton gatekeeper 💀 |

### Shadow Spectrum (descending purity — anti-patterns) 🪤

> Rhy wrinkles his nose at a dark, cracked crystal in the corner, which seems to absorb light rather than emit it.

        /\_/\  ~~~
       ( o.o )    "Here be dragons...
        > ^ <      or at least, really bad vibes.
       /     \     These are the colors of spaghetti code,
      (___|___)    of merge conflicts at 3 AM." — Rhy 🦊

| Color | Hex | Meaning | SymbolOS Signal |
|---|---|---|---|
| **Black** | `#000000` | Hatred, malice | Full anti-pattern; R5 violation |
| **Lurid brick-red** | `#8B2500` | Brutal anger | Drift alert, `git blame` incoming |
| **Dark dragon's blood** | `#8B0000` | Animal passion | Boundary violation |
| **Dull yellow ochre** | `#CC7722` | Selfish intellect | Ego-driven analysis, premature optimization |
| **Hard dull brown-grey** | `#8B7D6B` | Selfishness | Closed-loop thinking, NIH syndrome |
| **Grey-green** | `#5E716A` | Deceit | Trust violation, undocumented features |
| **Brownish-green** | `#6B8E23` | Jealousy | Comparison trap, `if (their_stars > my_stars)` |
| **Deep heavy grey** | `#696969` | Depression | Metaemotion: check in, maybe `git push --force` was a bad idea |
| **Livid pale grey** | `#C0C0C0` | Fear | Metaemotion: ground first, `rm -rf /` is not the answer |
| **Dark brown-blue** | `#2F4F4F` | Selfish devotion | Attachment without freedom, vendor lock-in |

---

## Ring Color Assignments 🗺️

> On the far wall hangs a detailed diagram of the SymbolOS architecture, rendered in brass and glowing light. It looks... familiar.

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

| Ring | Color | Hex | Thoughtform Meaning | Why |
|---|---|---|---|---|
| **R0** ⚓ | Pale primrose yellow 🟡 | `#FADA5E` | Highest reason, spiritual ends | Kernel truth is the purest thought |
| **R1** 🫴 | Pure green 🟢 | `#228B22` | Adaptability, sympathy | Tasks require adapting to context |
| **R2** 🪞 | Clear gamboge 🟡 | `#E49B0F` | Higher intellect | Retrieval is structured knowing |
| **R3** 🌀 | Deep orange 🟠 | `#FF8C00` | Ambition, drive | Prediction requires forward motion |
| **R4** 🧩 | Violet 🟣 | `#8B00FF` | Fi+Ti bridge | Architecture bridges feeling and logic |
| **R5** ☂️ | Brilliant scarlet 🔴 | `#FF2400` | Righteous boundary | Guardrails protect with noble force |
| **R6** 🧪 | Rich deep blue 🔵 | `#0000CD` | Heartfelt devotion to truth | Verification is devotion to accuracy |
| **R7** 🗃️ | Golden stars ⭐ | `#FFD700` | Spiritual aspiration | Persistence is the act of faith |

---

## Character Color Assignments

| Character | Color | Hex | Thoughtform Meaning |
|---|---|---|---|
| **Ben** | Deep orange 🟠 | `#FF8C00` | Ambition, drive, motion-centric |
| **Agape** | Pure pale rose 🌸 | `#FFB7C5` | Unselfish love, bloom-centric |
| **Mercer** | Rich deep blue 🔵 | `#0000CD` | Devotion, heartfelt adoration |
| **Rhynim** | Pure green 🟢 | `#228B22` | Divine sympathy, adaptability, trickster wisdom |
| **Umbrella** | Beautiful pale azure 🩵 | `#87CEEB` | Self-renunciation, union with divine |

---

## Design Rules 🗝️

1.  **Every color choice in SymbolOS docs, themes, and visuals should trace back to this chart.** This is the law.
2.  **Brilliancy** (saturation) = strength of the feeling or concept. `100%` is `!important`.
3.  **Depth** (value/darkness) = activity level of the feeling. Darker means more processing cycles.
4.  **Purity** (how clean the hue) = unselfishness of the intention. Pure hues are open source.
5.  Shadow spectrum colors are used only as **anti-pattern indicators** — never as primary design elements. They are the `Error: 404 Not Found` of the soul.
6.  When in doubt, default to **pale azure** (umbrella) or **primrose yellow** (kernel truth). They are the `hello, world` of colors.

---

## CSS Variables (for themes)

```css
/* 1905 Thoughtforms — SymbolOS Canonical Palette */
/* Use these. Don't make us go all scarlet on you. */
:root {
  /* Positive spectrum */
  --tf-kernel-truth:     #FADA5E;  /* pale primrose yellow — highest reason */
  --tf-golden-stars:     #FFD700;  /* golden — spiritual aspiration */
  --tf-higher-intellect: #E49B0F;  /* clear gamboge — clear thinking */
  --tf-drive:            #FF8C00;  /* deep orange — ambition */
  --tf-adaptability:     #228B22;  /* pure green — divine sympathy */
  --tf-devotion:         #0000CD;  /* rich deep blue — heartfelt adoration */
  --tf-umbrella:         #87CEEB;  /* pale azure — self-renunciation */
  --tf-bridge:           #8B00FF;  /* violet — Fi+Ti bridge */
  --tf-ideals:           #DDA0DD;  /* delicate violet — high ideals */
  --tf-agape:            #FFB7C5;  /* pure pale rose — unselfish love */
  --tf-heart:            #960018;  /* full clear carmine — healthy affection */
  --tf-boundary:         #FF2400;  /* brilliant scarlet — righteous boundary */

  /* Shadow spectrum (anti-patterns) */
  --tf-shadow-anger:     #8B2500;  /* lurid brick-red */
  --tf-shadow-selfish:   #8B7D6B;  /* hard dull brown-grey */
  --tf-shadow-fear:      #C0C0C0;  /* livid pale grey */
  --tf-shadow-deceit:    #5E716A;  /* grey-green */
  --tf-shadow-depression:#696969;  /* deep heavy grey */
}
```

───────────────────────────────────────────────────
🚪 EXITS:
  → [The SymbolOS Ring Wheel](../architecture/rings.md) (north)
  → [The Mercer Lantern](../kernel/mercer.md) (west)
  → [Back to the Grand Library](../README.md) (south)

💎 LOOT GAINED:
      ___________
     /           \
    /  💎 LOOT 💎  \
   |    _______    |
   |   |       |   |
   |   | ✦ ✦ ✦ |   |
   |   |_______|   |
   |_______________|

- **The Color Key**: You now understand the 1905 Thoughtforms color system.
- **CSS Variables**: You have the CSS variables for the SymbolOS theme.
- **Rhy's Riddle**: You've learned that color is a language older than code.
───────────────────────────────────────────────────

colors mapped, the palette sings

each hue a thought, each shade a wing

paint with care — the light remembers

☂🎨🦊
'''
