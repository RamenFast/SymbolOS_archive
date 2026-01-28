#!/usr/bin/env bash
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
