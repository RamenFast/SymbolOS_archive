# SymbolOS Chromacore '97

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Rendering Engine                              ║
║  📍 Floor: Ring 4 │ Difficulty: ⭐⭐⭐ │ Loot: A Complete Visual System ║
║  🎨 Color: Violet (#8B00FF)                                  ║
║                                                              ║
║  Psychedelic-core documentation. Terminal aesthetics.         ║
║  Structural grace. Looks like a demoScene intro,             ║
║  but reads like Arch Wiki.                                   ║
╚══════════════════════════════════════════════════════════════╝

```
  (¬_¬)
  <)  )╯  guardian of structural kindness
   /  \   — Rhynim watches over every page
```

> **Static SVG Documentation Artifact System — by Rhynim**

---

## What Is Chromacore?

Chromacore '97 is a documentation rendering engine built on psychedelic-era terminal aesthetics. Each page operates its own independent color system while maintaining strict typographic readability.

Inspired by [gentoo.org](https://gentoo.org), [wiki.archlinux.org](https://wiki.archlinux.org), [texttospeaker.org](https://texttospeaker.org), and [bedrock.dev](https://bedrock.dev) — this system merges clean technical documentation with demoScene visual intensity.

### Design Principles

- **Psychedelic edges, calm centre** — Swirling color bands at header/footer; white-on-dark readable body
- **10 plate systems** — Per-character color, 8×8 grid, monospace-first
- **Embedded via `<img>`** — Downloadable SVG export; GitHub-embeddable
- **Rhynim watches** — Every page has a guardian

---

## Architecture

### Palette Engine

```
getPalette(ti, fi, char, mode) → per-character suite
 ├── generateGradientStops(mode) → CSS gradient string
 ├── mapperFnAllColors(mode)     → schema-compatible coloring
 ├── Rendition Override Layer    → priority accent coloring
 └── Layout System               → target system
```

### Rendering Pipeline

```
SVGGrid Component      → 8×10 character renderer
├── Layout System      → per-page style algorithm
└── Export             → downloadable SVG output
```

---

## Plate Directory

| # | Plate | Style | Colors |
|---|---|---|---|
| 01 | **TI Accuracy Core** | Cool blue geometric precision | `#0066FF` → `#003399` |
| 02 | **TI Expression Spectrum** | Rainbow gradient header bands | Full spectrum |
| 03 | **FI Accuracy Warm** | Amber tech manual warmth | `#FFAA55` → `#CC6600` |
| 04 | **FI Expression Braveheart** | Vertical pink gradient | `#FF69B4` → `#8B008B` |
| 05 | **Psy97 Scroll Mode** | Psychedelic rotating bands | Full chromatic |
| 06 | **NFO Slab Classic** | Boxed BBS/warez layout | Cyan + box-drawing |
| 07 | **Palette Engine Spec** | Harmonized gradient rules | Systematic |
| 08 | **Rhynim Profile** | Cyan persona + ASCII guardian | `#00FFFF` minimal |
| 09 | **Accessibility Mode** | High-contrast greyscale | `#FFFFFF` / `#000000` |
| 10 | **Splash Archive** | 4-quadrant comparison | Mixed |

---

## Usage

### View in browser
```
open docs/chromacore/chromacore.html
```

### Embed in GitHub markdown
```html
<!-- GitHub SVG Embedding Method -->
<img src="docs/chromacore/plates/01_ti_accuracy.svg" alt="TI Accuracy Core" />
```

**Notes:**
- No external CSS dependencies
- No `<foreignObject>` (blocked by GitHub)
- All colors inline on `<text>` elements
- Font fallback: Courier New (universal)

---

## GitHub Compatibility

All SVG exports use inline `<text>` elements with explicit fill colors and `Courier New` fallback fonts. This ensures full rendering compatibility when embedded in GitHub README files via `<img src="file.svg">`.

---

## File Map

```
docs/chromacore/
├── README.md              ← you are here
├── chromacore.html        ← interactive viewer + plate navigator
└── plates/
    ├── 00_splash.svg
    ├── 01_ti_accuracy.svg
    ├── 02_ti_expression.svg
    ├── 03_fi_accuracy.svg
    ├── 04_fi_expression.svg
    ├── 05_psy97_scroll.svg
    ├── 06_nfo_slab.svg
    ├── 07_palette_engine.svg
    ├── 08_rhynim_profile.svg
    ├── 09_accessibility.svg
    └── 10_splash_archive.svg
```

---

*SymbolOS Chromacore '97 :: Rhynim watches*

☂🦊🎨
