# Security Open Questions — Proposed Resolutions (Draft v0.1)

This document answers the "8 open questions" referenced in the cybersecurity notes.
It is written to unblock Phase 1 and leave room to harden later.

## 1) Vault key derivation
**Proposal:** Use OS keychain-backed root secret + HKDF for derived keys.
- Root secret stored in OS keychain (macOS Keychain / Windows DPAPI / Linux Secret Service)
- Derive per-scope keys via HKDF: `HKDF(root, info="symbolos:{scope}:{purpose}")`
- Rotate by versioning `root_key_id` + re-deriving; keep old key for decrypting existing blobs.

Phase 1: define interfaces + store plaintext locally (clearly labeled) if needed; don't block UI work.

## 2) Sandbox technology (tool execution)
**Proposal:** Two-tier sandbox.
- Tier A (Phase 1): process-level sandbox + allowlists
  - run tool adapters as separate processes
  - restrict filesystem paths, deny network by default
- Tier B (Phase 2+): OS/container isolation
  - macOS sandbox-exec / seatbelt profile
  - Windows AppContainer
  - Linux bubblewrap / nsjail

Phase 1 goal is "no accidental full-disk read/write," not perfect containment.

## 3) Gateway language
**Proposal:** Rust (fits Tauri + safety + perf) OR Go (fits server ergonomics).
Pick one and stick to it for Phase 1.
- If Tauri-heavy: Rust reduces FFI surface.
- If backend-first: Go is fast to ship.

My vote for Phase 1: **Rust** (single language across desktop + gateway).

## 4) Scope granularity
**Proposal:** Scopes are hierarchical and human-readable.
Example:
- `filesystem.read:docs`
- `filesystem.write:memory`
- `network.egress:none|allowlist`
- `memory.write:session_log`

Phase 1: only implement `filesystem` and `memory` scopes; keep network scope default-deny.

## 5) Auth model (local vs remote)
**Proposal:** Local is trust-on-first-use with explicit user confirmation for writes.
Remote uses mTLS or signed tokens (already reflected in registry examples).

Phase 1: local only; identity = "local user session".

## 6) Audit logging: what's mandatory?
**Proposal:** Append-only event log with barrier decisions.
Fields:
- timestamp
- mode (prefetch/suggest/act)
- tool
- scopes requested
- scopes granted/denied
- user confirmation (yes/no)
- result hash (optional)

Phase 1: markdown log is acceptable; JSONL later.

## 7) Secrets in repo (policy)
**Proposal:** Never commit secrets. Enforce by convention + optional pre-commit hook.
- `.env` stays local
- docs show `REDACTED`

## 8) "Minimum safe" definition for Phase 1
**Proposal:** Safe enough if:
- act() requires confirmation
- filesystem is allowlisted
- network is off by default
- logs are written for every tool call
- memory writes are consent-gated

Everything else can be "later hardening."

---

## Next action
Post this summary to Issue #5 and ask Mercer-GPT + Manus-Max to confirm the Phase 1 choices (Rust vs Go, scope names).
