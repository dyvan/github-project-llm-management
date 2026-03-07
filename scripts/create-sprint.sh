#!/bin/bash
# Usage: ./scripts/create-sprint.sh "Sprint 1 (2025-W12)" "2025-03-21"
# Creates a GitHub milestone for a sprint with the given title and due date.
set -euo pipefail

TITLE="${1:?Usage: create-sprint.sh <title> <due-date>}"
DUE_DATE="${2:?Usage: create-sprint.sh <title> <due-date>}"

# Load .env if available
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

# Resolve owner/repo from .env or gh CLI
if [ -z "${GH_OWNER:-}" ] || [ -z "${GH_REPO:-}" ]; then
  REPO_INFO=$(GITHUB_TOKEN= gh repo view --json owner,name -q '.owner.login + "/" + .name')
  GH_OWNER="${REPO_INFO%%/*}"
  GH_REPO="${REPO_INFO##*/}"
fi

echo "Creating milestone: $TITLE (due $DUE_DATE) in $GH_OWNER/$GH_REPO"

GITHUB_TOKEN= gh api "repos/$GH_OWNER/$GH_REPO/milestones" \
  -f title="$TITLE" \
  -f due_on="${DUE_DATE}T23:59:59Z" \
  -f state="open" \
  --jq '"Milestone #\(.number) created: \(.title) (due \(.due_on))"'
