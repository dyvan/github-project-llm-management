# 🔀 Understanding Workflows

How the GitHub Actions automations work.

## Overview

```
Issue created → update-project.yml → Added to Project Board (Backlog)
     ↓
Label "auto-branch" → create-branch.yml → Branch created
     ↓
Developer codes
     ↓
PR opened → code-review-agent.yml → Gemini analyzes
          → ci-tests.yml → Tests run
          → update-project.yml → Status "In Review"
     ↓
PR merged → update-project.yml → Status "Done"
```

## Detailed Workflows

### 1. update-project.yml

**When**: Issue/PR created, labeled, merged

**Actions**:
- Issue created → Adds to Backlog
- Label added → Updates Status/Priority/Type
- PR opened → Status "In Review"
- PR merged → Status "Done"

**Variables**:
```yaml
env:
  GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  GH_OWNER: ${{ github.repository_owner }}
  GH_REPO: ${{ github.event.repository.name }}
```

### 2. create-branch.yml

**When**: Label `auto-branch` added

**Actions**:
1. Retrieves issue title
2. Creates slug (e.g., "Fix API Bug" → "fix-api-bug")
3. Creates branch `feat/{number}-{slug}`
4. Posts comment with instructions

### 3. code-review-agent.yml

**When**: PR opened/updated

**Actions**:
1. Retrieves the diff
2. Sends it to Gemini AI
3. Generates review (Strengths, Suggestions, Issues)
4. Posts comment

**Fallback mode**: Without GEMINI_API_KEY, basic checklist

### 4. ci-tests.yml

**When**: Push on main/develop, PR opened

**Actions**:
1. Checks script permissions
2. Validates workflow YAML syntax
3. Runs unit tests
4. Coverage report

## Customizing Workflows

### Add a new label mapping

In `update-project.yml`:
```yaml
- name: Update on custom label
  run: |
    if [[ "$LABEL" == "needs-review" ]]; then
      python scripts/project_sync.py --issue $NUM --status "In Review"
    fi
```

### Change the branch prefix

In `create-branch.yml`:
```bash
# Change "feat/" to "feature/"
BRANCH_NAME="feature/${ISSUE_NUMBER}-${SLUGIFIED}"
```

### Add notifications

```yaml
- name: Notify Slack
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
      -d '{"text":"PR merged!"}'
```

## Debugging a Workflow

```bash
# View logs
gh run list
gh run view RUN_ID --log

# Re-run a workflow
gh run rerun RUN_ID
```

[⬅️ Using Template](Using-The-Template) | [➡️ FAQ](FAQ)
