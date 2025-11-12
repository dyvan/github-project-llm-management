# Project LLM Management - Template GitHub Complet

Un template de dépôt GitHub prêt à être forké, intégrant une gestion complète de projets via **GitHub Projects v2**, **GitHub Actions**, et des **agents LLM autonomes** (Claude, ChatGPT, Gemini) avec supervision humaine centralisée.

## 📋 Vue d'ensemble

Ce template fournit une architecture complète pour :

- **Gestion de projets** via GitHub Projects v2 avec vues Backlog, Priority Board, Team Items
- **Automatisation CI/CD** via GitHub Actions (tests, builds, revues de code)
- **Agents LLM intégrés** pour assister la création de branches, revues de code, et suivi
- **Gouvernance transparente** via un Project Board central avec suivi en temps réel

### Architecture

```
Issue créée + label "auto-branch"
    ↓
GitHub Action "create-branch.yml"
    ↓
Agent Branch Creator crée feat/{issue-number}-{title}
    ↓
Développeur code localement
    ↓
Pull Request ouverte
    ↓
GitHub Action "ci-tests.yml" → lint, tests, build
    ↓
GitHub Action "code-review-agent.yml" → Code Reviewer commente
    ↓
Project Board → mise à jour Status (In QA → Done)
    ↓
PR mergée & pushe en dev/preprod
```

## 🚀 Démarrage rapide

**Nouveau ? Suivez le guide [QUICKSTART.md](QUICKSTART.md) pour un setup en 5 minutes.**

### Prérequis

