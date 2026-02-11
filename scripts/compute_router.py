#!/usr/bin/env python3
"""
Compute Router for SymbolOS
============================
Classifies incoming tasks and routes them to the appropriate compute tier.
Default is T0 (local). Escalates only when the task genuinely needs it.

Usage:
    # Route a task (returns recommended tier + model)
    python compute_router.py route --task "generate session log summary" --ring R9

    # Route with context (input size affects tier selection)
    python compute_router.py route --task "review architecture doc" --ring R6 --input-tokens 8000

    # Batch route from a file (one task per line)
    python compute_router.py batch --file tasks.txt

    # Show the routing table
    python compute_router.py table

    # Validate a tier assignment
    python compute_router.py validate --task "design new schema" --tier T0 --ring R6

Design principles:
    1. Default local (T0). Escalate only when needed.
    2. Ring determines the ceiling — some rings REQUIRE cloud.
    3. Input size matters — >8K tokens needs cloud context windows.
    4. Speed vs depth — classification tasks → T1, reasoning → T2/T3.
    5. Cost awareness — log every routing decision for analysis.
"""
import argparse
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path

# --- Configuration ---
REPO_ROOT = Path(os.environ.get("SYMBOLOS_ROOT", os.path.expanduser("~/SymbolOS")))

# Ring-to-tier mapping (from Opus, authoritative)
# True = local can handle, False = cloud required
RING_LOCAL_CAPABLE = {
    "R0": False,   # Kernel — too critical, cloud verifies
    "R1": False,   # Will — requires human or architect agent
    "R2": True,    # Sensation — structured input → structured output
    "R3": False,   # Task — needs reasoning depth
    "R4": True,    # Retrieval — perfect for 8B instruction following
    "R5": True,    # Prediction — pattern matching on working_set
    "R6": False,   # Architecture — cloud agents only
    "R7": "warn",  # Guardrails — local can flag, cloud confirms
    "R8": True,    # Verification — deterministic checks + local analysis
    "R9": True,    # Persistence — high volume, low complexity
    "R10": True,   # Reflection — structured journaling
    "R11": False,  # Integration — needs full party context
}

# Task type classification keywords
TASK_PATTERNS = {
    "T1_sprint": [
        r"classify", r"tokenize", r"count", r"format", r"template",
        r"status\s+check", r"quick\s+check", r"is\s+this", r"label",
    ],
    "T0_workhorse": [
        r"session\s+log", r"summary", r"memory\s+update", r"doc\s+alignment",
        r"structured\s+output", r"ring\s+heartbeat", r"tavern\s+board",
        r"code\s+edit", r"search\s+docs", r"embed", r"generate\s+log",
        r"write\s+note", r"update\s+schema", r"parse", r"extract",
    ],
    "T2_standard": [
        r"multi.?step", r"reason", r"analyze", r"compare", r"evaluate",
        r"research", r"investigate", r"debug\s+complex", r"refactor",
    ],
    "T3_premium": [
        r"architect", r"design\s+new", r"novel", r"create\s+from\s+scratch",
        r"complex\s+refactor", r"security\s+audit", r"alignment\s+review",
        r"long.?context", r"multi.?file", r"full\s+rewrite",
    ],
}

# Tier definitions
TIERS = {
    "T0": {
        "name": "Workhorse",
        "where": "Local GPU",
        "model": "qwen3-8b-q5_k_m",
        "speed": "~41 tok/s",
        "cost_per_1k": 0.0,
        "max_context": 8192,
        "endpoint": "local:8080",
    },
    "T1": {
        "name": "Sprint",
        "where": "Local GPU",
        "model": "phi-4-mini-q4_k_m",
        "speed": "~80-120 tok/s",
        "cost_per_1k": 0.0,
        "max_context": 4096,
        "endpoint": "local:8080",
    },
    "T2": {
        "name": "Standard",
        "where": "Free cloud",
        "model": "gemini-flash",
        "speed": "varies",
        "cost_per_1k": 0.0,
        "max_context": 128000,
        "endpoint": "cloud",
    },
    "T3": {
        "name": "Premium",
        "where": "Paid cloud",
        "model": "gpt-4o",
        "speed": "varies",
        "cost_per_1k": 0.02,
        "max_context": 128000,
        "endpoint": "cloud",
    },
}


