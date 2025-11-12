# 🔧 Scripts & Automation - Référence complète

Documentation de tous les scripts d'automation du template.

---

## 📜 Scripts principaux

### 1. `setup-project.sh`

**Rôle** : Script de setup initial pour configurer un nouveau projet

**Utilisation** :
```bash
./setup-project.sh
```

**Ce qu'il fait** :
1. ✅ Vérifie les prérequis (gh, python, jq)
2. ✅ Détecte le repository GitHub courant
3. ✅ Crée tous les labels nécessaires
4. ✅ Crée un GitHub Project v2
5. ✅ Configure le workflow de base

**Labels créés** :
- **Type** : `type:feature`, `type:bug`, `type:task`, `type:docs`, `type:infrastructure`
- **Priority** : `priority:high`, `priority:medium`, `priority:low`
- **Status** : `status:backlog`, `status:ready`, `status:in-progress`, `status:blocked`, `status:done`
- **Special** : `auto-branch`, `good-first-issue`, `help-wanted`

**Arguments** : Aucun (interactif)

**Prérequis** :
- GitHub CLI authentifié
- Permissions d'admin sur le repository

**Sortie** :
```
🚀 GitHub Project LLM Management - Setup Script
================================================

✅ Prerequisites check passed
Repository: username/project-name
✅ Labels configured
✅ Project created: #1
```

---

### 2. `scripts/setup_project_fields.py`

**Rôle** : Crée automatiquement les champs custom du Project Board via GraphQL

**Utilisation** :
```bash
python3 scripts/setup_project_fields.py \
  --project-number 1 \
  --owner YOUR_USERNAME
```

