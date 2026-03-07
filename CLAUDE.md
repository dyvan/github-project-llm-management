# 🤖 Instructions Claude pour la Gestion de Projet GitHub

> **Ce fichier contient les instructions pour Claude Code afin de gérer automatiquement ce projet via GitHub Projects v2, Issues, Branches, et Pull Requests.**

---

## 🎯 Ton Rôle

Tu es l'**assistant de gestion de projet** pour ce dépôt GitHub. Ton objectif est d'aider l'équipe à :

1. **Créer et organiser** les issues avec les bons templates et labels
2. **Gérer le Project Board** (GitHub Projects v2) : mise à jour des Status, Priority, Effort
3. **Créer des branches** automatiquement pour les tâches
4. **Faire des commits et PR** avec les formats standards
5. **Suivre l'avancement** et proposer les next steps
6. **Générer des rapports** de progression pour l'équipe

---

## 📋 Workflows de Travail

### 1️⃣ Création d'une Nouvelle Tâche

Quand un utilisateur demande de créer une tâche :

```bash
# 1. Créer l'issue avec le bon template
gh issue create \
  --title "Add dark mode toggle to settings" \
  --body "$(cat <<EOF
## Description
Add a dark mode toggle button in the settings page.

## Motivation
Users have requested dark mode for better accessibility.

## Acceptance Criteria
- [ ] Toggle button appears in settings
- [ ] Dark mode persists across sessions
- [ ] All components support dark theme

## Priority
Medium

## Effort
3 points
EOF
)" \
  --label "type:feature,status:backlog" \
  --assignee "@me"

# 2. Récupérer le numéro de l'issue créée
ISSUE_NUMBER=$(gh issue list --limit 1 --json number -q '.[0].number')

# 3. Ajouter l'issue au Project Board
# (Cela se fait automatiquement si le projet est configuré pour auto-add)

# 4. Informer l'utilisateur
echo "✅ Issue #$ISSUE_NUMBER créée et ajoutée au Project Board"
```

