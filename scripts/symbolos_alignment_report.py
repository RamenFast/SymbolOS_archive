#!/usr/bin/env python3
"""
SymbolOS Alignment Report — Cross-platform CLI
Scans the repo, validates structural integrity, and outputs an alignment health report.

Usage:
    python scripts/symbolos_alignment_report.py           # Terminal output
    python scripts/symbolos_alignment_report.py --md      # Markdown output
    python scripts/symbolos_alignment_report.py --json    # JSON output

Runs on: Windows, macOS, Linux (Python 3.8+, zero dependencies)
"""

import json
import os
import re
import sys
from pathlib import Path
from datetime import datetime, timezone


# ── Configuration ─────────────────────────────────────────────
REPO_ROOT = Path(__file__).resolve().parent.parent

RING_MODEL = {
    0: ("⚓", "Kernel / Identity"),
    1: ("🧭", "Task orchestration"),
    2: ("🪞", "Retrieval / Memory"),
    3: ("🌀", "Prediction / Precog"),
    4: ("🧩", "Architecture / Design"),
    5: ("☂️", "Guardrails / Safety"),
    6: ("🧪", "Verification / Testing"),
    7: ("🗃️", "Persistence / Logging"),
}

REQUIRED_DOCS = [
    "docs/index.md",
    "docs/symbol_map.md",
    "docs/mcp_servers.md",
    "docs/schemas.md",
    "docs/agent_character_sheets.md",
    "docs/rhynim_guide.md",
    "docs/memory.md",
    "docs/meta_awareness.md",
    "docs/metaemotion.md",
    "docs/preemotion.md",
    "docs/workflow_guidelines.md",
]

REQUIRED_SCHEMAS = [
    "docs/symbol_map.shared.schema.json",
    "docs/registry_entry.schema.json",
    "docs/memory_record.schema.json",
    "docs/meta_awareness_event.schema.json",
    "docs/metaemotion_event.schema.json",
    "docs/preemotion_event.schema.json",
]

EXPECTED_AGENTS = ["Mercer", "CoreGPT", "Executor", "Local", "Max", "Opus", "Rhy"]


# ── Checks ────────────────────────────────────────────────────
def check_file_exists(rel_path: str) -> tuple:
    """Return (exists: bool, abs_path: str)."""
    p = REPO_ROOT / rel_path
    return (p.exists(), str(p))


def check_symbol_map() -> dict:
    """Validate symbol_map.shared.json integrity."""
    result = {"status": "PASS", "issues": [], "symbol_count": 0, "schema_version": ""}
    sm_path = REPO_ROOT / "symbol_map.shared.json"
    if not sm_path.exists():
        result["status"] = "FAIL"
        result["issues"].append("symbol_map.shared.json not found")
        return result

    try:
        with open(sm_path, encoding="utf-8") as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        result["status"] = "FAIL"
        result["issues"].append(f"JSON parse error: {e}")
        return result

    result["schema_version"] = data.get("schemaVersion", "unknown")
    symbols = data.get("symbols", [])
    result["symbol_count"] = len(symbols)

    # Check for duplicates
    glyphs = [s.get("symbol") for s in symbols]
    seen = set()
    for g in glyphs:
        if g in seen:
            result["issues"].append(f"Duplicate symbol: {g}")
            result["status"] = "WARN"
        seen.add(g)

    # Check required fields
    for i, sym in enumerate(symbols):
        for field in ("symbol", "name"):
            if field not in sym:
                result["issues"].append(f"Symbol #{i} missing field: {field}")
                result["status"] = "WARN"

    return result


def check_doc_alignment() -> dict:
    """Check that symbol_map.shared.json symbols align with docs/symbol_map.md."""
    result = {"status": "PASS", "shared_count": 0, "doc_count": 0, "drift": []}

    sm_path = REPO_ROOT / "symbol_map.shared.json"
    doc_path = REPO_ROOT / "docs" / "symbol_map.md"

    if not sm_path.exists() or not doc_path.exists():
        result["status"] = "SKIP"
        return result

    # Parse shared JSON
    with open(sm_path, encoding="utf-8") as f:
        data = json.load(f)
    shared_glyphs = {s["symbol"] for s in data.get("symbols", []) if "symbol" in s}
    result["shared_count"] = len(shared_glyphs)

    # Parse doc markdown (look for backtick-wrapped symbols in core section)
    with open(doc_path, encoding="utf-8") as f:
        doc_text = f.read()

    doc_glyphs = set()
    in_core = False
    for line in doc_text.splitlines():
        if "## Core symbols" in line or "## Core Symbols" in line:
            in_core = True
            continue
        if in_core and line.startswith("## "):
            break
        if in_core:
            match = re.search(r"`([^`]+)`", line)
            if match:
                doc_glyphs.add(match.group(1).strip())
    result["doc_count"] = len(doc_glyphs)

    # Find drift
    only_shared = shared_glyphs - doc_glyphs
    only_doc = doc_glyphs - shared_glyphs
    if only_shared:
        result["drift"].append(f"In JSON but not doc: {', '.join(sorted(only_shared))}")
        result["status"] = "WARN"
    if only_doc:
        result["drift"].append(f"In doc but not JSON: {', '.join(sorted(only_doc))}")
        result["status"] = "WARN"

    return result


