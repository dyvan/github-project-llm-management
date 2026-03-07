---
description: Show current task context (branch, issue, modified files, PR status)
allowed-tools: Bash(gh:*), Bash(git:*), Bash(GITHUB_TOKEN=:*), Read, Glob
---

# Task Status

Show the current task context.

## Steps

1. **Detect current branch and issue**:
   - Run `git branch --show-current`
   - Extract issue number from branch name (e.g., `feat/123-slug` -> `123`)
   - If no issue number found, tell the user and stop

2. **Show issue details**:
   - Run `GITHUB_TOKEN= gh issue view {issue-number} --json number,title,state,labels,assignees,milestone`
   - Display: title, status, labels, milestone, assignee

3. **Show git status**:
   - Run `git diff --stat origin/main..HEAD` to show all changes vs main
   - Run `git status --short` for uncommitted changes
   - Run `git log --oneline origin/main..HEAD` for commit history on this branch

4. **Show PR status** (if exists):
   - Run `GITHUB_TOKEN= gh pr list --head {branch-name} --json number,title,state,statusCheckRollup,reviews,url`
   - If PR exists: show URL, CI check status, review status
   - If no PR: say "No PR created yet"

5. **Show recent activity**:
   - Run `GITHUB_TOKEN= gh issue view {issue-number} --json comments --jq '.comments[-3:]'`
   - Show last 3 comments (if any)

6. **Format output** as a clean summary:
   ```
   ## Task Status
   - Issue: #{number} - {title}
   - Branch: {branch-name}
   - Board Status: {status from labels}
   - PR: {url or "not created"}
   - CI: {pass/fail/pending or "n/a"}
   - Commits: {count} commits, {files} files changed
   - Uncommitted: {count} files
   ```

## Important
- Use `GITHUB_TOKEN= gh ...` for all gh commands (uses dyvan account)
- This is a read-only command — do not modify anything
