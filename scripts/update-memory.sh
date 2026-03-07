#!/bin/bash
# Update .ai/memory/current-sprint.md with data from GitHub
# Usage: scripts/update-memory.sh
# Uses GITHUB_TOKEN= to target dyvan account

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MEMORY_FILE="${REPO_ROOT}/.ai/memory/current-sprint.md"

if [ ! -f "$MEMORY_FILE" ]; then
    echo "Error: $MEMORY_FILE not found"
    exit 1
fi

# Use GITHUB_TOKEN= to target dyvan account
GH="gh"
if [ -n "${GITHUB_TOKEN:-}" ]; then
    GH="env GITHUB_TOKEN= gh"
fi

echo "Fetching data from GitHub..."

# Get open issues count
OPEN_COUNT=$(eval "$GH issue list --state open --json number --jq 'length'" 2>/dev/null || echo "?")

# Get in-progress issues
IN_PROGRESS=$(eval "$GH issue list --label 'status:in-progress' --json number,title --jq '.[] | \"- #\\(.number): \\(.title)\"'" 2>/dev/null || echo "_Could not fetch._")
if [ -z "$IN_PROGRESS" ]; then
    IN_PROGRESS="_No items in progress._"
fi

# Get in-review PRs
IN_REVIEW=$(eval "$GH pr list --json number,title --jq '.[] | \"- #\\(.number): \\(.title)\"'" 2>/dev/null || echo "_Could not fetch._")
if [ -z "$IN_REVIEW" ]; then
    IN_REVIEW="_No items in review._"
fi

# Get ready issues (next up)
NEXT_UP=$(eval "$GH issue list --label 'status:ready' --json number,title --jq '.[] | \"- #\\(.number): \\(.title)\"'" 2>/dev/null || echo "_Could not fetch._")
if [ -z "$NEXT_UP" ]; then
    NEXT_UP="_No items in Ready queue._"
fi

# Get recently closed issues (last 7 days)
WEEK_AGO=$(date -u -v-7d '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -d '7 days ago' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || echo "")
if [ -n "$WEEK_AGO" ]; then
    RECENTLY_CLOSED=$(eval "$GH issue list --state closed --json number,title,closedAt --jq '[.[] | select(.closedAt > \"$WEEK_AGO\")] | .[] | \"- #\\(.number): \\(.title)\"'" 2>/dev/null || echo "_Could not fetch._")
else
    RECENTLY_CLOSED="_Date calculation not supported on this platform._"
fi
if [ -z "$RECENTLY_CLOSED" ]; then
    RECENTLY_CLOSED="_No items closed this week._"
fi

TODAY=$(date '+%Y-%m-%d')

# Write updated file
cat > "$MEMORY_FILE" << EOF
# Current Sprint

> Active work, priorities, and blockers.
> Updated manually or via \`scripts/update-memory.sh\`.

## Sprint Info

- **Sprint**: (current)
- **Open issues**: ${OPEN_COUNT}
- **Last updated**: ${TODAY}

## In Progress

<!-- Items currently being worked on. Auto-populated by update-memory.sh -->

${IN_PROGRESS}

## Blockers

<!-- Anything blocking progress -->

_No blockers detected. Update manually if needed._

## In Review

<!-- PRs waiting for review -->

${IN_REVIEW}

## Next Up

<!-- High-priority items from Ready queue -->

${NEXT_UP}

## Recently Completed

<!-- Items closed this week -->

${RECENTLY_CLOSED}
EOF

echo "Updated ${MEMORY_FILE}"
echo "  Open issues: ${OPEN_COUNT}"
echo "  Date: ${TODAY}"
