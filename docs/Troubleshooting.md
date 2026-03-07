# 🐛 Troubleshooting

Solutions to common problems.

## "gh: command not found"

**Solution**: Install GitHub CLI

```bash
# macOS
brew install gh

# Linux (Ubuntu/Debian)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo apt install gh

# Windows
winget install GitHub.cli
```

## "Project not found" or "GraphQL errors" or HTTP 401

**Most common cause**: The `GH_TOKEN` secret is missing the `project` scope.

The default `GITHUB_TOKEN` provided by GitHub Actions does **not** support
Projects v2 GraphQL operations. You need a classic Personal Access Token (PAT)
with scopes: `repo`, `project`, `workflow`.

**How to fix**:

1. Create a new PAT at https://github.com/settings/tokens/new
2. Select scopes: `repo`, `project`, `workflow`
3. Save it as a repository secret:
   ```bash
   gh secret set GH_TOKEN
   ```
4. Re-run the failed workflow

See [Configuration](Configuration) for detailed instructions.

**Other causes**:
- Project does not exist or wrong number in `.github/project.yml`
- Fine-grained PAT used instead of classic PAT (Projects v2 requires classic)

```bash
# Verify existing projects
gh project list --owner YOUR_USERNAME

# Check the diagnostic step in update-project.yml workflow logs
# for detailed error messages
```

## "Permission denied" on scripts

**Solution**:
```bash
chmod +x template-setup.sh
chmod +x scripts/*.sh
chmod +x scripts/*.py
```

## Workflows not triggering

**Check**:
1. Actions enabled: Settings → Actions → General
2. Workflows valid: `./scripts/validate_setup.sh`
3. Secrets configured: `gh secret list`
4. Logs: Actions tab on GitHub

## Project Board not updating

**Solutions**:
```bash
# Verify the project exists
gh project list --owner YOUR_USERNAME

# Check project.yml
cat .github/project.yml

# Test manually
python3 scripts/project_sync.py --issue 1 --status "Backlog"
```

## Auto-branch not creating the branch

**Check**:
- Issue has the `auto-branch` label
- No existing branch with the same name
- Workflow logs in Actions

## Code Review not working

**No comment posted**:
- Check `GEMINI_API_KEY`: `gh secret list`
- Basic mode without API key

**API error**:
- Check key validity
- Check quotas: https://aistudio.google.com/

## Tests failing

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run tests
pytest tests/ -v

# Validate workflow YAML
python -c "import yaml; [yaml.safe_load(open(f)) for f in ['.github/workflows/ci-tests.yml']]"
```

## Invalid or insufficient GitHub token

**Recreate**:
1. Go to https://github.com/settings/tokens/new (must be **classic** token)
2. Select scopes: `repo`, `project`, `workflow`
3. Generate and copy the token
4. Store as secret: `gh secret set GH_TOKEN`

**Note**: Fine-grained PATs do not support Projects v2. Use a classic PAT.
See [Configuration](Configuration) for details.

## Need more help?

1. Validate setup: `./scripts/validate_setup.sh`
2. Check the FAQ: [FAQ](FAQ)
3. Open an issue: https://github.com/dyvan/github-project-llm-management/issues
4. Ask a question: https://github.com/dyvan/github-project-llm-management/discussions

[⬅️ Workflows](Understanding-Workflows) | [➡️ FAQ](FAQ)