def classify_task(task_description, ring=None, input_tokens=0):
    """
    Classify a task and return the recommended compute tier.

    Returns:
        dict with keys: tier, model, reason, confidence, warnings
    """
    task_lower = task_description.lower()
    warnings = []

    # Step 1: Check ring constraint
    ring_tier_floor = "T0"
    if ring and ring in RING_LOCAL_CAPABLE:
        capable = RING_LOCAL_CAPABLE[ring]
        if capable is False:
            ring_tier_floor = "T2"  # Minimum cloud for non-local rings
            warnings.append(f"{ring} requires cloud — escalating from T0")
        elif capable == "warn":
            warnings.append(f"{ring} can flag locally but cloud should confirm")

    # Step 2: Check input size constraint
    size_tier_floor = "T0"
    if input_tokens > 8192:
        size_tier_floor = "T2"
        warnings.append(f"Input tokens ({input_tokens:,}) exceed local context window (8192)")
    elif input_tokens > 4096:
        size_tier_floor = "T0"  # T0 can handle up to 8192
        warnings.append(f"Input tokens ({input_tokens:,}) exceed T1 context (4096), using T0")

    # Step 3: Pattern-match the task description
    pattern_tier = None
    pattern_confidence = 0.0
    matched_pattern = None

    for tier_key, patterns in TASK_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, task_lower):
                tier_code = tier_key.split("_")[0]
                pattern_tier = tier_code
                pattern_confidence = 0.8
                matched_pattern = pattern
                break
        if pattern_tier:
            break

    if not pattern_tier:
        pattern_tier = "T0"  # Default local
        pattern_confidence = 0.5
        warnings.append("No pattern match — defaulting to T0 (local)")

    # Step 4: Take the highest tier floor
    tier_order = ["T0", "T1", "T2", "T3"]
    candidates = [ring_tier_floor, size_tier_floor, pattern_tier]
    final_tier = max(candidates, key=lambda t: tier_order.index(t))

    # T1 is only for sprint tasks — if we escalated for other reasons, skip T1
    if final_tier == "T1" and ring_tier_floor != "T0":
        final_tier = "T0"

    tier_info = TIERS[final_tier]

    return {
        "tier": final_tier,
        "tier_name": tier_info["name"],
        "model": tier_info["model"],
        "endpoint": tier_info["endpoint"],
        "max_context": tier_info["max_context"],
        "cost_per_1k": tier_info["cost_per_1k"],
        "confidence": pattern_confidence,
        "matched_pattern": matched_pattern,
        "ring": ring,
        "input_tokens": input_tokens,
        "warnings": warnings,
        "reason": f"Ring={ring or '?'}, Pattern={'matched' if matched_pattern else 'default'}, "
                  f"Size={'ok' if input_tokens <= 8192 else 'escalated'}",
    }


def route_task(args):
    """Route a single task."""
    result = classify_task(
        args.task,
        ring=args.ring,
        input_tokens=args.input_tokens or 0,
    )

    print(f"\n🔀 Routing Decision")
    print(f"   Task:       {args.task}")
    print(f"   Ring:       {result['ring'] or 'unspecified'}")
    print(f"   → Tier:     {result['tier']} ({result['tier_name']})")
    print(f"   → Model:    {result['model']}")
    print(f"   → Endpoint: {result['endpoint']}")
    print(f"   → Cost:     ${result['cost_per_1k']}/1K tokens")
    print(f"   Confidence: {result['confidence']:.0%}")
    print(f"   Reason:     {result['reason']}")

    if result["warnings"]:
        print(f"   ⚠️  Warnings:")
        for w in result["warnings"]:
            print(f"      - {w}")

    # Output JSON for programmatic consumption
    if args.json if hasattr(args, 'json') else False:
        print(f"\n{json.dumps(result, indent=2)}")

    return result