- Python 3.11+
- Git
- [GitHub CLI](https://cli.github.com/) (`gh`)
- Compte GitHub avec permissions d'admin sur le dépôt

### Installation rapide

```bash
# 1. Utiliser comme template sur GitHub (bouton "Use this template")
# 2. Cloner votre nouveau repo
git clone https://github.com/your-username/your-project.git
cd your-project

# 3. Installer les dépendances
pip install -r requirements.txt

# 4. Authentifier GitHub CLI
gh auth login

# 5. Configurer les secrets GitHub
gh secret set GH_TOKEN        # Token avec scopes: repo, project, workflow
gh secret set CLAUDE_API_KEY  # Optionnel: pour AI code review

# 6. Lancer le setup
./setup-project.sh

# 7. Auto-configurer les champs du projet
python3 scripts/setup_project_fields.py --project-number 1 --owner YOUR_USERNAME

# 8. Valider l'installation
./scripts/validate_setup.sh
```

### GitHub Personal Access Token (PAT)

Le `GH_TOKEN` doit avoir ces **scopes** :

| Scope | Raison |
|-------|--------|
| `repo` | Accès complet au repo (lecture/écriture issues, PRs) |
| `project` | Gérer GitHub Projects v2 |
| `workflow` | Déclencher et gérer les workflows |

**Créer un token** : [github.com/settings/tokens/new](https://github.com/settings/tokens/new)

**Note** : Le `GITHUB_TOKEN` fourni automatiquement par Actions a des permissions limitées. Utilisez un PAT personnel pour les opérations sur les Projects.

## 📊 GitHub Projects v2 - Configuration

### Trois vues principales

#### 1. **Backlog** (Table view)
Toutes les issues futures et suggestions, triées par ordre de création.

**Colonnes visibles** :
- Title
- Priority (Low / Medium / High)
- Effort (1/2/3/5/8 points story)
- Owner
- Status

#### 2. **Priority Board** (Kanban view)
Tâches actuelles, triées par priorité et statut.

**Groupage** : Status
- Backlog
- In Progress
- In QA
- Done

**Filtres** : Priority = High ou Medium

#### 3. **Team Items** (Table view)
Vue filtrée par Owner et Sprint, pour suivi personnel.

**Colonnes** :
- Title
- Owner
- Sprint (custom field)
- Status
- Due Date

### Champs personnalisés

Tous créés automatiquement via `.github/workflows/setup-project.yml` :

| Champ | Type | Valeurs |
|-------|------|---------|
| **Priority** | Single select | Low, Medium, High |
| **Effort** | Single select | 1, 2, 3, 5, 8 |
| **Status** | Single select | Backlog, In Progress, In QA, Done |
| **Owner** | People | Assigné de l'issue |
| **Sprint** | Text | v1.0, v2.0, etc. |
| **Environment** | Single select | dev, preprod, prod |

## 🤖 Agents LLM

### 1. Branch Creator
**Rôle** : Crée automatiquement une branche de travail quand une issue reçoit le label `auto-branch`.

**Déclenchement** :
- Workflow : `.github/workflows/create-branch.yml`
- Event : `issues: [labeled]`
- Condition : `label.name == 'auto-branch'`

**Actions** :
1. Formate le titre de l'issue : `feat/{issue-number}-{slugified-title}`
2. Crée la branche via l'API GitHub
3. Commente l'issue avec le lien : `Branch created: git checkout feat/123-my-feature`

**Permissions** : `contents: write`, `issues: write`

**Configuration** : `.github/workflows/create-branch.yml`

---

### 2. Code Reviewer
**Rôle** : Analyse automatiquement les PRs, commente les problèmes de logique, sécurité, performance, documentation.

**Déclenchement** :
- Workflow : `.github/workflows/code-review-agent.yml`
- Event : `pull_request: [opened, synchronize]`

**Actions** :
1. Récupère le diff de la PR
2. Appelle l'API Claude (ou OpenAI/Gemini) avec le contexte du diff
3. Génère un commentaire structuré :
   - ✅ Points positifs
   - ⚠️ Suggestions d'amélioration
   - 🔴 Problèmes critiques (sécurité, perf)
4. Poste le commentaire sur la PR (non bloquant)
5. Met à jour le champ Project → Status = "In QA"

**Permissions** : `pull-requests: write`, `contents: read`

**Configuration** : `.github/workflows/code-review-agent.yml`

**Exemple de sortie** :
```markdown
## 🤖 Code Review by Claude

### ✅ Strengths
- Good error handling in the database query
- Proper input validation

### ⚠️ Suggestions
- Consider adding type hints for function parameters
- Extract magic number `100` into a constant

### 🔴 Critical Issues
None found!

---
*Review generated by Claude AI - This is informational, not blocking*
```

---

### 3. Test Feedback
**Rôle** : Lit les résultats CI/CD, commente les erreurs, et met à jour le Project Board.

**Déclenchement** :
- Workflow : `.github/workflows/ci-tests.yml`
- Event : `push: [main, develop]` ou `pull_request`

**Actions** :
1. Exécute lint (`pylint`, `black`, `mypy` pour Python)
2. Exécute tests (`pytest`)
3. Exécute build (si applicable)
4. Si succès : commente "✅ All checks passed!" et met à jour Status → "Ready for Merge"
5. Si erreur : commente l'erreur détaillée et met à jour Status → "Blocked"
6. Met à jour le champ Project automatiquement via GraphQL

**Permissions** : `contents: read`, `pull-requests: write`

**Configuration** : `.github/workflows/ci-tests.yml`

---

## 📝 Templates GitHub

### Issues

Trois templates disponibles dans `.github/ISSUE_TEMPLATE/` :

#### 1. Feature Request (`feature_request.yml`)
```yaml
- Description du feature
- Motivation / Cas d'usage
- Critères d'acceptation
- Checklist (Pas de UI, API docs, Tests)
→ Label automatique : type:feature
```

#### 2. Bug Report (`bug_report.yml`)
```yaml
- Description du bug
- Étapes pour reproduire
- Résultat attendu vs actuel
- Environnement (OS, Python version, etc.)
→ Label automatique : type:bug
```

#### 3. Task (`task.yml`)
```yaml
- Description de la tâche
- Motivations
- Sous-tâches (checklist)
→ Label automatique : type:task
```

### Pull Requests

Template dans `.github/PULL_REQUEST_TEMPLATE.md` :

```markdown
## Description
Résumé concis des changements

## Issue
Closes #123

## Type de changement
- [ ] Bug fix
- [ ] Feature
- [ ] Refactoring
- [ ] Documentation

## Checklist
- [ ] Tests ajoutés
- [ ] Documentation mise à jour
- [ ] Lint & formatting OK
- [ ] Pas de secrets committés
```

---

## ⚙️ Workflows GitHub Actions

### 1. `create-branch.yml`
Crée automatiquement une branche quand `auto-branch` label est ajouté.

```yaml
on:
  issues:
    types: [labeled]

jobs:
  create-branch:
    if: github.event.label.name == 'auto-branch'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: peterjgrainger/action-create-branch@v2.0.1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          branch: 'feat/${{ github.event.issue.number }}-${{ github.event.issue.title | slugify }}'
```

**Trigger** : Label `auto-branch` ajouté à une issue

---

### 2. `ci-tests.yml`
Exécute lint, tests, et build sur chaque PR et push.

**Étapes** :
1. Checkout code
2. Setup Python 3.11
3. Installer dépendances
4. Lint (`pylint`, `black --check`, `mypy`)
5. Tests (`pytest`)
6. Build (si applicable)
7. Commenter résultat sur la PR
8. Mettre à jour Project Board (Status)

**Runs on** : `ubuntu-latest`

---

### 3. `code-review-agent.yml`
Revue automatique de code via Claude/OpenAI/Gemini.

**Étapes** :
1. Récupérer diff de la PR
2. Appeler l'API Claude
3. Parser réponse
4. Poster commentaire sur PR
5. Mettre à jour Status du Project

**Permissions** : Lecture contents, écriture pull-requests

---

### 4. `update-project.yml`
Met à jour le Project Board après chaque push.

**Actions** :
- Récupère commit info
- Met à jour l'issue liée
- Synchronise Status du Project

---

## 🔐 Configuration des secrets

Créez un fichier `.env.example` (modèle) :

```bash
# GitHub
GH_TOKEN=your_github_token_here

# LLM APIs
CLAUDE_API_KEY=your_claude_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here

# Optionnel : Deployment
DEPLOY_URL_PREPROD=https://preprod.example.com
DEPLOY_URL_PROD=https://example.com
```

**⚠️ IMPORTANT** : Ne committez JAMAIS `.env` directement. Utilisez GitHub Secrets.

Pour ajouter les secrets via CLI :

```bash
gh secret set GH_TOKEN --body "your_token"
gh secret set CLAUDE_API_KEY --body "your_key"
```

---

## 📚 Documentation

La documentation complète est générée via **MkDocs** et disponible sur GitHub Pages.

**Build & déploiement** :
- Workflow : `.github/workflows/deploy-docs.yml`
- Source : `docs/` (Markdown)
- Sortie : `gh-pages` branch
- URL : `https://your-org.github.io/project-{nom}`

**Sections documentées** :
- Architecture
- Guides d'utilisation
- Configuration des agents
- FAQ

Lancez localement :
```bash
pip install mkdocs mkdocs-material
mkdocs serve
# Accédez à http://localhost:8000
```

---

## 🎯 Flux complet : exemple d'utilisation

### Scénario : Ajouter une fonctionnalité "dark mode"

1. **Créer une issue** :
   - Type : Feature Request
   - Titre : "Add dark mode toggle to settings"
   - Priority : Medium
   - Effort : 3

2. **Ajouter le label `auto-branch`** :
   - → GitHub Action crée `feat/123-add-dark-mode-toggle`

3. **Développer localement** :
   ```bash
   git checkout feat/123-add-dark-mode-toggle
   # Coder...
   git push
   ```

4. **Ouvrir une PR** :
   - Titre : "Add dark mode toggle (#123)"
   - Description : remplit le template
   - → GitHub Actions se déclenche :
     - `ci-tests.yml` : Lint, tests, build
     - `code-review-agent.yml` : Revue auto Claude
     - Project Board : Status → "In QA"

5. **Révisions** :
   - Code Reviewer Claude commente
   - Développeur fixe les issues
   - Push → Tests re-exécutés

6. **Approbation & Merge** :
   - Team approuve la PR
   - Code merged en `develop` (preprod)
   - Project Board : Status → "Done"

7. **Monitoring** :
   - Le Project Board en temps réel montre la progression
   - Onglet "Team Items" filtre par Owner et Sprint

---

## 🔧 Troubleshooting

### Erreur : "gh: command not found"

**Solution** : Installer GitHub CLI depuis [cli.github.com](https://cli.github.com/)

```bash
# macOS
brew install gh

# Linux (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Windows
winget install GitHub.cli
```

### Erreur : "Project not found" ou "GraphQL errors"

**Causes possibles** :
- Le projet n'existe pas encore
- `.github/project.yml` contient un mauvais numéro de projet
- Le token n'a pas le scope `project`

**Solution** :
1. Vérifier que le projet existe : `gh project list --owner YOUR_USERNAME`
2. Mettre à jour `.github/project.yml` avec le bon numéro
3. Recréer le token avec le scope `project` : [github.com/settings/tokens](https://github.com/settings/tokens)

### Erreur : "Permission denied" sur les scripts

**Solution** :
```bash
chmod +x setup-project.sh
chmod +x scripts/*.sh
chmod +x scripts/*.py
```

### Les workflows ne se déclenchent pas

**Vérifier** :
1. GitHub Actions activé : `Settings → Actions → General → Allow all actions`
2. Workflows valides : `./scripts/validate_setup.sh`
3. Secrets configurés : `gh secret list`
4. Logs des workflows : `Actions` tab sur GitHub

### Le Project Board ne se met pas à jour

**Vérifier** :
1. Variable `GH_OWNER` et `GH_REPO` dans workflows (doit être auto-configuré)
2. Le projet existe : `gh project list --owner YOUR_USERNAME`
3. `.github/project.yml` contient le bon `number`
4. Tester manuellement :
   ```bash
   python3 scripts/project_sync.py --issue 1 --status "Backlog"
   ```

### L'auto-branch ne crée pas de branche

**Vérifier** :
1. L'issue a bien le label `auto-branch`
2. Pas de branche existante avec le même nom
3. Permissions `contents: write` dans le workflow
4. Logs du workflow dans l'onglet Actions

### Le Code Review ne fonctionne pas

**Si pas de commentaire** :
- Vérifier que `CLAUDE_API_KEY` est configuré : `gh secret list`
- Le workflow tourne en mode "basic" sans API key
- Vérifier les logs du workflow pour les erreurs

**Si erreur API** :
- Vérifier la validité de la clé API Claude
- Vérifier les quotas API : [console.anthropic.com](https://console.anthropic.com/)

### Tests échouent localement

```bash
# Installer les dépendances de test
pip install -r requirements-dev.txt

# Lancer les tests
pytest tests/ -v

# Vérifier les workflows YAML
python -c "import yaml; [yaml.safe_load(open(f)) for f in ['".github/workflows/*.yml"]]"
```

### Besoin d'aide supplémentaire ?

1. **Valider le setup** : `./scripts/validate_setup.sh`
2. **Consulter la doc** : [QUICKSTART.md](QUICKSTART.md) | [TEMPLATE_USAGE.md](.github/TEMPLATE_USAGE.md)
3. **Ouvrir une issue** : [GitHub Issues](../../issues)
4. **Poser une question** : [GitHub Discussions](../../discussions)

---

## 📖 Ressources

- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Claude API Reference](https://docs.anthropic.com)
- [GitHub CLI Reference](https://cli.github.com/manual)
- [QUICKSTART.md](QUICKSTART.md) - Guide de démarrage en 5 minutes
- [TEMPLATE_USAGE.md](.github/TEMPLATE_USAGE.md) - Guide d'utilisation du template
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Comment contribuer

---

## 🤝 Contribution

Voir [CONTRIBUTING.md](./CONTRIBUTING.md) pour les règles de contribution.

---

## 📄 Licence

MIT License - Voir [LICENSE](./LICENSE)

---

## 📧 Support

- 📋 Issues : Utilisez les templates fournis
- 💬 Discussions : GitHub Discussions
- 📚 Documentation : Voir `docs/` ou GitHub Pages
- 🚀 Quickstart : [QUICKSTART.md](QUICKSTART.md)

---

**Créé avec ❤️ pour des projets gérés par des agents LLM autonomes et une supervision humaine centralisée.**
