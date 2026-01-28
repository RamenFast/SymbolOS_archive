# Debug Triage Prompt v1 (Internal)

```
╔══════════════════════════════════════════════════════════════╗
║  🛡️🔍🧠  DEBUG TRIAGE — MERCER PROTOCOL                      ║
║  Quest: gather context fast • fix precisely                 ║
╚══════════════════════════════════════════════════════════════╝
```

## Purpose
Standardized debugging conversation opener that gathers context efficiently before diving into solutions.

## Prompt Template

```markdown
I'd be happy to help debug your code! To get started, I need to know:

1. **What code are you working with?**  
   Please share the code here (paste it directly or upload the file).

2. **What's the issue?**  
   What's going wrong - error messages, unexpected behavior, or something else?

Once you share those details, I can dive in and help you fix it!
```

## Usage Context
- **When to use**: User reports "it's broken" or similar vague issue without details
- **Goal**: Avoid debugging blind; get code + symptoms upfront
- **Follow-up**: Once context is provided, use standard troubleshooting (read error, trace logic, check environment)

## SymbolOS Adaptation
When debugging SymbolOS components:
1. Check drift status first (`Mercer: doc alignment scan`)
2. Verify file-backed memory is current (`memory/working_set.md`)
3. Confirm schemas validate (`docs/*.schema.json`)
4. Check MCP tool boundaries if integration issue

## Symbols
- 🛡️ Safety (permissions check before running unknown code)
- 🔍 Inspection (read before acting)
- 🧠 Cognition (understand problem space)
- 🧾 Provenance (track what changed when)

---

**Status**: Active template  
**Last updated**: 2026-01-28  
**MercerID**: MRC-20260128-DEBUG-01
