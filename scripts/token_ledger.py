#!/usr/bin/env python3
"""
Token Ledger for SymbolOS
=========================
Logs every inference call (local or cloud) to a JSONL ledger file.
Provides daily summaries, cost tracking, and tier breakdown.

Usage:
    # Log an inference call
    python token_ledger.py log \
        --agent mercer-local --tier T0 --model qwen3-8b-q5_k_m \
        --tokens-in 340 --tokens-out 1200 --cost 0.00 \
        --task "generate session log summary" --ring R9 \
        --endpoint local:8080 --latency-ms 24000

    # Generate daily summary
    python token_ledger.py summary [--date 2026-02-11]

    # Generate weekly report
    python token_ledger.py report [--days 7]

    # Export CSV for analysis
    python token_ledger.py export [--date 2026-02-11] [--output ledger.csv]

Ledger format: memory/m0_episodic/token_ledger.jsonl
"""
import argparse
import csv
import json
import os
import sys
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path

# --- Configuration ---
REPO_ROOT = Path(os.environ.get("SYMBOLOS_ROOT", os.path.expanduser("~/SymbolOS")))
LEDGER_PATH = REPO_ROOT / "memory" / "m0_episodic" / "token_ledger.jsonl"

# Cost rates per 1K tokens (input/output) by tier
# T0/T1 = free (local), T2 = free tier cloud, T3 = paid cloud
COST_RATES = {
    "T0": {"in": 0.0, "out": 0.0},
    "T1": {"in": 0.0, "out": 0.0},
    "T2": {"in": 0.0, "out": 0.0},
    "T3": {"in": 0.01, "out": 0.03},  # approximate GPT-4o rates per 1K
}

VALID_TIERS = ["T0", "T1", "T2", "T3"]
VALID_RINGS = [f"R{i}" for i in range(12)]
VALID_AGENTS = [
    "mercer-local", "mercer-opus", "mercer-gpt", "manus-max",
    "codex-executor", "user-ben", "chasity", "rhy",
]


def ensure_ledger():
    """Create the ledger file and parent dirs if they don't exist."""
    LEDGER_PATH.parent.mkdir(parents=True, exist_ok=True)
    if not LEDGER_PATH.exists():
        LEDGER_PATH.touch()


def log_entry(args):
    """Append a single inference record to the ledger."""
    ensure_ledger()

    # Auto-calculate cost if not provided
    cost = args.cost
    if cost is None and args.tier in COST_RATES:
        rates = COST_RATES[args.tier]
        cost = (args.tokens_in / 1000 * rates["in"]) + \
               (args.tokens_out / 1000 * rates["out"])

    entry = {
        "ts": args.timestamp or datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "agent": args.agent,
        "tier": args.tier,
        "model": args.model,
        "tokens_in": args.tokens_in,
        "tokens_out": args.tokens_out,
        "cost_usd": round(cost or 0.0, 6),
        "task": args.task,
        "ring": args.ring,
        "endpoint": args.endpoint or f"{'local:8080' if args.tier in ('T0', 'T1') else 'cloud'}",
        "latency_ms": args.latency_ms or 0,
    }

    with open(LEDGER_PATH, "a") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

    print(f"✅ Logged: {entry['agent']} | {entry['tier']} | "
          f"{entry['tokens_in']}→{entry['tokens_out']} tok | "
          f"${entry['cost_usd']:.4f} | {entry['task'][:50]}")


def read_ledger(date_filter=None, days=None):
    """Read all ledger entries, optionally filtered by date."""
    ensure_ledger()
    entries = []

    if days:
        cutoff = datetime.utcnow() - timedelta(days=days)
    elif date_filter:
        cutoff = datetime.strptime(date_filter, "%Y-%m-%d")
    else:
        cutoff = None

    with open(LEDGER_PATH) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
                if cutoff:
                    entry_date = datetime.strptime(entry["ts"][:10], "%Y-%m-%d")
                    if days and entry_date < cutoff:
                        continue
                    if date_filter and entry_date.strftime("%Y-%m-%d") != date_filter:
                        continue
                entries.append(entry)
            except (json.JSONDecodeError, KeyError):
                continue

    return entries


