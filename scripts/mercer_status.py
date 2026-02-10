# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT — mercer_status.py
# ║  🎨 Color: 🟢 #228B22 (adaptability)
# ╚══════════════════════════════════════════════════════════════╝
#
#        /\_/\
#       ( o.o )  "A script a day keeps the drift away."
#        > ^ <
#       /|   |\
#      (_|   |_)  — Rhy 🦊
#
# ╔══════════════════════════════════════════════════════════════╗
# ║  🧬🔍☂️  MERCER STATUS — Python CLI                          ║
# ║  "Show me proof, not potential." — 💀 Skeleton Gatekeeper    ║
# ╚══════════════════════════════════════════════════════════════╝
#
#   (•_•)
#   <)  )╯  "we ball, but we verify"
#    /  \    — this script does the verifying
#

from __future__ import annotations

import json
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


@dataclass(frozen=True)
class CheckResult:
    """The result of a drift check. Like a health potion readout for your symbol map."""
    ok: bool
    code: int  # 0 ok (🐢), 2 drift/warn (💀), 1 error (🔥)
    summary: str


# ─── R0: Path Resolution ────────────────────────────────────
# 🐢 "find the repo root, turtle. nice and steady."

def _repo_root() -> Path:
    # scripts/mercer_status.py -> repo root
    return Path(__file__).resolve().parents[1]


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _read_json(path: Path) -> object:
    return json.loads(_read_text(path))


# ─── R6: Symbol Parsing ─────────────────────────────────────
# Parse the shared JSON map — the machine-readable meeting place.
# Every symbol here is a promise. We check if the docs keep it.
#
#     ___
#    / 🐢 \    "parsing JSON for emoji"
#   |  ._. |   "living in the future"
#    \_____/
#     |   |

def _parse_shared_symbols(map_json: dict) -> set[str]:
    symbols = set()
    for entry in map_json.get("symbols", []):
        sym = entry.get("symbol")
        if isinstance(sym, str) and sym.strip():
            symbols.add(sym)
    return symbols


_CORE_SECTION_RE = re.compile(r"^##\s+Core\s+symbols\s*$", re.IGNORECASE | re.MULTILINE)
_SECTION_HEADING_RE = re.compile(r"^##\s+", re.MULTILINE)
_BULLET_SYMBOL_RE = re.compile(r"^\s*-\s+`([^`]+)`\s+", re.MULTILINE)


def _parse_core_symbols_from_md(md_text: str) -> set[str]:
    """Parse the human-readable symbol map for core symbols.
    
    This is what humans actually read. If it drifts from the JSON,
    the skeleton stirs. 💀
    """
    match = _CORE_SECTION_RE.search(md_text)
    if not match:
        return set()

    start = match.end()
    next_heading = _SECTION_HEADING_RE.search(md_text, start)
    end = next_heading.start() if next_heading else len(md_text)

    block = md_text[start:end]
    found = set()
    for symbol_match in _BULLET_SYMBOL_RE.finditer(block):
        sym = symbol_match.group(1).strip()
        if sym:
            found.add(sym)
    return found


# ─── R6: Drift Computation ──────────────────────────────────
# The heart of the script. Compare shared vs human.
# If they match: 🐢 "this is fine"
# If they don't: 💀 "prove your worth!"

def _check_symbol_drift(shared_map_path: Path, symbol_map_md_path: Path) -> CheckResult:
    try:
        shared_map = _read_json(shared_map_path)
        if not isinstance(shared_map, dict):
            return CheckResult(False, 1, "symbol_map.shared.json is not an object")

        shared_symbols = _parse_shared_symbols(shared_map)
        md_text = _read_text(symbol_map_md_path)
        core_symbols = _parse_core_symbols_from_md(md_text)

        missing_in_docs = sorted(shared_symbols - core_symbols)
        extra_in_docs = sorted(core_symbols - shared_symbols)

        if not missing_in_docs and not extra_in_docs:
            # 🐢 "this is fine" — symbols aligned, umbrella held
            return CheckResult(True, 0, "Core symbols aligned ☂️✅")

        # 💀 Skeleton says: drift detected
        pieces: list[str] = []
        if missing_in_docs:
            pieces.append(f"docs missing: {' '.join(missing_in_docs)}")
        if extra_in_docs:
            pieces.append(f"docs extra: {' '.join(extra_in_docs)}")

        return CheckResult(False, 2, "; ".join(pieces))
    except Exception as exc:  # noqa: BLE001
        return CheckResult(False, 1, f"Error checking drift: {exc}")


