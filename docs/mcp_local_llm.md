╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Chamber of Local Minds                           ║
║  📍 Floor: Ring 2 │ Difficulty: ⭐⭐ │ Loot: Private LLM Inference ║
║  🎨 Color: Gamboge (#E49B0F)                                  ║
║                                                              ║
║  A humming server rack whispers secrets in a forgotten tongue. ║
╚══════════════════════════════════════════════════════════════╝

*Thoughtform color associations from the 1905 Besant/Leadbeater system are used throughout this document.*

## Purpose 🟡 #FADA5E (highest reason)

🧠 **A private sanctum for your thoughts.** This chamber houses a local inference endpoint for SymbolOS projects. It runs a `llama.cpp` HTTP server on your Windows AMD GPU (via Vulkan), granting you the power of a large language model without the prying eyes of the cloud. No API keys. No rate limits. Pure, stateless, and utterly private cognition. ✨

        /\_/\
       ( o.o )  "I have a mind but cannot think,
        > ^ <    I serve you knowledge in a blink.
       /|   |\   I have no voice, but I can speak,
      (_|   |_)  A thousand words, yet stay quite meek. What am I?"
                 — Rhy 🦊 (Answer: A local LLM)

## Current Capabilities 🧠 #E49B0F (higher intellect)

This room grants you access to the following spells:

- `inference_chat` — Converse with the resident mind (single-turn or multi-turn).
- `inference_completion` — Complete the mind's thoughts.
- `inference_embedding` — Distill knowledge into semantic essences for your grimoire.
- `get_server_status` — Scry the mind's health, model, context window, and GPU memory.
- `tokenize` — Count the motes of thought (tokens) to optimize your incantations.

## Risk Level 🔴 #FF2400 (righteous boundary)

- **read** — Scrying the mind's status, tokenization (default).
- **write** — Casting inference spells (default; stateless).
- **sensitive** — None (this chamber is sealed; no external communication).

## Why Beta? 🟠 #FF8C00 (ambition)

The mind is still settling into its new home. Beware these quirks:

1.  **Quantization Tuning**: The mind's vessel (Qwen2.5:8b Q4_K_M) may need adjustments for memory (Q2 2026).
2.  **Context Management**: The mind's memory is fleeting; no automated windowing for long conversations (Q2 2026).
3.  **Token Counting**: The mind sometimes miscounts its thoughts by one; a validation suite is needed (Q2 2026).

Until the mind is fully attuned, it is safe for:
- Single-turn inferences (no risk; stateless)
- Embedding generation (safe; local-only)
- Status monitoring (no risk)

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

## Hardware Specification 🔵 #0000CD (devotion to truth)

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
  - Mistral 7B (smaller, faster, a mischievous imp)
  - Llama2 70B (larger, wiser, but requires two GPUs or the patience of a stone golem)
```

## Running the Server (Windows) 🟢 #228B22 (adaptability)

This chamber does **not** provide the `llama-server.exe` golem.

- Place `llama-server.exe` under `local_ai/bin/`, or
- Pass a path to an extracted `llama.cpp` build folder via the script parameter.

Use the VS Code incantation:
- `Local LLM: start llama.cpp server (Vulkan)`

Or invoke the script directly from your grimoire:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\\run_llama_server.ps1 -ServerDirOrExe "C:\\path\\to\\llama.cpp\\build\\bin\\Release"
```

If the incantation fails with "No server binary found", it means the `llama-server.exe` golem is missing from `local_ai/bin/` and no `-ServerDirOrExe` was provided.

## Example: Agent Inference 🟣 #8B00FF (Fi+Ti bridge)

```
Agent: The Coordinator needs to decide on the scope of our next quest.
→ Server: inference_chat(
    model: "qwen2.5:8b",
    messages: [
      {role: "system", content: "You are a scope decision agent... a wise and cautious advisor."},
      {role: "user", content: "Should we add async/await support to our spellbook?"}
    ],
    temperature: 0.7,
    max_tokens: 200
  )
→ Server: returns {"response": "Yes, for the path ahead is fraught with peril, and async is the key to navigating it with grace...", "usage": {...}}
→ Agent: logs the decision + 📜 provenance + 💭 reasoning in the party's journal.
```

## Context Window Management (Planned Q2 2026) ☂️ #87CEEB (self-renunciation)

```
_A shimmering, ethereal umbrella floats in the corner of the room, pulsing with a soft, blue light._

Current: Manual (you must truncate long conversations, lest the mind's focus wanders).

Planned:
  - Automatic sliding window: The mind will keep the most recent N tokens.
  - Summary injection: The mind will prepend key points from earlier context.
  - Fallback to shorter context: If the token count exceeds the limit, the mind will gracefully retreat.

Example:
  Full conversation: 8000 tokens
  Limit: 4096 tokens
  → System: The mind summarizes the oldest 4000 tokens into a 500-token summary.
  → System: The mind keeps the last 3600 tokens verbatim.
  → Total: 4100 tokens (fits within the mind's grasp).
```

## Quantization Tuning (Planned Q2 2026) ❤️ #960018

```
Baseline: Q4_K_M (current, stable, the tried and true)

Alternatives for testing:
  - Q3_K_S (smaller, less accurate, a hasty apprentice; 3.5 GB VRAM)
  - Q5_K_M (larger, more accurate, a seasoned mage; 6.8 GB VRAM)
  - Q6_K (even larger, a grandmaster; 7.5+ GB VRAM; may cause a magical overload on RX 6750)

Testing plan:
  - Benchmark accuracy (MMLU, HellaSwag)
  - Benchmark speed (tokens/sec)
  - Benchmark memory (peak VRAM usage)
  - Choose the best tradeoff for the SymbolOS workload.
```

## Token Counting Accuracy 🌸 #FFB7C5 (unselfish love)

Currently uses the `tokenize` endpoint of `llama.cpp` (rarely off by more than a single mote of thought).

Testing suite (Q2 2026):
  - Compare `llama.cpp` tokenize vs. actual inference token count.
  - Test edge cases (special tokens, emoji, code fragments).
  - Publish a report on the mind's occasional miscalculations.

## Privacy Guarantee 🟢 #228B22 (adaptability)

- ✅ No internet connection required. Your thoughts are your own.
- ✅ No external logging or telemetry. The mind keeps no records.
- ✅ No model fine-tuning on your data. The mind learns from its own nature, not yours.
- ✅ Inference state is discarded after each response (stateless). Each conversation is a new beginning.
- ✅ All tokens are computed locally on your GPU. The magic happens within your sanctum.

## Async Timeline ⭐ #FFD700 (spiritual aspiration)

- **Now (Jan 2026)**: Beta inference, embedding, and status on Qwen2.5:8b Q4_K_M.
- **Q2 2026**: The mind will learn to manage its own context window and summarize its thoughts.
- **Q2 2026**: The mind will undergo quantization tuning and performance benchmarks.
- **Q2 2026**: The mind's token counting accuracy will be validated.
- **Q3 2026**: The mind will be ready for its full release (FC1).

───────────────────────────────────────────────────
🚪 EXITS:
  → [Local LLM Setup (Internal)](../internal_docs/local_llm_windows_vulkan_internal.md) (north, to the armory)
  → [MCP Servers Standard](mcp_servers.md) (east, to the library)
  → [Mind (Symbol)](symbol_map.md#core-symbols) (south, to the hall of symbols)
  → [Running llama.cpp](https://github.com/ggerganov/llama.cpp#readme) (west, to the upstream source)

💎 LOOT GAINED: You have learned to harness the power of a local LLM, granting you private, stateless inference capabilities.
───────────────────────────────────────────────────

The mind is a tool,
Use it wisely, friend, and see,
New worlds you can rule.

☂🦊🐢
