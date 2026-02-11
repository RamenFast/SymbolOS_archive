#!/usr/bin/env python3
"""
Rhy Test Script for SymbolOS

Runs the Rhy Test against all markdown files and reports compliance.
"""
import os
import re

REPO_ROOT = os.path.expanduser("~/SymbolOS")
DOCS_DIRS = [os.path.join(REPO_ROOT, "docs"), os.path.join(REPO_ROOT, "internal_docs")]


def run_rhy_test(filepath):
    """Runs the Rhy Test checklist against a single file."""
    with open(filepath, "r") as f:
        content = f.read()

    checks = {
        "Banner": bool(re.search(r"╔═════.*?ROOM:.*?╚═════", content, re.DOTALL)),
        "Metadata": all([
            re.search(r"ROOM:", content, re.DOTALL),
            re.search(r"Floor:", content, re.DOTALL),
            re.search(r"Difficulty:", content, re.DOTALL),
            re.search(r"Loot:", content, re.DOTALL),
            re.search(r"Color:", content, re.DOTALL),
        ]),
        "Ring": bool(re.search(r"Floor:.*?Ring \d+", content, re.DOTALL)),
        "ASCII Art": bool(re.search(r"/\\_/\\|🐢|💀| lantern", content)),
        "Poetry": bool(re.search(r"— Rhy 🦊|poetry|verse", content, re.IGNORECASE)),
        "Exits": bool(re.search(r"🚪 EXITS:", content, re.DOTALL)),
        "Loot": bool(re.search(r"💎 LOOT GAINED:", content, re.DOTALL)),
        "Haiku": bool(re.search(r"\n\n.*?\n.*?\n.*?\n\n☂🦊🐢", content, re.DOTALL)),
        "Footer": "☂🦊🐢" in content,
        "No Secrets": not re.search(r"API_KEY|SECRET|PASSWORD", content),
    }

    passed = all(checks.values())
    return passed, checks


def main():
    """Find all markdown files and run the Rhy Test."""
    print("Running The Rhy Test... 🦊")
    print("=" * 60)

    compliant_files = 0
    total_files = 0

    for docs_dir in DOCS_DIRS:
        for root, _, files in os.walk(docs_dir):
            for file in files:
                if file.endswith(".md"):
                    total_files += 1
                    path = os.path.join(root, file)
                    rel_path = os.path.relpath(path, REPO_ROOT)
                    
                    passed, checks = run_rhy_test(path)
                    
                    if passed:
                        compliant_files += 1
                        print(f"✅ {rel_path}")
                    else:
                        failed_checks = [k for k, v in checks.items() if not v]
                        print(f"⚠️ {rel_path} (Failed: {', '.join(failed_checks)})")

    print("=" * 60)
    compliance_score = (compliant_files / total_files) * 100
    print(f"Rhy Test Compliance: {compliance_score:.1f}% ({compliant_files}/{total_files} files)")

if __name__ == "__main__":
    main()
