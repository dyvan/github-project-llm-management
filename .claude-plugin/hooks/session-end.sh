#!/usr/bin/env bash
# Session end hook: saves current state to .ai/session-state.md.
# Captures branch, last commit, and timestamp.

set -euo pipefail

mkdir -p .ai

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "no commits")
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > .ai/session-state.md <<EOF
# Session State

- **Date**: ${DATE}
- **Branch**: ${BRANCH}
- **Last commit**: ${LAST_COMMIT}
EOF

echo "Session state saved to .ai/session-state.md"
