# Frequently Asked Questions (FAQ)

## Setup & Installation

### Q: Do I need to pay for the API keys?
**A:**
- **Claude API**: Anthropic uses a pay-as-you-go model. Free credits available for new accounts.
- **OpenAI**: Also pay-as-you-go, but usually more expensive than Claude for code review.
- **Gemini**: Free tier available, pay-as-you-go otherwise.

We recommend Claude for best code review quality and reasonable pricing.

### Q: Can I use this without LLM APIs?
**A:**
Yes! The template will still work:
- ✅ Branch Creator: Works without API keys
- ✅ CI Tests: Works without API keys
- ⚠️ Code Review: Falls back to basic lint if no API key is set
- ✅ Project Updates: Works without API keys

### Q: What Python versions are supported?
**A:**
3.11+ is the default. You can modify `.github/workflows/ci-tests.yml` to test against:
```yaml
python-version: ["3.9", "3.10", "3.11", "3.12"]
```

## Workflows & Automation

### Q: Why isn't my branch being created?
**A:**
Check these:
1. ✅ Did you add the `auto-branch` label?
2. ✅ Is the Actions tab showing the workflow running?
3. ✅ Check workflow logs for errors: **Actions → create-branch.yml → Latest run**

### Q: Can I use a different branch naming convention?
**A:**
Yes! Edit `.github/workflows/create-branch.yml` and modify the `BRANCH_NAME` variable:

```bash
# Current: feat/{number}-{slug}
BRANCH_NAME="feat/${ISSUE_NUMBER}-${SLUGIFIED}"

# Custom example: bugfix/{number}-{slug}
BRANCH_NAME="bugfix/${ISSUE_NUMBER}-${SLUGIFIED}"
```

### Q: Why did the Code Review Agent not comment?
**A:**
Reasons:
1. `CLAUDE_API_KEY` not set in secrets
2. API rate limit exceeded
3. PR diff too large (limit: 10000 lines)
4. Workflow failed (check Actions logs)

Solution: Add the secret and test on a new PR.

### Q: Can I disable certain workflows?
**A:**
Yes! Workflows have conditions. For example, to disable code review:
1. Go to `.github/workflows/code-review-agent.yml`
2. Add a condition in the `jobs:` section:
```yaml
jobs:
  code-review:
    if: false  # Disable this workflow
```

Or rename the file to `.disabled` to skip it.

## Project Board & Tracking

### Q: How do I bulk update statuses?
**A:**
Currently, GitHub Projects v2 doesn't have bulk edit via UI. You can:
1. Use GraphQL API for bulk updates
2. Use GitHub CLI:
```bash
gh issue list --label "ready" | xargs -I {} gh issue edit {} --project "Project Board"
```

### Q: Can I automate status transitions?
**A:**
Partially. Workflows can update statuses via GraphQL, but full automation requires:
1. Custom scripts in your repo
2. External tools (Zapier, Make, etc.)
3. Custom GitHub App

We recommend keeping human review for major status changes.

### Q: Why aren't my issues appearing in the project?
**A:**
Issues auto-appear if:
1. ✅ Project is linked to the repository
2. ✅ Issue has the right filters (if any)

To manually link an issue:
1. Open the issue
2. Go to **Projects** section on the right
3. Click **Add to project** → Select your project

## GitHub Actions & CI/CD

### Q: Why are my tests timing out?
**A:**
GitHub Actions has limits:
- **Free tier**: 6 hours per month per user (deprecated, now all public)
- **Jobs**: 6 hours max per job
- **Workflows**: 35-day retention

Solutions:
1. Optimize test suite (reduce expensive tests)
2. Use caching for dependencies
3. Run tests in parallel

### Q: Can I trigger workflows manually?
**A:**
Yes! Add `workflow_dispatch` to any workflow:

```yaml
on:
  pull_request:
  workflow_dispatch:  # Allows manual trigger
```

Then go to **Actions → Workflow name → Run workflow**

### Q: How do I see workflow logs?
**A:**
1. Go to **Actions** tab
2. Click the workflow run
3. Click the failed job
4. Expand steps to see logs
5. Look for error messages

