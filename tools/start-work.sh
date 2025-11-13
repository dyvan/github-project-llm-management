#!/bin/bash
# Helper script to start working on an issue
# This script adds the 'auto-branch' label to trigger branch creation
# Usage: ./tools/start-work.sh <issue-number>

set -e

if [ -z "$1" ]; then
    echo "❌ Usage: ./tools/start-work.sh <issue-number>"
    echo ""
    echo "Example:"
    echo "  ./tools/start-work.sh 42"
    echo ""
    echo "This will:"
    echo "  1. Add the 'auto-branch' label to issue #42"
    echo "  2. GitHub Actions will automatically create a branch"
    echo "  3. Issue will move to 'In progress' status on the board"
    exit 1
fi

ISSUE_NUM="$1"

# Validate issue exists
if ! gh issue view "$ISSUE_NUM" > /dev/null 2>&1; then
    echo "❌ Issue #$ISSUE_NUM not found"
    exit 1
fi

# Get issue title for confirmation
ISSUE_TITLE=$(gh issue view "$ISSUE_NUM" --json title -q '.title')

echo "📋 Issue #$ISSUE_NUM: $ISSUE_TITLE"
echo ""
echo "🔄 Adding 'auto-branch' label..."

# Add the auto-branch label
gh issue edit "$ISSUE_NUM" --add-label "auto-branch"

echo ""
echo "✅ Done! GitHub Actions will:"
echo "   1. Create a branch (feat/$ISSUE_NUM-...)"
echo "   2. Move issue to 'In progress' on the board"
echo ""
echo "📍 Next steps:"
echo "   1. Wait for the branch to be created (check GitHub Actions)"
echo "   2. Fetch and checkout the branch: git fetch origin && git checkout feat/$ISSUE_NUM-*"
echo "   3. Start developing!"
