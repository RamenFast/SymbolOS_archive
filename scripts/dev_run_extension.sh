#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚔️  SYMBOLOS SCRIPT — dev_run_extension.sh
# ║  🎨 Color: 🟢 #228B22 (adaptability)
# ╚══════════════════════════════════════════════════════════════╝
#
#        /\_/\
#       ( o.o )  "Bash it, don't crash it."
#        > ^ <
#       /|   |\
#      (_|   |_)  — Rhy 🦊
#
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXT_DIR="$WORKSPACE_DIR/extensions/mercer-status"

if ! command -v code >/dev/null 2>&1; then
  echo "Could not find VS Code 'code' launcher in PATH." >&2
  echo "Fix: In VS Code, run 'Shell Command: Install \'code\' command in PATH'" >&2
  exit 1
fi

echo "Workspace: $WORKSPACE_DIR"
echo "Extension: $EXT_DIR"
echo "Launching: code --extensionDevelopmentPath=..."

code --extensionDevelopmentPath "$EXT_DIR" "$WORKSPACE_DIR"

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