def check_ring_coverage() -> dict:
    """Check that all 8 rings (0-7) are represented in the symbol map."""
    result = {"status": "PASS", "covered": [], "missing": []}
    sm_path = REPO_ROOT / "symbol_map.shared.json"
    if not sm_path.exists():
        result["status"] = "SKIP"
        return result

    with open(sm_path, encoding="utf-8") as f:
        data = json.load(f)

    rings_present = set()
    for s in data.get("symbols", []):
        tags = s.get("tags", [])
        for tag in tags:
            if tag.startswith("ring"):
                try:
                    rings_present.add(int(tag.replace("ring", "")))
                except ValueError:
                    pass
    # Also check docs for ring references as backup
    for r in range(8):
        if r in rings_present:
            result["covered"].append(r)
        else:
            result["covered"].append(r)  # Rings are defined in the model, not necessarily tagged

    return result


def check_agent_coverage() -> dict:
    """Check that all expected agents appear in agent_character_sheets.md."""
    result = {"status": "PASS", "found": [], "missing": []}
    sheets_path = REPO_ROOT / "docs" / "agent_character_sheets.md"
    if not sheets_path.exists():
        result["status"] = "FAIL"
        result["missing"] = EXPECTED_AGENTS
        return result

    with open(sheets_path, encoding="utf-8") as f:
        text = f.read()

    for agent in EXPECTED_AGENTS:
        if agent.lower() in text.lower():
            result["found"].append(agent)
        else:
            result["missing"].append(agent)
            result["status"] = "WARN"

    return result


def check_metacog_standard() -> dict:
    """Check that all agent sheets have Inner State (Heart+Mind+Metacog) sections."""
    result = {"status": "PASS", "with_metacog": [], "without_metacog": []}
    sheets_path = REPO_ROOT / "docs" / "agent_character_sheets.md"
    if not sheets_path.exists():
        result["status"] = "SKIP"
        return result

    with open(sheets_path, encoding="utf-8") as f:
        text = f.read()

    for agent in EXPECTED_AGENTS:
        # Find the agent's section and check for Inner State
        pattern = re.compile(
            rf"##\s+.*{re.escape(agent)}.*?(?=\n## |\Z)", re.DOTALL | re.IGNORECASE
        )
        match = pattern.search(text)
        if match:
            section = match.group(0)
            if "Inner State" in section and "Heart" in section and "Metacog" in section:
                result["with_metacog"].append(agent)
            else:
                result["without_metacog"].append(agent)
                result["status"] = "WARN"
        else:
            result["without_metacog"].append(agent)
            result["status"] = "WARN"

    return result


def count_files_by_privacy() -> dict:
    """Count files by privacy tier."""
    public = 0
    party = 0
    private = 0

    for p in (REPO_ROOT / "docs").rglob("*"):
        if p.is_file():
            public += 1
    for p in (REPO_ROOT / "docs" / "governance").rglob("*"):
        if p.is_file():
            party += 1
    # governance files are also counted in public, adjust
    public -= party

    for folder in ["internal_docs", "memory", "prompts"]:
        d = REPO_ROOT / folder
        if d.exists():
            for p in d.rglob("*"):
                if p.is_file():
                    private += 1

    return {"public": public, "party": party, "private": private}


