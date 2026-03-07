---
description: Finish a task (push, create PR, update board)
allowed-tools: Bash(gh:*), Bash(git:*), Bash(GITHUB_TOKEN=:*), Read
argument-hint: <issue-number>
---

# Finish Task

You are finishing work on issue #$ARGUMENTS.

## Steps

1. **Verify clean state**:
   - Run `git status` to check for uncommitted changes
   - If there are uncommitted changes, warn the user and ask whether to commit them first
   - Run `git log --oneline origin/main..HEAD` to see all commits that will be in the PR

2. **Push the branch**:
   - Run `git push -u origin HEAD`

3. **Create the Pull Request**:
   - Fetch issue details: `GITHUB_TOKEN= gh issue view $ARGUMENTS --json title,body,labels`
   - Determine PR title from issue: `{type}: {title} (#$ARGUMENTS)` where type comes from labels (feat/fix/docs/refactor)
   - Create PR with:
     ```
     GITHUB_TOKEN= gh pr create \
       --title "{type}: {title} (#$ARGUMENTS)" \
       --body "## Summary
     {brief summary from issue body}

     ## Changes
     {list of commits}

     Closes #$ARGUMENTS" \
       --base main
     ```

4. **Update project board status to "In Review"**:
   - Get the item ID for issue $ARGUMENTS from the project board
   - Update status field (ID: `PVTSSF_lAHOAX_dWc4BGnyszg3nS_U`) to "In Review" (option: `df73e18b`):
     ```
     GITHUB_TOKEN= gh api graphql -f query='mutation { updateProjectV2ItemFieldValue(input: { projectId: "PVT_kwHOAX_dWc4BGnys", itemId: "ITEM_ID", fieldId: "PVTSSF_lAHOAX_dWc4BGnyszg3nS_U", value: { singleSelectOptionId: "df73e18b" } }) { projectV2Item { id } } }'
     ```

5. **Display summary**:
   - PR URL
   - Issue reference
   - Board status update confirmation
   - Remind about CI checks and code review

## Important
- Use `GITHUB_TOKEN= gh ...` for all gh commands (uses dyvan account)
- Never force-push
- Always use `--base main` for PRs
