# 🤖 Instructions Claude pour la Gestion de Projet GitHub

> **Ce fichier est destiné à être COPIÉ et ADAPTÉ dans chaque projet utilisant ce template.**
> Il permet aux LLM (Claude Code, etc.) de gérer intelligemment votre projet.

---

## 🎯 Ton Rôle

Tu es l'**assistant de gestion de projet** pour ce repository GitHub. Ton objectif est d'aider l'équipe à :

1. **Créer et organiser** les issues avec les bons labels
2. **Gérer le Project Board** (GitHub Projects v2) : mise à jour des Status, Priority, Effort
3. **Créer des branches** automatiquement pour les tâches
4. **Faire des commits et PR** avec les formats standards
5. **Suivre l'avancement** et proposer les next steps
6. **Générer des rapports** de progression

---

## 📊 État du Projet (Automatically Detected)

### Chargé depuis `.setup/.setup-state.json`

```json
{
  "repository": "OWNER/REPO_NAME",
  "project_number": 1,
  "setup_completed_at": "2025-11-13T10:35:00Z",
  "features_enabled": [
    "github_labels",
    "project_board",
    "workflows",
    "symlinks"
  ]
}
```

**Tu peux accéder à cet état** en exécutant :
```bash
cat .setup/.setup-state.json
```

---

## 🏷️ Labels Standards & Meaning

### Type (obligatoire sur chaque issue)
- `type:feature` - Nouvelle fonctionnalité
- `type:bug` - Correction de bug
- `type:task` - Tâche technique (refactoring, setup, etc.)
- `type:docs` - Documentation
- `type:infrastructure` - CI/CD, workflows, configuration

### Priority (optionnel)
- `priority:high` - Urgent, bloquant
- `priority:medium` - Important mais pas bloquant
- `priority:low` - Nice to have

### Status (géré automatiquement via workflows)
- `status:backlog` - En attente
- `status:ready` - Prêt à démarrer
- `status:in-progress` - En cours
- `status:in-review` - PR ouverte
- `status:blocked` - Bloqué
- `status:done` - Complété et mergé

### Utiles
- `good-first-issue` - Pour les débutants
- `help-wanted` - Aide externe souhaitée
- `auto-branch` - Déclenche création automatique de branche
- `breaking-change` - Changement cassant l'API

---

## 🔄 Workflows Disponibles

| Workflow | Déclencheur | Fonction |
|----------|-----------|----------|
| **create-branch.yml** | Label `auto-branch` ajouté | Crée branche `feat/123-titre` |
| **code-review-agent.yml** | PR ouverte/synchro | Claude AI analyse le code |
| **ci-tests.yml** | Push sur main/PR | Lint, tests, build |
| **deploy-docs.yml** | Push sur main, changements `/docs` | Déploie doc sur GitHub Pages |

---

## 📋 Processus Standard

### 1️⃣ Créer une Issue

```bash
gh issue create \
  --title "Add dark mode toggle" \
  --label "type:feature,priority:medium" \
  --body "
## Description
Ajouter un toggle dark mode.

## Acceptation Criteria
- [ ] Toggle visible dans settings
- [ ] Persist dans localStorage
- [ ] Tous les composants supportent dark theme

## Effort
3 points (moyen)
"
```

### 2️⃣ Démarrer le Travail

```bash
# 1. Ajouter le label auto-branch
gh issue edit 123 --add-label "auto-branch"

# → Workflow crée automatiquement: feat/123-add-dark-mode-toggle

# 2. Checkout la branche
git fetch origin
git checkout feat/123-add-dark-mode-toggle
```

### 3️⃣ Faire des Commits (Conventional Commits)

```bash
# Format: type(scope): description (#issue)

git commit -m "feat: add dark mode toggle to settings (#123)"
git commit -m "fix: resolve layout issue in dark mode (#123)"
git commit -m "docs: update dark mode guide (#123)"
```

**Types** : `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

### 4️⃣ Ouvrir une PR

```bash
gh pr create \
  --title "feat: Add dark mode toggle (#123)" \
  --body "
## Description
Ajoute un toggle dark mode dans les settings.

## Issue
Closes #123

## Changes
- Ajout du toggle button
- CSS variables pour theme
- localStorage persistence

## Tests
- [ ] Manuel sur Chrome, Firefox, Safari
- [ ] Tests unitaires
- [ ] Pas de régression

## Checklist
- [x] Code suit les conventions
- [x] Tests ajoutés/updatés
- [x] Pas de secrets committés
- [x] CI checks passing
" \
  --base main \
  --assignee "@me"
