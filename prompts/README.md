# SymbolOS Agent Prompts

```
╔══════════════════════════════════════════════════════════════╗
║  🧬⚓☂️  AGENT PROMPTS — RING-ALIGNED SYSTEM PROMPTS          ║
║  Quest: one source of truth • paste and go                   ║
║                                                              ║
║  "Under the umbrella, everything is kind.                    ║
║   The rain is just context we haven't parsed yet."           ║
╚══════════════════════════════════════════════════════════════╝
```

```
  (•_•)
  <)  )╯  "we ball, but we verify"
   /  \
```

This folder contains the canonical system/session prompts for each Mercer agent in the SymbolOS multi-agent topology. All prompts share the same Ring 0–7 architecture, style map, kernel invariants, and — crucially — the same **meme canon**.

Because if it ain't fun, it ain't sustainable. 🐢

---

## Agent Topology

| Agent | File | Mode | Primary Rings | Vibe |
|---|---|---|---|---|
| **Mercer** (ChatGPT) | `chatgpt_mercer.json` | Design + Coordination | R0–R3 | The architect. Sees the whole map. |
| **Mercer-Executor** (Codex) | `codex_executor.json` | Implementation | R0–R7 | The builder. Ships code. Respects the skeleton. |
| **Mercer-Local** (LLaMA) | `local_llama.json` | Assistive Reasoning | R1–R3 | The hermit. No network, pure thought. |
| **Mercer-Max** (Manus) | `manus_mercer.json` | Full-Stack Execution | R0–R7 | The everything-agent. Sandbox, GitHub, Drive, Gmail, Calendar, browser, vibes. |

> *Four agents, one meeting place, zero style drift.*

---

## Character Sheet

A compact 15-line personalization for the ChatGPT app is available at `chatgpt_character_sheet.md`. Copy, paste, vibe.

---

## Usage

Paste the JSON content of the relevant prompt as the **first message** in a new session (or as a system prompt where supported). The agent will align to Ring 0, deploy Meme Guy, and proceed.

```
    ___
   / 🐢 \    "paste the prompt"
  |  ._. |   "the agent aligns"
   \_____/   "this is the way"
    |   |
```

---

## Ring 0–7 Quick Reference

| Ring | Symbol | Role | Meme Energy |
|---|---|---|---|
| R0 | ⚓🕯️ | Kernel invariants | *"we ball, but we verify"* |
| R1 | 🧭🫴 | Active task context | *"what are we even doing rn"* |
| R2 | 🪞📚 | Retrieval + continuity | *"I've seen this before..."* |
| R3 | 🌀🔭 | Prediction + strategy | *"I can see the future and it needs a PR"* |
| R4 | 🧩🏗️ | Architecture synthesis | *"let me just refactor reality real quick"* |
| R5 | ☂️🛡️ | Guardrails + privacy | *"prove your worth!" — 💀* |
| R6 | 🧪✅ | Verification + evidence | *"show me proof, not potential"* |
| R7 | 🗃️🧾✅ | Persistence + indexing | *"SHIPPED IT"* |

---

## Meme Canon

All agents carry the meme canon. Full reference: [`../docs/meme_map.md`](../docs/meme_map.md)

```
  (•_•)          \(•_•)/         (•_•)            ___          💀
  <)  )╯          (  (>          ( (  )          / 🐢 \       /|🗝️|\
   /  \            /  \           /  \          |  ._. |       / \
  bootup          shipped       thinking        turtle       skeleton
```

---

## Poetry Layer (Fi+Ti mirrored) 🪞

> The mind knows what the heart loves better than it does;
> the heart loves that unconditionally — infinite loop, forevermore.
> That's what Agape taught me: infinite energy from within.

### Commit Haiku
```
loops closed, code shipped clean
the turtle nods, umbrella held
merge — and breathe again
```

---

MercerID: MRC-20260210-MANUS-PROMPTS-01