### Q: Can I run workflows locally?
**A:**
Yes! Use [act](https://github.com/nektos/act):

```bash
# Install
brew install act

# Run a workflow locally
act push

# Run specific job
act -j build
```

## LLM & Code Review

### Q: Will the AI leak my code?
**A:**
No:
- Claude: Anthropic doesn't use API calls for training (per their policy)
- Code review only analyzes the diff, not full codebase
- All processing is server-side and secure

However, **always** review third-party APIs' privacy policies.

### Q: Can I customize the code review prompt?
**A:**
Yes! In `.github/workflows/code-review-agent.yml`, find this section:

```python
prompt = f"""Review this GitHub Pull Request code changes...
```

Modify it to add your custom instructions:
```python
prompt = f"""Review this GitHub PR for our project.
Focus on: {your_priorities}
Ignore: {your_exclusions}
...
```

### Q: What's the typical cost per code review?
**A:**
**Claude (Anthropic)**:
- ~$0.01 - $0.05 per review (depending on code size)
- Much cheaper than OpenAI for this use case

Monitor spending:
```bash
# Check Anthropic usage
gh api user
```

### Q: Can I use multiple LLM providers?
**A:**
Not yet. The current implementation uses one provider. To support multiple:
1. Modify the code review script to choose provider
2. Use a config file or environment variable
3. Test each provider

Feature request: Consider opening an issue for multi-provider support!

## Git & Development

### Q: How do I revert a merged PR?
**A:**
```bash
# Option 1: Revert the commit
git revert {commit-hash}

# Option 2: Revert via GitHub UI
Go to PR → Click "Revert" button (appears after merge)
```

### Q: Can I rename a branch?
**A:**
```bash
# Rename locally
git branch -m old-name new-name

# Rename remote
git push origin new-name
git push origin --delete old-name
```

Then delete the old branch on GitHub.

### Q: Why is my commit not linked to an issue?
**A:**
Use the correct format in your commit message:
```bash
git commit -m "feat: Add feature

Closes #123"  # Must say "Closes #123"
```

Or in PR description:
```
Fixes #123
Resolves #456
Closes #789
```

## Troubleshooting

### Q: I broke something. How do I reset?
**A:**
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo to specific commit
git reset --hard {commit-hash}
```

⚠️ Be careful with `--hard`!

### Q: My workflow is in an infinite loop!
**A:**
1. Go to **Actions** tab
2. Click the stuck workflow
3. Click **Cancel workflow** (top right)
4. Fix the issue in the workflow file
5. Commit and push

Example infinite loop cause:
```yaml
# ❌ This causes infinite loop
on:
  push:
    paths: [".github/workflows/"]

jobs:
  update-workflow:
    runs-on: ubuntu-latest
    steps:
      - run: git push  # Triggers workflow again!
```

### Q: How do I debug a failing workflow?
**A:**
1. Check **Actions → Failed workflow → Logs**
2. Look for red text or error messages
3. Common issues:
   - Missing secrets: `Could not resolve secret`
   - Missing dependencies: `ModuleNotFoundError`
   - Wrong branch: Check `on: [branches]`
   - Permission issues: Check `permissions:` section

### Q: Can I get email notifications?
**A:**
Yes:
1. Go to **Settings → Notifications**
2. Enable **GitHub Actions** notifications
3. Choose: Always, Failing only, or Never

## Advanced Questions

### Q: How do I customize the project fields?
**A:**
In your GitHub Project v2 settings:
1. Click **Settings** (gear icon)
2. Click **Custom fields**
3. Add/Remove/Rename fields
4. Update workflows to sync with new field names

### Q: Can I use this for non-Python projects?
**A:**
Yes! Modify the workflows:
- JavaScript: Change `setup-python` to `setup-node`
- Go: Use `setup-go`
- Rust: Use `dtolnay/rust-toolchain`

Update the CI commands accordingly.

### Q: How do I integrate with external tools (Slack, Discord, Jira)?
**A:**
Options:
1. **Webhooks**: Send POST requests from workflows
2. **GitHub Apps**: Develop custom integrations
3. **Zapier/Make**: Connect without code
4. **GitHub API**: Custom scripts

Example: Slack notification
```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
```

## Still Have Questions?

- 📚 Read the [Architecture Guide](./architecture/overview.md)
- 📖 Check [Troubleshooting Guide](./guides/troubleshooting.md)
- 💬 Open a [GitHub Discussion](../../discussions)
- 🐛 File an [Issue](../../issues)

---

**Last Updated**: 2025-01-28
**Version**: 1.0.0
