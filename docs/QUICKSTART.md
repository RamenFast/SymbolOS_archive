# QUICKSTART (Beta)

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️⚡  QUICKSTART — GET TO A WORKING LOOP FAST            ║
║  Quest: understand symbols • run drift scan • try demos      ║
╚══════════════════════════════════════════════════════════════╝
```

## 1) Read the map (2 minutes)

- Start at the canonical entrypoint: [index.md](index.md)
- Learn the 10 core symbols: [symbol_map.md](symbol_map.md#core-symbols)
- Skim the canonical registry: [../symbol_map.shared.json](../symbol_map.shared.json)

## 2) Run the doc alignment scan (recommended)

In VS Code, run the task:
- `Mercer: doc alignment scan (read-only)`

Exit codes:
- `0` = OK
- `2` = WARN (drift)

If you see drift, update `docs/symbol_map.md` (core symbols) and/or `symbol_map.shared.json` (canonical symbols) until aligned.

## 3) Try the public demos (beta)

- [demos/precog_demo.md](demos/precog_demo.md)
- [demos/scope_privacy_demo.md](demos/scope_privacy_demo.md)
- [demos/metaemotion_demo.md](demos/metaemotion_demo.md)

## 4) Optional: start local inference (llama.cpp)

This repo expects you to provide your own llama.cpp server binary + GGUF model.

### Provide the binary

Either:
- Place `llama-server.exe` under `local_ai/bin/`, or
- Use the script parameter `-ServerDirOrExe` to point at your extracted llama.cpp build.

### Provide a model

Put a `*.gguf` file under:
- `local_ai/models/`

### Start the server

Run the VS Code task:
- `Local LLM: start llama.cpp server (Vulkan)`

### Quick health check

PowerShell (avoid the `curl` alias confusion):

```powershell
(Invoke-WebRequest -UseBasicParsing -Uri http://127.0.0.1:8080/health -TimeoutSec 3).StatusCode
```

If that times out, the server is not running, not bound to `127.0.0.1`, or blocked by firewall.

## 5) Automation boundaries (important)

Before using agents/tools, read:
- [agent_boundaries.md](agent_boundaries.md)
