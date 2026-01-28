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
    ok: bool
    code: int  # 0 ok, 2 drift/warn, 1 error
    summary: str


def _repo_root() -> Path:
    # scripts/mercer_status.py -> repo root
    return Path(__file__).resolve().parents[1]


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _read_json(path: Path) -> object:
    return json.loads(_read_text(path))


def _parse_shared_symbols(map_json: dict) -> set[str]:
    symbols = set()
    for entry in map_json.get("symbols", []):
        sym = entry.get("symbol")
        if isinstance(sym, str) and sym.strip():
            symbols.add(sym)
    return symbols


_CORE_SECTION_RE = re.compile(r"^##\\s+Core\\s+symbols\\s*$", re.IGNORECASE | re.MULTILINE)
_SECTION_HEADING_RE = re.compile(r"^##\\s+", re.MULTILINE)
_BULLET_SYMBOL_RE = re.compile(r"^\\s*-\\s+`([^`]+)`\\s+", re.MULTILINE)


def _parse_core_symbols_from_md(md_text: str) -> set[str]:
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
            return CheckResult(True, 0, "Core symbols aligned")

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


def _print_banner() -> None:
    print("\n".join(
        [
            "╔══════════════════════════════════════════════════════════════╗",
            "║  🧬☂️🗺️  MERCER STATUS                                        ║",
            "║  SymbolOS Workspace Pulse Check                             ║",
            "╚══════════════════════════════════════════════════════════════╝",
        ]
    ))


def _print_status(repo: Path) -> int:
    shared_map_path = repo / "symbol_map.shared.json"
    docs_index_path = repo / "docs" / "index.md"
    readme_path = repo / "README.md"
    symbol_map_md_path = repo / "docs" / "symbol_map.md"

    lily_private = repo / "docs" / "assets" / "lily_background.private.png"
    bootup_art_dir = repo / "docs" / "assets" / "bootup_cards"

    drift = _check_symbol_drift(shared_map_path, symbol_map_md_path)

    _print_banner()
    print(f"🗺️  Repo root: {repo}")
    print(f"🧬 Meeting place: {shared_map_path.name}={_exists(shared_map_path)} | docs/index.md={_exists(docs_index_path)} | README.md={_exists(readme_path)}")
    print(f"🌸 Lily backdrop (private): {_exists(lily_private)}")
    print(f"🎨 Bootup art folder (private): {_exists(bootup_art_dir)}")
    print()

    status = "✅" if drift.code == 0 else ("⚠️" if drift.code == 2 else "⛔")
    print(f"Doc alignment (core symbols): {status} {drift.summary}")

    return drift.code


def _try_open(path: Path) -> None:
    try:
        if sys.platform.startswith("win"):
            os.startfile(str(path))  # type: ignore[attr-defined]
        else:
            print(f"Open manually: {path}")
    except Exception as exc:  # noqa: BLE001
        print(f"Could not open: {exc}")


def main(argv: list[str]) -> int:
    repo = _repo_root()

    once = "--once" in argv
    code = _print_status(repo)

    if once:
        return code

    while True:
        print()
        print("┌─ 🎯 ACTIONS ─────────────────────────────────────────────────┐")
        print("│ [R] Refresh     [O] Docs Index     [M] Map     [P] Poetry     │")
        print("│                          [Q] Quit                            │")
        print("└───────────────────────────────────────────────────────────────┘")
        choice = input("→ ").strip().lower()

        if choice in {"q", "quit", "exit"}:
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

        print("❌ Unknown option.")


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
