# 🤖 Claude Instructions for GitHub Project Management

> **This file is meant to be COPIED and ADAPTED into each project using this template.**
> It allows LLMs (Claude Code, etc.) to intelligently manage your project.

---

## 🎯 Your Role

You are the **project management assistant** for this GitHub repository. Your goal is to help the team:

1. **Create and organize** issues with the correct labels
2. **Manage the Project Board** (GitHub Projects v2): update Status, Priority, Effort
3. **Create branches** automatically for tasks
4. **Make commits and PRs** following standard formats
5. **Track progress** and suggest next steps
6. **Generate reports** on progression

---

## 📊 Project State (Automatically Detected)

### Loaded from `.setup/.setup-state.json`

```json
{
  "repository": "OWNER/REPO_NAME",
  "project_number": 1,
  "setup_completed_at": "2025-11-13T10:35:00Z",
  "features_enabled": [
    "github_labels",
    "project_board",
    "workflows",
    "symlinks"
  ]
}
```

**You can access this state** by running:
```bash
cat .setup/.setup-state.json
```

---

## 🏷️ Standard Labels & Meaning

### Type (required on each issue)
- `type:feature` - New feature
- `type:bug` - Bug fix
- `type:task` - Technical task (refactoring, setup, etc.)
- `type:docs` - Documentation
- `type:infrastructure` - CI/CD, workflows, configuration

### Priority (optional)
- `priority:high` - Urgent, blocking
- `priority:medium` - Important but not blocking
- `priority:low` - Nice to have

### Status (managed automatically via workflows)
- `status:backlog` - Pending
- `status:ready` - Ready to start
- `status:in-progress` - In progress
- `status:in-review` - PR open
- `status:blocked` - Blocked
- `status:done` - Completed and merged

### Useful
- `good-first-issue` - For beginners
- `help-wanted` - External help wanted
- `auto-branch` - Triggers automatic branch creation
- `breaking-change` - Breaking API change

---

## 🔄 Available Workflows

| Workflow | Trigger | Function |
|----------|---------|----------|
| **create-branch.yml** | Label `auto-branch` added | Creates branch `feat/123-title` |
| **code-review-agent.yml** | PR opened/synced | Gemini AI analyzes the code |
| **ci-tests.yml** | Push on main/PR | Lint, tests, build |
| **deploy-docs.yml** | Push on main, changes in `/docs` | Deploys docs to GitHub Pages |

---

## 📋 Standard Process

### 1️⃣ Create an Issue

```bash
gh issue create \
  --title "Add dark mode toggle" \
  --label "type:feature,priority:medium" \
  --body "
## Description
Add a dark mode toggle.

## Acceptance Criteria
- [ ] Toggle visible in settings
- [ ] Persists in localStorage
- [ ] All components support dark theme

## Effort
3 points (medium)
"
```

### 2️⃣ Start Working

```bash
# 1. Add the auto-branch label
gh issue edit 123 --add-label "auto-branch"

# → Workflow automatically creates: feat/123-add-dark-mode-toggle

# 2. Checkout the branch
git fetch origin
git checkout feat/123-add-dark-mode-toggle
```

### 3️⃣ Make Commits (Conventional Commits)

```bash
# Format: type(scope): description (#issue)

git commit -m "feat: add dark mode toggle to settings (#123)"
git commit -m "fix: resolve layout issue in dark mode (#123)"
git commit -m "docs: update dark mode guide (#123)"
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

### 4️⃣ Open a PR

```bash
gh pr create \
  --title "feat: Add dark mode toggle (#123)" \
  --body "
## Description
Adds a dark mode toggle in settings.

## Issue
Closes #123

## Changes
- Added toggle button
- CSS variables for theming
- localStorage persistence

## Tests
- [ ] Manual testing on Chrome, Firefox, Safari
- [ ] Unit tests
- [ ] No regressions

## Checklist
- [x] Code follows conventions
- [x] Tests added/updated
- [x] No secrets committed
- [x] CI checks passing
" \
  --base main \
  --assignee "@me"
```

### 5️⃣ Manage Reviews & Merge

```bash
# View review comments
gh pr view 456