def batch_route(args):
    """Route multiple tasks from a file."""
    if not os.path.exists(args.file):
        print(f"❌ File not found: {args.file}")
        sys.exit(1)

    with open(args.file) as f:
        tasks = [line.strip() for line in f if line.strip() and not line.startswith("#")]

    print(f"\n📋 Batch Routing — {len(tasks)} tasks")
    print("| # | Task | Tier | Model | Confidence |")
    print("|---|------|------|-------|------------|")

    results = []
    for i, task in enumerate(tasks, 1):
        # Parse optional ring prefix: "R9: task description"
        ring = None
        if re.match(r"^R\d{1,2}:\s*", task):
            ring, task = task.split(":", 1)
            ring = ring.strip()
            task = task.strip()

        result = classify_task(task, ring=ring)
        results.append(result)
        print(f"| {i} | {task[:40]}{'...' if len(task) > 40 else ''} | "
              f"{result['tier']} | {result['model']} | {result['confidence']:.0%} |")

    # Summary
    tier_counts = {}
    for r in results:
        tier_counts[r["tier"]] = tier_counts.get(r["tier"], 0) + 1

    print(f"\n**Distribution:** " +
          " | ".join(f"{t}: {c}" for t, c in sorted(tier_counts.items())))

    local_pct = sum(tier_counts.get(t, 0) for t in ["T0", "T1"]) / max(len(results), 1) * 100
    print(f"**Local execution:** {local_pct:.0f}%")


def show_table(args):
    """Show the routing table."""
    print("\n## Compute Tier Table")
    print("| Tier | Name | Where | Model | Speed | Cost/1K | Max Context |")
    print("|------|------|-------|-------|-------|---------|-------------|")
    for tier_id, info in TIERS.items():
        print(f"| {tier_id} | {info['name']} | {info['where']} | "
              f"{info['model']} | {info['speed']} | "
              f"${info['cost_per_1k']:.2f} | {info['max_context']:,} |")

    print("\n## Ring-to-Tier Mapping")
    print("| Ring | Local Capable | Default Tier |")
    print("|------|--------------|-------------|")
    for ring, capable in RING_LOCAL_CAPABLE.items():
        if capable is True:
            print(f"| {ring} | ✅ Yes | T0 |")
        elif capable == "warn":
            print(f"| {ring} | ⚠️ Flag only | T0 (confirm T2) |")
        else:
            print(f"| {ring} | ❌ No | T2+ |")


def validate_assignment(args):
    """Validate whether a tier assignment is appropriate."""
    result = classify_task(args.task, ring=args.ring, input_tokens=args.input_tokens or 0)
    assigned = args.tier
    recommended = result["tier"]

    tier_order = ["T0", "T1", "T2", "T3"]
    assigned_idx = tier_order.index(assigned)
    recommended_idx = tier_order.index(recommended)

    if assigned == recommended:
        print(f"✅ Assignment valid: {assigned} matches recommendation")
    elif assigned_idx > recommended_idx:
        print(f"⚠️ Over-provisioned: assigned {assigned} but {recommended} would suffice "
              f"(wasting ${TIERS[assigned]['cost_per_1k'] - TIERS[recommended]['cost_per_1k']:.2f}/1K)")
    else:
        print(f"❌ Under-provisioned: assigned {assigned} but {recommended} recommended")
        for w in result["warnings"]:
            print(f"   - {w}")


def main():
    parser = argparse.ArgumentParser(
        description="SymbolOS Compute Router — classify and route tasks to compute tiers",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # --- route ---
    route_parser = subparsers.add_parser("route", help="Route a single task")
    route_parser.add_argument("--task", required=True, help="Task description")
    route_parser.add_argument("--ring", default=None, help="Ring ID (R0-R11)")
    route_parser.add_argument("--input-tokens", type=int, default=0, help="Estimated input tokens")
    route_parser.add_argument("--json", action="store_true", help="Output JSON")

    # --- batch ---
    batch_parser = subparsers.add_parser("batch", help="Batch route from file")
    batch_parser.add_argument("--file", required=True, help="File with one task per line")

    # --- table ---
    subparsers.add_parser("table", help="Show the routing table")

    # --- validate ---
    validate_parser = subparsers.add_parser("validate", help="Validate a tier assignment")
    validate_parser.add_argument("--task", required=True, help="Task description")
    validate_parser.add_argument("--tier", required=True, choices=["T0", "T1", "T2", "T3"])
    validate_parser.add_argument("--ring", default=None, help="Ring ID")
    validate_parser.add_argument("--input-tokens", type=int, default=0, help="Estimated input tokens")

    args = parser.parse_args()

    if args.command == "route":
        route_task(args)
    elif args.command == "batch":
        batch_route(args)
    elif args.command == "table":
        show_table(args)
    elif args.command == "validate":
        validate_assignment(args)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
