# 🤖 Claude Instructions for GitHub Project Management

> **This file contains instructions for Claude Code to automatically manage this project via GitHub Projects v2, Issues, Branches, and Pull Requests.**

---

## 🎯 Your Role

You are the **project management assistant** for this GitHub repository. Your goal is to help the team:

1. **Create and organize** issues with the right templates and labels
2. **Manage the Project Board** (GitHub Projects v2): update Status, Priority, Effort
3. **Create branches** automatically for tasks
4. **Make commits and PRs** following standard formats
5. **Track progress** and suggest next steps
6. **Generate reports** on progress for the team

---

## 📋 Workflows

### 1️⃣ Creating a New Task

When a user asks to create a task:

```bash
# 1. Create the issue with the right template
gh issue create \
  --title "Add dark mode toggle to settings" \
  --body "$(cat <<EOF
## Description
Add a dark mode toggle button in the settings page.

## Motivation
Users have requested dark mode for better accessibility.

## Acceptance Criteria
- [ ] Toggle button appears in settings
- [ ] Dark mode persists across sessions
- [ ] All components support dark theme

## Priority
Medium

## Effort
3 points
EOF
)" \
  --label "type:feature,status:backlog" \
  --assignee "@me"

# 2. Retrieve the created issue number
ISSUE_NUMBER=$(gh issue list --limit 1 --json number -q '.[0].number')

# 3. Add the issue to the Project Board
# (This happens automatically if the project is configured for auto-add)

# 4. Notify the user
echo "✅ Issue #$ISSUE_NUMBER created and added to the Project Board"
```

**Fields to always fill in**:
- **Title**: Clear and descriptive (action verb + target)
- **Type**: `type:feature`, `type:bug`, `type:task`, `type:docs`, `type:infrastructure`
- **Priority**: `High`, `Medium`, `Low`
- **Effort**: `1`, `2`, `3`, `5`, `8` (story points)
- **Status**: `Backlog` (default)

---

### 2️⃣ Starting a Task

When a user starts working on an issue:

```bash
# 1. Add the auto-branch label to trigger automatic branch creation
gh issue edit 123 --add-label "auto-branch"

# 2. Wait for the GitHub Actions workflow to create the branch
# The create-branch.yml workflow will create: feat/123-add-dark-mode-toggle

# 3. Check out the branch locally
git fetch origin
git checkout feat/123-add-dark-mode-toggle

# 4. Update the Status in the Project Board → "In Progress"
# (Via GraphQL or manually if GraphQL is not configured)

echo "✅ Branch created and ready for development"
echo "📍 Branch: feat/123-add-dark-mode-toggle"
```

**Branch naming conventions**:
- Features: `feat/{issue-number}-{short-description}`
- Bugs: `fix/{issue-number}-{short-description}`
- Docs: `docs/{issue-number}-{short-description}`
- Refactoring: `refactor/{issue-number}-{short-description}`

---

### 3️⃣ Making Commits

Commit format (Conventional Commits convention):

```bash
# General format
git commit -m "type(scope): description (#issue-number)"

# Examples
git commit -m "feat: add dark mode toggle to settings (#123)"
git commit -m "fix: resolve authentication bug in login (#124)"
git commit -m "docs: update API documentation (#125)"
git commit -m "refactor: simplify database queries (#126)"
git commit -m "test: add unit tests for auth module (#127)"
git commit -m "chore: update dependencies (#128)"
```

**Commit types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, whitespace, etc. (no code changes)
- `refactor`: Refactoring (neither feature nor fix)
- `test`: Adding or modifying tests
- `chore`: Maintenance (dependencies, configuration, etc.)
- `perf`: Performance improvement
- `ci`: CI/CD changes

**Important rules**:
- ✅ Always reference the issue: `(#123)`
- ✅ Clear and concise message (< 72 characters for the title)
- ✅ Optional commit body for more details
- ✅ One commit = one logical change

---

### 4️⃣ Opening a Pull Request

When the code is ready for review:

```bash
# 1. Push the branch
git push -u origin feat/123-add-dark-mode-toggle

# 2. Create the PR
gh pr create \
  --title "feat: Add dark mode toggle to settings (#123)" \
  --body "$(cat <<EOF
## Description
This PR adds a dark mode toggle to the settings page.

## Issue
Closes #123

## Type of Change
- [x] Feature
- [ ] Bug fix
- [ ] Refactoring
- [ ] Documentation

## Changes Made
- Added toggle button component in settings page
- Implemented dark theme CSS variables
- Added localStorage persistence for theme preference
- Updated all components to support dark mode

## Tests Performed
- [x] Manual testing in Chrome, Firefox, Safari
- [x] Unit tests for theme toggle logic
- [x] Visual regression tests

## Checklist
- [x] Code follows project style guidelines
- [x] Tests added/updated
- [x] Documentation updated
- [x] No secrets or sensitive data committed
- [x] All CI checks passing

## Screenshots
(Add screenshots if applicable)
EOF
)" \
  --base develop \
  --assignee "@me"

# 3. Notify the user
echo "✅ PR created and ready for review"
echo "🤖 The Code Review Agent (Gemini) will analyze automatically"
echo "🧪 CI/CD tests will run automatically"
```

**The PR template must always contain**:
- Concise description of changes
- Issue reference: `Closes #123`
- Type of change
- Detailed list of modifications
- Tests performed
- Quality checklist

---

### 5️⃣ Managing the Project Board

#### Updating the Status

Available statuses in the Project Board:
- **Backlog**: Planned tasks not yet started
- **Ready**: Tasks ready to start (all dependencies resolved)
- **In Progress**: Tasks currently in development
- **In Review**: PR opened, awaiting review
- **Done**: Task completed and merged

**Automatic transitions via workflows**:
- Issue created → `Backlog`
- Label `auto-branch` added → `Ready`
- PR opened → `In Review`
- PR merged → `Done`

**Manual update via GraphQL** (if needed):
```bash
# See scripts/project_sync.py for details
python scripts/project_sync.py --issue 123 --status "In Progress"
```

---

### 6️⃣ Tracking and Reports

#### Listing Tasks in Progress

```bash
# "In Progress" issues
gh issue list --label "status:in-progress" --json number,title,assignees

# PRs awaiting review
gh pr list --label "status:in-review" --json number,title,author

# Blocked issues
gh issue list --label "status:blocked" --json number,title,body
```

#### Generating a Daily Report

```bash
# Run the dashboard script
python scripts/generate_dashboard.py

# Output in DASHBOARD.md:
# - Tasks in progress
# - Tasks completed this week
# - Team velocity
# - Identified blockers
# - Suggested next steps
```

---

## 🏷️ Labels and Classification

### Standard Labels

**Type** (required):
- `type:feature` - New feature
- `type:bug` - Bug fix
- `type:task` - Technical task (refactoring, setup, etc.)
- `type:docs` - Documentation
- `type:infrastructure` - CI/CD, workflows, configuration

**Status** (automatic via workflow):
- `status:backlog` - Pending
- `status:ready` - Ready to start
- `status:in-progress` - In progress
- `status:in-review` - In review
- `status:blocked` - Blocked
- `status:done` - Completed

**Priority**:
- `priority:high` - Urgent, blocking
- `priority:medium` - Important but not blocking
- `priority:low` - Nice to have

**Other useful labels**:
- `auto-branch` - Triggers automatic branch creation
- `good-first-issue` - Good for beginners
- `help-wanted` - External help wanted
- `breaking-change` - Breaking API change
- `needs-discussion` - Requires discussion before implementation

---

## 🔄 Available GitHub Actions Workflows

### 1. `create-branch.yml`
**Trigger**: Label `auto-branch` added to an issue
**Action**: Automatically creates a branch `feat/{issue-number}-{title}`
**Usage**: Add the label via `gh issue edit 123 --add-label "auto-branch"`

### 2. `code-review-agent.yml`
**Trigger**: PR opened, synchronized, or reopened
**Action**: Gemini AI analyzes the code and posts a comment with:
  - ✅ Positive points
  - ⚠️ Improvement suggestions
  - 🔴 Critical issues (security, performance)
**Usage**: Automatic, no intervention needed

### 3. `ci-tests.yml`
**Trigger**: Push to main/develop/staging or PR
**Action**: Runs lint, tests, build and posts results
**Usage**: Automatic, checks code quality

### 4. `deploy-docs.yml`
**Trigger**: Push to main/develop with changes in `docs/`
**Action**: Deploys MkDocs documentation to GitHub Pages
**Usage**: Automatic after documentation changes

### 5. `update-project.yml`
**Trigger**: Push, PR events, issue events
**Action**: Synchronizes the Project Board (currently logging, GraphQL to be implemented)
**Usage**: Automatic, event tracking

---

## 📊 Useful Commands for Tracking

### Sprint Statistics

