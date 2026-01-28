# Local LLM on Windows (Vulkan) — RX 6750 XT (Internal)

This is the "🧠⚡" path: run a local LLM server on-device using your AMD GPU.
It is designed to be:
- ☂️ private-by-default (no cloud)
- 🧾 auditable (explicit scripts + paths)
- 🧬 meeting-place compatible (discoverable via `symbol_map.shared.json`)

## Goal (working prototype)
- A local HTTP server that accepts chat/completions (OpenAI-ish compatible) and runs inference using Vulkan GPU offload.

## Folder conventions (repo-local)
- `local_ai/bin/` — put the `llama-server.exe` (or `server.exe`) binary here
- `local_ai/models/` — put a single GGUF model here
- `scripts/` — runnable PowerShell helpers

These folders are ignored by git via `.gitignore`.

## Step 0 — sanity checks
In PowerShell:
- `nvidia-smi` should NOT be required (AMD)
- Ensure AMD Adrenalin drivers are installed and up to date.

## Step 1 — get llama.cpp (recommended: prebuilt, still hacker)
Option A (fastest): download a prebuilt llama.cpp Windows release and extract it.
- From the release, locate a server binary (often `llama-server.exe`).
- Copy it into: `local_ai/bin/`

Option B (full control): build llama.cpp yourself.
- Requires CMake + a C/C++ toolchain.
- Build with Vulkan enabled.

## Step 2 — choose ONE model (disk-efficient)
Pick one GGUF to start.

Suggested starting points (good leverage per GB):
- 8B instruct @ `Q4_K_M` (~4–6 GB): better reasoning, fits your 12GB VRAM for partial offload.
- 3B–4B instruct @ `Q4_K_M` (~2–3 GB): faster + lighter, weaker reasoning.

Place exactly one model at:
- `local_ai/models/<model>.gguf`

## Step 3 — run the server (prototype)
Use the repo script:
- `scripts/run_llama_server.ps1`

Or run the VS Code task:
- `Local LLM: start llama.cpp server (Vulkan)`

It will:
- auto-pick the first `*.gguf` in `local_ai/models/`
- start the server on `http://127.0.0.1:8080`
- attempt GPU offload via `--ngl` (if supported by your binary)

## Step 4 — quick test
Once running, hit the health endpoint in a browser:
- `http://127.0.0.1:8080/`

Or curl (PowerShell):
- `Invoke-RestMethod http://127.0.0.1:8080/`

## Troubleshooting
- If it runs but is slow: increase GPU layers (`--ngl`) until VRAM limits bite.
- If it crashes on startup: reduce context size, lower `--ngl`, verify Vulkan runtime/drivers.
- If you don’t have `llama-server.exe` in your release: look for any server binary, or build from source.

## Next evolution (SymbolOS integration)
- Add a small "Local Compute" doc in `docs/` once we decide what’s safe-to-share.
- Add a VS Code task to start/stop the server.
- Add a SymbolOS client wrapper that logs prompts/results to `memory/session_log_*.md` (🧾 provenance).
