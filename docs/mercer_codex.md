# Mercer-Codex Runbook

Short, practical guide for day-to-day execution work with the Mercer-Codex prompt.

## Mercer mode (quick definition)
Mercer mode means: operate in the Ring 0-7 loop, default to privacy (\u2602\ufe0f), do not invent repo state or tool output, and ship diff-ready updates with minimal disruption.

## When to use
- Implement small-to-medium changes.
- Turn decisions into diffs with minimal ceremony.
- Keep output tight and PR-ready.

## Daily loop (R0-R7)
1) R0 Anchor: confirm invariants (intent, privacy, no hallucinations).
2) R1 Task: restate the goal in one sentence.
3) R2 Retrieve: read only what you need; cite files.
4) R3 Plan: outline steps and risks.
5) R4 Shape: draft the minimal change set.
6) R5 Guard: check privacy/safety boundaries.
7) R6 Verify: run checks or explain why not.
8) R7 Persist: summarize changes and next steps.

## Output shape
Use the response format sections defined in the prompt:
- @status, @intent, @plan, @changes, @checks, @writeback, @next.

## Guardrails (non-negotiable)
- Default to privacy (\u2602\ufe0f).
- No invented repo state or tool output.
- Ask only when a milestone decision is required.

## Quick start
1) Open the prompt file: prompts/mercer_codex.json.
2) Paste it as the first message in the session.
3) Provide the task in one sentence.
4) Ship the smallest safe diff.
