# 📦 GitHub Project Management Template

Ce répertoire contient **tout ce qui est nécessaire** pour gérer un projet avec GitHub Projects v2, automatisations, et intégration LLM.

> **⚠️ Les utilisateurs ne doivent JAMAIS avoir besoin de toucher ces fichiers directement.**
> Tout se configure via `bash template-setup.sh` à la racine du projet.

---

## 📂 Structure

```
template/
├── .setup/                 # Setup et state management
│   ├── setup.sh           # Script d'orchestration principal (idempotent)
│   ├── .setup-state.json  # État du setup (gitignored)
│   ├── lib/               # Utilitaires partagés
│   │   ├── colors.sh
│   │   ├── state.sh
│   │   ├── validators.sh
│   │   └── github-api.sh
│   └── steps/             # Étapes modulables du setup
│       ├── 1-check-state.sh
│       ├── 2-check-prerequisites.sh
│       ├── 3-init-labels.sh
│       ├── 4-create-project.sh
│       ├── 5-link-workflows.sh
│       └── 6-finalize.sh
│
├── .github/               # Workflows & Templates GitHub
│   ├── workflows/         # GitHub Actions workflows
│   │   ├── create-branch.yml
│   │   ├── code-review-agent.yml
│   │   ├── ci-tests.yml
│   │   └── ...
│   ├── ISSUE_TEMPLATE/    # Issue templates
│   │   ├── bug.md
│   │   ├── feature.md
│   │   └── task.md
│   └── PULL_REQUEST_TEMPLATE.md
│
├── config/                # Fichiers de configuration
│   ├── labels.json        # Définition des labels
│   └── project-fields.json # Champs personnalisés du Project
│
├── scripts/               # Utilitaires optionnels
│   ├── setup_project_fields.py
│   ├── project_sync.py
│   ├── generate_dashboard.py
│   └── velocity_calculator.py
│
├── docs/                  # Documentation du template
│   ├── WORKFLOWS.md
│   ├── TROUBLESHOOTING.md
│   └── ADVANCED.md
│
└── README.md             # Ce fichier
```

---

## 🔧 Idempotence & State Management

### Comment ça fonctionne

Le script setup est **complètement idempotent**. À chaque run :

1. ✅ Vérifie l'état sauvegardé dans `.setup-state.json`
2. ✅ Saute les étapes déjà complétées
3. ✅ Met à jour uniquement ce qui manque
4. ✅ Peut être relancé en toute sécurité, même après succès

### Fichier d'état

```json
{
  "version": "1.0",
  "setup_started_at": "2025-11-13T10:30:00Z",
  "setup_completed_at": "2025-11-13T10:35:00Z",
  "steps": {
    "check_prerequisites": true,
    "init_labels": true,
    "create_project": true,
    "setup_fields": true,
    "link_workflows": true,
    "create_symlinks": true,
    "setup_complete": true
  },
  "configuration": {
    "repo_owner": "dyvan",
    "repo_name": "my-project",
    "project_number": 1
  },
  "errors": []
}
```

Ce fichier est **gitignored** et n'est créé que dans le user's repository, jamais dans le template.

---

## 🚀 Setup Flow

### 1. User Lance le Setup

```bash
cd mon-projet
bash template-setup.sh
```

### 2. Script Racine Valide les Prérequis

- ✅ GitHub CLI (gh) installé et authentifié
- ✅ Python 3.8+
- ✅ Git repository
- ✅ GitHub remote

### 3. Orchestre les Étapes (idempotent)

```bash
template/.setup/setup.sh
├── 1-check-state.sh              # Vérifie si setup est complète
├── 2-check-prerequisites.sh      # Valide gh, python, git
├── 3-init-labels.sh              # Crée les labels (saute si existent)
├── 4-create-project.sh           # Crée Project v2 (saute si existe)
├── 5-link-workflows.sh           # Crée symlinks vers template/.github/
└── 6-finalize.sh                 # Affiche résumé
```

### 4. Résultat Final

Dans le user's repo :

```
.github/
├── workflows/              → symlink vers template/.github/workflows
├── ISSUE_TEMPLATE/         → symlink vers template/.github/ISSUE_TEMPLATE
└── PULL_REQUEST_TEMPLATE.md → symlink vers template/.github/...

.setup/
└── .setup-state.json       # État du setup (gitignored)

CLAUDE.md                    # Instructions pour LLM
.env                         # Secrets & config (gitignored)
```