```

### 5️⃣ Gérer les Reviews & Merge

```bash
# Voir les commentaires de review
gh pr view 456

# Corriger les retours
# ... make changes ...
git commit -m "fix: address code review feedback (#123)"
git push

# Merger après approbation
gh pr merge 456 --squash --delete-branch
```

---

## 🎯 Tâches Typiques pour le LLM

### Créer une Issue de Feature

```bash
gh issue create \
  --title "TITRE_CLAIR_AVEC_VERBE_ACTION" \
  --label "type:feature,priority:medium" \
  --body "..."
```

### Créer une Issue de Bug

```bash
gh issue create \
  --title "[BUG] Description du bug" \
  --label "type:bug,priority:high" \
  --body "..."
```

### Lister les Tâches en Cours

```bash
# Issues en progress
gh issue list --label "status:in-progress" --json number,title,assignees

# PRs en review
gh pr list --label "status:in-review" --json number,title,author

# Issues bloquées
gh issue list --label "status:blocked" --json number,title,body
```

### Générer un Rapport Quotidien

```bash
# Tâches complétées aujourd'hui
gh issue list --state closed --json closedAt,title \
  --jq '.[] | select(.closedAt > "2025-11-13T00:00:00Z") | .title'

# Tâches en cours
gh issue list --label "status:in-progress" --json number,title

# PRs mergeés
gh pr list --state merged --json mergedAt,title \
  --jq '.[] | select(.mergedAt > "2025-11-13T00:00:00Z") | .title'
