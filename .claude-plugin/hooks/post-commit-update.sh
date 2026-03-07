#!/usr/bin/env bash
# Post-commit hook: extracts issue number from the last commit and logs it.
# In the future, this could update the project board automatically.
# Uses GITHUB_TOKEN= gh to target the dyvan account.

set -euo pipefail

# Get the last commit message
COMMIT_MSG=$(git log -1 --pretty=%B 2>/dev/null || true)

if [ -z "$COMMIT_MSG" ]; then
  exit 0
fi

# Extract issue number(s) from the commit message
ISSUES=$(echo "$COMMIT_MSG" | grep -oE '#[0-9]+' | sort -u || true)

if [ -z "$ISSUES" ]; then
  echo "No issue reference found in commit message."
  exit 0
fi

for ISSUE in $ISSUES; do
  NUM=$(echo "$ISSUE" | tr -d '#')
  echo "Issue #${NUM} referenced in commit."
done