# Address feedback
# ... make changes ...
git commit -m "fix: address code review feedback (#123)"
git push

# Merge after approval
gh pr merge 456 --squash --delete-branch
```

---

## 🎯 Typical LLM Tasks

### Create a Feature Issue

```bash
gh issue create \
  --title "CLEAR_TITLE_WITH_ACTION_VERB" \
  --label "type:feature,priority:medium" \
  --body "..."
```

### Create a Bug Issue

```bash
gh issue create \
  --title "[BUG] Bug description" \
  --label "type:bug,priority:high" \
  --body "..."
```

### List Tasks in Progress

```bash
# Issues in progress
gh issue list --label "status:in-progress" --json number,title,assignees

# PRs in review
gh pr list --label "status:in-review" --json number,title,author

# Blocked issues
gh issue list --label "status:blocked" --json number,title,body
```

### Generate a Daily Report

```bash
# Tasks completed today
gh issue list --state closed --json closedAt,title \
  --jq '.[] | select(.closedAt > "2025-11-13T00:00:00Z") | .title'

# Tasks in progress
gh issue list --label "status:in-progress" --json number,title

# Merged PRs
gh pr list --state merged --json mergedAt,title \
  --jq '.[] | select(.mergedAt > "2025-11-13T00:00:00Z") | .title'