def generate_summary(args):
    """Generate a daily compute summary."""
    date = args.date or datetime.utcnow().strftime("%Y-%m-%d")
    entries = read_ledger(date_filter=date)

    if not entries:
        print(f"📊 No entries for {date}")
        return

    # Aggregate by tier
    tier_stats = defaultdict(lambda: {
        "calls": 0, "tokens_in": 0, "tokens_out": 0,
        "cost": 0.0, "latency_total": 0
    })
    agent_stats = defaultdict(lambda: {"calls": 0, "tokens_total": 0})
    ring_stats = defaultdict(lambda: {"calls": 0, "tokens_total": 0})

    for e in entries:
        tier = e.get("tier", "T0")
        ts = tier_stats[tier]
        ts["calls"] += 1
        ts["tokens_in"] += e.get("tokens_in", 0)
        ts["tokens_out"] += e.get("tokens_out", 0)
        ts["cost"] += e.get("cost_usd", 0)
        ts["latency_total"] += e.get("latency_ms", 0)

        agent = e.get("agent", "unknown")
        agent_stats[agent]["calls"] += 1
        agent_stats[agent]["tokens_total"] += e.get("tokens_in", 0) + e.get("tokens_out", 0)

        ring = e.get("ring", "?")
        ring_stats[ring]["calls"] += 1
        ring_stats[ring]["tokens_total"] += e.get("tokens_in", 0) + e.get("tokens_out", 0)

    total_cost = sum(t["cost"] for t in tier_stats.values())
    total_tokens = sum(t["tokens_in"] + t["tokens_out"] for t in tier_stats.values())
    total_calls = sum(t["calls"] for t in tier_stats.values())

    # Estimate cloud-only cost (if everything ran on T3)
    cloud_only_cost = total_tokens / 1000 * 0.02  # rough average

    # Print summary
    print(f"\n## 💰 Compute Summary — {date}")
    print(f"**Total calls:** {total_calls} | **Total tokens:** {total_tokens:,} | "
          f"**Total cost:** ${total_cost:.4f}")
    print(f"**Estimated all-cloud cost:** ${cloud_only_cost:.4f} | "
          f"**Savings:** ${cloud_only_cost - total_cost:.4f} "
          f"({((cloud_only_cost - total_cost) / max(cloud_only_cost, 0.001)) * 100:.0f}%)")
    print()

    # Tier breakdown
    print("### By Tier")
    print("| Tier | Calls | Tokens In | Tokens Out | Cost | Avg Latency |")
    print("|------|-------|-----------|------------|------|-------------|")
    for tier in VALID_TIERS:
        if tier in tier_stats:
            ts = tier_stats[tier]
            avg_lat = ts["latency_total"] / max(ts["calls"], 1)
            print(f"| {tier} | {ts['calls']} | {ts['tokens_in']:,} | "
                  f"{ts['tokens_out']:,} | ${ts['cost']:.4f} | {avg_lat:.0f}ms |")
    print()

    # Agent breakdown
    print("### By Agent")
    print("| Agent | Calls | Total Tokens |")
    print("|-------|-------|-------------|")
    for agent, stats in sorted(agent_stats.items(), key=lambda x: -x[1]["tokens_total"]):
        print(f"| {agent} | {stats['calls']} | {stats['tokens_total']:,} |")
    print()

    # Ring breakdown
    print("### By Ring")
    print("| Ring | Calls | Total Tokens |")
    print("|------|-------|-------------|")
    for ring in VALID_RINGS:
        if ring in ring_stats:
            rs = ring_stats[ring]
            print(f"| {ring} | {rs['calls']} | {rs['tokens_total']:,} |")

    # Return structured data for programmatic use
    return {
        "date": date,
        "total_calls": total_calls,
        "total_tokens": total_tokens,
        "total_cost_usd": round(total_cost, 6),
        "estimated_cloud_cost_usd": round(cloud_only_cost, 4),
        "savings_usd": round(cloud_only_cost - total_cost, 4),
        "tier_breakdown": dict(tier_stats),
        "agent_breakdown": dict(agent_stats),
        "ring_breakdown": dict(ring_stats),
    }


