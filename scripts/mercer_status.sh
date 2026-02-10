#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  🧬🔍☂️  MERCER STATUS — Bash Launcher                       ║
# ║  "we ball, but we verify" — (•_•) <)  )╯                    ║
# ╚══════════════════════════════════════════════════════════════╝
#
# 🐢 This script finds Python and runs mercer_status.py.
#    That's it. Simple. Steady. Turtle energy.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_SCRIPT="$SCRIPT_DIR/mercer_status.py"

# Find Python — the turtle searches patiently 🐢
PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  echo "⛔ python/python3 not found on PATH" >&2
  echo "   💀 \"Prove your worth!\" — install Python first" >&2
  exit 1
fi

# 🐢 "this is fine" — launching status check
exec "$PYTHON_BIN" "$PY_SCRIPT" "$@"
