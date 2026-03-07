# 🤖 Automation Guide - What's Automated vs Manual

This document explains exactly what is automated in this template and what requires manual setup.

---

## ✅ **Fully Automated** (No Manual Intervention)

### 1. **Branch Creation** ✅
**Trigger**: Adding `auto-branch` label to an issue
**What happens**:
- GitHub Action `create-branch.yml` automatically creates branch `feat/{issue-number}-{title}`
- Comment posted on issue with checkout instructions

**Example**:
```bash
gh issue create --title "Add dark mode" --label "type:feature"
gh issue edit 123 --add-label "auto-branch"
# → Branch feat/123-add-dark-mode created automatically
```

---

### 2. **Project Board Synchronization** ✅ **NEW**
**Trigger**: Issue creation, PR open/close, label changes
**What happens**:
- Issues/PRs automatically added to GitHub Projects v2
- Custom fields updated via GraphQL:
  - **Issue created** → Status = "Backlog"
  - **Label `auto-branch`** → Status = "Ready"
  - **PR opened** → Status = "In Review"
  - **PR merged** → Status = "Done"
  - **Labels `priority:*`** → Priority field updated
  - **Labels `type:*`** → Type field updated

**Workflow**: `.github/workflows/update-project.yml`
**Script**: `scripts/project_sync.py`

**Example**:
```bash
# Create issue
gh issue create --title "Fix login bug" --label "type:bug,priority:high"
# → Automatically added to Project Board with Type=Bug, Priority=High, Status=Backlog

# Open PR
gh pr create --title "Fix login bug" --body "Closes #123"
# → Issue #123 status updated to "In Review"
# → PR added to Project Board

# Merge PR
gh pr merge 45
# → Issue #123 status updated to "Done"
# → PR status updated to "Done"
```

---

### 3. **Code Review by AI** ✅
**Trigger**: PR opened, synchronized, or reopened
**What happens**:
- Gemini AI analyzes the diff
- Posts structured comment with:
  - ✅ Strengths
  - ⚠️ Suggestions
  - 🔴 Critical issues (security, performance)

**Workflow**: `.github/workflows/code-review-agent.yml`

**Requirements**: `GEMINI_API_KEY` secret configured (or `GEMINI_REVIEW_API_KEY`)

---

### 4. **CI/CD Testing** ✅
**Trigger**: Push to main/develop/staging or PR events
**What happens**:
- Lint check (pylint, black, mypy)
- Run tests (pytest with coverage)
- Build package
- Post results as PR comment
- Update commit status checks

**Workflow**: `.github/workflows/ci-tests.yml`

---

### 5. **Documentation Deployment** ✅
**Trigger**: Push to main/develop with changes in `docs/`
**What happens**:
- MkDocs builds documentation
- Deploys to GitHub Pages

**Workflow**: `.github/workflows/deploy-docs.yml`

---

## ⚠️ **Semi-Automated** (Initial Setup Required)

### 1. **GitHub Project Board Creation** ⚠️
**Manual setup required**:
1. Run `./setup-project.sh` (one-time setup)
2. Manually configure custom fields in Project Settings:
   - Priority (Single select: High, Medium, Low)
   - Effort (Single select: 1, 2, 3, 5, 8)
   - Type (Single select: Feature, Bug, Task, Docs, Infrastructure)
   - Status (Single select: Backlog, Ready, In Progress, In Review, Done)
   - Owner (People)
   - Target Version (Text)

**Once configured**: Fully automated via GraphQL

**Why manual?**: GitHub API doesn't support creating custom fields yet

---

### 2. **Labels Configuration** ⚠️
**Manual setup required**:
1. Run `./setup-project.sh` (creates all labels)
2. Or manually create via GitHub UI

**Once configured**: Labels work automatically with workflows

---

### 3. **GitHub Secrets** ⚠️
**Manual setup required**:
```bash
gh secret set GH_TOKEN
gh secret set GEMINI_API_KEY
```

**Why manual?**: Security - secrets cannot be auto-configured

---

## 📋 **Complete Setup Checklist**

Use this checklist when setting up a new project from this template:

### Initial Setup (One-Time)

- [ ] **1. Clone/Fork the template repository**
  ```bash
  git clone https://github.com/your-org/github-project-llm-management.git
  cd github-project-llm-management
  ```

- [ ] **2. Run the setup script**
  ```bash
  ./setup-project.sh
  ```
  This will:
  - ✅ Check prerequisites (gh, python3, jq)
  - ✅ Create GitHub labels
  - ✅ Create GitHub Project v2
  - ✅ Install Python dependencies

- [ ] **3. Configure GitHub Secrets**
  ```bash
  gh secret set GH_TOKEN          # GitHub Personal Access Token
  gh secret set GEMINI_API_KEY    # Google Gemini API key
  ```

- [ ] **4. Manually configure Project Board custom fields**
  - Go to Project Settings → Fields
  - Add: Priority, Effort, Type, Status, Owner, Target Version
  - See `PROJECT_BOARD_SETUP.md` for details

- [ ] **5. Enable GitHub Pages** (if you want docs)
  - Go to Settings → Pages
  - Source: Deploy from branch `gh-pages`

- [ ] **6. Enable Project Board auto-add**
  - Go to Project Settings → Workflows
  - Enable "Auto-add items" for issues and PRs

### Verify Automation Works

- [ ] **Test 1: Auto-branch creation**
  ```bash
  gh issue create --title "Test issue" --label "type:feature"
  gh issue edit <number> --add-label "auto-branch"
  # Verify branch created
  ```

