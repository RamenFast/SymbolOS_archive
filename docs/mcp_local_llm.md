# MCP Local LLM Server

```
╔══════════════════════════════════════════════════════════════╗
║  🧠☂️  MCP LOCAL LLM SERVER — PRIVATE INFERENCE ENDPOINT     ║
║  Quest: stateless cognition without cloud or rate limits     ║
╚══════════════════════════════════════════════════════════════╝
```

**Status: Beta** | Async note: Quantization tuning + context management (Q2 2026)

## Purpose

🧠 **Local inference endpoint** for SymbolOS projects. Runs llama.cpp HTTP server on Windows AMD GPU (Vulkan). No cloud. No API keys. No rate limits. Stateless; full privacy.

## Current Capabilities (Beta)

- `inference_chat` — Chat completion (single-turn or multi-turn)
- `inference_completion` — Text completion
- `inference_embedding` — Generate embeddings for semantic search
- `get_server_status` — Check health, model, context window, GPU memory
- `tokenize` — Count tokens for prompt optimization

## Risk Level

- **read** — Status checks, tokenization (default)
- **write** — Inference calls (default; stateless)
- **sensitive** — None (local-only; no external communication)

## Why Beta?

1. **Quantization tuning** incomplete; Qwen2.5:8b Q4_K_M may need adjustments for memory (Q2 2026)
2. **Context management** rudimentary; no automated windowing for long conversations (Q2 2026)
3. **Token counting** sometimes off-by-one; need validation suite (Q2 2026)

Until full release, this tool is safe for:
- Single-turn inference (no risk; stateless)
- Embedding generation (safe; local-only)
- Status monitoring (no risk)

## Hardware Specification

```
Device: AMD RX 6750 XT (12 GB VRAM)
Acceleration: Vulkan (llama.cpp)
Endpoint: http://127.0.0.1:8080
Server: llama.cpp HTTP API (OpenAI-compatible)

Model: Qwen2.5:8b-instruct-q4_k_m (default)
  - Parameters: 8 billion
  - Quantization: Q4_K_M (4-bit, ~5.2 GB VRAM)
  - Context window: 4096 tokens
  - Performance: ~40-60 tokens/sec on RX 6750 XT

Alternative models available:
  - Mistral 7B (smaller, faster)
  - Llama2 70B (larger; requires 2x GPU or patience)

## Running the Server (Windows)

This repo does **not** ship `llama-server.exe`.

- Put `llama-server.exe` under `local_ai/bin/`, or
- Pass a path to an extracted `llama.cpp` build folder via the script parameter.

Use the VS Code task:
- `Local LLM: start llama.cpp server (Vulkan)`

Or run the script directly:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\\run_llama_server.ps1 -ServerDirOrExe "C:\\path\\to\\llama.cpp\\build\\bin\\Release"
```

If the task errors with "No server binary found", it means `llama-server.exe` is missing from `local_ai/bin/` and no `-ServerDirOrExe` was provided.
```

## Example: Agent Inference

```
Agent: Coordinator needs to decide on scope
→ Server: inference_chat(
    model: "qwen2.5:8b",
    messages: [
      {role: "system", content: "You are a scope decision agent..."},
      {role: "user", content: "Should we add async/await support?"}
    ],
    temperature: 0.7,
    max_tokens: 200
  )
→ Server: returns {"response": "Yes, async is needed because...", "usage": {...}}
→ Agent: logs decision + 🧾 provenance + 💭 reasoning
```

## Context Window Management (Planned Q2 2026)

```
Current: Manual (user must truncate long conversations)

Planned:
  - Automatic sliding window: keep most recent N tokens
  - Summary injection: prepend key points from earlier context
  - Fallback to shorter context: if token count exceeds limit

Example:
  Full conversation: 8000 tokens
  Limit: 4096 tokens
  → System: summarize oldest 4000 tokens into 500-token summary
  → System: keep last 3600 tokens verbatim
  → Total: 4100 tokens (fits with margin)
```

## Quantization Tuning (Planned Q2 2026)

```
Baseline: Q4_K_M (current, stable)

Alternatives for testing:
  - Q3_K_S (smaller; less accurate; 3.5 GB VRAM)
  - Q5_K_M (larger; more accurate; 6.8 GB VRAM)
  - Q6_K (even larger; 7.5+ GB VRAM; may OOM on RX 6750)

Testing plan:
  - Benchmark accuracy (MMLU, HellaSwag)
  - Benchmark speed (tokens/sec)
  - Benchmark memory (peak VRAM usage)
  - Choose best tradeoff for SymbolOS workload
```

## Token Counting Accuracy

Currently uses llama.cpp `tokenize` endpoint (rarely off by >1 token).

Testing suite (Q2 2026):
  - Compare llama.cpp tokenize vs. actual inference token count
  - Test edge cases (special tokens, emoji, code)
  - Publish discrepancy report

## Privacy Guarantee

- ✅ No internet connection required
- ✅ No external logging/telemetry
- ✅ No model fine-tuning on user data
- ✅ Inference state discarded after response (stateless)
- ✅ All tokens computed locally on user's GPU

## Async Timeline

- **Now (Jan 2026)**: Beta inference, embedding, status on Qwen2.5:8b Q4_K_M
- **Q2 2026**: Context windowing + automatic summarization
- **Q2 2026**: Quantization tuning suite + performance benchmarks
- **Q2 2026**: Token counting accuracy validation
- **Q3 2026**: Full release candidate (FC1)

## See Also

- [Local LLM Setup (Internal)](../internal_docs/local_llm_windows_vulkan_internal.md) — Hardware guide, driver setup, troubleshooting
- [MCP Servers Standard](mcp_servers.md) — Risk levels, error envelope
- [Mind (Symbol)](symbol_map.md#core-symbols) — 🧠 meaning
- [Running llama.cpp](https://github.com/ggerganov/llama.cpp#readme) — Upstream docs
