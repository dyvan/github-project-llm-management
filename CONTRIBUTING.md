# Contributing

Thank you for your interest in contributing to this project! This document describes the rules and processes for contributing.

## 🎯 Code of Conduct

See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md). By participating, you agree to abide by this code.

## 📝 How to Contribute

### Reporting a Bug

1. Check that the bug has not already been reported in [Issues](../../issues)
2. Create a new issue using the **Bug Report** template
3. Describe the steps to reproduce the bug
4. Include screenshots or logs if relevant
5. Mention your OS, Python version, etc.

### Suggesting a Feature

1. Check that the feature has not already been suggested
2. Create a new issue using the **Feature Request** template
3. Clearly describe the motivation and use cases
4. List the acceptance criteria

### Submitting Code

#### 1. Fork and clone

```bash
git clone https://github.com/YOUR_USERNAME/project-name.git
cd project-name
```

#### 2. Create a branch

```bash
# Via GitHub (recommended): Add the "auto-branch" label to the issue
# → The action automatically creates feat/{issue-number}-{title}

# Or manually:
git checkout -b feat/123-my-feature
```

#### 3. Develop

- Follow the project's code style
- Add tests for your changes
- Document significant changes
- Write clear commit messages

```bash
git add .
git commit -m "feat: Add dark mode toggle

- Implement toggle component
- Add CSS variables for theming
- Update documentation"
```

#### 4. Run tests locally

```bash
# Python
pip install -r requirements-dev.txt
pytest
black --check .
pylint src/
mypy src/

# JavaScript (if applicable)
npm run lint
npm run test
```

#### 5. Push and create a Pull Request

```bash
git push origin feat/123-my-feature
```

Then on GitHub:
1. Go to your fork
2. Click **Compare & pull request**
3. Fill in the PR template
4. Link the issue: `Closes #123`
5. Submit

#### 6. Code review

- The **Code Review Agent** (Gemini) will comment automatically
- The team will review the PR
- Tests (lint, pytest, build) must pass
- Address feedback and commit fixes

#### 7. Merge

Once approved:
1. PR merged into `develop` (pre-production branch)
2. Project Board status → "Done"
3. Branch deleted (optional)

---

## 🏗️ Project Structure

```
project-name/
├── .github/
│   ├── workflows/           # GitHub Actions
│   ├── ISSUE_TEMPLATE/      # Issue templates
│   └── PULL_REQUEST_TEMPLATE/
├── docs/                    # MkDocs documentation
├── scripts/                 # Automation scripts
├── template/                # Template setup files
├── tests/                   # Unit tests
├── requirements.txt         # Python dependencies
├── template-setup.sh        # Project setup script
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

---

## Workflows: Template vs Internal

Not all workflow files in `.github/workflows/` are distributed to template users. The setup step `5-copy-files.sh` uses an explicit whitelist.

**Template workflows** (distributed to users):

| Workflow | Purpose |
|---|---|
| `create-branch.yml` | Auto-create branch from issue |
| `code-review-agent.yml` | Gemini AI code review |
| `auto-close-feature.yml` | Auto-close parent when subs done |
| `generate-specification.yml` | Gemini generates detailed spec |
| `plan-with-gemini.yml` | Gemini generates spec questionnaire |
| `update-project.yml` | Sync project board |
| `ci-tests.yml` | Lint, tests, build |
| `deploy-docs.yml` | Deploy MkDocs to GitHub Pages |

**Internal workflows** (NOT distributed, development-only):

| Workflow | Purpose |
|---|---|
| `e2e-test-template.yml` | End-to-end template validation |
| `e2e-test-install.yml` | End-to-end install flow test |
| `template-validation.yml` | Template structure validation |
| `auto-add-to-project.yml` | Auto-add items to project board (repo-specific) |

A CI test (`tests/test_template_distribution.py`) enforces that internal workflows never appear in the whitelist.

---

## Tech Stack

### Languages
- **Python 3.11+** (primary language)
- **YAML** for GitHub Actions workflows
- **Markdown** for documentation

### Development Tools
- **pytest**: Unit tests
- **pylint** / **black**: Linting and formatting
- **mypy**: Type checking
- **mkdocs**: Documentation
- **GitHub Actions**: CI/CD

### LLM APIs
- **Gemini (Google)**: Code review, planning, specification

---

## 🔍 Pre-submission Checklist

Before opening a PR, make sure that:

- [ ] Your code passes the tests: `pytest`
- [ ] Formatting is correct: `black src/ tests/`
- [ ] No warnings: `pylint src/`
- [ ] Types are verified: `mypy src/`
- [ ] Documentation is up to date (docstrings, README, docs/)
- [ ] No secrets committed (API keys, tokens, etc.)
- [ ] Commits have clear messages
- [ ] Issue is linked in the PR description

---

## 📊 Using the Project Board

**GitHub Projects v2** is at the heart of project management:

1. **Issues created** → Automatically added to the Backlog
2. **Label `auto-branch`** → Branch created automatically
3. **PR opened** → Status → "In QA"
4. **Tests pass** → Status → "Ready for Merge"
5. **PR merged** → Status → "Done"

**Views**:
- **Backlog**: All issues, sorted by priority
- **Priority Board**: Kanban by status
- **Team Items**: Filtered by Owner and Sprint

---

## 🚀 Deployment

### Development Environment

Each PR merged into `develop` triggers:
- Full test suite
- Build
- Optional: pre-production deployment

### Production Environment

To be defined based on your needs:
- Release tags (v1.0, v1.1, etc.)
- Or `main` branch deployed to production

---

## ❓ Questions or Need Help?

- 📖 Check out the [documentation](./docs/)
- 💬 Use the [Discussions](../../discussions)
- 📋 Create an [Issue](../../issues) (use the "Task" template)

---

## ✅ Maintainer Checklist

Before merging a PR:

- [ ] Code review passed
- [ ] Tests are green
- [ ] Linting is clean
- [ ] Documentation is up to date
- [ ] Issue is correctly linked
- [ ] No major breaking changes (or they are documented)
- [ ] Commits have clear messages

---

Thank you for contributing! 🎉
