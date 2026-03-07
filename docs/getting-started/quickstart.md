# Quick Start Guide

Get your first automated workflow running in 5 minutes!

## Prerequisites

- Repository is [installed](./installation.md)
- GitHub secrets configured
- GitHub Projects v2 enabled

## 🎯 Create Your First Issue

### Step 1: Open GitHub Issues
Navigate to your repository and click the **Issues** tab.

### Step 2: Create New Issue
Click **New issue** → Select **Feature Request**

### Step 3: Fill the Form

```markdown
Title: Add user profile page

Description:
- Display user information
- Show user statistics
- Allow profile editing

Motivation: Users want to see and manage their profile data

Acceptance Criteria:
- [ ] Profile page displays user info
- [ ] Statistics are shown
- [ ] Edit functionality works

Priority: Medium
Effort: 5
```

### Step 4: Submit Issue
Click **Submit new issue**

## 🤖 Trigger the Branch Creator

### Step 1: Go to Issue Details
Click on the issue you just created.

### Step 2: Add Label
Click **Labels** → Select **`auto-branch`**

### Step 3: Watch the Magic ✨

The **Branch Creator** workflow will:
1. ⏳ Run (check **Actions** tab)
2. 📝 Create a comment with your branch name
3. 🌿 Push the new branch to GitHub

**Comment example:**
```
✅ Branch auto-created: `feat/123-add-user-profile-page`

Next steps:
1. git checkout feat/123-add-user-profile-page
2. Make your changes
3. Push and create a Pull Request
```

## 💻 Develop Locally

### Step 1: Check Out the Branch
```bash
git pull origin
git checkout feat/123-add-user-profile-page
```

### Step 2: Make Your Changes
```bash
# Edit files
nano src/app.py

# Create a simple example file
cat > src/profile.py << 'EOF'
def get_user_profile(user_id):
    """Get user profile by ID."""
    return {"id": user_id, "name": "John Doe"}

def update_profile(user_id, data):
    """Update user profile."""
    # Implementation
    pass
EOF
```

### Step 3: Run Tests Locally (Optional)
```bash
pytest tests/
black src/
pylint src/
mypy src/
```

### Step 4: Commit and Push
```bash
git add .
git commit -m "feat: Add user profile page

- Implement profile display
- Add profile editing functionality
- Update documentation"

git push origin feat/123-add-user-profile-page
```

## 📋 Create a Pull Request

### Step 1: Open PR on GitHub
Navigate to your repository:
- You'll see a **Compare & pull request** button
- Click it, or go to **Pull requests** → **New pull request**

### Step 2: Select Branches
- **Base**: `develop` (or your main branch)
- **Compare**: `feat/123-add-user-profile-page`

### Step 3: Fill PR Description
Use the template provided:

```markdown
## Description
Added user profile page with display and edit functionality.

## Issue
Closes #123

## Type of change
- [ ] Feature

## Checklist
- [x] Tests added
- [x] Documentation updated
- [x] Lint passed

## Screenshots
[Add screenshot if applicable]
```

### Step 4: Create Pull Request
Click **Create pull request**

## 🤖 Automated Workflows Execute

### Code Review Agent
**What happens:**
- Gemini AI analyzes your code
- Posts feedback comment on PR

**Example comment:**
```markdown
## 🤖 Code Review by Gemini AI

### ✅ Strengths
- Good error handling
- Clear function names

### ⚠️ Suggestions
- Add type hints to functions
- Extract magic number 100 to constant

### 🔴 Critical Issues
None found!
```

### CI Tests
**What happens:**
- Tests run: `pytest`
- Lint check: `black`, `pylint`, `mypy`
- Build test
- Coverage report

**Example result:**
```markdown
## ✅ Tests Passed

- Tests: 127/127 ✅
- Coverage: 85%
- Lint: OK
```

## ✅ Code Review & Merge

### Step 1: Address Feedback
If Gemini suggested improvements:
```bash
# Make changes
nano src/profile.py

# Commit
git commit -am "refactor: Add type hints and improve error handling"
git push
```

Tests will re-run automatically!

### Step 2: Request Review
Ask a team member to review:
- Click **Request a reviewer** on PR
- Mention team members: `@username`

### Step 3: Get Approval
Once approved and tests pass:

**Your team reviews and approves** → ✅

### Step 4: Merge
Click **Merge pull request**

Options:
- **Create a merge commit** (recommended)
- **Squash and merge** (for clean history)
- **Rebase and merge** (for linear history)

Then **Confirm merge**

## 📊 Project Board Updates

### Watch Your Issue Progress
1. Navigate to **Projects** tab
2. See your issue move through statuses:
   - **Backlog** → (when created)
   - **In Progress** → (when PR opened)
   - **In QA** → (when tests run)
   - **Done** → (when PR merged)

### Check Metrics
In the **Priority Board** view:
- Priority: Medium ✓
- Effort: 5 ✓
- Owner: You ✓
- Status: Done ✓

## 🎉 Success!

You just completed the full workflow:

```
Issue Created
    ↓
Branch Auto-Created
    ↓
Coded Locally
    ↓
PR Submitted
    ↓
Code Review (AI)
    ↓
Tests Passed
    ↓
PR Merged
    ↓
Project Updated
```

## 📚 What's Next?

- [Architecture Guide](../architecture/overview.md) - Learn how it works
- [Advanced Customization](../Advanced-Customization.md) - Customize the template
- [Contributing](../Contributing.md) - Start contributing to projects
- [FAQ](../faq.md) - Common questions and answers

## 💡 Tips

### Naming Conventions
- Branch: `feat/{number}-{description}` (auto-created)
- Commits: `feat:`, `fix:`, `docs:`, `refactor:`
- PRs: Reference issue: `Closes #123`

### Best Practices
- Write clear issue descriptions
- Include acceptance criteria
- Link PRs to issues
- Keep commits focused and atomic
- Write meaningful commit messages

### Keyboard Shortcuts
- `?` on GitHub → See keyboard shortcuts
- `c` → Create issue/PR
- `p` → Go to PRs
- `g` → Go to issues

---

**Congratulations! You're ready to manage projects with LLM agents.**

For detailed guides, see the [full documentation](../index.md).
