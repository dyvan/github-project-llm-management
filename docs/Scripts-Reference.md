# 🔧 Scripts & Automation - Complete Reference

Documentation for all template automation scripts.

---

## 📜 Main Scripts

### 1. `template-setup.sh`

**Purpose**: Initial setup script to configure a new project

**Usage**:
```bash
bash template-setup.sh
```

**What it does**:
1. ✅ Checks prerequisites (gh, python, jq)
2. ✅ Detects the current GitHub repository
3. ✅ Creates all required labels
4. ✅ Creates a GitHub Project v2
5. ✅ Configures the base workflow

**Labels created**:
- **Type**: `type:feature`, `type:bug`, `type:task`, `type:docs`, `type:infrastructure`
- **Priority**: `priority:high`, `priority:medium`, `priority:low`
- **Status**: `status:backlog`, `status:ready`, `status:in-progress`, `status:blocked`, `status:done`
- **Special**: `auto-branch`, `good-first-issue`, `help-wanted`

**Arguments**: None (interactive)

**Prerequisites**:
- GitHub CLI authenticated
- Admin permissions on the repository

**Output**:
```
🚀 GitHub Project LLM Management - Setup Script
================================================

✅ Prerequisites check passed
Repository: username/project-name
✅ Labels configured
✅ Project created: #1
```

---

### 2. `scripts/setup_project_fields.py`

**Purpose**: Automatically creates Project Board custom fields via GraphQL

**Usage**:
```bash
python3 scripts/setup_project_fields.py \
  --project-number 1 \
  --owner YOUR_USERNAME
```

**Arguments**:
- `--project-number`: Project number (visible in the URL)
- `--owner`: Project owner (username or organization)
- `--project-id`: (Optional) GraphQL project ID (alternative to --project-number)

**What it does**:
1. ✅ Looks up the project by number
2. ✅ Checks existing fields
3. ✅ Creates missing fields:
   - **Status** (Single Select): Backlog, Ready, In Progress, In Review, Blocked, Done
   - **Priority** (Single Select): Low, Medium, High
   - **Effort** (Single Select): 1, 2, 3, 5, 8
   - **Type** (Single Select): Feature, Bug, Task, Docs, Infrastructure
   - **Target Version** (Text)

**Environment variables**:
- `GH_TOKEN` or `GITHUB_TOKEN`: GitHub token with `project` scope

**Output**:
```
🔍 Checking existing fields...
📋 Creating custom fields...
  ✅ Created field: Status
  ✅ Created field: Priority
  ⏭️  Field 'Effort' already exists, skipping...
✅ All fields configured!
```

**Error handling**:
- If the project doesn't exist → Explicit error
- If the field already exists → Skip (no duplicates)
- If the token doesn't have the right scope → Explicit error

---

### 3. `scripts/validate_setup.sh`

**Purpose**: Validates that the template is correctly configured

**Usage**:
```bash
./scripts/validate_setup.sh
```

**What it checks**:
1. ✅ **Prerequisites**: gh, python3, git installed
2. ✅ **Repository**: Inside a git repo with GitHub remote
3. ✅ **Authentication**: GitHub CLI authenticated
4. ✅ **Secrets**: GH_TOKEN and GEMINI_API_KEY configured
5. ✅ **Labels**: All required labels exist
6. ✅ **Project**: At least one project exists
7. ✅ **Workflows**: All workflows are present
8. ✅ **Dependencies**: Python packages installed

**Output (success)**:
```
🔍 GitHub Project Template - Setup Validation
==============================================

[1/8] Checking prerequisites...
  ✅ GitHub CLI (gh) installed
  ✅ Python 3 installed (3.11.5)
  ✅ Git installed

[2/8] Checking repository context...
  ✅ Inside a Git repository
  ✅ Repository: username/project-name

...

==============================================
✅ All checks passed! Template is ready to use.
```

**Output (errors)**:
```
❌ Setup incomplete: 2 error(s), 3 warning(s).

Please fix the errors above before using this template.
```

**Exit codes**:
- `0`: All OK
- `1`: Errors found

---

### 4. `scripts/project_sync.py`

**Purpose**: Syncs issues/PRs with the Project Board via GraphQL

**Usage**:
```bash
# Sync an issue
python3 scripts/project_sync.py \
  --issue 123 \
  --status "In Progress" \
  --priority "High"

# Sync a PR
python3 scripts/project_sync.py \
  --pr 456 \
  --status "In Review"

# Specify a project
python3 scripts/project_sync.py \
  --issue 123 \
  --project 1 \
  --status "Done"
```

**Arguments**:
- `--issue NUMBER`: Issue number to sync
- `--pr NUMBER`: PR number to sync
- `--project NUMBER`: (Optional) Project number
- `--status VALUE`: Set the Status field
- `--priority VALUE`: Set the Priority field
- `--effort VALUE`: Set the Effort field
- `--type VALUE`: Set the Type field
- `--version VALUE`: Set the Target Version field

