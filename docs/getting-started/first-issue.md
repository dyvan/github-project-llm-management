# Create Your First Issue

This guide shows you how to create your first issue and trigger the automatic workflows.

## 🎯 Step 1: Create an Issue

### Via the GitHub Interface

1. Go to: https://github.com/dyvan/github-project-llm-management/issues
2. Click **New issue**
3. Select the **Feature Request** template

### Via the CLI

```bash
gh issue create \
  --title "Implement user authentication" \
  --body "Add OAuth2 authentication system

**Motivation**: Users need secure login

**Acceptance Criteria**:
- [ ] OAuth2 provider integration
- [ ] Token refresh mechanism
- [ ] Tests covering auth flow" \
  --label "type:feature"
```

## 📝 Fill in the Form

**Feature Request Example**:

```
Title: Add dark mode toggle

Description:
Users want a dark mode option for accessibility and reduced eye strain.

Motivation:
- Improve accessibility for users with light sensitivity
- Reduce eye strain during night usage
- Follow modern app standards

Acceptance Criteria:
- [ ] Toggle switch in settings
- [ ] Theme persists in localStorage
- [ ] Works across all pages
- [ ] Tests cover both themes
- [ ] Documentation updated
```

## 🏷️ Add the `auto-branch` Label

### Via the Interface

1. In the issue, click **Labels**
2. Search for `auto-branch`
3. Click it to add it

### Expected Result

**Immediately** after adding the label:

✅ The **Branch Creator** triggers

```
✅ Branch auto-created: `feat/1-add-dark-mode-toggle`

**Next steps:**
1. Clone the repository and checkout the branch:
   git checkout feat/1-add-dark-mode-toggle
2. Make your changes
3. Push and create a Pull Request
4. The Code Review Agent will automatically review your PR

---
Created by GitHub Actions
```

## 📊 Check the Project Board

1. Go to the **Projects** tab
2. Select your **Project Board**
3. Your issue appears in **Backlog**

**Visible columns**:
- Title: "Add dark mode toggle"
- Priority: Medium
- Effort: 5
- Status: Backlog
- Owner: (you)

## 💻 Develop Locally

Once the branch is created, you can get started:

```bash
# Clone the repo (if not already done)
git clone https://github.com/dyvan/github-project-llm-management.git
cd github-project-llm-management

# Checkout the branch
git checkout feat/1-add-dark-mode-toggle

# Develop
echo "export const darkMode = true;" > src/theme.js

# Commit
git add .
git commit -m "feat: Add dark mode toggle

- Implement toggle component
- Add theme CSS variables
- Save preference in localStorage"

# Push
git push origin feat/1-add-dark-mode-toggle
```

## 🔄 Open a Pull Request

### Via the Interface

1. You'll see a "Compare & pull request" banner
2. Click it
3. Fill in the template:

```markdown
## Description
Added dark mode toggle to settings page.

## Issue
Closes #1

## Type of change
- [x] Feature

## Checklist
- [x] Tests added
- [x] Documentation updated
- [x] Lint passed
```

4. Click **Create pull request**

### Automatic Workflows Trigger

#### 1️⃣ Code Review Agent
Within ~30 seconds:

```
## 🤖 Automated Code Review by Gemini AI

### ✅ Strengths
- Clean component structure
- Good use of React hooks

### ⚠️ Suggestions
- Add error boundary wrapper
- Consider memoization for performance

### 🔴 Critical Issues
None found!
```

#### 2️⃣ CI Tests
Within ~1 minute:

```
## ✅ Tests Passed

- Tests: 45/45 ✅
- Coverage: 87%
- Lint: OK
- Build: ✅
```

#### 3️⃣ Project Board Update
Status change: **Backlog → In QA**

## ✅ Merge the PR

### Merge Conditions

- ✅ Code review completed
- ✅ All tests pass
- ✅ Approved by a maintainer

### Merge via Interface

1. Go to your PR
2. Click **Merge pull request**
3. Choose the strategy:
   - **Create a merge commit** (recommended)
   - **Squash and merge**
   - **Rebase and merge**
4. Click **Confirm merge**

### Final Result

- ✅ Branch merged into `main`
- ✅ Project status: **Done**
- ✅ Issue closed automatically (Closes #1)
- 🎉 Feature deployed!

## 📋 Summary Checklist

You just:

- [ ] Created an issue with a template
- [ ] Added the `auto-branch` label
- [ ] Had a branch auto-created
- [ ] Developed locally
- [ ] Pushed changes
- [ ] Opened a PR
- [ ] Code Review Agent commented
- [ ] CI tests passed
- [ ] PR approved
- [ ] Merged into main
- [ ] Issue closed
- [ ] Project Board updated

**Congratulations! You've mastered the full workflow! 🚀**

## 🎓 Next Steps

- Explore the [LLM agents](../guides/using-agents.md)
- Set up [Slack webhooks](../guides/setup-github-projects.md)
- Customize the [workflows](../architecture/workflows.md)
