# Configuration

How to customize the template for your needs.

## GitHub Token (GH_TOKEN) -- REQUIRED for Projects v2

The `update-project.yml` workflow uses GitHub's GraphQL API to automatically
sync issues and PRs with your Projects v2 board. This requires a Personal
Access Token (PAT) with the **`project` scope**, which the default
`GITHUB_TOKEN` does **not** provide.

### Why the default GITHUB_TOKEN is not enough

GitHub Actions provides an automatic `GITHUB_TOKEN` for each workflow run.
However, this token does **not** include the `project` scope needed for
Projects v2 GraphQL mutations (`addProjectV2ItemById`,
`updateProjectV2ItemFieldValue`, etc.). Attempting to use it will result in:

- HTTP 401 errors
- `"Resource not accessible by integration"` GraphQL errors
- Silent failures with `continue-on-error: true`

### Creating a Personal Access Token

1. Go to **https://github.com/settings/tokens/new** (classic token)
2. Give it a descriptive name, e.g. `project-bot-token`
3. Set an expiration (recommended: 90 days, then rotate)
4. Select the following scopes:

| Scope       | Why it is needed |
|-------------|-----------------|
| `repo`      | Read/write access to repository contents, issues, and PRs |
| `project`   | Read/write access to Projects v2 (GraphQL API) |
| `workflow`  | Allows the token to trigger and update GitHub Actions workflows |

5. Click **Generate token** and copy the value immediately.

### Adding the token as a repository secret

```bash
# Using GitHub CLI (recommended)
gh secret set GH_TOKEN
# Paste the token when prompted

# Or via the GitHub web UI:
# Settings > Secrets and variables > Actions > New repository secret
# Name: GH_TOKEN
# Value: <your token>
```

### Verifying the token works

After setting the secret, you can verify it by triggering the
`update-project.yml` workflow. Check the **"Diagnose token permissions for
Projects v2"** step in the workflow logs. You should see:

```
GraphQL auth OK (authenticated as: your-username)
Projects v2 access OK (found N project(s) for your-username)
```

If you see warnings about missing `project` scope, regenerate the token
with the correct scopes.

### Fine-Grained Personal Access Tokens

Fine-grained PATs do not currently support Projects v2 GraphQL operations.
You must use a **classic** PAT. See the
[GitHub docs on token types](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
for details.

---

## Project configuration file

### `.github/project.yml`

```yaml
project:
  number: 1  # Change to match your project number
  name: "Project Backlog"
  auto_link: true

fields:
  status:
    options: ["Backlog", "Ready", "In Progress", "In Review", "Blocked", "Done"]
    default: "Backlog"
  priority:
    options: ["Low", "Medium", "High"]
    default: "Medium"
```

**To modify**:
- `project.number`: Set to the number of your GitHub Project (visible in the project URL)

## GitHub Labels

Labels are created by `setup-project.sh`. To customize:

```bash
# Edit setup-project.sh labels section
declare -a LABELS=(
    "type:feature:0e8a16:New feature"
    "priority:urgent:ff0000:Urgent"  # Add your labels
)
```

## Other Secrets

### Required
- `GH_TOKEN`: PAT with scopes `repo`, `project`, `workflow` (see above)

### Optional
- `GEMINI_API_KEY`: Google Gemini API key (used by code review, planning, and spec workflows)
- `GEMINI_PLAN_API_KEY`: Dedicated key for plan-with-gemini workflow (falls back to GEMINI_API_KEY)
- `GEMINI_SPEC_API_KEY`: Dedicated key for generate-specification workflow (falls back to GEMINI_API_KEY)
- `GEMINI_REVIEW_API_KEY`: Dedicated key for code-review-agent workflow (falls back to GEMINI_API_KEY)
- `SLACK_WEBHOOK_URL`: For Slack notifications

```bash
gh secret set GH_TOKEN
gh secret set GEMINI_API_KEY
```

## Workflows

Modify workflows in `.github/workflows/` as needed:

### Change branch naming convention
In `create-branch.yml`:
```bash
BRANCH_NAME="feat/${ISSUE_NUMBER}-${SLUGIFIED}"  # Customize
```

### Add fields to the Project Board
In `update-project.yml`, add your label mappings:
```bash
if [[ "$LABEL" == "my-label" ]]; then
  python scripts/project_sync.py --issue $ISSUE_NUM --status "My Status"
fi
```

[<- Getting Started](Getting-Started) | [-> Using The Template](Using-The-Template)