**Environment variables**:
- `GH_TOKEN` or `GITHUB_TOKEN`: GitHub token
- `GH_OWNER`: Repository owner
- `GH_REPO`: Repository name

**How it works**:
1. Retrieves the GraphQL ID of the issue/PR
2. Finds the project (or uses the first one found)
3. Adds the item to the project (if not already added)
4. Updates the requested fields

**Output**:
```
✅ Issue #123 synced successfully
```

**Used by**:
- Workflow `update-project.yml` (automatically)
- Can be called manually for debugging

---

## 🤖 GitHub Actions Workflows

### 1. `.github/workflows/update-project.yml`

**Purpose**: Automatically syncs the Project Board with issues/PRs

**Triggers**:
- Issue created → Adds to Backlog
- Issue labeled → Updates Status/Priority/Type based on the label
- PR opened → Updates Status to "In Review"
- PR merged → Updates Status to "Done"

**Label mapping example**:
```yaml
Label "auto-branch"       → Status: "Ready"
Label "status:in-progress" → Status: "In Progress"
Label "priority:high"      → Priority: "High"
Label "type:feature"       → Type: "Feature"
```

**Environment variables defined**:
```yaml
env:
  GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  GH_OWNER: ${{ github.repository_owner }}
  GH_REPO: ${{ github.event.repository.name }}
```

---

### 2. `.github/workflows/create-branch.yml`

**Purpose**: Automatically creates a branch when the `auto-branch` label is added

**Trigger**:
- Issue labeled with `auto-branch`

**What it does**:
1. Retrieves the issue title
2. Creates a slug (e.g., "Fix bug API" → "fix-bug-api")
3. Creates a branch `feat/{issue-number}-{slug}`
4. Posts a comment with git instructions

**Example**:
```
Issue #42: "Add dark mode"
→ Branch created: feat/42-add-dark-mode

Comment posted:
✅ Branch created: feat/42-add-dark-mode

Get started:
git fetch origin
git checkout feat/42-add-dark-mode
```

---

### 3. `.github/workflows/code-review-agent.yml`

**Purpose**: Automatically analyzes PRs with Gemini AI

**Trigger**:
- PR opened, updated, or reopened

**What it does**:
1. Retrieves the PR diff
2. Sends it to the Gemini API with a structured prompt
3. Generates a code review with:
   - ✅ Strengths
   - ⚠️ Improvement suggestions
   - 🔴 Critical issues
4. Posts the review as a comment

**Fallback mode**:
If `GEMINI_API_KEY` is not configured, works in basic mode (manual checklist).

**Model used**: `gemini-2.0-flash`

---

### 4. `.github/workflows/ci-tests.yml`

**Purpose**: Runs tests and validations on each PR

**Trigger**:
- Push on main/develop/staging
- PR opened

**Steps**:
1. ✅ Check script permissions
2. ✅ Validate workflow YAML syntax
3. ✅ Test the setup script
4. ✅ Run unit tests (pytest)
5. ✅ Check code coverage

**Test matrix**:
- Python 3.11

---

## 📝 Configuration Files

### `.github/project.yml`

Central project configuration:

```yaml
project:
  number: 1  # Project number
  name: "Project Backlog"
  auto_link: true  # Auto-add issues to project

fields:
  status:
    options: ["Backlog", "Ready", "In Progress", ...]
    default: "Backlog"

automation:
  auto_branch:
    enabled: true
    label: "auto-branch"
```

**Used by**: All workflows to identify the target project

---

## 🔧 Advanced Usage

### Debug: Sync Manually

```bash
# Force sync an issue
python3 scripts/project_sync.py --issue 123 --status "Backlog"

# Check the result
gh project item-list 1 --owner YOUR_USERNAME
```

### Test Workflows Locally

```bash
# Install act (GitHub Actions local runner)
brew install act  # macOS
# or: https://github.com/nektos/act

# Test the CI workflow
act -j test

# Test the update-project workflow (simulation)
act issues -e test_event.json
```

---

## 💡 Tips & Tricks

### Get the GraphQL ID of a Project

```bash
gh api graphql -f query='
{
  user(login: "YOUR_USERNAME") {
    projectV2(number: 1) {
      id
      title
    }
  }
}'
```

### List All Items in a Project

```bash
gh project item-list 1 --owner YOUR_USERNAME --format json
```

### Check Configured Secrets

```bash
gh secret list
```

---

## 🐛 Troubleshooting

**Error: "Project not found"**
- Check that `.github/project.yml` has the correct number
- Check that the project exists: `gh project list --owner YOUR_USERNAME`

**Error: "GraphQL errors"**
- Check that `GH_TOKEN` has the `project` scope
- Recreate the token: https://github.com/settings/tokens

**Script won't run**
- Make it executable: `chmod +x script.sh`

---

[⬅️ Back to Home](Home) | [Next: Workflows ➡️](Understanding-Workflows)
