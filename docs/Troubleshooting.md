# 🐛 Dépannage

Solutions aux problèmes courants.

## "gh: command not found"

**Solution** : Installer GitHub CLI

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

## "Permission denied" sur scripts

**Solution** :
```bash
chmod +x setup-project.sh
chmod +x scripts/*.sh
chmod +x scripts/*.py
```

## Workflows ne se déclenchent pas

**Vérifier** :
1. Actions activées : Settings → Actions → General
2. Workflows valides : `./scripts/validate_setup.sh`
3. Secrets configurés : `gh secret list`
4. Logs : Actions tab sur GitHub

## Project Board ne se met pas à jour

**Solutions** :
```bash
# Vérifier projet existe
gh project list --owner YOUR_USERNAME

# Vérifier project.yml
cat .github/project.yml

# Tester manuellement
python3 scripts/project_sync.py --issue 1 --status "Backlog"
```

## Auto-branch ne crée pas la branche

**Vérifier** :
- Issue a bien label `auto-branch`
- Pas de branche existante même nom
- Workflow logs dans Actions

## Code Review ne fonctionne pas

**Sans commentaire** :
- Vérifier `GEMINI_API_KEY` : `gh secret list`
- Mode basique sans API key

**Erreur API** :
- Vérifier validité clé
- Vérifier quotas : https://aistudio.google.com/

## Tests échouent

```bash
# Installer dépendances dev
pip install -r requirements-dev.txt

# Lancer tests
pytest tests/ -v

# Vérifier workflows YAML
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

## Besoin d'aide supplémentaire

1. Valider setup : `./scripts/validate_setup.sh`
2. Consulter FAQ : [FAQ](FAQ)
3. Ouvrir issue : https://github.com/dyvan/github-project-llm-management/issues
4. Poser question : https://github.com/dyvan/github-project-llm-management/discussions

[⬅️ Workflows](Understanding-Workflows) | [➡️ FAQ](FAQ)
