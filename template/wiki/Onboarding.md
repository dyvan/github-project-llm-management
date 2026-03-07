# Onboarding

Welcome! This guide helps new contributors (human or AI) get started quickly.

## Prerequisites

- Git installed and configured
- GitHub CLI (`gh`) authenticated
- Language runtime installed (see project README)
- Editor with linter/formatter configured

## Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd <repo-name>
   ```

2. **Install dependencies**
   ```bash
   # See README.md for project-specific commands
   ```

3. **Verify setup**
   ```bash
   # Run tests to confirm everything works
   ```

4. **Read key documentation**
   - [Architecture](Architecture) -- understand the system
   - [Conventions](Conventions) -- learn the code style
   - [Decisions](Decisions) -- understand past choices

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Project overview and setup instructions |
| `CLAUDE.md` | Instructions for AI assistants |
| `CONTRIBUTING.md` | Contribution guidelines |
| `.github/workflows/` | CI/CD pipeline definitions |
| `.ai/memory/` | Persistent AI context files |

## Useful Commands

```bash
# Check project status
gh issue list --label "status:in-progress"

# Run tests
# (project-specific command here)

# Create a feature branch
gh issue edit <number> --add-label "auto-branch"

# Open a pull request
gh pr create --title "feat: description (#issue)" --body "Closes #issue"
```

## Your First Contribution

1. Pick an issue labeled `good-first-issue`
2. Read the issue description and acceptance criteria
3. Create a branch and make your changes
4. Run tests and linters locally
5. Open a PR referencing the issue

## Getting Help

- Comment on the issue if you have questions
- Check [Troubleshooting](../../docs/Troubleshooting.md) for common problems
- Review the [FAQ](../../docs/faq.md)

## Related Pages

- [Conventions](Conventions) -- coding standards
- [Architecture](Architecture) -- system design
