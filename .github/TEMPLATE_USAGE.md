# Template Usage Guide

This document explains how to use this repository as a template for your own projects.

## Overview

This template provides a complete GitHub project management system with:
- Automated Project Board synchronization
- Auto-branch creation from issues
- AI-powered code review
- CI/CD pipeline with tests
- Issue and PR templates

## Using This Template

### Method 1: GitHub Template (Recommended)

1. Click the **"Use this template"** button at the top of this repository
2. Choose a name for your new repository
3. Select public or private visibility
4. Click **"Create repository from template"**

### Method 2: Fork

1. Click the **"Fork"** button at the top right
2. This creates a copy under your account
3. You can keep it in sync with upstream updates

### Method 3: Manual Clone

```bash
git clone https://github.com/dyvan/github-project-llm-management.git my-project
cd my-project
rm -rf .git
git init
git add .
git commit -m "Initial commit from template"
```

## Post-Template Checklist

After creating your repository from this template, follow these steps:

### ✅ 1. Initial Configuration

- [ ] Update `README.md` with your project details
- [ ] Update `.github/project.yml` with your project number
- [ ] Update `.env.example` with your specific configuration
- [ ] Review and customize issue templates in `.github/ISSUE_TEMPLATE/`
- [ ] Review and customize PR template in `.github/PULL_REQUEST_TEMPLATE.md`

### ✅ 2. GitHub Setup

```bash
# Authenticate with GitHub CLI
gh auth login

# Set required secrets
gh secret set GH_TOKEN        # GitHub PAT with repo, project, workflow scopes
gh secret set CLAUDE_API_KEY  # Optional: for AI code review

# Run setup script
./setup-project.sh

# Auto-configure project fields
python3 scripts/setup_project_fields.py --project-number 1 --owner YOUR_USERNAME

# Validate setup
./scripts/validate_setup.sh
```

### ✅ 3. Customize Workflows

Review and customize these workflows for your needs:

**`.github/workflows/ci-tests.yml`**
- Update test commands for your language/framework
- Add deployment steps if needed
- Customize test matrix (Python versions, OS, etc.)

**`.github/workflows/code-review-agent.yml`**
- Choose your LLM provider (Claude, OpenAI, Gemini)
- Adjust review prompt in the template
- Configure when reviews should trigger

**`.github/workflows/update-project.yml`**
- Customize field mappings (Status, Priority, Type)
- Add custom label-to-field mappings
- Adjust automation rules

**`.github/workflows/create-branch.yml`**
- Customize branch naming convention
- Adjust branch prefix (feat/, fix/, docs/, etc.)
- Modify issue comment template

### ✅ 4. Project Structure

Add your project files while keeping the automation:

```
your-project/
├── .github/              # Keep all automation files
├── src/                  # Add your source code here
│   └── ...
├── tests/                # Keep test directory, add your tests
│   ├── test_workflows.py
│   ├── test_project_sync.py
│   └── test_your_code.py    # Add your tests
├── docs/                 # Add documentation
├── scripts/              # Keep automation scripts
├── requirements.txt      # Update with your dependencies
└── README.md            # Update with your project info
```

### ✅ 5. Labels Configuration

The setup script creates these labels. Customize in `setup-project.sh`:

**Type Labels:**
- `type:feature` - New features
- `type:bug` - Bug fixes
- `type:task` - Technical tasks
- `type:docs` - Documentation
- `type:infrastructure` - CI/CD, workflows

**Priority Labels:**
- `priority:high` - High priority
- `priority:medium` - Medium priority
- `priority:low` - Low priority

**Status Labels:**
- `status:blocked` - Blocked issues
- `status:in-progress` - Currently working on

**Special Labels:**
- `auto-branch` - Triggers automatic branch creation
- `good-first-issue` - For newcomers
- `help-wanted` - Needs assistance

### ✅ 6. Project Board Configuration

Edit `.github/project.yml` to match your workflow:

```yaml
project:
  number: 1  # Your project number

fields:
  status:
    options:
      - "Backlog"      # Customize these
      - "Ready"
      - "In Progress"
      - "In Review"
      - "Done"

  priority:
    options:
      - "Low"
      - "Medium"
      - "High"
```

## Customization Examples

### Example 1: Different Branch Naming

Edit `.github/workflows/create-branch.yml`:

