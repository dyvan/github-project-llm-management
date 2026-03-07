#!/bin/bash
# Initialize GitHub Wiki with starter templates
#
# Usage: ./scripts/init-wiki.sh
#
# Clones the wiki repo, copies template pages, commits and pushes.
# Prerequisites:
#   - Wiki must be enabled on the repo (Settings > Features > Wiki)
#   - Create at least one page via the GitHub UI first (initializes the wiki repo)
#   - Git push access to the wiki repo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WIKI_TEMPLATES="${REPO_ROOT}/template/wiki"

# Detect repo owner/name from git remote
REMOTE_URL=$(git -C "${REPO_ROOT}" remote get-url origin 2>/dev/null || true)
if [ -z "$REMOTE_URL" ]; then
    echo "Error: no git remote 'origin' found"
    exit 1
fi

# Extract owner/repo from SSH or HTTPS URL
OWNER_REPO=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]||; s|\.git$||')
if [ -z "$OWNER_REPO" ]; then
    echo "Error: could not parse owner/repo from remote URL"
    exit 1
fi

WIKI_URL="https://github.com/${OWNER_REPO}.wiki.git"
TMPDIR=$(mktemp -d)

cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

echo "Cloning wiki for ${OWNER_REPO}..."
if ! git clone "$WIKI_URL" "$TMPDIR/wiki" 2>/dev/null; then
    echo "Error: could not clone wiki. Make sure:"
    echo "  1. Wiki is enabled in repo Settings > Features > Wiki"
    echo "  2. You have created at least one page via the GitHub UI"
    exit 1
fi

if [ ! -d "$WIKI_TEMPLATES" ]; then
    echo "Error: wiki templates not found at ${WIKI_TEMPLATES}"
    exit 1
fi

echo "Copying wiki templates..."
COUNT=0
for tmpl in "$WIKI_TEMPLATES"/*.md; do
    if [ -f "$tmpl" ]; then
        BASENAME=$(basename "$tmpl")
        if [ -f "$TMPDIR/wiki/$BASENAME" ]; then
            echo "  Skipping $BASENAME (already exists)"
        else
            cp "$tmpl" "$TMPDIR/wiki/$BASENAME"
            echo "  Added $BASENAME"
            COUNT=$((COUNT + 1))
        fi
    fi
done

if [ "$COUNT" -eq 0 ]; then
    echo "No new pages to add. Wiki is already up to date."
    exit 0
fi

cd "$TMPDIR/wiki"
git add -A
git commit -m "Initialize wiki with starter templates"
git push

echo "Done. Pushed ${COUNT} wiki page(s) to ${OWNER_REPO}."
