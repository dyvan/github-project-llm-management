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

## "Project not found" ou "GraphQL errors"

**Causes** :
- Projet n'existe pas
- Mauvais numéro dans `.github/project.yml`
- Token sans scope `project`

**Solutions** :
```bash
# Vérifier projets existants
gh project list --owner YOUR_USERNAME

# Mettre à jour project.yml avec bon numéro
# Recréer token avec scope project
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
- Vérifier `CLAUDE_API_KEY` : `gh secret list`
- Mode basique sans API key

**Erreur API** :
- Vérifier validité clé
- Vérifier quotas : https://console.anthropic.com/

## Tests échouent

```bash
# Installer dépendances dev
pip install -r requirements-dev.txt

# Lancer tests
pytest tests/ -v

# Vérifier workflows YAML
python -c "import yaml; [yaml.safe_load(open(f)) for f in ['.github/workflows/ci-tests.yml']]"
```

## Token GitHub invalide

**Recréer** :
1. Aller sur https://github.com/settings/tokens/new
2. Cocher scopes : `repo`, `project`, `workflow`
3. Générer
4. Configurer : `gh secret set GH_TOKEN`

## Besoin d'aide supplémentaire

1. Valider setup : `./scripts/validate_setup.sh`
2. Consulter FAQ : [FAQ](FAQ)
3. Ouvrir issue : https://github.com/dyvan/github-project-llm-management/issues
4. Poser question : https://github.com/dyvan/github-project-llm-management/discussions

[⬅️ Workflows](Understanding-Workflows) | [➡️ FAQ](FAQ)
