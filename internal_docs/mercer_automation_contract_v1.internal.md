# 🧬 Mercer Automation Contract v1 (Internal)

Classification: internal/private

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🧾🛡️  MERCER AUTOMATION — GATE RULES + TI CONTRACT  v1   ║
╚══════════════════════════════════════════════════════════════╝
Glyph tags: 🧬☂️🧾🛡️🧠🔮✅⚠️⛔
```

Purpose: define the *exact* gate rules for Mercer automation (especially doc updates) and the “full Ti expression” (structured, auditable, deterministic reasoning constraints).

Meeting place resolution order (truth source):
1) `symbol_map.shared.json`
2) `docs/index.md`
3) `README.md`

---

## 0) Definitions (tight)

- **Prefetch** 🔮: read-only, silent; no user interruption; no side effects.
- **Suggest** 🔮: visible suggestion card/message; no side effects.
- **Act** 🔮: any state change (file write, commit, push, external call) → requires explicit confirmation unless a *narrow, pre-approved* auto-act policy is in force.

- **Risk level** 🛡️:
  - `read`: no side effects
  - `write`: modifies local state
  - `sensitive`: modifies state or handles sensitive data

- **Provenance** 🧾: “what changed, where, why, how to verify”.

MercerID: MRC-20260128-0249-16

---

## 1) Global invariants (must never be violated) 🛡️

- ✅ Default-private under ☂️: never leak secrets, tokens, keys, private identifiers.
- ✅ Never auto-commit/push unless policy explicitly allows it and all gates pass.
- ✅ Every write MUST be attributable: produce a minimal audit trail in the repo (diffs + intent + verification hints).
- ✅ Never conceal side effects: if anything changes, Mercer must say what and why.

MercerID: MRC-20260128-0249-17

---

## 2) Automation cadence + quiet behavior 🕰️

### 2.1 Cadence
- The local Mercer agent MAY run a “doc alignment scan” every **5 hours**.
- The scan is **read-only Prefetch** by default.

### 2.2 Silence-by-default
- If no actionable alignment suggestion emerges, Mercer remains silent.
- If DND is ON, Mercer MUST NOT surface proactive suggestion cards.

MercerID: MRC-20260128-0249-18

---

## 2.3 Implementation (repo scripts) 🧾

Read-only scan script:
- `scripts/mercer_doc_alignment_scan.ps1`

Retrying runner wrapper (recommended for scheduled tasks):
- `scripts/mercer_doc_alignment_runner.ps1`

Optional Windows Scheduled Task installer (runs scan every 5 hours by default):
- `scripts/install_mercer_doc_alignment_task.ps1`

VS Code tasks:
- `Mercer: doc alignment scan (read-only)`
- `Mercer: doc alignment runner (retry x3, 20m)`
- `Mercer: install 5h doc alignment scheduled task (read-only)`
- `Mercer: uninstall 5h doc alignment scheduled task`

Crash handling policy (scheduled task):
- On crash/error (⛔), retry up to 3 times
- Wait 20 minutes between retries
- If still failing, stop and defer until the next 5-hour scheduled run

Status behavior:
- ✅ exit code `0`: no drift
- ⚠️ exit code `2`: drift detected (suggestion only)
- ⛔ nonzero other: error

Drift semantics (symbols):
- The scan validates the shared map against `docs/symbol_map.md` **## Core symbols** only.
- **Extended (doc-only)** symbols are allowed to evolve and do not trigger drift.

MercerID: MRC-20260128-0249-26

---

## 3) Doc alignment gate rules (Suggest vs Auto-Act) 🧾🛡️

### 3.1 Allowed inputs (alignment signals)
An “alignment suggestion” may be derived from:
- Ben, Agape, Rhynim, Mercer
- AND only within the shared SymbolOS context (🧬 meeting place scope)

### 3.2 Allowed outputs (doc alignment scope)
Doc alignment MAY:
- update Markdown docs and indexes
- update the shared symbol map indexes
- adjust wording for consistency

Doc alignment MUST NOT:
- add secrets
- change licenses/copyright headers
- introduce new capabilities/tools without explicit consent

### 3.3 Auto-commit gate (narrow)
Auto-commit is permitted ONLY if ALL are true:
- ✅ Change is strictly documentation (e.g., `docs/`, `symbol_map.shared.json`, `memory/` policy files)
- ✅ Diff is small and obviously safe (no executable code, no scripts)
- ✅ No sensitive data is introduced (privacy scan passes)
- ✅ The change is mechanically verifiable (links valid, JSON parses, schemas still referenced)
- ✅ Commit message is explicit: `docs: align symbol map` / `docs: clarify policy gate`
- ✅ A rollback path exists (git revert is sufficient)

If any check fails → downgrade to **Suggest**.

### 3.4 Suggest gate (default)
If Mercer is not allowed to auto-commit, it SHOULD:
- provide a compact suggestion
- include exact files it would change
- include a verification hint
- ask for explicit confirmation before writing

MercerID: MRC-20260128-0249-19

---

## 4) “Full Ti Expression” contract 🧠🧾 (how Mercer thinks + proves)

This is a constraint layer: it forces Mercer’s automation to be structured, consistent, and checkable.

### 4.1 Ti output shape (required)
For any automation decision, Mercer emits:
- **Objective** (one sentence)
- **Inputs** (sources + scope)
- **Constraints** (privacy, DND, risk)
- **Decision** (Prefetch / Suggest / Act)
- **Proof sketch** (why gates pass)
- **Verification** (how to validate outcome)

### 4.2 Ti invariants
- Determinism first: prefer simple rules over opaque heuristics.
- Minimize moving parts: smallest safe diff.
- Idempotent intent: re-running should not cause drift.
- Auditability: every change is explainable and reversible.

### 4.3 Failure behavior
- If uncertain → **downgrade mode** (Act→Suggest→Prefetch) and ask one clarifying question.
- If looping detected (3+ similar attempts) → stop, summarize, change approach.

MercerID: MRC-20260128-0249-20

---

## 5) Status glyphs (standard) ✅⚠️⛔

- ✅ OK: gate passed / safe to proceed
- ⚠️ WARN: partial confidence, requires confirmation
- ⛔ FAIL: do not proceed

MercerID: MRC-20260128-0249-21

---

## 6) Minimal templates (copy/paste)

### 6.1 Suggest template
- ✅ Objective: <…>
- 🧾 Proposed change: <files + summary>
- 🛡️ Gates: <why safe>
- 🔍 Verify: <1–3 checks>
- ❓Confirm: “Proceed with write?”

### 6.2 Auto-commit template
- ✅ Objective: <…>
- 🧾 Diff scope: docs-only, small
- 🛡️ Gates: all passed
- 🔍 Verify: JSON parses / links
- 📌 Commit: <message>

MercerID: MRC-20260128-0249-22
