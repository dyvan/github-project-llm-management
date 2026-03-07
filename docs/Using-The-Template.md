# 🎓 Using the Template

Complete guide to using all the template features.

## Create an Issue

```bash
gh issue create \
  --title "Add dark mode" \
  --label "type:feature,priority:high" \
  --body "Feature description"
```

**Result**: Issue automatically added to the Project Board with Priority=High, Type=Feature

## Auto-create a Branch

Add the `auto-branch` label to an issue:

```bash
gh issue edit 123 --add-label "auto-branch"
```

**Result**:
- ✅ Branch created: `feat/123-issue-title`
- ✅ Comment posted with git instructions
- ✅ Status updated: "Ready"

## Work on a Branch

```bash
# Fetch the branch
git fetch origin
git checkout feat/123-add-dark-mode

# Make your changes
# ...

# Commit with issue reference
git add .
git commit -m "feat: add dark mode toggle (#123)"
git push origin feat/123-add-dark-mode
```

## Create a Pull Request

```bash
gh pr create \
  --title "Add dark mode (#123)" \
  --body "Closes #123"
```

**Result**:
- ✅ CI/CD runs
- ✅ Gemini AI analyzes the code (if configured)
- ✅ Issue Status → "In Review"

## Merge a PR

When the PR is approved:

```bash
gh pr merge 456 --squash
```

**Result**:
- ✅ PR and issue → Status "Done"
- ✅ Branch automatically deleted

## Use Labels to Automate

| Label | Automatic Action |
|-------|-------------------|
| `auto-branch` | Creates a branch |
| `priority:high` | Priority → High |
| `type:bug` | Type → Bug |
| `status:in-progress` | Status → In Progress |

## View the Project Board

```bash
# List items
gh project item-list 1 --owner YOUR_USERNAME

# View in the browser
gh project view 1 --owner YOUR_USERNAME --web
```

## Issue Templates

Use the templates in `.github/ISSUE_TEMPLATE/`:

- `feature_request.yml`: New feature
- `bug_report.yml`: Report a bug
- `task.yml`: Technical task

## Complete Workflow

### Example: Develop a New Feature

1. **Create the issue**
   ```bash
   gh issue create --title "Add user profile" --label "type:feature,priority:medium,auto-branch"
   ```

2. **Branch auto-created** → `feat/1-add-user-profile`

3. **Develop**
   ```bash
   git checkout feat/1-add-user-profile
   # Code...
   git commit -m "feat: add user profile page (#1)"
   git push
   ```

4. **Create PR**
   ```bash
   gh pr create --title "Add user profile (#1)" --body "Closes #1"
   ```

5. **Auto review** → Gemini analyzes the code

6. **Merge** → Status automatically set to "Done"

[⬅️ Configuration](Configuration) | [➡️ Workflows](Understanding-Workflows)
