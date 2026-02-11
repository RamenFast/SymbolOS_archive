# SymbolOS Web — React + Vite + TypeScript

The **React** frontend for SymbolOS. A component-based SPA with Framer Motion animations,
canvas particle effects, 3D card tilt, and the full Dungeon Explorer experience.

## Quick Start

```bash
cd web
npm install
npm run dev          # → http://localhost:5173
```

## Build for Production

```bash
npm run build        # outputs to ../dist/
npm run preview      # preview production build
```

## Architecture

```
web/
├── index.html            Vite entry point
├── package.json          Dependencies (React 19, Framer Motion 12, Vite 6)
├── vite.config.ts        Vite config (React plugin, builds to ../dist)
├── tsconfig.json         TypeScript strict mode
└── src/
    ├── main.tsx          React root mount
    ├── App.tsx           Main app — mode bar, views, overlays
    ├── App.css           All styles (CSS variables, dungeon, chromacore)
    ├── data.ts           Typed data — agents, floors, rooms, rings, wisdoms
    └── vite-env.d.ts     Vite type refs
```

## Features

| Feature | Implementation |
|---------|---------------|
| **Mode switching** | `AnimatePresence` + crossfade between Dungeon/Chromacore |
| **Particle field** | Canvas-based 2D particles (much smoother than DOM) |
| **Agent cards** | 3D perspective tilt on mouse move via `onMouseMove` |
| **Floor collapse** | `AnimatePresence` with height animation |
| **Ring wheel** | Animated pulse on active ring (cycles every 2s) |
| **Search** | Real-time filter with query highlighting |
| **Dice roller** | d20 roll → wisdom quote (6s auto-dismiss) |
| **Fox popup** | Toggle reveal with spring animation |
| **Konami code** | `↑↑↓↓←→←→BA` → Mercer Lantern overlay |
| **HP bars** | Animated fill on mount via Framer Motion |
| **Header glow** | HSL hue cycling border (360° rainbow) |

## Dependencies

- **React 19** — Component library
- **Framer Motion 12** — Animation primitives
- **Vite 6** — Build tool with HMR
- **TypeScript 5.7** — Type safety

Zero runtime CSS framework. Pure CSS variables matching the SymbolOS 1905 palette.

## Relationship to index.html

The static `index.html` at repo root is the **zero-dependency** version with all 11 Chromacore
SVG plates inline. This React app is the **enhanced** version focused on the Dungeon Explorer
with richer animations and component architecture. Both are maintained in parallel.