```yaml
# Change from feat/{number}-{title}
BRANCH_NAME="feat/${ISSUE_NUMBER}-${SLUGIFIED}"

# To feature/{number}-{title}
BRANCH_NAME="feature/${ISSUE_NUMBER}-${SLUGIFIED}"

# Or type-based naming
if [[ "$ISSUE_LABELS" == *"type:bug"* ]]; then
  BRANCH_NAME="fix/${ISSUE_NUMBER}-${SLUGIFIED}"
else
  BRANCH_NAME="feat/${ISSUE_NUMBER}-${SLUGIFIED}"
fi
```

### Example 2: Add Slack Notifications

Add to any workflow:

```yaml
- name: Notify Slack
  if: success()
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK_URL }} \
      -H 'Content-Type: application/json' \
      -d '{"text":"✅ PR #${{ github.event.pull_request.number }} reviewed"}'
```

### Example 3: Custom Status Transitions

Edit `.github/workflows/update-project.yml`:

```yaml
# Add custom label mapping
if [[ "$LABEL" == "ready-for-qa" ]]; then
  python scripts/project_sync.py --issue $ISSUE_NUM --status "In QA"
elif [[ "$LABEL" == "deployed-staging" ]]; then
  python scripts/project_sync.py --issue $ISSUE_NUM --status "Staging"
fi
```

### Example 4: Multi-Language Support

Update `.github/workflows/ci-tests.yml`:

```yaml
strategy:
  matrix:
    language: [python, javascript]
    include:
      - language: python
        setup: pip install -r requirements.txt
        test: pytest
      - language: javascript
        setup: npm install
        test: npm test
```

## Maintaining Template Updates

To keep your project in sync with template improvements:

### Option 1: Merge Updates (if forked)

```bash
git remote add template https://github.com/dyvan/github-project-llm-management.git
git fetch template
git merge template/main --allow-unrelated-histories
```

### Option 2: Cherry-pick Updates

```bash
git remote add template https://github.com/dyvan/github-project-llm-management.git
git fetch template
git cherry-pick <commit-hash>
```

### Option 3: Manual Updates

Regularly check the [template repository](https://github.com/dyvan/github-project-llm-management) for:
- Workflow improvements
- New features
- Bug fixes
- Security updates

## Removing Template Files

If you don't need certain features, you can remove:

**To disable AI code review:**
```bash
rm .github/workflows/code-review-agent.yml
```

**To disable auto-branch creation:**
```bash
rm .github/workflows/create-branch.yml
```

**To disable project board sync:**
```bash
rm .github/workflows/update-project.yml
rm scripts/project_sync.py
```

**To use only as documentation template:**
```bash
# Keep only
.github/ISSUE_TEMPLATE/
.github/PULL_REQUEST_TEMPLATE.md
README.md
CONTRIBUTING.md
```

## Best Practices

### 1. Start Small
Enable one automation at a time:
1. First: Project Board sync
2. Then: Auto-branch creation
3. Finally: AI code review

### 2. Test Before Production
- Create test issues with `[TEST]` prefix
- Use a test project board initially
- Validate workflows in a separate branch

### 3. Document Customizations
- Keep a `CUSTOMIZATIONS.md` file
- Document what you changed from the template
- Helps when merging template updates

### 4. Monitor Workflow Runs
- Check Actions tab regularly
- Fix failures promptly
- Adjust automation based on team feedback

### 5. Iterate on Configuration
- Start with template defaults
- Adjust based on team needs
- Get feedback from contributors

## Getting Help

- 📖 Read the [README.md](../README.md)
- 🚀 See [QUICKSTART.md](../QUICKSTART.md) for setup
- 🤝 Check [CONTRIBUTING.md](../CONTRIBUTING.md) for contribution guidelines
- 🐛 [Open an issue](../../issues) if something doesn't work
- 💬 [Start a discussion](../../discussions) for questions

## Troubleshooting

### Workflows Not Running

**Check:**
- Settings → Actions → General → "Allow all actions"
- Workflow file syntax is valid (run tests)
- Required secrets are configured

### Project Board Not Updating

**Check:**
- `.github/project.yml` has correct project number
- `GH_TOKEN` secret has `project` scope
- Project exists and is accessible
- Run `./scripts/validate_setup.sh`

### Auto-Branch Not Creating

**Check:**
- Issue has `auto-branch` label
- Repository permissions allow branch creation
- No existing branch with same name
- Check workflow logs in Actions tab

## Support

This template is maintained by the community. Contributions welcome!

- **Issues**: Report bugs or request features
- **Pull Requests**: Contribute improvements
- **Discussions**: Ask questions or share ideas

---

Made with ❤️ for automated project management
