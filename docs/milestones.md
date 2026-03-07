# Milestones and Sprint Tracking

GitHub Milestones group issues into time-boxed sprints with progress bars.

## Sprint Naming Convention

Format: **`Sprint N (YYYY-WNN)`** -- e.g. `Sprint 1 (2025-W12)` due 2025-03-21.

## Creating a Sprint

### With the helper script

```bash
./scripts/create-sprint.sh "Sprint 1 (2025-W12)" "2025-03-21"
```

The script reads `GH_OWNER`/`GH_REPO` from `.env`, or detects them via `gh repo view`.

### Manually

```bash
GITHUB_TOKEN= gh api repos/{owner}/{repo}/milestones \
  -f title="Sprint 1 (2025-W12)" -f due_on="2025-03-21T23:59:59Z"
```

## Assigning Issues to a Milestone

```bash
GITHUB_TOKEN= gh issue edit 123 --milestone "Sprint 1 (2025-W12)"
```

Or use the GitHub UI sidebar on any issue.

## Integration with Slash Commands

`/next-task` prioritises issues by milestone due-date so current-sprint
tasks surface first. `/sprint-report` reads milestone progress to
generate a summary.

## Viewing Sprint Progress

```bash
GITHUB_TOKEN= gh api repos/{owner}/{repo}/milestones --jq \
  '.[] | "\(.title): \(.open_issues) open, \(.closed_issues) closed"'
```

GitHub also shows a progress bar on each milestone page.