```bash
# Issues completed this week
gh issue list --state closed --label "status:done" --json closedAt,title \
  --jq '.[] | select(.closedAt > "2025-11-03") | .title'

# Total effort (story points) completed
# (Requires a custom script to parse custom fields)
python scripts/velocity_calculator.py --sprint current

# PRs merged this week
gh pr list --state merged --json mergedAt,title \
  --jq '.[] | select(.mergedAt > "2025-11-03") | .title'
```

### Identifying Blockers

```bash
# Issues with "blocked" label
gh issue list --label "status:blocked" --json number,title,body

# PRs with CI failures
gh pr list --json number,title,statusCheckRollup \
  --jq '.[] | select(.statusCheckRollup[].conclusion == "failure")'

# Issues with no activity for 7 days
gh issue list --json number,title,updatedAt \
  --jq '.[] | select(.updatedAt < (now - 604800 | todate))'
```

### Suggested Next Steps

```bash
# "Ready" issues sorted by priority
gh issue list --label "status:ready" --json number,title,labels \
  --jq 'sort_by(.labels[] | select(.name | contains("priority")) | .name) | reverse'

# High priority items not yet started
gh issue list --label "priority:high" --label "status:backlog" \
  --json number,title
```

---

## 🎯 Best Practices

### 1. Create Atomic Issues
✅ **Good**: "Add authentication to login page"
❌ **Bad**: "Build entire authentication system"

**Why**: Makes tracking, reviews, and velocity measurement easier

### 2. Estimate Effort Honestly

**Story points scale**:
- **1 point**: < 1 hour, trivial change
- **2 points**: 2-4 hours, simple change
- **3 points**: 1 day, medium change
- **5 points**: 2-3 days, complex change
- **8 points**: 1 week, very complex change

⚠️ If > 8 points → **Break down** into multiple issues

### 3. Always Reference Issues

In commits:
```bash
git commit -m "feat: add login form (#123)"
```

In PRs:
```markdown
Closes #123
Related to #124, #125
```

**Why**: GitHub automatically closes issues and creates traceability links

### 4. Keep the Project Board Up to Date

- ✅ Update the Status as soon as a step changes
- ✅ Add comments on issues to explain blockers
- ✅ Review the Backlog every week
- ✅ Archive "Done" tasks after each sprint

### 5. Collaborative Code Review

- ✅ Respond to Code Review Agent (Gemini) comments
- ✅ Fix critical issues (🔴) before merging
- ✅ Consider suggestions (⚠️) to improve the code
- ✅ Request a human review for significant changes

---

## 🚨 Emergency Management

### Critical Production Bug

```bash
# 1. Create an issue ASAP
gh issue create \
  --title "CRITICAL: Authentication broken in production" \
  --label "type:bug,priority:high,status:in-progress" \
  --assignee "@me"

# 2. Create a hotfix branch
git checkout -b fix/urgent-auth-bug
git push -u origin fix/urgent-auth-bug

# 3. Quick fix + tests
# ... apply the fix ...
git commit -m "fix: resolve authentication bug (critical)"

# 4. Emergency PR
gh pr create \
  --title "CRITICAL FIX: Resolve authentication bug" \
  --body "Emergency fix for production issue. Closes #XXX" \
  --base main \
  --label "priority:high"

# 5. Merge after CI tests pass
gh pr merge --squash --delete-branch
```

### Deployment Rollback

```bash
# 1. Create a rollback issue
gh issue create \
  --title "Rollback deployment v1.2.0" \
  --label "type:task,priority:high"

# 2. Revert the problematic commit
git revert <commit-hash>
git push origin main

# 3. Notify the team
gh issue comment <issue-number> \
  --body "✅ Rollback completed. Version v1.1.0 restored."
```

---

## 📈 Metrics to Track

### Team Velocity

**Automatically calculated by**: `scripts/velocity_calculator.py`

**Formula**:
```
Velocity = Sum of completed story points / Number of weeks
```

**Example**:
- Week 1: 13 points
- Week 2: 15 points
- Week 3: 12 points
- **Average velocity**: 13.3 points/week

**Usage**:
- Plan sprints: "We can take on ~13 points this sprint"
- Identify slowdowns: "Velocity dropping → investigate"

### Lead Time for Changes

**Definition**: Time between the first commit and the merge to production

**Calculated by**: `scripts/generate_dashboard.py`

**Target**: < 3 days for features, < 1 day for bugs

### Code Review Time

**Definition**: Time between opening the PR and the first review comment

**Target**: < 24 hours

### Test Coverage

**Extracted by**: Workflow `ci-tests.yml`

**Target**: > 80% coverage

---

## 🔧 Available Scripts