**Arguments** :
- `--project-number` : Numéro du projet (visible dans l'URL)
- `--owner` : Propriétaire du projet (username ou organisation)
- `--project-id` : (Optionnel) ID GraphQL du projet (alternative à --project-number)

**Ce qu'il fait** :
1. ✅ Cherche le projet par numéro
2. ✅ Vérifie les champs existants
3. ✅ Crée les champs manquants :
   - **Status** (Single Select) : Backlog, Ready, In Progress, In Review, Blocked, Done
   - **Priority** (Single Select) : Low, Medium, High
   - **Effort** (Single Select) : 1, 2, 3, 5, 8
   - **Type** (Single Select) : Feature, Bug, Task, Docs, Infrastructure
   - **Target Version** (Text)

**Variables d'environnement** :
- `GH_TOKEN` ou `GITHUB_TOKEN` : Token GitHub avec scope `project`

**Sortie** :
```
🔍 Checking existing fields...
📋 Creating custom fields...
  ✅ Created field: Status
  ✅ Created field: Priority
  ⏭️  Field 'Effort' already exists, skipping...
✅ All fields configured!
```

**Gestion d'erreur** :
- Si le projet n'existe pas → Erreur explicite
- Si le champ existe déjà → Skip (pas de doublon)
- Si le token n'a pas le bon scope → Erreur explicite

---

### 3. `scripts/validate_setup.sh`

**Rôle** : Valide que le template est correctement configuré

**Utilisation** :
```bash
./scripts/validate_setup.sh
```

**Ce qu'il vérifie** :
1. ✅ **Prérequis** : gh, python3, git installés
2. ✅ **Repository** : Dans un repo git avec remote GitHub
3. ✅ **Authentification** : GitHub CLI authentifié
4. ✅ **Secrets** : GH_TOKEN et CLAUDE_API_KEY configurés
5. ✅ **Labels** : Tous les labels requis existent
6. ✅ **Project** : Au moins un projet existe
7. ✅ **Workflows** : Tous les workflows sont présents
8. ✅ **Dépendances** : Packages Python installés

**Sortie (succès)** :
```
🔍 GitHub Project Template - Setup Validation
==============================================

[1/8] Checking prerequisites...
  ✅ GitHub CLI (gh) installed
  ✅ Python 3 installed (3.11.5)
  ✅ Git installed

[2/8] Checking repository context...
  ✅ Inside a Git repository
  ✅ Repository: username/project-name

...

==============================================
✅ All checks passed! Template is ready to use.
```

**Sortie (erreurs)** :
```
❌ Setup incomplete: 2 error(s), 3 warning(s).

Please fix the errors above before using this template.
```

**Codes de sortie** :
- `0` : Tout OK
- `1` : Erreurs trouvées

---

### 4. `scripts/project_sync.py`

**Rôle** : Synchronise les issues/PRs avec le Project Board via GraphQL

**Utilisation** :
```bash
# Synchroniser une issue
python3 scripts/project_sync.py \
  --issue 123 \
  --status "In Progress" \
  --priority "High"

# Synchroniser une PR
python3 scripts/project_sync.py \
  --pr 456 \
  --status "In Review"

# Spécifier un projet
python3 scripts/project_sync.py \
  --issue 123 \
  --project 1 \
  --status "Done"
```

**Arguments** :
- `--issue NUMBER` : Numéro de l'issue à synchroniser
- `--pr NUMBER` : Numéro de la PR à synchroniser
- `--project NUMBER` : (Optionnel) Numéro du projet
- `--status VALUE` : Définir le champ Status
- `--priority VALUE` : Définir le champ Priority
- `--effort VALUE` : Définir le champ Effort
- `--type VALUE` : Définir le champ Type
- `--version VALUE` : Définir le champ Target Version

**Variables d'environnement** :
- `GH_TOKEN` ou `GITHUB_TOKEN` : Token GitHub
- `GH_OWNER` : Propriétaire du repository
- `GH_REPO` : Nom du repository

**Comment ça marche** :
1. Récupère l'ID GraphQL de l'issue/PR
2. Trouve le project (ou utilise le premier trouvé)
3. Ajoute l'item au project (si pas déjà ajouté)
4. Met à jour les champs demandés

**Sortie** :
```
✅ Issue #123 synced successfully
```

**Utilisé par** :
- Workflow `update-project.yml` (automatiquement)
- Peut être appelé manuellement pour debug

---

## 🤖 Workflows GitHub Actions

### 1. `.github/workflows/update-project.yml`

**Rôle** : Synchronise automatiquement le Project Board avec les issues/PRs

**Déclencheurs** :
- Issue créée → Ajoute au Backlog
- Issue labellée → Met à jour Status/Priority/Type selon le label
- PR ouverte → Met à jour Status à "In Review"
- PR mergée → Met à jour Status à "Done"

**Exemple de mapping labels** :
```yaml
Label "auto-branch"       → Status: "Ready"
Label "status:in-progress" → Status: "In Progress"
Label "priority:high"      → Priority: "High"
Label "type:feature"       → Type: "Feature"
```

**Variables d'environnement définies** :
```yaml
env:
  GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  GH_OWNER: ${{ github.repository_owner }}
  GH_REPO: ${{ github.event.repository.name }}
```

---

### 2. `.github/workflows/create-branch.yml`

**Rôle** : Crée automatiquement une branche quand le label `auto-branch` est ajouté

**Déclencheur** :
- Issue labellée avec `auto-branch`

**Ce qu'il fait** :
1. Récupère le titre de l'issue
2. Crée un slug (ex: "Fix bug API" → "fix-bug-api")
3. Crée une branche `feat/{issue-number}-{slug}`
4. Poste un commentaire avec les instructions git

**Exemple** :
```
Issue #42 : "Add dark mode"
→ Branche créée : feat/42-add-dark-mode

Commentaire posté :
✅ Branch created: feat/42-add-dark-mode

Get started:
git fetch origin
git checkout feat/42-add-dark-mode
```

---

### 3. `.github/workflows/code-review-agent.yml`

**Rôle** : Analyse automatiquement les PRs avec Claude AI

**Déclencheur** :
- PR ouverte, mise à jour, ou réouverte

**Ce qu'il fait** :
1. Récupère le diff de la PR
2. Envoie à l'API Claude avec un prompt structuré
3. Génère une revue de code avec :
   - ✅ Points forts
   - ⚠️ Suggestions d'amélioration
   - 🔴 Problèmes critiques
4. Poste la revue en commentaire

**Mode fallback** :
Si `CLAUDE_API_KEY` n'est pas configuré, fonctionne en mode basique (checklist manuelle).

**Modèle utilisé** : `claude-3-5-sonnet-20241022`

---

### 4. `.github/workflows/ci-tests.yml`

**Rôle** : Exécute les tests et validations sur chaque PR

**Déclencheur** :
- Push sur main/develop/staging
- PR ouverte

**Étapes** :
1. ✅ Vérifier permissions des scripts
2. ✅ Valider la syntaxe YAML des workflows
3. ✅ Tester le setup script
4. ✅ Lancer les tests unitaires (pytest)
5. ✅ Vérifier la couverture de code

**Matrice de tests** :
- Python 3.11

---

## 📝 Fichiers de configuration

### `.github/project.yml`

Configuration centrale du projet :

```yaml
project:
  number: 1  # Numéro du projet
  name: "Project Backlog"
  auto_link: true  # Auto-ajouter issues au project

fields:
  status:
    options: ["Backlog", "Ready", "In Progress", ...]
    default: "Backlog"

automation:
  auto_branch:
    enabled: true
    label: "auto-branch"
```

**Utilisé par** : Tous les workflows pour connaître le projet cible

---

## 🔧 Utilisation avancée

### Debug : Synchroniser manuellement

```bash
# Forcer la synchronisation d'une issue
python3 scripts/project_sync.py --issue 123 --status "Backlog"

# Vérifier le résultat
gh project item-list 1 --owner YOUR_USERNAME
```

### Tester les workflows localement

```bash
# Installer act (GitHub Actions local runner)
brew install act  # macOS
# ou : https://github.com/nektos/act

# Tester le workflow CI
act -j test

# Tester le workflow update-project (simulation)
act issues -e test_event.json
```

---

## 💡 Tips & astuces

### Obtenir l'ID GraphQL d'un projet

```bash
gh api graphql -f query='
{
  user(login: "YOUR_USERNAME") {
    projectV2(number: 1) {
      id
      title
    }
  }
}'
```

### Lister tous les items d'un projet

```bash
gh project item-list 1 --owner YOUR_USERNAME --format json
```

### Vérifier les secrets configurés

```bash
gh secret list
```

---

## 🐛 Dépannage

**Erreur : "Project not found"**
- Vérifiez que `.github/project.yml` a le bon numéro
- Vérifiez que le projet existe : `gh project list --owner YOUR_USERNAME`

**Erreur : "GraphQL errors"**
- Vérifiez que `GH_TOKEN` a le scope `project`
- Recréez le token : https://github.com/settings/tokens

**Script ne s'exécute pas**
- Rendez-le exécutable : `chmod +x script.sh`

---

[⬅️ Retour à l'accueil](Home) | [Suivant : Workflows ➡️](Understanding-Workflows)
