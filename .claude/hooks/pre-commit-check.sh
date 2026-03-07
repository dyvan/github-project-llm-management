#!/usr/bin/env bash
# Pre-commit hook: validates that the commit message references an issue (#NNN).
# Receives JSON on stdin from Claude Code with tool input containing the commit message.
# Exits non-zero if no issue reference is found.

set -euo pipefail

# Read stdin (Claude Code passes JSON with tool name and input)
INPUT=$(cat)

# Extract the commit message from the input
# The input JSON contains the bash command; we look for the commit message pattern
COMMIT_MSG=$(echo "$INPUT" | grep -oE '"command"\s*:\s*"[^"]*"' | head -1 | sed 's/"command"\s*:\s*"//;s/"$//' || true)

# If we couldn't extract from JSON, use the raw input
if [ -z "$COMMIT_MSG" ]; then
  COMMIT_MSG="$INPUT"
fi

# Check for issue reference pattern (#NNN)
if echo "$COMMIT_MSG" | grep -qE '#[0-9]+'; then
  exit 0
fi

echo "ERROR: Commit message must reference an issue (#NNN)."
echo "Example: git commit -m \"feat: add feature X (#123)\""
exit 1
