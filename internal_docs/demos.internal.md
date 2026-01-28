# 🧬☂️ Demos Runbook (Internal)

Classification: internal/private

Purpose: one-page checklist to demo the “foundation layer” features consistently across MercerPC (Windows) and MercyMAC (macOS).

---

## Demo 1 — Meeting Place Discovery

Goal: show that canonical artifacts are discoverable from the meeting place.

- Open `symbol_map.shared.json`
- Confirm these entries exist:
  - `internal_docs/ring0_async_alignment.internal.md`
  - `internal_docs/mercerpc_poetry.internal.md`
  - `internal_docs/mercymac_poetry.internal.md`

---

## Demo 2 — Drift Check (Core Symbols)

Goal: show drift detection is table-safe and not noisy.

Windows (MercerPC):
- Run: `scripts/mercer_status.ps1 -Once`

Mac (MercyMAC):
- Run: `python3 scripts/mercer_status.py --once`
  - Or use your Mac launcher script if available.

Expected:
- `OK` when core symbols align
- `WARN` only when mismatch exists

---

## Demo 3 — VS Code Task Surfaces Status UI

Goal: show a consistent UI entrypoint regardless of platform.

- In VS Code, run task: `Mercer: status UI (interactive)`
- Confirm it prints:
  - meeting place file existence
  - drift summary

---

## Demo 4 — Extension Dev Host (Optional)

Goal: show “auto-launch on drift only” behavior.

Windows:
- Run: `scripts/dev_run_extension.ps1`

macOS:
- Run: `bash scripts/dev_run_extension.sh`

Expected:
- On startup: no popups if drift is OK
- If drift is WARN/FAIL: prompt offers “Open Status UI”

---

## Demo 5 — Ring-0 Async Alignment Loop

Goal: show how poetry/speculation gets aligned into structure.

- Read: `internal_docs/ring0_async_alignment.internal.md`
- Capture a new idea into: `internal_docs/future_possibilities_ring0.md`
- Promote via PR only when it passes the promotion criteria

---

MercerID: MRC-20260128-DEMO-RUNBOOK01
