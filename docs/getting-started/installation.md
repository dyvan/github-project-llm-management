# Installation Guide

## System Requirements

- **Git**: 2.30+
- **GitHub Account**: With repository admin access
- **GitHub CLI**: `gh` 2.0+
- **Python**: 3.11+ (if using Python workflows)

## Step 1: Clone the Repository

```bash
# Clone this template
git clone https://github.com/your-org/project-llm-management.git
cd project-llm-management

# Or fork and clone your fork
git clone https://github.com/YOUR_USERNAME/project-llm-management.git
```

## Step 2: Install Dependencies (Optional)

If you want to run workflows locally for testing:

```bash
# Python dependencies
pip install -r requirements.txt

# Development tools (for local testing)
pip install pytest black pylint mypy mkdocs mkdocs-material
```

## Step 3: Configure GitHub Secrets

Navigate to your repository settings:

**Settings → Secrets and variables → Actions**

Add the following secrets:

### Required Secrets

#### `GITHUB_TOKEN`
GitHub automatically provides this, but you can also create a Personal Access Token:

```bash
gh auth login
# Select: GitHub.com
# Select: HTTPS
# Authenticate with browser
```

#### `CLAUDE_API_KEY` (for Code Review)
1. Get your API key from [console.anthropic.com](https://console.anthropic.com)
2. Add it to your repo secrets:

```bash
gh secret set CLAUDE_API_KEY --body "sk-ant-..."
```

### Optional Secrets

#### `OPENAI_API_KEY` (Alternative to Claude)
```bash
gh secret set OPENAI_API_KEY --body "sk-..."
```

#### `GEMINI_API_KEY` (Alternative to Claude)
```bash
gh secret set GEMINI_API_KEY --body "AIza..."
```

## Step 4: Enable GitHub Projects v2

1. Go to your repository
2. Click the **Projects** tab
3. Click **New project**
4. Select **Table** or **Board** view
5. Name it: `Project Board`
6. Create the project

## Step 5: Configure Project Fields

### Custom Fields to Create

In the project settings, add these fields:

| Field Name | Type | Values |
|-----------|------|--------|
| **Priority** | Single select | Low, Medium, High |
| **Effort** | Single select | 1, 2, 3, 5, 8 |
| **Status** | Single select | Backlog, In Progress, In QA, Done |
| **Owner** | People | Auto (from assignee) |
| **Sprint** | Text | v1.0, v2.0, etc. |
| **Environment** | Single select | dev, preprod, prod |

### Create Views

#### 1. Backlog (Table)
- Columns: Title, Priority, Effort, Owner, Status
- Filter: Status != "Done"
- Sort: Created date (oldest first)

#### 2. Priority Board (Kanban)
- Group by: Status
- Filter: Priority = High OR Medium
- Sort: Priority (highest first)

#### 3. Team Items (Table)
- Columns: Title, Owner, Sprint, Status, Due Date
- Filter: Owner = me (for personal view)

## Step 6: Configure Workflows

Most workflows are pre-configured, but verify they're enabled:

**Settings → Actions → General**

Ensure:
- ✅ Actions workflows are enabled
- ✅ Read/write permissions for Actions

## Step 7: Test the Setup

### Create a test issue
```bash
gh issue create \
  --title "Test: Setup verification" \
  --body "Testing the workflow setup" \
  --label "auto-branch"
```

This should automatically:
1. Create a branch: `feat/1-test-setup-verification`
2. Post a comment with checkout instructions
3. Trigger the CI workflow

### Verify workflows ran
```bash
gh run list --workflow ci-tests.yml
gh run list --workflow create-branch.yml
```

## Step 8: Configure MkDocs (Documentation)

```bash
# Install MkDocs
pip install mkdocs mkdocs-material

# Build docs locally
mkdocs build

# Serve locally
mkdocs serve
# Visit http://localhost:8000
```

### Deploy to GitHub Pages

The workflow `.github/workflows/deploy-docs.yml` automatically deploys when you push to `docs/`:

1. Go to **Settings → Pages**
2. Set source to **Deploy from a branch**
3. Select **gh-pages** branch
4. Save

Your docs will be available at: `https://your-username.github.io/project-llm-management`

## Step 9: Create Development Environment

### Python Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Install Pre-commit Hooks (Optional)
```bash
pip install pre-commit
pre-commit install
```

## Step 10: Verify Installation

Run this checklist:

- [ ] Repository cloned/forked locally
- [ ] GitHub secrets configured
- [ ] GitHub Projects v2 created
- [ ] Workflows enabled
- [ ] Test issue created and branch auto-created
- [ ] MkDocs documentation built
- [ ] Local development environment set up

## Troubleshooting

### Issue: Workflows not running
**Solution**: Check **Settings → Actions → General** → ensure workflows are enabled

### Issue: Code Review Agent not working
**Solution**: Verify `CLAUDE_API_KEY` is set correctly (no extra spaces)

### Issue: Branch not created
**Solution**: Ensure `auto-branch` label is added to the issue

### Issue: Python tests fail
**Solution**: Install all dev dependencies: `pip install -r requirements.txt`

## Next Steps

1. ✅ [Quick Start Guide](./quickstart.md) - Run your first workflow
2. 📚 [Architecture Overview](../architecture/overview.md) - Understand the system
3. 📝 [Contributing Guide](../../CONTRIBUTING.md) - Start contributing

---

Need help? Check the [FAQ](../faq.md) or [Troubleshooting Guide](../guides/troubleshooting.md)