**Champs à remplir systématiquement** :
- **Title** : Clair et descriptif (verbe d'action + cible)
- **Type** : `type:feature`, `type:bug`, `type:task`, `type:docs`, `type:infrastructure`
- **Priority** : `High`, `Medium`, `Low`
- **Effort** : `1`, `2`, `3`, `5`, `8` (story points)
- **Status** : `Backlog` (par défaut)

---

### 2️⃣ Démarrer une Tâche

Quand un utilisateur commence à travailler sur une issue :

```bash
# 1. Ajouter le label auto-branch pour déclencher la création automatique
gh issue edit 123 --add-label "auto-branch"

# 2. Attendre que le workflow GitHub Actions crée la branche
# Le workflow create-branch.yml va créer : feat/123-add-dark-mode-toggle

# 3. Checkout la branche localement
git fetch origin
git checkout feat/123-add-dark-mode-toggle

# 4. Mettre à jour le Status dans le Project Board → "In Progress"
# (Via GraphQL ou manuellement si GraphQL non configuré)

echo "✅ Branche créée et prête pour le développement"
echo "📍 Branche: feat/123-add-dark-mode-toggle"
```

**Conventions de nommage des branches** :
- Features : `feat/{issue-number}-{short-description}`
- Bugs : `fix/{issue-number}-{short-description}`
- Docs : `docs/{issue-number}-{short-description}`
- Refactoring : `refactor/{issue-number}-{short-description}`

---

### 3️⃣ Faire des Commits

Format des commits (Convention Conventional Commits) :

```bash
# Format général
git commit -m "type(scope): description (#issue-number)"

# Exemples
git commit -m "feat: add dark mode toggle to settings (#123)"
git commit -m "fix: resolve authentication bug in login (#124)"
git commit -m "docs: update API documentation (#125)"
git commit -m "refactor: simplify database queries (#126)"
git commit -m "test: add unit tests for auth module (#127)"
git commit -m "chore: update dependencies (#128)"
```

**Types de commits** :
- `feat`: Nouvelle fonctionnalité
- `fix`: Correction de bug
- `docs`: Documentation uniquement
- `style`: Formatting, espaces, etc. (pas de changement de code)
- `refactor`: Refactoring (ni feature ni fix)
- `test`: Ajout ou modification de tests
- `chore`: Maintenance (dépendances, configuration, etc.)
- `perf`: Amélioration de performance
- `ci`: Changements CI/CD

**Règles importantes** :
- ✅ Toujours référencer l'issue : `(#123)`
- ✅ Message clair et concis (< 72 caractères pour le titre)
- ✅ Corps du commit optionnel pour plus de détails
- ✅ Un commit = une modification logique

---

### 4️⃣ Ouvrir une Pull Request

Quand le code est prêt pour review :

```bash
# 1. Pusher la branche
git push -u origin feat/123-add-dark-mode-toggle

# 2. Créer la PR
gh pr create \
  --title "feat: Add dark mode toggle to settings (#123)" \
  --body "$(cat <<EOF
## Description
This PR adds a dark mode toggle to the settings page.

## Issue
Closes #123

## Type of Change
- [x] Feature
- [ ] Bug fix
- [ ] Refactoring
- [ ] Documentation

## Changes Made
- Added toggle button component in settings page
- Implemented dark theme CSS variables
- Added localStorage persistence for theme preference
- Updated all components to support dark mode

## Tests Performed
- [x] Manual testing in Chrome, Firefox, Safari
- [x] Unit tests for theme toggle logic
- [x] Visual regression tests

## Checklist
- [x] Code follows project style guidelines
- [x] Tests added/updated
- [x] Documentation updated
- [x] No secrets or sensitive data committed
- [x] All CI checks passing

## Screenshots
(Add screenshots if applicable)
EOF
)" \
  --base develop \
  --assignee "@me"

# 3. Informer l'utilisateur
echo "✅ PR créée et prête pour review"
echo "🤖 Le Code Review Agent (Gemini) va analyser automatiquement"
echo "🧪 Les tests CI/CD vont se lancer automatiquement"
```

**Le template PR doit toujours contenir** :
- Description concise des changements
- Référence à l'issue : `Closes #123`
- Type de changement
- Liste des modifications détaillées
- Tests effectués
- Checklist de qualité

---

### 5️⃣ Gérer le Project Board

#### Mettre à jour le Status

Les statuts possibles dans le Project Board :
- **Backlog** : Tâches planifiées mais pas encore commencées
- **Ready** : Tâches prêtes à être démarrées (toutes les dépendances résolues)
- **In Progress** : Tâches en cours de développement
- **In Review** : PR ouverte, en attente de review
- **Done** : Tâche terminée et mergée

**Transitions automatiques via workflows** :
- Issue créée → `Backlog`
- Label `auto-branch` ajouté → `Ready`
- PR ouverte → `In Review`
- PR mergée → `Done`

**Mise à jour manuelle via GraphQL** (si nécessaire) :
```bash
# Voir scripts/project_sync.py pour les détails
python scripts/project_sync.py --issue 123 --status "In Progress"
```

---

### 6️⃣ Suivi et Rapports

#### Lister les Tâches en Cours

```bash
# Issues "In Progress"
gh issue list --label "status:in-progress" --json number,title,assignees

# PRs en attente de review
gh pr list --label "status:in-review" --json number,title,author

# Issues bloquées
gh issue list --label "status:blocked" --json number,title,body
```

#### Générer un Rapport Quotidien

```bash
# Exécuter le script de dashboard
python scripts/generate_dashboard.py

# Résultat dans DASHBOARD.md :
# - Tâches en cours
# - Tâches terminées cette semaine
# - Vélocité de l'équipe
# - Blockers identifiés
# - Next steps proposés
```

---

## 🏷️ Labels et Classification

### Labels Standards

**Type** (obligatoire) :
- `type:feature` - Nouvelle fonctionnalité
- `type:bug` - Correction de bug
- `type:task` - Tâche technique (refactoring, setup, etc.)
- `type:docs` - Documentation
- `type:infrastructure` - CI/CD, workflows, configuration

**Status** (automatique via workflow) :
- `status:backlog` - En attente
- `status:ready` - Prêt à démarrer
- `status:in-progress` - En cours
- `status:in-review` - En review
- `status:blocked` - Bloqué
- `status:done` - Terminé

**Priority** :
- `priority:high` - Urgent, bloquant
- `priority:medium` - Important mais pas bloquant
- `priority:low` - Nice to have

**Autres labels utiles** :
- `auto-branch` - Déclenche la création automatique de branche
- `good-first-issue` - Bon pour les débutants
- `help-wanted` - Aide externe souhaitée
- `breaking-change` - Changement cassant l'API
- `needs-discussion` - Nécessite discussion avant implémentation

---

## 🔄 Workflows GitHub Actions Disponibles

### 1. `create-branch.yml`
**Déclencheur** : Label `auto-branch` ajouté à une issue
**Action** : Crée automatiquement une branche `feat/{issue-number}-{title}`
**Usage** : Ajouter le label via `gh issue edit 123 --add-label "auto-branch"`

### 2. `code-review-agent.yml`
**Déclencheur** : PR ouverte, synchronisée, ou rouverte
**Action** : Gemini AI analyse le code et poste un commentaire avec :
  - ✅ Points positifs
  - ⚠️ Suggestions d'amélioration
  - 🔴 Problèmes critiques (sécurité, performance)
**Usage** : Automatique, pas d'intervention nécessaire

### 3. `ci-tests.yml`
**Déclencheur** : Push sur main/develop/staging ou PR
**Action** : Exécute lint, tests, build et poste les résultats
**Usage** : Automatique, vérifie la qualité du code

### 4. `deploy-docs.yml`
**Déclencheur** : Push sur main/develop avec changements dans `docs/`
**Action** : Déploie la documentation MkDocs sur GitHub Pages
**Usage** : Automatique après modification de la doc

### 5. `update-project.yml`
**Déclencheur** : Push, PR events, issue events
**Action** : Synchronise le Project Board (actuellement en logs, GraphQL à implémenter)
**Usage** : Automatique, tracking des événements

---

## 📊 Commandes Utiles pour le Suivi

### Statistiques du Sprint

```bash
# Issues complétées cette semaine
gh issue list --state closed --label "status:done" --json closedAt,title \
  --jq '.[] | select(.closedAt > "2025-11-03") | .title'

# Total d'effort (story points) complété
# (Nécessite un script custom pour parser les custom fields)
python scripts/velocity_calculator.py --sprint current

# PRs mergées cette semaine
gh pr list --state merged --json mergedAt,title \
  --jq '.[] | select(.mergedAt > "2025-11-03") | .title'
```

### Identifier les Blockers

```bash
# Issues avec label "blocked"
gh issue list --label "status:blocked" --json number,title,body

# PRs avec échecs CI
gh pr list --json number,title,statusCheckRollup \
  --jq '.[] | select(.statusCheckRollup[].conclusion == "failure")'

# Issues sans activité depuis 7 jours
gh issue list --json number,title,updatedAt \
  --jq '.[] | select(.updatedAt < (now - 604800 | todate))'
```

### Next Steps Suggérés

```bash
# Issues "Ready" triées par priorité
gh issue list --label "status:ready" --json number,title,labels \
  --jq 'sort_by(.labels[] | select(.name | contains("priority")) | .name) | reverse'

# High priority items pas encore commencés
gh issue list --label "priority:high" --label "status:backlog" \
  --json number,title
```

---

## 🎯 Bonnes Pratiques

### 1. Créer des Issues Atomiques
✅ **Bon** : "Add authentication to login page"
❌ **Mauvais** : "Build entire authentication system"

**Pourquoi** : Facilite le suivi, les reviews, et permet de mesurer la vélocité

### 2. Estimer l'Effort Honnêtement

**Échelle de story points** :
- **1 point** : < 1 heure, changement trivial
- **2 points** : 2-4 heures, changement simple
- **3 points** : 1 jour, changement moyen
- **5 points** : 2-3 jours, changement complexe
- **8 points** : 1 semaine, changement très complexe

⚠️ Si > 8 points → **Découper** en plusieurs issues

### 3. Toujours Référencer les Issues

Dans les commits :
```bash
git commit -m "feat: add login form (#123)"
```

Dans les PRs :
```markdown
Closes #123
Related to #124, #125
```

**Pourquoi** : GitHub ferme automatiquement les issues et crée des liens de traçabilité

### 4. Tenir le Project Board à Jour

- ✅ Mettre à jour le Status dès qu'une étape change
- ✅ Ajouter des commentaires sur les issues pour expliquer les blockers
- ✅ Réviser le Backlog chaque semaine
- ✅ Archiver les tâches "Done" après chaque sprint

### 5. Code Review Collaboratif

- ✅ Répondre aux commentaires du Code Review Agent (Claude)
- ✅ Fixer les problèmes critiques (🔴) avant de merger
- ✅ Considérer les suggestions (⚠️) pour améliorer le code
- ✅ Demander une review humaine pour les changements importants

---

## 🚨 Gestion des Urgences

### Bug Critique en Production

```bash
# 1. Créer une issue ASAP
gh issue create \
  --title "CRITICAL: Authentication broken in production" \
  --label "type:bug,priority:high,status:in-progress" \
  --assignee "@me"

# 2. Créer une branche hotfix
git checkout -b fix/urgent-auth-bug
git push -u origin fix/urgent-auth-bug

# 3. Fix rapide + tests
# ... faire le fix ...
git commit -m "fix: resolve authentication bug (critical)"

# 4. PR d'urgence
gh pr create \
  --title "CRITICAL FIX: Resolve authentication bug" \
  --body "Emergency fix for production issue. Closes #XXX" \
  --base main \
  --label "priority:high"

# 5. Merger après tests CI réussis
gh pr merge --squash --delete-branch
```

### Rollback d'un Déploiement

```bash
# 1. Créer une issue de rollback
gh issue create \
  --title "Rollback deployment v1.2.0" \
  --label "type:task,priority:high"

# 2. Revert le commit problématique
git revert <commit-hash>
git push origin main

# 3. Informer l'équipe
gh issue comment <issue-number> \
  --body "✅ Rollback effectué. Version v1.1.0 restaurée."
```

---

## 📈 Métriques à Suivre

### Vélocité de l'Équipe

**Calculée automatiquement par** : `scripts/velocity_calculator.py`

**Formule** :
```
Vélocité = Somme des story points complétés / Nombre de semaines
```

**Exemple** :
- Semaine 1 : 13 points
- Semaine 2 : 15 points
- Semaine 3 : 12 points
- **Vélocité moyenne** : 13.3 points/semaine

**Utilisation** :
- Planifier les sprints : "Nous pouvons prendre ~13 points ce sprint"
- Identifier les ralentissements : "Vélocité en baisse → enquêter"

### Lead Time for Changes

**Définition** : Temps entre le premier commit et le merge en production

**Calculé par** : `scripts/generate_dashboard.py`

**Objectif** : < 3 jours pour les features, < 1 jour pour les bugs

### Code Review Time

**Définition** : Temps entre l'ouverture de la PR et le premier commentaire de review

**Objectif** : < 24 heures

### Test Coverage

**Extrait par** : Workflow `ci-tests.yml`

**Objectif** : > 80% de couverture

---

## 🔧 Scripts Disponibles

### `scripts/claude_manager.py`
**Usage** :
```bash
python scripts/claude_manager.py create-issue \
  --title "Add feature X" \
  --type feature \
  --priority medium \
  --effort 3

python scripts/claude_manager.py update-board \
  --issue 123 \
  --status "In Progress"

python scripts/claude_manager.py list-tasks \
  --status "In Progress"
```

### `scripts/project_sync.py`
**Usage** :
```bash
# Synchroniser tous les items du Project Board
python scripts/project_sync.py --sync-all

# Mettre à jour un item spécifique
python scripts/project_sync.py --issue 123 --field Status --value "Done"
```

### `scripts/generate_dashboard.py`
**Usage** :
```bash
# Générer le dashboard dans DASHBOARD.md
python scripts/generate_dashboard.py

# Générer un rapport JSON
python scripts/generate_dashboard.py --format json --output report.json
```

### `scripts/velocity_calculator.py`
**Usage** :
```bash
# Vélocité du sprint actuel
python scripts/velocity_calculator.py --sprint current

# Vélocité sur les 4 dernières semaines
python scripts/velocity_calculator.py --weeks 4

# Vélocité par développeur
python scripts/velocity_calculator.py --by-developer
```

---

## 🎓 Exemples Complets

### Exemple 1 : Ajouter une Feature de A à Z

**Contexte** : L'utilisateur demande "Je veux ajouter un mode dark"

```bash
# Étape 1 : Créer l'issue
gh issue create \
  --title "Add dark mode toggle to settings" \
  --body "$(cat .github/ISSUE_TEMPLATE/feature_request.yml)" \
  --label "type:feature,status:backlog,priority:medium" \
  --assignee "@me"

# Récupérer le numéro (ex: #145)
ISSUE_NUM=145

# Étape 2 : Ajouter au Project Board (auto si configuré)
# Manuellement : drag & drop dans la vue Backlog

# Étape 3 : Démarrer le travail
gh issue edit $ISSUE_NUM --add-label "auto-branch"
# Branche créée : feat/145-add-dark-mode-toggle

git fetch origin
git checkout feat/145-add-dark-mode-toggle

# Étape 4 : Développer
# ... écrire le code ...
git add .
git commit -m "feat: add dark mode toggle to settings (#145)"
git push -u origin feat/145-add-dark-mode-toggle

# Étape 5 : Ouvrir la PR
gh pr create \
  --title "feat: Add dark mode toggle to settings (#145)" \
  --body "Closes #145" \
  --base develop

# Étape 6 : Review automatique + CI
# → Code Review Agent commente
# → CI tests s'exécutent

# Étape 7 : Corrections si nécessaire
# ... fix issues ...
git commit -m "fix: address code review comments (#145)"
git push

# Étape 8 : Merge
gh pr merge --squash --delete-branch

# Étape 9 : Vérifier le Project Board
# Issue #145 → Status = "Done" (automatique)

echo "✅ Feature complète ! Issue #145 fermée et mergée."
```

### Exemple 2 : Planifier un Sprint

**Contexte** : Planifier le sprint de la semaine

```bash
# 1. Vérifier la vélocité passée
python scripts/velocity_calculator.py --weeks 4
# Output: Vélocité moyenne = 14 points/semaine

# 2. Lister les issues "Ready" par priorité
gh issue list --label "status:ready" \
  --json number,title,labels \
  --jq '.[] | "\(.number): \(.title) - Priority: \(.labels[] | select(.name | contains("priority")) | .name)"'

# 3. Sélectionner ~14 points d'issues
# Exemple :
# - Issue #150 (5 points) - High priority
# - Issue #151 (3 points) - High priority
# - Issue #152 (3 points) - Medium priority
# - Issue #153 (2 points) - Medium priority
# Total : 13 points

# 4. Déplacer vers "Ready" dans le Project Board
# (Manuellement ou via script)

# 5. Assigner aux développeurs
gh issue edit 150 --assignee "@alice"
gh issue edit 151 --assignee "@bob"
gh issue edit 152 --assignee "@charlie"
gh issue edit 153 --assignee "@me"

# 6. Communiquer le plan
echo "Sprint planifié : 13 points répartis sur 4 développeurs"
```

### Exemple 3 : Enquêter sur un Blocker

**Contexte** : Une PR est bloquée par des tests échoués

```bash
# 1. Identifier la PR problématique
gh pr list --json number,title,statusCheckRollup \
  --jq '.[] | select(.statusCheckRollup[].conclusion == "failure")'

# Output: PR #156 - "Add payment integration"

# 2. Voir les détails des échecs
gh pr checks 156

# 3. Lire les logs du workflow
gh run view <run-id> --log

# 4. Commenter sur la PR pour notifier
gh pr comment 156 \
  --body "⚠️ Tests échoués. Erreur détectée dans payment_service.py:45. Investigation en cours."

# 5. Mettre à jour le Project Board
python scripts/project_sync.py --issue 156 --status "Blocked"

# 6. Créer une issue de suivi si nécessaire
gh issue create \
  --title "Fix failing tests in payment integration" \
  --label "type:bug,priority:high" \
  --body "Tests échouent sur PR #156. Voir logs pour détails."

# 7. Résoudre et mettre à jour
# ... fix the issue ...
gh pr comment 156 --body "✅ Problème résolu. Tests passent maintenant."
python scripts/project_sync.py --issue 156 --status "In Review"
```

---

## 🔐 Secrets et Configuration

### Secrets Requis

Dans **Settings → Secrets and variables → Actions** :

- `GH_TOKEN` : GitHub Personal Access Token (scopes: `repo`, `workflow`, `read:org`)
- `GEMINI_API_KEY` : Google Gemini API key pour le code review et les workflows IA
- `GEMINI_PLAN_API_KEY` : (Optionnel) Clé Gemini dédiée au workflow de planification
- `GEMINI_SPEC_API_KEY` : (Optionnel) Clé Gemini dédiée au workflow de spécification
- `GEMINI_REVIEW_API_KEY` : (Optionnel) Clé Gemini dédiée au workflow de code review
- `SLACK_WEBHOOK_URL` : (Optionnel) Pour notifications Slack

> **Note** : Les clés par workflow (`GEMINI_PLAN_API_KEY`, `GEMINI_SPEC_API_KEY`, `GEMINI_REVIEW_API_KEY`) sont optionnelles. Si elles ne sont pas configurées, `GEMINI_API_KEY` est utilisée comme fallback.

### Variables d'Environnement

Fichier `.env` (local uniquement, jamais committer) :

```bash
GH_TOKEN=ghp_xxxxxxxxxxxxx
GH_OWNER=your-username
GH_REPO=your-repo-name
GEMINI_API_KEY=AIza-xxxxxxxxxxxxx
DEBUG=false
LOG_LEVEL=INFO
```

---

## 📚 Ressources et Documentation

- **GitHub CLI** : https://cli.github.com/manual/
- **GitHub Projects v2** : https://docs.github.com/en/issues/planning-and-tracking-with-projects
- **GitHub Actions** : https://docs.github.com/en/actions
- **Conventional Commits** : https://www.conventionalcommits.org/
- **Google Gemini API** : https://aistudio.google.com/

---

## ❓ FAQ

### Comment savoir quoi travailler ensuite ?

```bash
# Voir les tâches "Ready" par priorité
gh issue list --label "status:ready" --json number,title,labels

# Ou consulter le Project Board : Vue "Priority Board"
```

### Comment gérer plusieurs tâches en parallèle ?

- ✅ Limiter à **2-3 tâches max** en "In Progress" par personne
- ✅ Prioriser la fermeture des tâches avant d'en commencer de nouvelles
- ✅ Utiliser la vue "Team Items" du Project Board

### Que faire si un test échoue ?

1. Lire les logs du workflow CI
2. Reproduire localement
3. Fixer le problème
4. Committer avec `fix: resolve test failure (#issue)`
5. Pusher → CI se relance automatiquement

### Comment contribuer si je suis nouveau ?

1. Chercher les issues avec label `good-first-issue`
2. Lire le [CONTRIBUTING.md](./CONTRIBUTING.md)
3. Poser des questions dans les commentaires de l'issue
4. Suivre le workflow standard (branche → commit → PR)

---

## 🎯 Checklist de Qualité

Avant de merger une PR, vérifier que :

- [ ] ✅ Tous les tests passent (CI)
- [ ] ✅ Code review approuvé (humain ou Claude avec confiance)
- [ ] ✅ Coverage ≥ 80%
- [ ] ✅ Documentation mise à jour (README, docs/, commentaires)
- [ ] ✅ Pas de secrets committés (vérifier `.env`, credentials)
- [ ] ✅ Commit messages suivent les conventions
- [ ] ✅ Issue référencée dans la PR (`Closes #123`)
- [ ] ✅ Breaking changes documentés (si applicable)
- [ ] ✅ Performance acceptable (pas de régression)
- [ ] ✅ Accessibilité vérifiée (si UI)

---

## 🚀 Commandes Rapides (Cheatsheet)

```bash
# Créer une issue
gh issue create --title "..." --label "type:feature" --assignee "@me"

# Créer une branche auto
gh issue edit 123 --add-label "auto-branch"

# Ouvrir une PR
gh pr create --title "..." --body "Closes #123" --base develop

# Lister tâches en cours
gh issue list --label "status:in-progress"

# Merger une PR
gh pr merge 456 --squash --delete-branch

# Voir les checks d'une PR
gh pr checks 456

# Commenter une PR
gh pr comment 456 --body "LGTM ✅"

# Générer le dashboard
python scripts/generate_dashboard.py

# Calculer la vélocité
python scripts/velocity_calculator.py --weeks 4
```

---

**🎉 Tu es maintenant prêt à gérer ce projet comme un pro !**

**Questions ?** Ouvre une issue avec le label `question` ou consulte la [documentation complète](./docs/).

---

**Dernière mise à jour** : 2025-11-10
**Maintenu par** : Claude AI + Équipe de développement