def _exists(path: Path) -> str:
    return "YES" if path.exists() else "NO"


# ─── R0: Banner ─────────────────────────────────────────────
# The first thing you see. Sets the vibe.

def _print_banner() -> None:
    print("\n".join(
        [
            "",
            "╔══════════════════════════════════════════════════════════════╗",
            "║  🧬☂️🧾  MERCER STATUS — SYMBOLOS WORKSPACE CHECK             ║",
            "║                                                              ║",
            '║  "Under the umbrella, everything is kind.                    ║',
            '║   The rain is just context we haven\'t parsed yet."           ║',
            "╚══════════════════════════════════════════════════════════════╝",
            "",
            "  (•_•)",
            '  <)  )╯  "we ball, but we verify"',
            "   /  \\",
            "",
        ]
    ))


# ─── R1: Status Display ─────────────────────────────────────
# Show the current state of the workspace.
# "Good enough signal. Start. Adjust on the way."

def _print_status(repo: Path) -> int:
    shared_map_path = repo / "symbol_map.shared.json"
    docs_index_path = repo / "docs" / "index.md"
    readme_path = repo / "README.md"
    symbol_map_md_path = repo / "docs" / "symbol_map.md"

    lily_private = repo / "docs" / "assets" / "lily_background.private.png"
    bootup_art_dir = repo / "docs" / "assets" / "bootup_cards"

    drift = _check_symbol_drift(shared_map_path, symbol_map_md_path)

    _print_banner()
    print(f"  Repo root: {repo}")
    print(f"  Meeting place: {shared_map_path.name}={_exists(shared_map_path)} | docs/index.md={_exists(docs_index_path)} | README.md={_exists(readme_path)}")
    print(f"  Lily backdrop present (private): {_exists(lily_private)}")
    print(f"  Bootup art folder present (private): {_exists(bootup_art_dir)}")

    # 🐢 or 💀 — the moment of truth
    if drift.code == 0:
        status = "🐢 ✅"
        print(f"\n  Doc alignment (core symbols): {status} {drift.summary}")
        print('  "this is fine" — the turtle nods')
    elif drift.code == 2:
        status = "💀 ⚠️"
        print(f"\n  Doc alignment (core symbols): {status} {drift.summary}")
        print('  "Prove your worth!" — the skeleton stirs')
    else:
        status = "🔥 ⛔"
        print(f"\n  Doc alignment (core symbols): {status} {drift.summary}")
        print('  "me optimizing my system instead of using it" — 🧠🔥')

    return drift.code


def _try_open(path: Path) -> None:
    try:
        if sys.platform.startswith("win"):
            os.startfile(str(path))  # type: ignore[attr-defined]
        else:
            print(f"  Open manually: {path}")
    except Exception as exc:  # noqa: BLE001
        print(f"  Could not open: {exc}")


# ─── R1: Interactive Loop ────────────────────────────────────
# The main menu. Simple, clear, vibes intact.
#
#   \(•_•)/
#    (  (>   "interactive mode engaged"
#    /  \    — the meeting place is open

def main(argv: list[str]) -> int:
    repo = _repo_root()

    once = "--once" in argv
    code = _print_status(repo)

    if once:
        return code

    while True:
        print("")
        print("  Actions: [R]efresh  [O]pen docs index  [M]ap (shared)  [P]oetry (public)  [Q]uit")
        choice = input("  > ").strip().lower()

        if choice in {"q", "quit", "exit"}:
            # 🐢 "see you next session"
            print("")
            print("  loops closed, code shipped clean")
            print("  the turtle nods, umbrella held")
            print("  merge — and breathe again")
            print("")
            return code
        if choice in {"r", ""}:
            code = _print_status(repo)
            continue
        if choice == "o":
            _try_open(repo / "docs" / "index.md")
            continue
        if choice == "m":
            _try_open(repo / "symbol_map.shared.json")
            continue
        if choice == "p":
            _try_open(repo / "docs" / "public_private_expression.md")
            continue

        print("  Unknown option. 🐢 Try again.")


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

# ─── EOF ─────────────────────────────────────────────────────
# "Always return to the meeting place.
#  The map is steady. The hands are open."
# ☂🗺✋😎

#
#    ___
#   / 🐢 \    "this is fine"
#  |  ._. |   — script complete
#   \_____/   — umbrella held
#    |   |
#
# loops run, scripts hum clean
# the fox grins, the turtle nods
# execute — breathe
#
# ☂🦊🐢