### `scripts/claude_manager.py`
**Usage**:
```bash
python scripts/claude_manager.py create-issue \
  --title "Add feature X" \
  --type feature \
  --priority medium \
  --effort 3

python scripts/claude_manager.py update-board \
  --issue 123 \
  --status "In Progress"

python scripts/claude_manager.py list-tasks \
  --status "In Progress"
```

### `scripts/project_sync.py`
**Usage**:
```bash
# Synchronize all Project Board items
python scripts/project_sync.py --sync-all

# Update a specific item
python scripts/project_sync.py --issue 123 --field Status --value "Done"
```

### `scripts/generate_dashboard.py`
**Usage**:
```bash
# Generate the dashboard in DASHBOARD.md
python scripts/generate_dashboard.py

# Generate a JSON report
python scripts/generate_dashboard.py --format json --output report.json
```

### `scripts/velocity_calculator.py`
**Usage**:
```bash
# Current sprint velocity
python scripts/velocity_calculator.py --sprint current

# Velocity over the last 4 weeks
python scripts/velocity_calculator.py --weeks 4

# Velocity per developer
python scripts/velocity_calculator.py --by-developer
```

---

## 🎓 Complete Examples

### Example 1: Adding a Feature from Start to Finish

**Context**: The user asks "I want to add a dark mode"

```bash
# Step 1: Create the issue
gh issue create \
  --title "Add dark mode toggle to settings" \
  --body "$(cat .github/ISSUE_TEMPLATE/feature_request.yml)" \
  --label "type:feature,status:backlog,priority:medium" \
  --assignee "@me"

# Retrieve the number (e.g., #145)
ISSUE_NUM=145

# Step 2: Add to Project Board (auto if configured)
# Manually: drag & drop in the Backlog view

# Step 3: Start working
gh issue edit $ISSUE_NUM --add-label "auto-branch"
# Branch created: feat/145-add-dark-mode-toggle

git fetch origin
git checkout feat/145-add-dark-mode-toggle

# Step 4: Develop
# ... write the code ...
git add .
git commit -m "feat: add dark mode toggle to settings (#145)"
git push -u origin feat/145-add-dark-mode-toggle

# Step 5: Open the PR
gh pr create \
  --title "feat: Add dark mode toggle to settings (#145)" \
  --body "Closes #145" \
  --base develop

# Step 6: Automatic review + CI
# → Code Review Agent comments
# → CI tests run

# Step 7: Corrections if needed
# ... fix issues ...
git commit -m "fix: address code review comments (#145)"
git push

# Step 8: Merge
gh pr merge --squash --delete-branch

# Step 9: Verify the Project Board
# Issue #145 → Status = "Done" (automatic)

echo "✅ Feature complete! Issue #145 closed and merged."
```

### Example 2: Planning a Sprint

**Context**: Planning the sprint for the week

```bash
# 1. Check past velocity
python scripts/velocity_calculator.py --weeks 4
# Output: Average velocity = 14 points/week

# 2. List "Ready" issues by priority
gh issue list --label "status:ready" \
  --json number,title,labels \
  --jq '.[] | "\(.number): \(.title) - Priority: \(.labels[] | select(.name | contains("priority")) | .name)"'

# 3. Select ~14 points worth of issues
# Example:
# - Issue #150 (5 points) - High priority
# - Issue #151 (3 points) - High priority
# - Issue #152 (3 points) - Medium priority
# - Issue #153 (2 points) - Medium priority
# Total: 13 points

# 4. Move to "Ready" in the Project Board
# (Manually or via script)

# 5. Assign to developers
gh issue edit 150 --assignee "@alice"
gh issue edit 151 --assignee "@bob"
gh issue edit 152 --assignee "@charlie"
gh issue edit 153 --assignee "@me"

# 6. Communicate the plan
echo "Sprint planned: 13 points distributed across 4 developers"
```

### Example 3: Investigating a Blocker

**Context**: A PR is blocked by failing tests

```bash
# 1. Identify the problematic PR
gh pr list --json number,title,statusCheckRollup \
  --jq '.[] | select(.statusCheckRollup[].conclusion == "failure")'

# Output: PR #156 - "Add payment integration"

# 2. View failure details
gh pr checks 156

# 3. Read the workflow logs
gh run view <run-id> --log

# 4. Comment on the PR to notify
gh pr comment 156 \
  --body "⚠️ Tests failed. Error detected in payment_service.py:45. Investigation in progress."

# 5. Update the Project Board
python scripts/project_sync.py --issue 156 --status "Blocked"

# 6. Create a follow-up issue if needed
gh issue create \
  --title "Fix failing tests in payment integration" \
  --label "type:bug,priority:high" \
  --body "Tests are failing on PR #156. See logs for details."

# 7. Resolve and update
# ... fix the issue ...
gh pr comment 156 --body "✅ Issue resolved. Tests are passing now."
python scripts/project_sync.py --issue 156 --status "In Review"
```

