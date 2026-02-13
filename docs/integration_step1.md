# Integration Step 1 Plan (2026-02-13)

This document outlines the tasks for the initial integration sprint for SymbolOS. The goal is to restructure and unify the private repository and prepare for the MCP + LLaMA upgrade.

## Objectives

- Audit the repository tree and archive outdated scripts, docs and styles into `archive/`.
- Adopt `docs/mercer_webview_theme_v1.css` as the canonical style map; delete legacy style files.
- Tag all docs with maturity (🌱 / 🌿 / 🌳 / 🍃) and classification (public/internal/confidential).
- Add a registry entry for each MCP tool and ensure inputs/outputs and risk levels are documented.
- Upgrade the local LLaMA script to support low‑memory, normal and full‑send profiles.
- Clean up `memory/` by closing or archiving stale logs and open loops.
- Design a Windows GUI concept for Mercer (Rust + Tauri) but defer implementation until the end of Step 1.

## Next Steps

Once this plan is committed, we will begin executing these tasks directly on `main` and create a Tavern entry summarizing progress.
