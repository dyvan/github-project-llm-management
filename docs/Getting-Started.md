# 🚀 Getting Started Guide

Install and configure the template in **5 minutes flat**.

## Prerequisites (2 minutes)

Before you begin, make sure you have:

### 1. Git
```bash
# Check if Git is installed
git --version

# Install Git if needed:
# macOS: brew install git
# Linux: sudo apt install git
# Windows: https://git-scm.com/download/win
```

### 2. GitHub CLI
```bash
# Install GitHub CLI
# macOS
brew install gh

# Linux (Ubuntu/Debian)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo apt install gh

# Windows
winget install GitHub.cli

# Verify the installation
gh --version
```

### 3. Python 3.11+
```bash
# Check if Python is installed
python3 --version

# Install Python if needed:
# macOS: brew install python@3.11
# Linux: sudo apt install python3.11
# Windows: https://www.python.org/downloads/
```

---

## Step 1: Create Your Project (1 minute)

### Option A: Use as a template (recommended)

1. On GitHub, click the **"Use this template"** button at the top of the page
2. Give your project a name (e.g., `my-project`)
3. Choose visibility (Public or Private)
4. Click **"Create repository from template"**

```bash
# Clone your new repository
git clone https://github.com/YOUR_NAME/my-project.git
cd my-project
```

### Option B: Add to an existing project

```bash
cd your-existing-project
git remote add template https://github.com/dyvan/github-project-llm-management.git
git fetch template
git merge template/main --allow-unrelated-histories
```

---

## Step 2: GitHub Authentication (30 seconds)

```bash
# Log in to GitHub
gh auth login

# Follow the instructions:
# 1. Choose "GitHub.com"
# 2. Choose "HTTPS"
# 3. Say "Yes" to authenticate
# 4. Choose "Login with a web browser"
# 5. Copy the code and open the browser
```

---

## Step 3: Configure Secrets (1 minute)

### Create a GitHub Personal Access Token (PAT)

1. Go to: https://github.com/settings/tokens/new
2. Give it a name: `My template automation`
3. **Check these scopes**:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `project` (Full control of projects)
   - ✅ `workflow` (Update GitHub Action workflows)
4. Click **"Generate token"**
5. **Copy the token** (you won't see it again!)

### Configure the token

```bash
# Configure the GitHub token
gh secret set GH_TOKEN
# Paste your token when prompted

# (Optional) Configure the Gemini API key for AI code review
gh secret set GEMINI_API_KEY
# Get your key at: https://aistudio.google.com/app/apikey
```

> **💡 Note**: Without `GEMINI_API_KEY`, code review will work in basic mode (without AI).

---

## Step 4: Installation (2 minutes)

```bash
# Install Python dependencies
pip install -r requirements.txt

# Run the setup script
./setup-project.sh
```

**The script will**:
1. ✅ Verify that everything is installed
2. ✅ Create GitHub labels (type:feature, priority:high, etc.)
3. ✅ Create a GitHub Project v2
4. ✅ Ask you to note the project number

> **🔔 Important**: Note the **project number** displayed (e.g., Project #1)

---

## Step 5: Project Configuration (1 minute)

### 5a. Update the project number

Edit the `.github/project.yml` file:

```yaml
project:
  number: 1  # 👈 Replace with your project number
  name: "Project Backlog"
```

### 5b. Auto-create custom fields

```bash
# Automatically create the Project Board fields
python3 scripts/setup_project_fields.py --project-number 1 --owner YOUR_NAME
```

This automatically creates:
- **Status**: Backlog, Ready, In Progress, In Review, Blocked, Done
- **Priority**: Low, Medium, High
- **Effort**: 1, 2, 3, 5, 8 (story points)
- **Type**: Feature, Bug, Task, Docs, Infrastructure
- **Target Version**: (free text field)

---

## Step 6: Validation (30 seconds)

```bash
# Validate that everything works
./scripts/validate_setup.sh
```

If you see `✅ All checks passed!`, **you're all set**! 🎉

---

## Quick Test

Let's test that the automation works:

### 1. Create an issue

```bash
gh issue create \
  --title "Test automation" \
  --label "type:feature,priority:medium,auto-branch" \
  --body "Test that the automation works"
```

### 2. Watch the magic ✨

A few seconds later, you should see:
- ✅ Issue added to the Project Board with Priority=Medium
- ✅ Branch automatically created: `feat/1-test-automation`
- ✅ Comment posted on the issue with git instructions

### 3. Create a Pull Request

```bash
# Fetch the branch
git fetch origin
git checkout feat/1-test-automation

# Make a change (example)
echo "# Test" > test.md
git add test.md
git commit -m "feat: test automation (#1)"
git push origin feat/1-test-automation

# Create a PR
gh pr create \
  --title "Test PR" \
  --body "Closes #1"
```

### 4. Watch the magic again ✨

You should see:
- ✅ CI/CD launching automatically
- ✅ Gemini AI analyzing your code (if API key is configured)
- ✅ Project Board updated: Status → "In Review"

---

## Next Steps

Now that everything is working:

1. **[📖 Read the full documentation](Using-The-Template)** - Understand all the features
2. **[⚙️ Customize the template](Configuration)** - Adapt to your needs
3. **[🔀 Understand the workflows](Understanding-Workflows)** - Learn how it works

---

## Need Help?

- **Having issues?** → Check the [Troubleshooting](Troubleshooting) page
- **Question?** → Post in the [Discussions](https://github.com/dyvan/github-project-llm-management/discussions)
- **Bug?** → Open an [Issue](https://github.com/dyvan/github-project-llm-management/issues)

---

[⬅️ Back to Home](Home) | [Next: Configuration ➡️](Configuration)