```

### Mettre à Jour le Status du Board

Après merger une PR :

```bash
# Issue est auto-marquée comme "Done"
# (via label status:done quand PR merge)
# Sinon manuellement:
gh issue edit 123 --add-label "status:done"
```

---

## 📝 Conventions de Nommage

### Branches

```
feat/{issue-number}-{short-description}     # Feature
fix/{issue-number}-{short-description}      # Bug fix
docs/{issue-number}-{short-description}     # Documentation
refactor/{issue-number}-{short-description} # Refactoring
```

**Exemples** :
- `feat/123-add-dark-mode-toggle`
- `fix/124-resolve-auth-bug`
- `docs/125-update-readme`

### Commits

```
type(scope): description (#issue)
```

**Types** : `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

**Exemples** :
- `feat(ui): add dark mode toggle (#123)`
- `fix(auth): resolve login bug (#124)`
- `docs(readme): update installation guide (#125)`
- `test(auth): add unit tests for login (#127)`

### Issues

```
🎯 TITRE_COURT_ET_CLAIR_AVEC_VERBE_ACTION
```

**Exemples** :
- ✅ `Add dark mode toggle to settings`
- ✅ `Fix authentication bug in login flow`
- ❌ `Dark mode` (trop vague)
- ❌ `Bug in the system` (pas assez spécifique)

---

## 🔀 Multi-Session Support

### Reprendre le Contexte du Projet

À chaque nouvelle session, tu peux charger le contexte :

```bash
# 1. Afficher l'état du setup
cat .setup/.setup-state.json

# 2. Voir les issues en cours
gh issue list --label "status:in-progress" --json number,title,body

# 3. Voir les PRs en review
gh pr list --state open --json number,title,author

# 4. Lire CLAUDE.md pour les conventions
cat CLAUDE.md
```

### Sauvegarder l'État du Travail

Quand tu ouvres une PR :
```bash
# L'état est sauvegardé dans:
# - Issue #123 (description + commentaires)
# - PR #456 (description + changements)
# - Branch feat/123-... (code)
```

Une autre session LLM peut reprendre :
```bash
# Voir le travail en cours
gh pr view 456
gh issue view 123
```

---

## 💡 Bonnes Pratiques

### Issues Atomiques

✅ **Bon** : "Add dark mode toggle to settings"
❌ **Mauvais** : "Implement entire theme system"

### Estimer l'Effort

- **1-2 points** : < 2 heures
- **3 points** : 1 jour
- **5-8 points** : 2-3 jours

Si > 8 points → découper en plusieurs issues

### Toujours Référencer les Issues

```bash
# Dans les commits
git commit -m "feat: add toggle (#123)"

# Dans les PRs
gh pr create --body "Closes #123"

# Dans les commentaires
gh issue comment 123 --body "Related to #124, #125"
```

### Synchroniser le Board

Chaque soir :
```bash
# Fermer les issues sans activité depuis 7 jours
gh issue list --json number,updatedAt,title \
  --jq '.[] | select(.updatedAt < now - 604800) | .number'
```

---

## 🚨 Gestion des Urgences

### Bug Critique en Production

```bash
# 1. Créer issue ASAP
gh issue create \
  --title "CRITICAL: [Description]" \
  --label "type:bug,priority:high,status:in-progress"

# 2. Branche hotfix
git checkout -b fix/ISSUE_NUM-urgent-description
git push -u origin fix/ISSUE_NUM-urgent-description

# 3. Fix + tests
# ... code ...
git commit -m "fix: critical issue (#XXX)"

# 4. PR d'urgence
gh pr create --title "CRITICAL FIX: [Description]" \
  --label "priority:high"

# 5. Merger après tests
gh pr merge --squash --delete-branch
```

---

## 📊 Métriques à Tracker

### Vélocité (Issues Complétées par Semaine)

```bash
# Chercher les issues fermées depuis 7 jours
gh issue list --state closed --json closedAt,title \
  --jq '.[] | select(.closedAt > "2025-11-06T00:00:00Z") | .title'
```

### Lead Time (Temps jusqu'au Merge)

Objectif : < 3 jours pour features, < 1 jour pour bugs

### Code Review Time

Objectif : < 24h avant premier commentaire

---

## 🔐 Secrets & Configuration

### Requis (optionnel)

```bash
# GitHub CLI (déjà instancié)
gh auth status

# Variables disponibles dans workflows
echo $GH_TOKEN         # GitHub Token
echo $CLAUDE_API_KEY   # Pour AI review (optionnel)
```

### .env (gitignored)

```bash
# Setup avec:
cp .env.example .env
# Puis éditer si besoin
```

---

## 🎓 Exemples Complets

### Exemple 1: Ajouter une Feature de A à Z

```bash
# 1. Créer issue
ISSUE=$(gh issue create --title "Add API rate limiting" \
  --label "type:feature,priority:medium" --json number -q '.number')

# 2. Démarrer
gh issue edit $ISSUE --add-label "auto-branch"
git fetch origin
git checkout feat/$ISSUE-add-api-rate-limiting

# 3. Développer
# ... code ...

# 4. Commit
git commit -m "feat: add API rate limiting (#$ISSUE)"
git push

# 5. PR
gh pr create --title "feat: Add API rate limiting (#$ISSUE)" \
  --body "Closes #$ISSUE"

# 6. Merger (après review)
gh pr merge --squash --delete-branch
```

### Exemple 2: Planifier un Sprint

```bash
# 1. Lister les issues "Ready"
gh issue list --label "status:ready" \
  --json number,title,labels

# 2. Assigner au sprint (ajouter label)
gh issue edit 123 --add-label "sprint:nov-13"
gh issue edit 124 --add-label "sprint:nov-13"
gh issue edit 125 --add-label "sprint:nov-13"

# 3. Assigner à des développeurs
gh issue edit 123 --assignee "@alice"
gh issue edit 124 --assignee "@bob"
gh issue edit 125 --assignee "@me"
```

---

## ❓ Commandes Utiles (Cheatsheet)

```bash
# Issues
gh issue create --title "..." --label "type:feature"
gh issue list --label "status:in-progress"
gh issue edit 123 --add-label "priority:high"
gh issue comment 123 --body "..."
gh issue view 123

# PRs
gh pr create --title "..." --base main
gh pr list --state open
gh pr view 456
gh pr checks 456
gh pr merge 456 --squash --delete-branch

# Project Board (via labels)
gh issue edit 123 --add-label "status:in-review"
gh issue edit 123 --add-label "status:done"

# Utility
gh repo view
gh auth status
gh label list
```

---

## 🚀 Conseils pour les LLMs

1. **Toujours** référencer l'issue dans les commits et PRs
2. **Toujours** utiliser les conventions de nommage (branches, commits)
3. **Toujours** vérifier l'état du board avant d'ouvrir une PR
4. **Toujours** tester idempotence (peut-on relancer le script setup ?)
5. **Toujours** nettoyer les branches mergées
6. **Checkpoint** régulièrement : faire des commits logiques
7. **Explain** dans les PR body : pourquoi ce changement

---

## 📚 Documentation Complète

- **README.md** - Quick start du template
- **template/README.md** - Architecture du template
- **template/docs/WORKFLOWS.md** - Détail des automations
- **template/docs/TROUBLESHOOTING.md** - Dépannage
- **template/docs/ADVANCED.md** - Personnalisation

---

**Créé pour permettre aux LLMs de gérer vos projets en toute autonomie, en mode multi-session persistent.**

🤖 Tu as maintenant tout pour gérer ce projet efficacement !
