# Local LLaMA Design v2

## Objective
Provide a flexible, multi-profile deployment for the local LLaMA agent used in SymbolOS. This v2 design introduces three profiles to accommodate different hardware capabilities and ensures deterministic operation across Ring 0.

## Profiles

### Low-memory profile
- **Hardware**: 4–8 GB RAM devices (e.g. ThinkPad X220).
- **Model**: small quantised model (3–5 B parameters) such as Qwen3‑4B or similar, using quantisation level Q5_K_M or lower.
- **Download**: script will automatically fetch the smallest supported model and verify checksums.
- **Use**: quick intent resolution and shell translation on legacy hardware; limited context length.

### Normal profile
- **Hardware**: 8–12 GB RAM (default desktop/laptop).
- **Model**: Qwen3‑8B Q5_K_M (existing).
- **Download**: default in `setup_local_llama.ps1`.
- **Use**: general tasks, code translation, summarisation.

### Full‑send profile
- **Hardware**: ≥12 GB RAM with GPU or high‑end CPU.
- **Model**: larger models (e.g. Qwen3‑14B or beyond) with optional GPU acceleration via Vulkan.
- **Download**: specify `-Profile full-send` to fetch and unzip. 
- **Use**: heavy reasoning tasks, summarisation of large documents, complex planning.

## Script changes
- Add a `-Profile` parameter to `scripts/setup_local_llama.ps1`. Valid values: `low`, `normal`, `full-send`.
- The script selects model size, quantisation, and download URL based on the profile.
- Create a folder structure `local_ai/models/{profile}` for storing downloaded models.
- Verify model checksums after download.
- Provide clear output messages about memory requirements and next steps.

## Notes
- Do not commit downloaded models to Git.
- Document any additional dependencies (e.g. Vulkan drivers) in `docs/local_ai_requirements.md`.
- This document should be updated whenever a new model or profile is introduced.