- [ ] **Test 2: Project Board sync**
  ```bash
  gh issue create --title "Test sync" --label "type:bug,priority:high"
  # Check Project Board: should appear with Type=Bug, Priority=High
  ```

- [ ] **Test 3: Code review**
  ```bash
  # Create a PR
  gh pr create --title "Test PR" --body "Test"
  # Check for Claude AI review comment
  ```

- [ ] **Test 4: CI/CD**
  ```bash
  git push origin main
  # Check Actions tab for workflow runs
  ```

---

## 🔄 **Daily Workflow** (100% Automated)

Once setup is complete, your daily workflow is fully automated:

### Create a Feature

```bash
# 1. Create issue
gh issue create \
  --title "Add user authentication" \
  --label "type:feature,priority:high" \
  --body "Need OAuth2 integration"

# 2. Trigger auto-branch
gh issue edit 123 --add-label "auto-branch"

# 3. Checkout and develop
git fetch origin
git checkout feat/123-add-user-authentication

# 4. Commit and push
git commit -m "feat: add OAuth2 integration (#123)"
git push

# 5. Create PR
gh pr create --title "feat: Add user authentication (#123)" --body "Closes #123"

# ✨ Automation takes over:
# - Issue status → "In Review"
# - Claude reviews code
# - CI runs tests
# - PR status tracked in Project Board

# 6. Merge PR
gh pr merge --squash

# ✨ Automation completes:
# - Issue status → "Done"
# - PR status → "Done"
# - Branch deleted
```

**Human involvement**: Only steps 1-6. Everything else is automated.

---

## 🎯 **What Gets Automated**

### Issue Lifecycle
```
Create issue
  ↓ (automated)
Added to Project Board → Status: "Backlog"
  ↓ (manual: add label)
Label "auto-branch" added
  ↓ (automated)
Branch created → Status: "Ready"
  ↓ (manual: develop)
Code written & pushed
  ↓ (manual: create PR)
PR opened
  ↓ (automated)
Status: "In Review" + AI code review + CI tests
  ↓ (manual: merge)
PR merged
  ↓ (automated)
Status: "Done" + Branch deleted
```

### Project Board Fields (All Automated)
- ✅ **Status**: Backlog → Ready → In Review → Done
- ✅ **Priority**: Based on `priority:*` labels
- ✅ **Type**: Based on `type:*` labels
- ⚠️ **Effort**: Must be set manually (no auto-detection yet)
- ⚠️ **Owner**: Auto-set to assignee if configured
- ⚠️ **Target Version**: Must be set manually

---

## 🚀 **Advanced: Manual Commands**

### Update Project Board Manually

```bash
# Update issue status
python scripts/project_sync.py --issue 123 --status "In Progress"

# Update multiple fields
python scripts/project_sync.py \
  --issue 123 \
  --status "In Progress" \
  --priority "High" \
  --effort "3"

# Update PR
python scripts/project_sync.py --pr 45 --status "Done"
```

### Using with Claude AI

Claude can use these commands via `claude.md` instructions:

```bash
# Claude can autonomously execute:
gh issue create --title "..." --label "..."
gh issue edit 123 --add-label "auto-branch"
python scripts/project_sync.py --issue 123 --status "In Progress"
gh pr create --title "..." --body "Closes #123"
```

---

## 📊 **Automation Coverage**

| Task | Automated | Manual | Frequency |
|------|-----------|--------|-----------|
| Create issue | ⚠️ | User creates | Daily |
| Add to Project Board | ✅ | - | Automatic |
| Set initial status | ✅ | - | Automatic |
| Create branch | ✅ | - | On label |
| Code development | - | ⚠️ | Developer |
| Commit | - | ⚠️ | Developer |
| Create PR | ⚠️ | User creates | Per feature |
| Update status (PR open) | ✅ | - | Automatic |
| Code review (AI) | ✅ | - | Automatic |
| CI/CD tests | ✅ | - | Automatic |
| Merge PR | - | ⚠️ | Reviewer |
| Update status (Done) | ✅ | - | Automatic |
| Close issue | ✅ | - | Automatic |
| Deploy docs | ✅ | - | Automatic |

**Automation rate**: ~70% of tasks are fully automated

---

## 🔧 **Troubleshooting**

### Project Board not updating?

**Check**:
1. Is `GH_TOKEN` secret configured?
   ```bash
   gh secret list | grep GH_TOKEN
   ```
2. Does Project Board exist?
   ```bash
   gh project list
   ```
3. Are custom fields configured correctly?
   - Status field must have: Backlog, Ready, In Progress, In Review, Done
   - Priority field must have: High, Medium, Low
   - Type field must have: Feature, Bug, Task, Docs, Infrastructure

**Debug**:
```bash
# Test script manually
export GH_TOKEN=your_token
export GITHUB_REPOSITORY_OWNER=your_username
export GITHUB_REPOSITORY=your_repo
python scripts/project_sync.py --issue 123 --status "In Progress"
```

### Code review not working?

**Check**:
1. Is `GEMINI_API_KEY` secret configured?
2. Check workflow logs: Actions → Code Review Agent

**Fallback**: Script provides basic review without API key

### CI tests failing?

**Check**:
1. Is `requirements.txt` up to date?
2. Are all tests passing locally?
   ```bash
   pytest
   black --check .
   pylint src/
   ```

---

## 📚 **Related Documentation**

- `README.md`: Main project documentation
- `claude.md`: Instructions for Claude AI
- `PROJECT_BOARD_SETUP.md`: Detailed Project Board setup
- `CONTRIBUTING.md`: Contribution guidelines
- `.github/workflows/`: All automation workflows

---

**Last Updated**: 2025-11-10
**Automation Version**: 2.0 (GraphQL-based)
