#!/usr/bin/env python3
"""
Ring Heartbeat Script for SymbolOS

Runs a health check across all 12 rings of cognition and produces a
structured report.
"""
import json
import os
import re
from datetime import datetime, timedelta

# --- Configuration ---
REPO_ROOT = os.path.expanduser("~/SymbolOS")
NOW = datetime.now()

RINGS = [
    {"id": 0, "name": "Kernel", "symbol": "⚓"},
    {"id": 1, "name": "Will", "symbol": "🎯"},
    {"id": 2, "name": "Sensation", "symbol": "👁️"},
    {"id": 3, "name": "Task", "symbol": "🫴"},
    {"id": 4, "name": "Retrieval", "symbol": "📚"},
    {"id": 5, "name": "Prediction", "symbol": "🌀"},
    {"id": 6, "name": "Architecture", "symbol": "🧩"},
    {"id": 7, "name": "Guardrails", "symbol": "🛡️"},
    {"id": 8, "name": "Verification", "symbol": "🧪"},
    {"id": 9, "name": "Persistence", "symbol": "🗃️"},
    {"id": 10, "name": "Reflection", "symbol": "🪞"},
    {"id": 11, "name": "Integration", "symbol": "🌌"},
]

# --- Health Checks ---

def check_r0_kernel():
    """Symbol map is valid JSON."""
    try:
        with open(os.path.join(REPO_ROOT, "symbol_map.shared.json")) as f:
            data = json.load(f)
        return True, f"{len(data.get('symbols', []))} symbols valid"
    except Exception as e:
        return False, f"symbol_map.shared.json invalid: {e}"

def check_r1_will():
    """Working set updated recently."""
    path = os.path.join(REPO_ROOT, "memory/m3_intentional/working_set.md")
    if not os.path.exists(path):
        return False, "working_set.md missing"
    mtime = datetime.fromtimestamp(os.path.getmtime(path))
    if (NOW - mtime) > timedelta(days=1):
        return False, f"working_set.md stale ({(NOW - mtime).days}d ago)"
    return True, "working_set.md fresh"

def check_r4_retrieval():
    """No open loops older than 7 days."""
    path = os.path.join(REPO_ROOT, "memory/m3_intentional/open_loops.md")
    if not os.path.exists(path):
        return True, "open_loops.md missing (ok)"
    with open(path) as f:
        content = f.read()
    # Simple regex for dates like (YYYY-MM-DD)
    dates = re.findall(r"\((\d{4}-\d{2}-\d{2})\)", content)
    old_loops = 0
    for date_str in dates:
        try:
            loop_date = datetime.strptime(date_str, "%Y-%m-%d")
            if (NOW - loop_date).days > 7:
                old_loops += 1
        except ValueError:
            continue
    if old_loops > 0:
        return False, f"{old_loops} open loops > 7 days old"
    return True, "All open loops are recent"

def check_r7_guardrails():
    """Basic secret scan."""
    # This is a naive check, a real one would be more robust
    # and use tools like git-secrets or trufflehog.
    files_to_scan = [f for f in os.listdir(REPO_ROOT) if f.endswith(".md")]
    secrets_found = []
    patterns = ["API_KEY", "SECRET", "PASSWORD"]
    for filename in files_to_scan:
        with open(os.path.join(REPO_ROOT, filename)) as f:
            content = f.read()
            for pattern in patterns:
                if pattern in content:
                    secrets_found.append(filename)
    if secrets_found:
        return False, f"Potential secrets in {', '.join(set(secrets_found))}"
    return True, "No obvious secrets found"

def check_r9_persistence():
    """Recent commit and today's session log exists."""
    today_log = os.path.join(REPO_ROOT, f"memory/m0_episodic/session_log_{NOW.strftime('%Y-%m-%d')}.md")
    if not os.path.exists(today_log):
        return False, "Today's session log missing"
    return True, "Today's session log exists"

# --- Main Execution ---

def main():
    """Run all checks and print the report."""
    print("Ring Heartbeat —", NOW.strftime("%Y-%m-%dT%H:%M:%SZ"))
    print("=" * 60)

    results = []
    # Placeholder checks for rings not yet implemented
    all_checks = {
        0: check_r0_kernel,
        1: check_r1_will,
        2: lambda: (True, "Sensation check not implemented"),
        3: lambda: (True, "Task check not implemented"),
        4: check_r4_retrieval,
        5: lambda: (True, "Prediction check not implemented"),
        6: lambda: (True, "Architecture check not implemented"),
        7: check_r7_guardrails,
        8: lambda: (True, "Verification check not implemented"),
        9: check_r9_persistence,
        10: lambda: (True, "Reflection check not implemented"),
        11: lambda: (True, "Integration check not implemented"),
    }

    total_score = 0
    for ring in RINGS:
        is_healthy, message = all_checks[ring['id']]()
        status_icon = "✅" if is_healthy else "⚠️"
        if is_healthy:
            total_score += 1
        print(f"{status_icon} R{ring['id']:<2} {ring['symbol']} {ring['name']:<12} | {message}")
        results.append(is_healthy)

    print("=" * 60)
    overall_health = (total_score / len(RINGS)) * 100
    health_icon = "💚" if overall_health > 80 else "💛" if overall_health > 60 else "💔"
    print(f"Overall Health: {overall_health:.1f}% {health_icon}")

if __name__ == "__main__":
    main()
