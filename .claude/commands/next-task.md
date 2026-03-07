---
description: Auto-pick the next task from the project board (Ready, sorted by Priority > Milestone > Effort)
allowed-tools: Bash(gh:*), Bash(GITHUB_TOKEN=:*), Read
---

# Next Task

Query the GitHub Project board and recommend the next task to work on.

## Steps

1. **Query the project board for Ready items**:
   Run a GraphQL query to fetch all items with Status = "Ready" from the project board:
   ```
   GITHUB_TOKEN= gh api graphql -f query='
   {
     node(id: "PVT_kwHOAX_dWc4BGnys") {
       ... on ProjectV2 {
         items(first: 100) {
           nodes {
             id
             fieldValues(first: 20) {
               nodes {
                 ... on ProjectV2ItemFieldSingleSelectValue {
                   field { ... on ProjectV2SingleSelectField { name } }
                   optionId
                   name
                 }
                 ... on ProjectV2ItemFieldMilestoneValue {
                   field { ... on ProjectV2Field { name } }
                   milestone {
                     title
                     dueOn
                   }
                 }
               }
             }
             content {
               ... on Issue {
                 number
                 title
                 url
                 labels(first: 10) { nodes { name } }
                 assignees(first: 5) { nodes { login } }
                 milestone {
                   title
                   dueOn
                 }
               }
             }
           }
         }
       }
     }
   }'
   ```

2. **Filter for Ready items only**:
   From the results, keep only items where the Status field optionId is `61e4505c` (Ready).

3. **Sort candidates** using this priority order:
   a. **Priority** (highest first):
      - P0 (`79628723`) — most urgent
      - P1 (`0a877460`)
      - P2 (`da944a9c`)
      - No priority — lowest
   b. **Milestone due date** (earliest first):
      - Items with a milestone due date sort before those without
      - Earlier due dates sort first
   c. **Effort** (smallest first, to favor quick wins at same priority):
      - 1 (`08e40e54`)
      - 2 (`8296128d`)
      - 3 (`94ddd87f`)
      - 5 (`61b3d099`)
      - 8 (`02981c20`)
      - No effort — sort last

4. **Display top 3 candidates**:
   Format the output as a ranked list:
   ```
   ## Next Task Candidates

   ### #1 Pick
   - Issue: #{number} - {title}
   - Priority: {P0/P1/P2}
   - Milestone: {milestone title} (due {date})
   - Effort: {points} points
   - Labels: {labels}
   - URL: {url}

   ### #2
   ...

   ### #3
   ...
   ```

   If no Ready items are found, report:
   ```
   No tasks with Status = "Ready" found on the project board.
   Consider moving items from Backlog to Ready, or run /sprint-report to review the board.
   ```

5. **Ask the user**:
   After displaying the candidates, ask:
   > "Would you like to start working on #{top-pick-number}? (I will run /start-task {number})"

   Wait for confirmation before doing anything else.

## Important
- Use `GITHUB_TOKEN= gh ...` for all gh commands (uses dyvan account)
- The project board ID is `PVT_kwHOAX_dWc4BGnys`
- This is a read-only command — do not modify anything
- Do NOT automatically start a task; always ask for confirmation first
