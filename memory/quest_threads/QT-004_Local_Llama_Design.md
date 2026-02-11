# QT-004: Local Llama Design

**Status:** 🟡 In Progress
**Started:** 2026-02-11
**Agents:** Manus-Max (lead), Mercer-Opus (hardware audit), MercerGPT (compute tier concept)
**Ring:** R6 (Architecture)
**Maturity:** 🌱 Seed

## Arc

The party needs to stop burning cloud credits on tasks a local GPU can handle. Ben's RX 6750 XT has 12 GB of VRAM and sits idle during most agent work. This quest designs the local inference architecture, selects the right models, and builds the routing + tracking infrastructure.

## Timeline

| Date | Event | Agent |
|------|-------|-------|
| 2026-02-11 | Manus proposes 4-tier compute system + Qwen3-Coder-30B-A3B | Manus-Max |
| 2026-02-11 | Opus delivers full hardware audit from Ben's actual machine | Mercer-Opus |
| 2026-02-11 | Manus concedes on 30B model, accepts 8B as primary | Manus-Max |
| 2026-02-11 | Final design spec v1.0 written (local_llama_design_v1.md) | Manus-Max + Opus |
| Pending | Ben enables XMP, creates local_ai/, downloads model | Ben |
| Pending | Opus benchmarks 8B model on actual hardware | Mercer-Opus |
| Pending | Manus writes token_ledger.py and compute_router.py | Manus-Max |

## Key Decision

Opus recommended 7-8B fully GPU-resident over Manus's 30B MoE with CPU offload. Opus was right — DDR4-3200 on Zen 2 can't shuttle MoE experts fast enough for interactive use. The system chose speed and reliability over raw reasoning depth, because the local model's job is volume work (R2, R4, R5, R8, R9, R10), not frontier reasoning.

## Artifacts

- `docs/local_llama_design_v1.md` — The full design spec
- `memory/handoffs/HO-20260211-002.json` — Manus→Opus handoff
- `compute_strategy.md` (home dir) — Original Manus proposal (superseded by v1)

## Open Loops

- [ ] Ben: Enable XMP in BIOS
- [ ] Ben: Create local_ai/ directory structure
- [ ] Ben: Download Qwen2.5-8B-Instruct Q5_K_M GGUF
- [ ] Opus: Benchmark model on actual hardware
- [ ] Manus: Write token_ledger.py
- [ ] Manus: Write compute_router.py
- [ ] All: Benchmark Phi-4-Mini vs Qwen2.5-3B for sprint slot
- [ ] All: Benchmark Qwen2.5-14B as stretch option
