# 🎨 Advanced Customization

To adapt the template to your specific needs.

## Changing branch naming

Edit `.github/workflows/create-branch.yml`:

```bash
# From: feat/{number}-{title}
BRANCH_NAME="feat/${ISSUE_NUMBER}-${SLUGIFIED}"

# To: feature/{number}-{title}
BRANCH_NAME="feature/${ISSUE_NUMBER}-${SLUGIFIED}"

# Or: type-based naming
if [[ "$LABELS" == *"type:bug"* ]]; then
  BRANCH_NAME="fix/${ISSUE_NUMBER}-${SLUGIFIED}"
else
  BRANCH_NAME="feat/${ISSUE_NUMBER}-${SLUGIFIED}"
fi
```

## Adding custom fields to the Project Board

1. Create the field manually on the GitHub Project Board settings page.
   The GitHub API does not support creating custom fields programmatically.

2. Map it in `update-project.yml`:

```yaml
- name: Update sprint field
  run: |
    if [[ "$LABEL" == "sprint:1" ]]; then
      python scripts/project_sync.py --issue $NUM --sprint "Sprint 1"
    fi
```

## Slack/Discord Notifications

Add to any workflow:

```yaml
- name: Notify Slack
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK_URL }} \
      -H 'Content-Type: application/json' \
      -d '{"text":"✅ PR #${{ github.event.pull_request.number }} merged!"}'
```

## Multi-repository with a single Project

Set the same `GH_PROJECT_NUMBER` in each repo.

## Changing the LLM model

All AI workflows use Gemini. The default model is `gemini-2.0-flash`. To change the model, update the corresponding variable in the `code-review-agent.yml` workflow.

## Adding custom validations

In `ci-tests.yml`, add your steps:

```yaml
- name: Custom validation
  run: |
    ./scripts/my_custom_check.sh
```

## Custom issue templates

Edit `.github/ISSUE_TEMPLATE/*.yml` to suit your needs.

[⬅️ FAQ](FAQ) | [➡️ Contributing](Contributing)
