# Scripts Directory

Python scripts for GitHub Projects v2 automation and management.

---

## 📄 `project_sync.py`

Synchronizes GitHub issues and pull requests with GitHub Projects v2 board using GraphQL API.

### Features

- ✅ Add issues/PRs to Project Board automatically
- ✅ Update custom fields (Status, Priority, Effort, Type, Owner, Target Version)
- ✅ Support for both organization and user projects
- ✅ Works with GitHub Actions workflows

### Usage

#### Basic Sync

```bash
# Sync issue to project
python scripts/project_sync.py --issue 123

# Sync PR to project
python scripts/project_sync.py --pr 45
```

#### Update Custom Fields

```bash
# Update status
python scripts/project_sync.py --issue 123 --status "In Progress"

# Update multiple fields
python scripts/project_sync.py \
  --issue 123 \
  --status "In Progress" \
  --priority "High" \
  --effort "3" \
  --type "Feature"

# Update PR with target version
python scripts/project_sync.py \
  --pr 45 \
  --status "In Review" \
  --version "v1.2"
```

#### Specify Project

```bash
# Use specific project number
python scripts/project_sync.py --issue 123 --project 5 --status "Ready"
```

### Environment Variables

Required:
- `GH_TOKEN` or `GITHUB_TOKEN`: GitHub Personal Access Token with `repo` and `project` scopes
- `GH_OWNER` or `GITHUB_REPOSITORY_OWNER`: Repository owner (username or org)
- `GH_REPO` or `GITHUB_REPOSITORY`: Repository name

Example:
```bash
export GH_TOKEN=ghp_xxxxxxxxxxxxx
export GH_OWNER=your-username
export GH_REPO=your-repo-name

python scripts/project_sync.py --issue 123 --status "In Progress"
```

### Field Values

#### Status
- `Backlog`: Planned but not started
- `Ready`: Ready to start
- `In Progress`: Currently being worked on
- `In Review`: PR open, waiting for review
- `Blocked`: Blocked by external dependency
- `Done`: Completed and merged

#### Priority
- `High`: Critical, urgent
- `Medium`: Important but not urgent
- `Low`: Nice to have

#### Effort (Story Points)
- `1`: < 1 hour, trivial change
- `2`: 2-4 hours, simple change
- `3`: 1 day, moderate change
- `5`: 2-3 days, complex change
- `8`: 1 week, very complex change

#### Type
- `Feature`: New functionality
- `Bug`: Bug fix
- `Task`: Technical task (refactoring, setup, etc.)
- `Docs`: Documentation
- `Infrastructure`: CI/CD, workflows, configuration

### Usage in GitHub Actions

```yaml
- name: Sync issue to project
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    GITHUB_REPOSITORY_OWNER: ${{ github.repository_owner }}
    GITHUB_REPOSITORY: ${{ github.repository }}
  run: |
    python scripts/project_sync.py \
      --issue ${{ github.event.issue.number }} \
      --status "Backlog"
```

### Troubleshooting

#### "No projects found"
- Ensure you have at least one GitHub Project v2 created
- Check that `GH_TOKEN` has `project` scope
- Verify `GH_OWNER` is correct (organization or user)

#### "Field 'X' not found in project"
- Check that custom fields are configured in Project Settings
- Field names are case-sensitive: use exactly "Status", "Priority", etc.
- Run the project setup script to create fields

#### "Option 'X' not found for field 'Y'"
- Check that the field options match exactly
- For Status: must have "Backlog", "Ready", "In Progress", "In Review", "Done"
- For Priority: must have "High", "Medium", "Low"
- For Effort: must have "1", "2", "3", "5", "8"

#### "GraphQL errors"
- Enable debug output: add `--verbose` flag (if implemented)
- Check GitHub API status: https://www.githubstatus.com/
- Verify token permissions: `gh auth status`

### Examples

#### Full Workflow Example

```bash
# 1. Create issue and sync
gh issue create --title "Add dark mode" --label "type:feature"
python scripts/project_sync.py --issue 123 --status "Backlog" --type "Feature"

# 2. Start work
python scripts/project_sync.py --issue 123 --status "In Progress" --priority "High" --effort "3"

# 3. Open PR
gh pr create --title "feat: Add dark mode" --body "Closes #123"
python scripts/project_sync.py --pr 45 --status "In Review"

# 4. Merge PR
gh pr merge 45
python scripts/project_sync.py --issue 123 --status "Done"
python scripts/project_sync.py --pr 45 --status "Done"
```

#### Batch Update

```bash
#!/bin/bash
# Mark all high-priority issues as ready

for issue in $(gh issue list --label "priority:high" --json number -q '.[].number'); do
  python scripts/project_sync.py --issue $issue --status "Ready"
done
```

---

## 🔮 Future Scripts (Planned)

- `generate_dashboard.py`: Generate project dashboard (DASHBOARD.md)
- `velocity_calculator.py`: Calculate team velocity from completed story points
- `claude_manager.py`: CLI interface for Claude to manage projects
- `issue_templates_generator.py`: Bulk create issues from templates

---

## 🛠️ Development

### Adding New Scripts

1. Create script in `scripts/` directory
2. Add shebang: `#!/usr/bin/env python3`
3. Make executable: `chmod +x scripts/your_script.py`
4. Document in this README
5. Add usage examples

### Testing

```bash
# Test project sync locally
export GH_TOKEN=your_token
export GH_OWNER=your_username
export GH_REPO=your_repo

# Create test issue
TEST_ISSUE=$(gh issue create --title "Test issue" --body "Testing" --json number -q '.number')

# Test sync
python scripts/project_sync.py --issue $TEST_ISSUE --status "Backlog"

# Verify in Project Board
gh project item-list <project-number>

# Clean up
gh issue close $TEST_ISSUE
```

---

## 📚 Related Documentation

- `../AUTOMATION.md`: Complete automation guide
- `../claude.md`: Instructions for Claude AI
- `../.github/workflows/update-project.yml`: Workflow using this script
- `../PROJECT_BOARD_SETUP.md`: Project Board setup guide

---

**Last Updated**: 2025-11-10
