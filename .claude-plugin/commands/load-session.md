---
description: Load previous session context and resume work
allowed-tools: Read, Bash(git:*), Bash(gh:*), Bash(GITHUB_TOKEN=:*), Glob
---

# Load Session

Resume work from a previously saved session.

## Steps

1. **Read session state**:
   - Read `.ai/session-state.md`
   - If file doesn't exist, tell the user "No saved session found. Use /start-task to begin a new task."

2. **Verify branch**:
   - Check if the saved branch still exists: `git branch -a | grep {branch}`
   - If exists, checkout: `git checkout {branch}`
   - If not, warn the user that the branch was deleted

3. **Show what changed since last save**:
   - Compare current state with saved state
   - New commits on the branch: `git log --oneline {saved-commit}..HEAD` (if any)
   - Changes on main since: `git log --oneline {branch}..origin/main` (if any, suggest rebase)

4. **Check for new activity on issue/PR**:
   - `GITHUB_TOKEN= gh issue view {issue-number} --json comments,updatedAt`
   - Show comments added since the saved date
   - If PR exists, show new reviews or CI status changes

5. **Display session summary**:
   ```
   ## Resumed Session
   - Issue: #{number} - {title}
   - Branch: {branch}
   - Last progress: {saved context}
   - Blockers: {saved blockers}
   - Next steps: {saved next steps}
   - New activity: {any new comments/reviews since save}
   ```

## Important
- Use `GITHUB_TOKEN= gh ...` for all gh commands (uses dyvan account)
- This is read-only except for `git checkout`