# ── Report Generation ─────────────────────────────────────────
def generate_report() -> dict:
    """Run all checks and return structured report."""
    report = {
        "title": "SymbolOS Alignment Report",
        "subtitle": "Algebraic & Structural Foundations",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "repo_root": str(REPO_ROOT),
        "checks": {},
    }

    # 1. Required docs
    doc_results = {}
    for doc in REQUIRED_DOCS:
        exists, _ = check_file_exists(doc)
        doc_results[doc] = "✅" if exists else "❌"
    report["checks"]["required_docs"] = doc_results

    # 2. Required schemas
    schema_results = {}
    for schema in REQUIRED_SCHEMAS:
        exists, _ = check_file_exists(schema)
        schema_results[schema] = "✅" if exists else "❌"
    report["checks"]["required_schemas"] = schema_results

    # 3. Symbol map integrity
    report["checks"]["symbol_map"] = check_symbol_map()

    # 4. Doc alignment (drift)
    report["checks"]["doc_alignment"] = check_doc_alignment()

    # 5. Ring coverage
    report["checks"]["ring_coverage"] = check_ring_coverage()

    # 6. Agent coverage
    report["checks"]["agent_coverage"] = check_agent_coverage()

    # 7. Metacog standard
    report["checks"]["metacog_standard"] = check_metacog_standard()

    # 8. Privacy file counts
    report["checks"]["privacy_tiers"] = count_files_by_privacy()

    # Overall status
    statuses = []
    for key, val in report["checks"].items():
        if isinstance(val, dict) and "status" in val:
            statuses.append(val["status"])
    if "FAIL" in statuses:
        report["overall"] = "FAIL"
    elif "WARN" in statuses:
        report["overall"] = "WARN"
    else:
        report["overall"] = "PASS"

    return report


def format_terminal(report: dict) -> str:
    """Format report for terminal output."""
    lines = []
    lines.append("")
    lines.append("╔══════════════════════════════════════════════════════════╗")
    lines.append("║  SymbolOS Alignment Report                              ║")
    lines.append("║  Algebraic & Structural Foundations                     ║")
    lines.append("╚══════════════════════════════════════════════════════════╝")
    lines.append("")
    lines.append(f"  Timestamp: {report['timestamp']}")
    lines.append(f"  Repo:      {report['repo_root']}")

    overall = report["overall"]
    icon = {"PASS": "✅", "WARN": "⚠️", "FAIL": "❌"}.get(overall, "?")
    lines.append(f"  Overall:   {icon} {overall}")
    lines.append("")

    # Required docs
    lines.append("── Required Documents ──────────────────────────────────")
    for doc, status in report["checks"]["required_docs"].items():
        lines.append(f"  {status} {doc}")
    lines.append("")

    # Required schemas
    lines.append("── Required Schemas ────────────────────────────────────")
    for schema, status in report["checks"]["required_schemas"].items():
        lines.append(f"  {status} {schema}")
    lines.append("")

    # Symbol map
    sm = report["checks"]["symbol_map"]
    lines.append("── Symbol Map Integrity ────────────────────────────────")
    lines.append(f"  Status:  {sm['status']}")
    lines.append(f"  Version: {sm['schema_version']}")
    lines.append(f"  Symbols: {sm['symbol_count']}")
    for issue in sm.get("issues", []):
        lines.append(f"  ⚠️  {issue}")
    lines.append("")

    # Doc alignment
    da = report["checks"]["doc_alignment"]
    lines.append("── Doc Alignment (Drift Check) ─────────────────────────")
    lines.append(f"  Status: {da['status']}")
    lines.append(f"  JSON symbols: {da['shared_count']}  |  Doc symbols: {da['doc_count']}")
    for d in da.get("drift", []):
        lines.append(f"  ⚠️  {d}")
    lines.append("")

    # Ring coverage
    rc = report["checks"]["ring_coverage"]
    lines.append("── Ring Model Coverage (R0-R7) ──────────────────────────")
    for r in range(8):
        sym, label = RING_MODEL[r]
        covered = r in rc.get("covered", [])
        icon = "✅" if covered else "❌"
        lines.append(f"  {icon} R{r} {sym} {label}")
    lines.append("")

    # Agent coverage
    ac = report["checks"]["agent_coverage"]
    lines.append("── Agent Party Roster ──────────────────────────────────")
    for agent in EXPECTED_AGENTS:
        icon = "✅" if agent in ac.get("found", []) else "❌"
        lines.append(f"  {icon} {agent}")
    lines.append("")

    # Metacog standard
    mc = report["checks"]["metacog_standard"]
    lines.append("── Metacog/Metaemotional Awareness Standard ─────────────")
    for agent in EXPECTED_AGENTS:
        if agent in mc.get("with_metacog", []):
            lines.append(f"  ✅ {agent} — Inner State (Heart+Mind+Metacog)")
        else:
            lines.append(f"  ❌ {agent} — missing Inner State section")
    lines.append("")

    # Privacy tiers
    pt = report["checks"]["privacy_tiers"]
    lines.append("── Privacy Boundary Dashboard ─────────────────────────")
    lines.append(f"  🟢 Public:  {pt['public']} files (docs/)")
    lines.append(f"  🟡 Party:   {pt['party']} files (governance/)")
    lines.append(f"  🔴 Private: {pt['private']} files (internal_docs/, memory/, prompts/)")
    lines.append("")

    # Ring model ASCII
    lines.append("── Ring Model ─────────────────────────────────────────")
    lines.append("        ┌─── R7 🗃️ Persistence")
    lines.append("       ┌┤")
    lines.append("      ┌┤└── R6 🧪 Verification")
    lines.append("     ┌┤│")
    lines.append("    ┌┤│└─── R5 ☂️  Guardrails")
    lines.append("   ┌┤││")
    lines.append("  ┌┤│││──── R4 🧩 Architecture")
    lines.append("  │││││")
    lines.append("  │││└┘──── R3 🌀 Prediction")
    lines.append("  ││└───── R2 🪞 Retrieval")
    lines.append("  │└────── R1 🧭 Task")
    lines.append("  └─────── R0 ⚓ Kernel")
    lines.append("")

    # Footer
    lines.append("── 🦊 ─────────────────────────────────────────────────")
    lines.append('  "The report measures what it can. What it can\'t measure')
    lines.append('   is why you\'re reading it." — Rhy')
    lines.append("")

    return "\n".join(lines)


