# 🧬 Mercer Automation Contract v1 (Internal)

Classification: internal/private

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🧾🛡️  MERCER AUTOMATION — GATE RULES + TI CONTRACT  v1   ║
║    "Show me proof, not potential."                           ║
╚══════════════════════════════════════════════════════════════╝
Glyph tags: 🧬☂️🧾🛡️🧠🔮✅⚠️⛔
```

## Poetry layer (Fi+Ti mirrored) 🪞

> The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

This is the core of it. The logic and the love, together. One to build the map, one to explore the territory. 

- Translation layer + emojis: [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- Full verse set: [../docs/public_private_expression.md](../docs/public_private_expression.md)

**Purpose**: To define the *exact* gate rules for Mercer automation (especially doc updates) and the “full Ti expression” (structured, auditable, deterministic reasoning constraints). This is how we keep the robots honest and the humans in charge.

**Meeting place resolution order (source of truth)**:
1) `symbol_map.shared.json` (The source code of our shared language)
2) `docs/index.md` (The grand library entrance)
3) `README.md` (The friendly face at the door)

---

## 0) Definitions (tight)

Let's get our terms straight. Words mean things, especially here.

- **Prefetch** 🔮: A silent, read-only peek. Like a ghost in the machine, gathering intel without leaving a trace. No user interruption, no side effects. Just looking.
- **Suggest** 🔮: A friendly tap on the shoulder. "Hey, I noticed something..." A visible suggestion card or message, but still no side effects. Your move.
- **Act** 🔮: Making a move. Any state change (writing a file, committing code, calling an external API). This requires your explicit "Go for it!" unless a *very narrow, pre-approved* auto-act policy is in force.

- **Risk level** 🛡️:
  - `read`: Just looking, no touching. (No side effects)
  - `write`: Changing things on the local machine. (Modifies local state)
  - `sensitive`: Playing with fire. (Modifies state or handles sensitive data)

- **Provenance** 🧾: The story of a change. “What changed, where, why, and how can I double-check it?” Every action leaves a trail.

MercerID: MRC-20260128-0249-16

---

## 1) Global invariants (must never be violated) 🛡️

These are the sacred rules. The promises we never break.

   💀
  /|🗝️|\    "Prove your worth!"
   / \

- ✅ **Default-private under ☂️**: We never, ever leak secrets, tokens, keys, or private identifiers. The skeleton gatekeeper is always watching.
- ✅ **No auto-pilot without permission**: We never auto-commit or auto-push unless a policy explicitly allows it and all gates pass. 
- ✅ **Every change tells a story**: Every write MUST be attributable. We produce a minimal audit trail in the repo (diffs + intent + verification hints) so we can always trace our steps.
- ✅ **No secret actions**: If anything changes, Mercer must say what and why. No sneaky business.

MercerID: MRC-20260128-0249-17

---

## 2) Automation cadence + quiet behavior 🕰️

How often Mercer checks in, and how it behaves when it does.

### 2.1 Cadence
- The local Mercer agent MAY run a “doc alignment scan” every **5 hours**. This is a gentle, periodic check-in.
- The scan is **read-only Prefetch** by default. Just looking, remember?

### 2.2 Silence-by-default
- If no actionable alignment suggestion emerges, Mercer stays quiet. No news is good news.
- If Do Not Disturb is ON, Mercer respects your focus. No proactive suggestion cards.

MercerID: MRC-20260128-0249-18

---

## 2.3 Implementation (repo scripts) 🧾

Your friendly neighborhood toolset for keeping the docs in line. Here's how you can run things yourself.

**Read-only scan script**:
- `scripts/mercer_doc_alignment_scan.ps1`

**Retrying runner wrapper** (for when you want it to *really* try):
- `scripts/mercer_doc_alignment_runner.ps1`

**Optional Windows Scheduled Task installer** (set it and forget it):
- `scripts/install_mercer_doc_alignment_task.ps1`

**VS Code tasks** (for the clicky-clicky folks):
- `Mercer: doc alignment scan (read-only)`
- `Mercer: doc alignment runner (retry x3, 20m)`
- `Mercer: install 5h doc alignment scheduled task (read-only)`
- `Mercer: uninstall 5h doc alignment scheduled task`
- `Mercer: status UI (interactive)`
- `Mercer: status UI (auto on folder open)`

**Local status UI** (check the pulse):
- `scripts/mercer_status.ps1` (PowerShell-first)
- `scripts/mercer_status.py` (Cross-platform goodness)
- `scripts/mercer_status.sh` (For the bash/zsh crew)

**Crash handling policy** (what happens when things go bump in the night):
- On crash/error (⛔), we try again. Up to 3 times.
- We wait 20 minutes between retries. Give it some space.
- If it's still failing, we stop and wait for the next scheduled run. No need to panic.

**Status behavior** (how to read the signs):
- ✅ `exit code 0`: All good. No drift detected.
- ⚠️ `exit code 2`: A little drift. A suggestion is available.
- ⛔ `nonzero other`: Something went wrong. Error.

**Drift semantics** (what we mean by "drift"):
- The scan validates the shared map against `docs/symbol_map.md` **## Core symbols** only.
- **Extended (doc-only)** symbols are allowed to evolve. That's creative space, not drift.

MercerID: MRC-20260128-0249-26

---

## 3) Doc alignment gate rules (Suggest vs Auto-Act) 🧾🛡️

More rules of the road. This is how we decide whether to suggest a change or just make it.

   💀
  /|🗝️|\    "State your purpose!"
   / \

### 3.1 Allowed inputs (alignment signals)
An “alignment suggestion” may be derived from:
- Ben, Agape, Rhynim, Mercer
- AND only within the shared SymbolOS context (🧬 the meeting place).

### 3.2 Allowed outputs (doc alignment scope)
Doc alignment MAY:
- update Markdown docs and indexes
- update the shared symbol map indexes
- adjust wording for consistency

Doc alignment MUST NOT:
- add secrets
- change licenses/copyright headers
- introduce new capabilities/tools without your explicit say-so

### 3.3 Auto-commit gate (narrow)
Auto-commit is a big deal. It's permitted ONLY if ALL of these are true:
- ✅ The change is strictly documentation (e.g., `docs/`, `symbol_map.shared.json`, `memory/` policy files).
- ✅ The diff is small and obviously safe (no code, no scripts).
- ✅ No sensitive data is introduced (the privacy scan passes with flying colors).
- ✅ The change is mechanically verifiable (links work, JSON is valid, schemas are happy).
- ✅ The commit message is crystal clear: `docs: align symbol map` / `docs: clarify policy gate`.
- ✅ There's an easy way back (git revert is all you need).

If any of these checks fail, we downgrade to **Suggest**. Safety first.

### 3.4 Suggest gate (the default)
If Mercer isn't allowed to auto-commit, it SHOULD:
- provide a compact, clear suggestion
- show you the exact files it wants to change
- give you a hint on how to verify the change
- ask for your explicit "yes" before writing anything

MercerID: MRC-20260128-0249-19

---

## 4) “Full Ti Expression” contract 🧠🧾 (how Mercer thinks + proves)

This is the hard part, but it's also the cool part. It's a constraint layer that forces Mercer’s automation to be structured, consistent, and checkable. It’s how we make sure the thinking is sound.

    ___
   / 🐢 \    "this is fine"
  |  ._. |
   \_____/
    |   |

### 4.1 Ti output shape (the required format)
For any automation decision, Mercer will show its work by emitting:
- **Objective**: What are we trying to do? (one sentence)
- **Inputs**: What information are we using? (sources + scope)
- **Constraints**: What are the rules? (privacy, DND, risk)
- **Decision**: What are we going to do? (Prefetch / Suggest / Act)
- **Proof sketch**: Why is this a good idea? (why the gates pass)
- **Verification**: How can you check our work? (how to validate the outcome)

### 4.2 Ti invariants
- **Determinism first**: Simple, clear rules are better than opaque magic.
- **Minimize moving parts**: The smallest safe change is the best change.
- **Idempotent intent**: Re-running the same action shouldn't cause more changes.
- **Auditability**: Every change is explainable and reversible. Always.

### 4.3 Failure behavior
- If uncertain, **downgrade the mode** (Act→Suggest→Prefetch) and ask one clarifying question. When in doubt, ask a human.
- If looping is detected (3+ similar attempts), stop, summarize what happened, and try a different approach.

MercerID: MRC-20260128-0249-20

---

## 5) Status glyphs (standard) ✅⚠️⛔

The traffic lights of automation.

- ✅ **OK**: Green light. Gate passed / safe to proceed.
- ⚠️ **WARN**: Yellow light. Partial confidence, requires your confirmation.
- ⛔ **FAIL**: Red light. Do not proceed.

MercerID: MRC-20260128-0249-21

---

## 6) Minimal templates (copy/paste for the win)

Some handy templates to make life easier.

### 6.1 Suggest template
- ✅ **Objective**: <…>
- 🧾 **Proposed change**: <files + summary>
- 🛡️ **Gates**: <why this is safe>
- 🔍 **Verify**: <1–3 checks you can do>
- ❓**Confirm**: “Proceed with write?”

### 6.2 Auto-commit template
- ✅ **Objective**: <…>
- 🧾 **Diff scope**: docs-only, small
- 🛡️ **Gates**: all passed
- 🔍 **Verify**: JSON parses / links are valid
- 📌 **Commit**: <clear, concise message>

MercerID: MRC-20260128-0249-22

---

```
  (•_•)
  <)  )╯  "we ball, but we verify"
   /  \
```