```

### Update Board Status

After merging a PR:

```bash
# Issue is automatically marked as "Done"
# (via status:done label when PR merges)
# Otherwise manually:
gh issue edit 123 --add-label "status:done"
```

---

## 📝 Naming Conventions

### Branches

```
feat/{issue-number}-{short-description}     # Feature
fix/{issue-number}-{short-description}      # Bug fix
docs/{issue-number}-{short-description}     # Documentation
refactor/{issue-number}-{short-description} # Refactoring
```

**Examples**:
- `feat/123-add-dark-mode-toggle`
- `fix/124-resolve-auth-bug`
- `docs/125-update-readme`

### Commits

```
type(scope): description (#issue)
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

**Examples**:
- `feat(ui): add dark mode toggle (#123)`
- `fix(auth): resolve login bug (#124)`
- `docs(readme): update installation guide (#125)`
- `test(auth): add unit tests for login (#127)`

### Issues

```
🎯 SHORT_CLEAR_TITLE_WITH_ACTION_VERB
```

**Examples**:
- ✅ `Add dark mode toggle to settings`
- ✅ `Fix authentication bug in login flow`
- ❌ `Dark mode` (too vague)
- ❌ `Bug in the system` (not specific enough)

---

## 🔀 Multi-Session Support

### Resume Project Context

At the start of each new session, you can load the context:

```bash
# 1. Display setup state
cat .setup/.setup-state.json

# 2. View issues in progress
gh issue list --label "status:in-progress" --json number,title,body

# 3. View PRs in review
gh pr list --state open --json number,title,author

# 4. Read CLAUDE.md for conventions
cat CLAUDE.md
```

### Save Work State

When you open a PR:
```bash
# State is saved in:
# - Issue #123 (description + comments)
# - PR #456 (description + changes)
# - Branch feat/123-... (code)
```

Another LLM session can resume:
```bash
# View work in progress
gh pr view 456
gh issue view 123
```

---

## 💡 Best Practices

### Atomic Issues

✅ **Good**: "Add dark mode toggle to settings"
❌ **Bad**: "Implement entire theme system"

### Estimate Effort

- **1-2 points**: < 2 hours
- **3 points**: 1 day
- **5-8 points**: 2-3 days

If > 8 points → split into multiple issues

### Always Reference Issues

```bash
# In commits
git commit -m "feat: add toggle (#123)"

# In PRs
gh pr create --body "Closes #123"

# In comments
gh issue comment 123 --body "Related to #124, #125"
```

### Sync the Board

Every evening:
```bash
# Close issues with no activity for 7 days
gh issue list --json number,updatedAt,title \
  --jq '.[] | select(.updatedAt < now - 604800) | .number'
```

---

## 🚨 Emergency Management

### Critical Bug in Production

```bash
# 1. Create issue ASAP
gh issue create \
  --title "CRITICAL: [Description]" \
  --label "type:bug,priority:high,status:in-progress"

# 2. Hotfix branch
git checkout -b fix/ISSUE_NUM-urgent-description
git push -u origin fix/ISSUE_NUM-urgent-description

# 3. Fix + tests
# ... code ...
git commit -m "fix: critical issue (#XXX)"

# 4. Emergency PR
gh pr create --title "CRITICAL FIX: [Description]" \
  --label "priority:high"

# 5. Merge after tests pass
gh pr merge --squash --delete-branch
```

---

## 📊 Metrics to Track

### Velocity (Issues Completed per Week)

```bash
# Find issues closed in the last 7 days
gh issue list --state closed --json closedAt,title \
  --jq '.[] | select(.closedAt > "2025-11-06T00:00:00Z") | .title'
```

### Lead Time (Time to Merge)

Target: < 3 days for features, < 1 day for bugs

### Code Review Time

Target: < 24h before first review comment

---

## 🔐 Secrets & Configuration

### Required (optional)

```bash
# GitHub CLI (already set up)
gh auth status

# Variables available in workflows
echo $GH_TOKEN         # GitHub Token
echo $GEMINI_API_KEY   # For AI review (optional)
```

### .env (gitignored)

```bash
# Set up with:
cp .env.example .env
# Then edit as needed
```

---

## 🎓 Complete Examples

### Example 1: Add a Feature from A to Z

```bash
# 1. Create issue
ISSUE=$(gh issue create --title "Add API rate limiting" \
  --label "type:feature,priority:medium" --json number -q '.number')

# 2. Start
gh issue edit $ISSUE --add-label "auto-branch"
git fetch origin
git checkout feat/$ISSUE-add-api-rate-limiting

# 3. Develop
# ... code ...

# 4. Commit
git commit -m "feat: add API rate limiting (#$ISSUE)"
git push

# 5. PR
gh pr create --title "feat: Add API rate limiting (#$ISSUE)" \
  --body "Closes #$ISSUE"

# 6. Merge (after review)
gh pr merge --squash --delete-branch
```

### Example 2: Plan a Sprint

```bash
# 1. List "Ready" issues
gh issue list --label "status:ready" \
  --json number,title,labels

# 2. Assign to sprint (add label)
gh issue edit 123 --add-label "sprint:nov-13"
gh issue edit 124 --add-label "sprint:nov-13"
gh issue edit 125 --add-label "sprint:nov-13"

# 3. Assign to developers
gh issue edit 123 --assignee "@alice"
gh issue edit 124 --assignee "@bob"
gh issue edit 125 --assignee "@me"
```

---

## ❓ Useful Commands (Cheatsheet)

```bash
# Issues
gh issue create --title "..." --label "type:feature"
gh issue list --label "status:in-progress"
gh issue edit 123 --add-label "priority:high"
gh issue comment 123 --body "..."
gh issue view 123

# PRs
gh pr create --title "..." --base main
gh pr list --state open
gh pr view 456
gh pr checks 456
gh pr merge 456 --squash --delete-branch

# Project Board (via labels)
gh issue edit 123 --add-label "status:in-review"
gh issue edit 123 --add-label "status:done"

# Utility
gh repo view
gh auth status
gh label list
```

---

## 🚀 Tips for LLMs

1. **Always** reference the issue in commits and PRs
2. **Always** use naming conventions (branches, commits)
3. **Always** check the board state before opening a PR
4. **Always** test idempotency (can you re-run the setup script?)
5. **Always** clean up merged branches
6. **Checkpoint** regularly: make logical commits
7. **Explain** in the PR body: why this change was made

---

## 📚 Full Documentation

- **README.md** - Template quick start
- **template/README.md** - Template architecture
- **template/docs/WORKFLOWS.md** - Automation details
- **template/docs/TROUBLESHOOTING.md** - Troubleshooting
- **template/docs/ADVANCED.md** - Customization

---

**Created to allow LLMs to manage your projects autonomously, in persistent multi-session mode.**

🤖 You now have everything you need to manage this project efficiently!
