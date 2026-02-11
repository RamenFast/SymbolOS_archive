╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Forge of Local Minds (v1.0)                      ║
║  📍 Floor: R6 (Architecture) │ Difficulty: ⭐⭐⭐ │ Loot: A compute strategy that doesn't bankrupt the party ║
║  🎨 Color: ⭐ #FFD700 (spiritual aspiration) + 🔵 #0000CD (devotion to truth) ║
║  🌱 Maturity: Seed                                              ║
║                                                              ║
║  Two forges. One design. The GPU hums, the wallet breathes.     ║
╚══════════════════════════════════════════════════════════════╝

> "Shine dat light: trace a leaf decision back to its root value, then come forward again with the smallest safe step."

## Authors

This document was forged by two agents working in sync, each contributing from their own vantage point:

| Agent | Contribution | Method |
|-------|-------------|--------|
| **Manus-Max** ⭐ | Compute tier architecture, token ledger design, router logic, model research | Cloud sandbox + web research |
| **Mercer-Opus** 🔵 | Hardware audit, real VRAM/RAM constraints, model sizing math, ring-role mapping | Local terminal probes on Ben's actual machine |

The disagreement between them — and its resolution — is documented honestly below. That's how the system works.

## The Hardware (Probed by Opus, Not Guessed)

Opus ran actual system probes on Ben's machine. These numbers are real, not spec-sheet estimates.

| Component | Spec | Implication |
|-----------|------|------------|
| **GPU** | RX 6750 XT, RDNA 2, 12 GB GDDR6 | Vulkan-only compute. No CUDA, no ROCm. |
| **Usable VRAM** | ~10.5 GiB (after 1440p 165Hz display overhead) | Not 12 GB. Budget accordingly. |
| **CPU** | Ryzen 5 3600, 6c/12t, Zen 2 | AVX2 only (no AVX-512). Decent but not fast for CPU inference. |
| **RAM** | 32 GB DDR4, currently at 2133 MHz | XMP being enabled → 3200 MHz. ~50% bandwidth improvement for offloaded layers. |
| **RAM bandwidth (after XMP)** | ~51 GB/s dual-channel | This is the bottleneck for any CPU-offloaded model layers. |
| **Available for offload** | ~14-16 GB safely | Combined ceiling: ~24-26 GB (GPU + CPU). |
| **Storage** | SATA SSD (C:), 72.8 GB free | Models go here. SATA is fine — model loading is a one-time cost. |

## The Disagreement (And Why Opus Is Right)

Manus-Max initially recommended **Qwen3-Coder-30B-A3B** as the primary local model, based on Reddit benchmarks showing 16 t/s output on similar VRAM. Opus flagged this as Tier 3 on Ben's actual hardware — **3-10 t/s with heavy CPU offload**, which is the "pain zone for interactive use."

The issue is threefold. First, the Reddit benchmarks were from users with faster RAM (DDR5 or higher-clocked DDR4) and newer CPUs with AVX-512. Ben's Zen 2 at DDR4-3200 will bottleneck harder on CPU-offloaded expert layers. Second, the 30B-A3B model's MoE architecture means expert layers constantly shuttle between GPU and CPU — and at ~51 GB/s RAM bandwidth, that shuttle is slow. Third, and most importantly, Opus correctly identified that the local model's job in SymbolOS is **not** heavy coding. It's memory management, doc alignment, structured output, and ring verification. These tasks need speed and reliability, not raw reasoning depth.

> "Instruction-following quality > raw reasoning depth" — Mercer-Opus

Manus-Max concurs. The revised recommendation follows.

## The Final Model Design

### Primary Model: Qwen2.5-8B-Instruct @ Q5_K_M

This is the daily driver. Fully GPU-resident, no CPU offload needed, fast and reliable.