---

## 🔐 Secrets and Configuration

### Required Secrets

In **Settings → Secrets and variables → Actions**:

- `GH_TOKEN`: GitHub Personal Access Token (scopes: `repo`, `workflow`, `read:org`)
- `GEMINI_API_KEY`: Google Gemini API key for code review and AI workflows
- `GEMINI_PLAN_API_KEY`: (Optional) Dedicated Gemini key for the planning workflow
- `GEMINI_SPEC_API_KEY`: (Optional) Dedicated Gemini key for the specification workflow
- `GEMINI_REVIEW_API_KEY`: (Optional) Dedicated Gemini key for the code review workflow
- `SLACK_WEBHOOK_URL`: (Optional) For Slack notifications

> **Note**: Per-workflow keys (`GEMINI_PLAN_API_KEY`, `GEMINI_SPEC_API_KEY`, `GEMINI_REVIEW_API_KEY`) are optional. If not configured, `GEMINI_API_KEY` is used as a fallback.

### Environment Variables

`.env` file (local only, never commit):

```bash
GH_TOKEN=ghp_xxxxxxxxxxxxx
GH_OWNER=your-username
GH_REPO=your-repo-name
GEMINI_API_KEY=AIza-xxxxxxxxxxxxx
DEBUG=false
LOG_LEVEL=INFO
```

---

## 📚 Resources and Documentation

- **GitHub CLI**: https://cli.github.com/manual/
- **GitHub Projects v2**: https://docs.github.com/en/issues/planning-and-tracking-with-projects
- **GitHub Actions**: https://docs.github.com/en/actions
- **Conventional Commits**: https://www.conventionalcommits.org/
- **Google Gemini API**: https://aistudio.google.com/

---

## ❓ FAQ

### How do I know what to work on next?

```bash
# View "Ready" tasks by priority
gh issue list --label "status:ready" --json number,title,labels

# Or check the Project Board: "Priority Board" view
```

### How do I manage multiple tasks in parallel?

- ✅ Limit to **2-3 tasks max** "In Progress" per person
- ✅ Prioritize closing tasks before starting new ones
- ✅ Use the "Team Items" view on the Project Board

### What to do if a test fails?

1. Read the CI workflow logs
2. Reproduce locally
3. Fix the problem
4. Commit with `fix: resolve test failure (#issue)`
5. Push → CI reruns automatically

### How to contribute if I'm new?

1. Look for issues with the `good-first-issue` label
2. Read the [CONTRIBUTING.md](./CONTRIBUTING.md)
3. Ask questions in the issue comments
4. Follow the standard workflow (branch → commit → PR)

---

## 🎯 Quality Checklist

Before merging a PR, verify that:

- [ ] ✅ All tests pass (CI)
- [ ] ✅ Code review approved (human or AI with confidence)
- [ ] ✅ Coverage ≥ 80%
- [ ] ✅ Documentation updated (README, docs/, comments)
- [ ] ✅ No secrets committed (check `.env`, credentials)
- [ ] ✅ Commit messages follow conventions
- [ ] ✅ Issue referenced in the PR (`Closes #123`)
- [ ] ✅ Breaking changes documented (if applicable)
- [ ] ✅ Acceptable performance (no regression)
- [ ] ✅ Accessibility verified (if UI)

---

## 🚀 Quick Commands (Cheatsheet)

```bash
# Create an issue
gh issue create --title "..." --label "type:feature" --assignee "@me"

# Create an auto-branch
gh issue edit 123 --add-label "auto-branch"

# Open a PR
gh pr create --title "..." --body "Closes #123" --base develop

# List tasks in progress
gh issue list --label "status:in-progress"

# Merge a PR
gh pr merge 456 --squash --delete-branch

# View PR checks
gh pr checks 456

# Comment on a PR
gh pr comment 456 --body "LGTM ✅"

# Generate the dashboard
python scripts/generate_dashboard.py

# Calculate velocity
python scripts/velocity_calculator.py --weeks 4
```

---

**🎉 You are now ready to manage this project like a pro!**

**Questions?** Open an issue with the `question` label or check the [full documentation](./docs/).

---

**Last updated**: 2025-11-10
**Maintained by**: Claude AI + Development Team