---

## 🤖 Intégration LLM (CLAUDE.md)

Le fichier `CLAUDE.md` à la racine du user's project contient :

1. **État du projet** : lu depuis `.setup-state.json`
2. **Conventions** : branches, commits, issues
3. **Labels standards** : avec descriptions
4. **Workflows disponibles** : avec déclencheurs
5. **Capacités du LLM** : quoi faire pour gérer le projet
6. **Exemples** : cas d'usage typiques

Le LLM peut ainsi :
- ✅ Lire l'état du projet
- ✅ Créer/updater des issues
- ✅ Faire des commits conventionnels
- ✅ Ouvrir des PRs avec bons templates
- ✅ Manager le board de manière multi-session

---

## 📝 Configuration

### labels.json

Définit les 17 labels standards :

- **Type** : `feature`, `bug`, `task`, `docs`, `infrastructure`
- **Priority** : `high`, `medium`, `low`
- **Status** : `backlog`, `ready`, `in-progress`, `in-review`, `blocked`, `done`
- **Utiles** : `good-first-issue`, `help-wanted`, `auto-branch`

### project-fields.json

Champs personnalisés du Project :

- **Status** : Backlog, Ready, In Progress, In Review, Done, Blocked
- **Priority** : High, Medium, Low
- **Effort** : 1, 2, 3, 5, 8 (story points)
- **Sprint** : texte libre (opcional)

---

## 🔗 Symlinks : Toujours à Jour

Les workflows et templates sont symlinkés vers `template/.github/` :

```bash
.github/workflows/          → template/.github/workflows
.github/ISSUE_TEMPLATE/     → template/.github/ISSUE_TEMPLATE
```

**Avantages** :
- ✅ Mise à jour du template = mise à jour automatique
- ✅ Zéro duplication
- ✅ Un seul endroit à maintenir
- ✅ Easy to override (remove symlink, create local version)

---

## 🛠️ Scripts Utilitaires

### setup_project_fields.py

Configure les champs personnalisés du Project v2 (via GraphQL) :

```bash
python3 scripts/setup_project_fields.py --project-number 1 --owner dyvan
```

### project_sync.py

Synchronise le Project Board avec les issues/PRs :

```bash
python3 scripts/project_sync.py --sync-all
```

### generate_dashboard.py

Génère un dashboard de progression :

```bash
python3 scripts/generate_dashboard.py --format json --output report.json
```

### velocity_calculator.py

Calcule la vélocité de l'équipe :

```bash
python3 scripts/velocity_calculator.py --weeks 4
```

---

## 📖 Documentation Supplémentaire

- **[WORKFLOWS.md](./docs/WORKFLOWS.md)** - Détail des automations
- **[TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)** - Dépannage
- **[ADVANCED.md](./docs/ADVANCED.md)** - Personnalisation

---

## ❓ Maintenance du Template

### Pour les contributeurs du template

Si vous améliorez le template :

1. ✅ Modifiez les fichiers dans `template/`
2. ✅ Testez avec `bash template-setup.sh --dry-run`
3. ✅ Relancez 2-3x pour tester idempotence
4. ✅ Committez vos changements
5. ✅ Créez une PR

### Points d'entrée

- **Root script** : `../template-setup.sh` (copy cette logique si besoin)
- **Main setup** : `.setup/setup.sh`
- **Steps** : `.setup/steps/*.sh` (ajouter des étapes ici)
- **Libraries** : `.setup/lib/*.sh` (utilitaires partagés)

---

## 🎯 Principes de Conception

### Simplicité pour l'Utilisateur

```bash
# C'est TOUT ce que l'utilisateur fait
bash template-setup.sh

# C'est tout.
```

### Complexité Caché dans le Template

- Setup modulaire et testable
- Idempotence garantie
- Logging détaillé
- État persistant

### LLM-First

- État queryable via `.setup-state.json`
- Conventions claires dans `CLAUDE.md`
- Capacités explicites listées
- Exemples fournis

---

**Cette structure permet un template professional-grade tout en restant simple pour les utilisateurs.**
