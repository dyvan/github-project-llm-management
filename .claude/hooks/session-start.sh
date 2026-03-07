#!/usr/bin/env bash
# Session start hook: outputs saved session state and current git context.
# Checks for .ai/session-state.md and outputs its content if present.

set -euo pipefail

# Output saved session state if it exists
if [ -f ".ai/session-state.md" ]; then
  echo "=== Previous Session State ==="
  cat .ai/session-state.md
  echo ""
fi

# Output current git context
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "no commits")

echo "=== Current Context ==="
echo "Branch: ${BRANCH}"
echo "Last commit: ${LAST_COMMIT}"