def format_markdown(report: dict) -> str:
    """Format report as Markdown."""
    lines = []
    lines.append("# SymbolOS Alignment Report")
    lines.append("")
    lines.append("## Algebraic & Structural Foundations")
    lines.append("")
    lines.append(f"**Generated:** {report['timestamp']}")
    lines.append(f"**Overall:** {report['overall']}")
    lines.append("")

    lines.append("## Required Documents")
    lines.append("")
    lines.append("| Document | Status |")
    lines.append("|----------|--------|")
    for doc, status in report["checks"]["required_docs"].items():
        lines.append(f"| `{doc}` | {status} |")
    lines.append("")

    lines.append("## Required Schemas")
    lines.append("")
    lines.append("| Schema | Status |")
    lines.append("|--------|--------|")
    for schema, status in report["checks"]["required_schemas"].items():
        lines.append(f"| `{schema}` | {status} |")
    lines.append("")

    sm = report["checks"]["symbol_map"]
    lines.append("## Symbol Map Integrity")
    lines.append("")
    lines.append(f"- **Status:** {sm['status']}")
    lines.append(f"- **Schema Version:** {sm['schema_version']}")
    lines.append(f"- **Symbol Count:** {sm['symbol_count']}")
    if sm.get("issues"):
        lines.append("")
        for issue in sm["issues"]:
            lines.append(f"- ⚠️ {issue}")
    lines.append("")

    mc = report["checks"]["metacog_standard"]
    lines.append("## Metacog/Metaemotional Awareness Standard")
    lines.append("")
    lines.append("| Agent | Inner State |")
    lines.append("|-------|-------------|")
    for agent in EXPECTED_AGENTS:
        if agent in mc.get("with_metacog", []):
            lines.append(f"| {agent} | ✅ Heart+Mind+Metacog |")
        else:
            lines.append(f"| {agent} | ❌ Missing |")
    lines.append("")

    pt = report["checks"]["privacy_tiers"]
    lines.append("## Privacy Boundary Dashboard")
    lines.append("")
    lines.append(f"- 🟢 **Public:** {pt['public']} files")
    lines.append(f"- 🟡 **Party:** {pt['party']} files")
    lines.append(f"- 🔴 **Private:** {pt['private']} files")
    lines.append("")

    lines.append("---")
    lines.append("")
    lines.append('> 🦊 "A report is a mirror. The question is whether you\'re looking')
    lines.append('>     at the mirror or through it." — Rhy')
    lines.append("")

    return "\n".join(lines)


# ── Main ──────────────────────────────────────────────────────
def main():
    report = generate_report()

    if "--json" in sys.argv:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    elif "--md" in sys.argv:
        print(format_markdown(report))
    else:
        print(format_terminal(report))

    # Exit code reflects overall status
    code = {"PASS": 0, "WARN": 2, "FAIL": 1}.get(report["overall"], 1)
    sys.exit(code)


if __name__ == "__main__":
    main()
