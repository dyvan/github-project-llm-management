# 🤝 Contributing

Thanks for your interest! Here's how to get involved.

## Reporting a bug

1. Check that it doesn't already exist in [Issues](../../issues)
2. Create an issue using the "Bug Report" template
3. Describe the steps to reproduce
4. Include screenshots if relevant

## Suggesting a feature

1. Create an issue using the "Feature Request" template
2. Describe the motivation and use cases
3. List acceptance criteria

## Submitting code

### 1. Fork and clone

```bash
git clone https://github.com/YOUR_USERNAME/github-project-llm-management.git
cd github-project-llm-management
```

### 2. Create a branch

```bash
# Recommended method: create an issue with the "auto-branch" label
# Or manually:
git checkout -b feat/123-my-feature
```

### 3. Develop

- Follow the code style
- Add tests
- Document your changes

```bash
git commit -m "feat: add new feature

- Description of the change
- Impact
- Tests added"
```

### 4. Test

```bash
pip install -r requirements-dev.txt
pytest tests/ -v
./scripts/validate_setup.sh
```

### 5. Create the PR

```bash
git push origin feat/123-my-feature
gh pr create --title "My feature (#123)" --body "Closes #123"
```

## Checklist before submitting

- [ ] Tests pass
- [ ] Documentation updated
- [ ] No secrets committed
- [ ] Clear commit messages
- [ ] Issue linked in the PR

## Code of conduct

See [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md). By participating, you agree to this code.

## Questions?

- [Discussions](../../discussions)
- [Issues](../../issues)

[⬅️ Advanced Customization](Advanced-Customization) | [🏠 Home](Home)
