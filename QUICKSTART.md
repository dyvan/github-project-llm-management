# Quickstart - 5 Minutes Setup

Get your GitHub project management automation running in 5 minutes.

## Prerequisites

- Git installed
- GitHub CLI (`gh`) installed - [Install here](https://cli.github.com/)
- Python 3.11+ installed
- A GitHub repository (fork this template or use existing repo)

## Step 1: Setup Repository (1 min)

### Option A: Use as Template

```bash
# On GitHub, click "Use this template" button
# Then clone your new repository
git clone https://github.com/YOUR_USERNAME/your-project-name.git
cd your-project-name
```

### Option B: Add to Existing Repository

```bash
cd your-existing-repo
git remote add template https://github.com/dyvan/github-project-llm-management.git
git fetch template
git merge template/main --allow-unrelated-histories
```

## Step 2: Authenticate GitHub CLI (30 sec)

```bash
gh auth login
# Follow the prompts to authenticate
```

## Step 3: Configure GitHub Secrets (1 min)

```bash
# Required: GitHub Personal Access Token
# Go to: https://github.com/settings/tokens/new
# Required scopes: repo, project, workflow
gh secret set GH_TOKEN
# Paste your token when prompted

# Optional: Claude API Key (for AI code review)
gh secret set CLAUDE_API_KEY
# Get your key from: https://console.anthropic.com/
```

## Step 4: Run Setup Script (2 min)

```bash
# Install Python dependencies
pip install -r requirements.txt

# Run the setup script (creates labels and project)
./setup-project.sh

# When prompted for project name, press Enter for default "Project Backlog"
# Follow the instructions to configure custom fields
```

## Step 5: Configure Project Number (30 sec)

After setup script creates the project:

1. Note the project number (visible in URL: `github.com/.../projects/1`)
2. Edit `.github/project.yml` and set:
   ```yaml
   project:
     number: 1  # Your project number
   ```

## Step 6: Auto-configure Project Fields (1 min)

```bash
# Automatically create custom fields via GraphQL
python3 scripts/setup_project_fields.py --project-number 1 --owner YOUR_USERNAME
```

This creates:
- Status: Backlog, Ready, In Progress, In Review, Blocked, Done
- Priority: Low, Medium, High
- Effort: 1, 2, 3, 5, 8
- Type: Feature, Bug, Task, Docs, Infrastructure
- Target Version: (text field)

## Step 7: Validate Setup (30 sec)

```bash
./scripts/validate_setup.sh
```

If you see `✅ All checks passed!`, you're ready to go!

## Quick Test

Create your first automated issue:

```bash
# Create an issue
gh issue create --title "Test automation" --label "type:feature,priority:medium,auto-branch"

# Watch the magic happen:
# ✅ Issue added to Project Board with Priority=Medium, Type=Feature
# ✅ Branch automatically created: feat/1-test-automation
# ✅ Comment posted on issue with checkout instructions
```

Checkout the branch and create a PR:

```bash
git fetch origin
git checkout feat/1-test-automation
# Make changes, commit, push
gh pr create --title "Test PR" --body "Closes #1"

# Watch more magic:
# ✅ CI/CD tests run automatically
# ✅ Claude AI reviews your code (if CLAUDE_API_KEY set)
# ✅ Project Board status updates to "In Review"
```

## What You Get

✅ **Automated Project Board** synced with Issues/PRs
✅ **Auto-branch creation** on `auto-branch` label
✅ **AI code review** by Claude (if API key configured)
✅ **CI/CD pipeline** with tests and validation
✅ **Status tracking** from Backlog → Done
✅ **Label-based automation** for Priority, Type, Status

## Next Steps

- Read [TEMPLATE_USAGE.md](.github/TEMPLATE_USAGE.md) for detailed usage
- Customize `.github/project.yml` for your workflow
- Add your own project code to the repository
- Invite team members and assign issues

## Troubleshooting

### "gh: command not found"
Install GitHub CLI: https://cli.github.com/

### "Permission denied" on scripts
```bash
chmod +x setup-project.sh scripts/*.sh scripts/*.py
```

### "Project not found"
Make sure you:
1. Ran `./setup-project.sh`
2. Updated `.github/project.yml` with correct project number
3. Project exists at: `https://github.com/YOUR_USERNAME/projects`

### "CLAUDE_API_KEY not set"
Code review agent will run in basic mode without AI. To enable:
```bash
gh secret set CLAUDE_API_KEY
```

### Workflows not triggering
Make sure GitHub Actions is enabled:
- Go to repo Settings → Actions → General
- Enable "Allow all actions and reusable workflows"

## Get Help

- 📖 Full documentation: [README.md](README.md)
- 🐛 Report issues: [GitHub Issues](../../issues)
- 💬 Questions: [GitHub Discussions](../../discussions)

---

**Setup time: ~5 minutes** | **Automation time saved: hours per week** 🚀