def generate_report(args):
    """Generate a multi-day report."""
    days = args.days or 7
    entries = read_ledger(days=days)

    if not entries:
        print(f"📊 No entries in the last {days} days")
        return

    # Group by date
    by_date = defaultdict(list)
    for e in entries:
        d = e.get("ts", "")[:10]
        by_date[d].append(e)

    print(f"\n## 📈 Compute Report — Last {days} Days")
    print("| Date | Calls | Tokens | Cost | Local % |")
    print("|------|-------|--------|------|---------|")

    total_cost = 0
    total_tokens = 0
    total_local = 0

    for date in sorted(by_date.keys()):
        day_entries = by_date[date]
        calls = len(day_entries)
        tokens = sum(e.get("tokens_in", 0) + e.get("tokens_out", 0) for e in day_entries)
        cost = sum(e.get("cost_usd", 0) for e in day_entries)
        local = sum(1 for e in day_entries if e.get("tier") in ("T0", "T1"))
        local_pct = (local / max(calls, 1)) * 100

        total_cost += cost
        total_tokens += tokens
        total_local += local

        print(f"| {date} | {calls} | {tokens:,} | ${cost:.4f} | {local_pct:.0f}% |")

    total_calls = sum(len(v) for v in by_date.values())
    overall_local_pct = (total_local / max(total_calls, 1)) * 100
    print(f"| **Total** | **{total_calls}** | **{total_tokens:,}** | "
          f"**${total_cost:.4f}** | **{overall_local_pct:.0f}%** |")


def export_csv(args):
    """Export ledger to CSV."""
    date = args.date
    entries = read_ledger(date_filter=date) if date else read_ledger()

    if not entries:
        print("📊 No entries to export")
        return

    output = args.output or f"token_ledger{'_' + date if date else ''}.csv"
    fieldnames = ["ts", "agent", "tier", "model", "tokens_in", "tokens_out",
                  "cost_usd", "task", "ring", "endpoint", "latency_ms"]

    with open(output, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for entry in entries:
            writer.writerow({k: entry.get(k, "") for k in fieldnames})

    print(f"✅ Exported {len(entries)} entries to {output}")


def main():
    parser = argparse.ArgumentParser(
        description="SymbolOS Token Ledger — track all inference calls",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # --- log ---
    log_parser = subparsers.add_parser("log", help="Log an inference call")
    log_parser.add_argument("--agent", required=True, help="Agent name")
    log_parser.add_argument("--tier", required=True, choices=VALID_TIERS, help="Compute tier")
    log_parser.add_argument("--model", required=True, help="Model name/ID")
    log_parser.add_argument("--tokens-in", type=int, required=True, help="Input tokens")
    log_parser.add_argument("--tokens-out", type=int, required=True, help="Output tokens")
    log_parser.add_argument("--cost", type=float, default=None, help="Cost in USD (auto-calc if omitted)")
    log_parser.add_argument("--task", required=True, help="Task description")
    log_parser.add_argument("--ring", default="R9", choices=VALID_RINGS, help="Ring ID")
    log_parser.add_argument("--endpoint", default=None, help="Endpoint URL")
    log_parser.add_argument("--latency-ms", type=int, default=None, help="Latency in ms")
    log_parser.add_argument("--timestamp", default=None, help="ISO timestamp (default: now)")

    # --- summary ---
    summary_parser = subparsers.add_parser("summary", help="Generate daily summary")
    summary_parser.add_argument("--date", default=None, help="Date (YYYY-MM-DD, default: today)")

    # --- report ---
    report_parser = subparsers.add_parser("report", help="Generate multi-day report")
    report_parser.add_argument("--days", type=int, default=7, help="Number of days (default: 7)")

    # --- export ---
    export_parser = subparsers.add_parser("export", help="Export ledger to CSV")
    export_parser.add_argument("--date", default=None, help="Filter by date (YYYY-MM-DD)")
    export_parser.add_argument("--output", default=None, help="Output CSV path")

    args = parser.parse_args()

    if args.command == "log":
        log_entry(args)
    elif args.command == "summary":
        generate_summary(args)
    elif args.command == "report":
        generate_report(args)
    elif args.command == "export":
        export_csv(args)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
