---
description: Start working on a GitHub issue (checkout branch, load context, update board)
allowed-tools: Bash(gh:*), Bash(git:*), Bash(GITHUB_TOKEN=:*), Read, Grep, Glob
argument-hint: <issue-number>
---

# Start Task

You are starting work on issue #$ARGUMENTS in this repository.

## Steps

1. **Fetch issue details**:
   Run `GITHUB_TOKEN= gh issue view $ARGUMENTS --json number,title,body,labels,assignees,milestone,comments` to get full context.

2. **Determine branch name**:
   - Extract the issue title, slugify it (lowercase, hyphens, max 40 chars)
   - Determine prefix from labels: `type:feature` -> `feat/`, `type:bug` -> `fix/`, `type:docs` -> `docs/`, `type:task` -> `refactor/`, default -> `feat/`
   - Branch name: `{prefix}{issue-number}-{slug}`

3. **Create or checkout the branch**:
   - Run `git fetch origin`
   - Check if branch already exists: `git branch -a | grep {branch-name}`
   - If exists: `git checkout {branch-name}`
   - If not: `git checkout -b {branch-name}`

4. **Update project board status to "In Progress"**:
   - Get the item ID: `GITHUB_TOKEN= gh api graphql -f query='{ node(id: "PVT_kwHOAX_dWc4BGnys") { ... on ProjectV2 { items(first: 100) { nodes { id content { ... on Issue { number } } } } } } }'`
   - Find the item matching issue number $ARGUMENTS
   - Update status to "In Progress" (option ID: `47fc9ee4`):
     ```
     GITHUB_TOKEN= gh api graphql -f query='mutation { updateProjectV2ItemFieldValue(input: { projectId: "PVT_kwHOAX_dWc4BGnys", itemId: "ITEM_ID", fieldId: "PVTSSF_lAHOAX_dWc4BGnyszg3nS_U", value: { singleSelectOptionId: "47fc9ee4" } }) { projectV2Item { id } } }'
     ```

5. **Display context summary**:
   Show a summary with:
   - Issue title and number
   - Branch name
   - Acceptance criteria (from issue body)
   - Labels, milestone, assignee
   - Related/blocking issues (from comments or body)

6. **Scan for likely affected files**:
   Extract keywords from the issue title and body, then use Grep/Glob to find potentially relevant files in the codebase. List the top 5-10 most relevant files.

## Important
- Use `GITHUB_TOKEN= gh ...` for all gh commands (uses dyvan account)
- The project board ID is `PVT_kwHOAX_dWc4BGnys`
- Do NOT commit anything — just set up the workspace
