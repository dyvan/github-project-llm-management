---
description: Generate a sprint progress report
allowed-tools: Bash(gh:*), Bash(GITHUB_TOKEN=:*), Bash(date:*), Read, Write
---

# Sprint Report

Generate a progress report for the current sprint.

## Steps

1. **Determine sprint window**:
   - Default: last 7 days
   - Calculate start date: `date -v-7d +%Y-%m-%d` (macOS) or `date -d '7 days ago' +%Y-%m-%d`

2. **Gather closed issues**:
   - `GITHUB_TOKEN= gh issue list --state closed --json number,title,labels,closedAt`
   - Filter to issues closed within the sprint window
   - Extract effort points from project board fields if available

3. **Gather open PRs**:
   - `GITHUB_TOKEN= gh pr list --json number,title,state,author,statusCheckRollup,url,createdAt`
   - Show status of each (draft, review requested, approved, changes requested)

4. **Gather in-progress issues**:
   - `GITHUB_TOKEN= gh issue list --label "status:in-progress" --json number,title,assignees`

5. **Identify blockers**:
   - `GITHUB_TOKEN= gh issue list --label "status:blocked" --json number,title,body`
   - Also check for PRs with failing CI

6. **Check milestones**:
   - `GITHUB_TOKEN= gh api repos/{owner}/{repo}/milestones --jq '.[] | {title, open_issues, closed_issues, due_on}'`
   - Show progress toward current milestone

7. **Format the report**:
   ```markdown
   # Sprint Report - {date range}

   ## Completed ({count})
   | # | Title | Effort | Closed |
   |---|-------|--------|--------|
   | {issues} |

   ## In Progress ({count})
   | # | Title | Assignee | PR |
   |---|-------|----------|-----|
   | {issues} |

   ## Open PRs ({count})
   | # | Title | Status | CI |
   |---|-------|--------|-----|
   | {prs} |

   ## Blockers ({count})
   {list of blocked issues with reason}

   ## Milestone Progress
   - {milestone}: {closed}/{total} issues ({percent}%)

   ## Velocity
   - This sprint: {points} points
   - Avg (4 weeks): {avg} points/sprint
   ```

8. **Output** the report to stdout (do not write to a file unless the user asks).

## Important
- Use `GITHUB_TOKEN= gh ...` for all gh commands (uses dyvan account)
- This is a read-only command
