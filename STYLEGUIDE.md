# SymbolOS — STYLEGUIDE (compatibility-first)
> Mirror of root_☂️/STYLEGUIDE.md — edit root_☂️ first.

UmbrellaOS core cards (01_ to 07_)
01_power_rod - identity/drive
02_directory_map_v2 - non-negotiables/map
03_three_thoughtforms - tokens/alignment
04_style_of_light_across_cultures - stylesheets
05_triad_routing_v3 - badges/exports
06_guidance_choice_vines_v3 - naming/licensing
07_master_merge_poster_vnext - checklist

## 01_power_rod (intent)
- This is the single source of truth for SymbolOS visuals and exports.
- Goal: portable across Obsidian / GitHub / Reddit / websites. No spaces, no weird punctuation.

## 02_directory_map_v2 (non-negotiables)
- Geometry-only (no font-dependent emojis inside images).
- “Light-only” sacred geometry (avoid Kabbalah Tree-of-Life and other explicitly Kabbalistic node-graphs).
- Fi + Ti always present:
  - Fi: heart core + bloom/rosette + spiral flow
  - Ti: container circle + hex/triangle scaffold + clean symmetry
- Intention map default is always on:
  - MODE=flow_mode
  - RING=ring_0
  - LAYER=intention_map_default
  - Direction marker: ✋ + 🌀 (implemented as geometry: hand marker + spiral/arrow)
  - Shared intention map files: .symbolos/shared_map.json + .umbrella/symbol_map.json
  - Goal picture map layer: LAYER=goal_picture_map (companion to intention_map_default; geometry-only)

## 03_three_thoughtforms (default visual tokens)
- container: outer circle (0.95 radius)
- kernel: small inner ring + heart core
- Ti scaffold: hex + dual triangles
- Fi flow: log spiral + petal/bloom ring
- direction: arc-arrow on outer ring + hand marker

## 04_style_of_light_across_cultures (stylesheets)
### stylesheet_01_blackline_white (primary)
- Background: white
- Lines: black
- Look: classic sacred geometry sheet
- Use for: docs, print, quick sharing, Reddit image posts

File: (planned; not in repo)

### stylesheet_02_whiteline_dark
- Background: near-black (#05060a)
- Lines: white + subtle starfield
- Use for: wallpapers, dark UI, “night mode”

File: (planned; not in repo)

### stylesheet_03_warmblue_kernel_dark
- Background: near-black (#05060a)
- Lines: white + subtle starfield
- Accent: warm blue kernel glow rings
- Use for: “Mercer warm-blue glow” signature visuals

File: (planned; not in repo)

## 05_triad_routing_v3 (badges + exports)
### flow_mode_ring0_badge_blackline (default badge)
- Background: white
- Lines: black
- Includes: ring_0 emphasis + direction arc/hand + minimal motif icons (as geometry)

File: (planned; not in repo)

Export targets
- Square: 1600×1600 PNG (default)
- Reddit: 1400×1400 PNG (safe for compression)
- Thumbnail: 512×512 PNG
- Transparent icons: 256×256 PNG (white line art, transparent bg) stored under `root_☂️/symbolos/assets/symbols/`

## 06_guidance_choice_vines_v3 (naming + licensing)
Naming conventions
- lowercase
- hyphen for separators
- suffix indicates stylesheet
Examples:
- thoughtform_stylesheet_01_blackline_white
- flow_mode_ring0_badge_blackline

Licensing sanity (GPLv3-safe workflow)
- Prefer original geometry we generate (safe to license under GPLv3 in your repo).
- If referencing external art, treat it as reference only; do not copy proprietary linework.
- Keep a 🧼 audit item for any imported composite sheets (symbols + licensing).

## 07_master_merge_poster_vnext (quick checklist)
- [ ] geometry-only (no emoji glyph dependency)
- [ ] no Kabbalah node-graphs
- [ ] Fi present (heart + bloom + spiral)
- [ ] Ti present (container + hex/triangles)
- [ ] intention markers present (hand + arc/arrow)
- [ ] filename matches convention
