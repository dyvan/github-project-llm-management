---
description: Save current work context for session continuity
allowed-tools: Bash(git:*), Bash(gh:*), Bash(GITHUB_TOKEN=:*), Bash(date:*), Read, Write, Glob
---

# Save Session

Save the current work context so it can be resumed later.

## Steps

1. **Gather current state**:
   - Branch: `git branch --show-current`
   - Issue number: extract from branch name
   - Last commit: `git log --oneline -1`
   - Uncommitted changes: `git status --short`
   - Diff summary: `git diff --stat origin/main..HEAD`

2. **Gather issue context** (if issue number found):
   - `GITHUB_TOKEN= gh issue view {issue-number} --json title,state,labels,body`
   - Check for PR: `GITHUB_TOKEN= gh pr list --head {branch} --json number,url,state`

3. **Ask the user**:
   - "What was your progress so far?"
   - "Any blockers or open questions?"
   - "What should be done next?"
   (If the user already provided this info in conversation, use that instead of asking again)

4. **Write session state** to `.ai/session-state.md`:
   ```markdown
   # Session State
   Updated: {ISO date}

   ## Current Task
   - Issue: #{number} - {title}
   - Branch: {branch}
   - PR: {url or "not created"}

   ## Progress
   - Last commit: {hash} {message}
   - Files changed: {list}
   - Status: {in-progress/blocked/ready-for-review}

   ## Context
   {user-provided progress notes}

   ## Blockers
   {user-provided blockers or "None"}

   ## Next Steps
   {user-provided next steps}
   ```

5. **Confirm** what was saved and where.

## Important
- Use `GITHUB_TOKEN= gh ...` for all gh commands (uses dyvan account)
- Create `.ai/` directory if it doesn't exist
- Add `.ai/session-state.md` to `.gitignore` if not already there (this is local state, not committed)