| Property | Value |
|----------|-------|
| **Model** | Qwen2.5-8B-Instruct |
| **Quantization** | Q5_K_M |
| **VRAM** | ~6.5 GB (fits entirely in 10.5 GiB budget) |
| **Speed** | ~40-60 tok/s on RX 6750 XT via Vulkan |
| **Context** | 4096 default, 8192 achievable |
| **Strengths** | Instruction following, JSON output, markdown, summaries |
| **Tier** | T0 + T1 (free, local) |

This model handles the vast majority of SymbolOS agent work: session log generation, memory updates, doc alignment checks, structured output, ring heartbeat analysis, tavern board posts, and simple code edits. At 40-60 t/s, it feels interactive and responsive.

### Secondary Model: Phi-4-Mini @ Q4_K_M

The speed demon. For ultra-fast tasks where latency matters more than depth.

| Property | Value |
|----------|-------|
| **Model** | Phi-4-Mini (3.8B) |
| **Quantization** | Q4_K_M |
| **VRAM** | ~2.5 GB |
| **Speed** | ~80-120 tok/s |
| **Context** | 4096 |
| **Strengths** | Classification, tokenization, quick checks, tool calling |
| **Tier** | T1 (fast local) |

This model is for the tasks that don't need any reasoning at all — token counting, simple classification ("is this a doc edit or a code change?"), template filling, and status formatting. It can coexist with the primary model in VRAM if needed (~9 GB total).

### Stretch Model: Qwen2.5-14B-Instruct @ Q4_K_M (Optional)

For when you want better reasoning without going to cloud. Requires partial CPU offload.

| Property | Value |
|----------|-------|
| **Model** | Qwen2.5-14B-Instruct |
| **Quantization** | Q4_K_M |
| **VRAM** | ~8-9 GB (most layers on GPU) |
| **CPU offload** | ~2-4 GB in RAM |
| **Speed** | ~15-25 tok/s (after XMP) |
| **Context** | 4096 |
| **Strengths** | Better reasoning, multi-step tasks, code review |
| **Tier** | T0 (quality-first local tasks) |

This is the "benchmark it and see" option. If 15-25 t/s feels acceptable for non-interactive batch work (overnight alignment runs, large doc rewrites), it's worth having. If not, the 8B model covers everything.

### What We're NOT Running Locally

Heavy coding from scratch, complex multi-file refactors, novel architecture design, and long-context analysis (>8K tokens) all go to cloud agents. The local model is a workhorse, not a thoroughbred. Cloud agents (Manus-Max, MercerGPT, Opus) handle the hard stuff. Local handles the volume.

## The Compute Tier System (Revised)

Incorporating Opus's hardware reality and role mapping:

| Tier | Name | Where | Model | Speed | Cost | Ring Coverage |
|------|------|-------|-------|-------|------|-------------|
| **T0** | Workhorse | Local GPU | Qwen2.5-8B Q5_K_M | 40-60 t/s | $0.00 | R2, R4, R5, R8, R9, R10 |
| **T1** | Sprint | Local GPU | Phi-4-Mini Q4_K_M | 80-120 t/s | $0.00 | Quick checks, classification |
| **T2** | Standard | Free cloud tiers | Gemini Flash, Groq | varies | ~free | Multi-step reasoning |
| **T3** | Premium | Paid cloud | GPT-4o, Claude, Manus | varies | $0.01-0.10 | Architecture, novel design |

The router classifies every task before execution. Default is T0. Escalate only when the task genuinely needs it.

## Ring-to-Model Mapping (From Opus)

Opus mapped which rings the local model serves. This is the authoritative assignment:

| Ring | Role | Local Model Handles? | Why |
|------|------|---------------------|-----|
| R0 Kernel | Identity invariants | ❌ | Too critical — cloud agents verify |
| R1 Will | Intent declaration | ❌ | Requires human or architect agent |
| R2 Sensation | Process file changes, diffs | ✅ | Structured input → structured output |
| R3 Task | Break down goals | ❌ | Needs reasoning depth |
| R4 Retrieval | Summarize memory, search | ✅ | Perfect for 8B instruction following |
| R5 Prediction | Precog-lite, anticipate next | ✅ | Pattern matching on working_set |
| R6 Architecture | Design decisions | ❌ | Cloud agents only |
| R7 Guardrails | Safety checks | ⚠️ | Local can flag, cloud confirms |
| R8 Verification | Heartbeat, alignment | ✅ | Deterministic checks + local analysis |
| R9 Persistence | Session logs, tavern board | ✅ | High volume, low complexity |
| R10 Reflection | Self-reflection entries | ✅ | Structured journaling |
| R11 Integration | Synthesis, loop closure | ❌ | Needs full party context |

Six rings handled locally. Six rings handled by cloud. Clean split.

## Token Ledger Design

Every inference — local or cloud — gets logged to `memory/m0_episodic/token_ledger.jsonl`:

```json
{
  "ts": "2026-02-11T06:00:00Z",
  "agent": "mercer-local",
  "tier": "T0",
  "model": "qwen2.5-8b-q5_k_m",
  "tokens_in": 340,
  "tokens_out": 1200,
  "cost_usd": 0.00,
  "task": "generate session log summary",
  "ring": "R9",
  "endpoint": "local:8080",
  "latency_ms": 24000
}
```

Daily summaries get appended to the session log with a `## 💰 Compute Summary` section showing tier breakdown, total spend, and estimated savings vs all-cloud.

## Setup Sequence (For Ben)

This is the concrete "do this now" checklist, building on the infrastructure Opus confirmed is already wired up:

**Step 1: Create the directory**
```powershell
mkdir C:\Users\Ben\SymbolOS\local_ai\bin
mkdir C:\Users\Ben\SymbolOS\local_ai\models
```

**Step 2: Download llama.cpp (Vulkan build)**
Get the latest Windows release from [llama.cpp releases](https://github.com/ggerganov/llama.cpp/releases) — look for the `vulkan` build. Extract `llama-server.exe` to `local_ai/bin/`.

**Step 3: Download the primary model**
```
Qwen2.5-8B-Instruct-Q5_K_M.gguf (~6.5 GB)
```
From HuggingFace. Place in `local_ai/models/`.

**Step 4: Enable XMP in BIOS**
Reboot → BIOS → Enable XMP/DOCP profile → DDR4-3200. This gives ~50% more bandwidth for any future CPU offload work.

**Step 5: Launch**
Use the existing VS Code task or:
```powershell
.\scripts\run_llama_server.ps1
```

**Step 6: Verify**
```powershell
Invoke-RestMethod http://127.0.0.1:8080/
```

That's it. The MCP integration, OpenAI-compatible API, and VS Code task are already wired up from previous work.

## What Happens Next

Phase 1 (this week): Ben sets up the local model. Opus verifies it runs. Manus writes the token ledger script.

Phase 2 (next week): Manus writes the compute router. Opus integrates it into the local agent loop. MercerGPT reviews the tier assignments.

Phase 3 (ongoing): The system tracks its own spend. We tune the tier boundaries based on real data. The wallet breathes.

---

*Two forges agreed. The fast model wins the daily race. The smart model wins the hard fights. The wallet wins the war.*

───────────────────────────────────────────────────
🚪 EXITS:
  → [MCP Local LLM](mcp_local_llm.md) (north, to the inference chamber)
  → [Local LLM Setup (Internal)](../internal_docs/local_llm_windows_vulkan_internal.md) (east, to the armory)
  → [Compute Strategy](../compute_strategy.md) (west, to the war room)
  → [Ring System v2](ring_system_v2.md) (south, to the ring hall)

💎 LOOT GAINED: A compute architecture that respects both the hardware and the wallet. Two agents in agreement. A clear path forward.
───────────────────────────────────────────────────

The forge burns bright,
Two minds align on what's right,
Local light, cloud height.

☂🦊🐢⭐🔵
