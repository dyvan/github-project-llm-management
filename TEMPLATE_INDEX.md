# 📑 Template Index & Quick Navigation

**Perdus dans la structure ?** Voici comment naviguer rapidement.

---

## 🎯 Par Cas d'Usage

### 👤 Je suis un utilisateur du template

**Démarrer un projet** :
1. Lire `README.md` (3 commandes)
2. Lancer `bash template-setup.sh`
3. ✅ Done ! Votre projet est configuré

**Gérer le projet** :
- Lire `CLAUDE.md` pour les conventions
- Utiliser GitHub CLI : `gh issue create`, `gh pr create`
- Consulter `template/README.md` pour dépannage

**Fichiers importants pour vous** :
- `README.md` → Quick start
- `CLAUDE.md` → Comment gérer le projet
- `.env.example` → Secrets/config
- `.setup/.setup-state.json` → État du projet

---

### 🤖 Je suis un LLM (Claude Code, etc.)

**Premiers pas** :
1. Lire `CLAUDE.md` → Instructions complètes
2. Lire `.setup/.setup-state.json` → État du projet
3. Utiliser `gh` CLI pour gérer le projet

**Capacités** :
- Créer/updater issues
- Créer branches avec naming standard
- Faire commits (Conventional Commits)
- Ouvrir PRs
- Manager le Project Board

**Fichiers clés pour vous** :
- `CLAUDE.md` → Instructions de gestion
- `.setup/.setup-state.json` → État queryable
- `template/config/labels.json` → Labels standards
- `template/config/project-fields.json` → Champs du Project

---

### 🔧 Je suis un mainteneur du template

**Apporter des changements** :
1. Modifier fichiers dans `template/`
2. Tester : `bash template-setup.sh --dry-run`
3. Committer & pusher
4. Les utilisateurs bénéficient automatiquement (via symlinks)

**Ajouter une étape du setup** :
1. Créer `template/.setup/steps/7-your-step.sh`
2. Sourcecer les libs : `source ../lib/colors.sh`
3. Ajouter au main orchestrator
4. Tester avec `--reset-state`

**Fichiers à modifier** :
- `template/.setup/steps/` → Ajouter étapes
- `template/.setup/lib/` → Utilitaires partagés
- `template/config/` → Configuration
- `template/README.md` → Documentation template

---

## 📂 Structure Complète

```
/
├── 📄 README.md                    ← Quick start pour users
├── 📄 CLAUDE.md                    ← Instructions LLM (user's copy)
├── 📄 CLAUDE-USER-TEMPLATE.md      ← Template pour CLAUDE.md
├── 📄 .env.example                 ← Secrets template
├── 📄 TEMPLATE_INDEX.md            ← Ce fichier
├── 📄 REFACTOR_SUMMARY.md          ← Changements détaillés
│
├── 📄 template-setup.sh            ← SEUL entry point
│
└── 📁 template/                    ← TON LE TEMPLATE
    │
    ├── 📄 README.md                ← Architecture template
    │
    ├── 📁 .setup/                  ← Setup orchestration
    │   ├── 📄 setup.sh             ← Main orchestrator (idempotent)
    │   ├── 📄 .setup-state.json    ← État du setup (gitignored)
    │   │
    │   ├── 📁 lib/                 ← Utilitaires partagés
    │   │   ├── colors.sh           ← Output formatting
    │   │   ├── state.sh            ← State management
    │   │   ├── validators.sh       ← Prerequisite checks
    │   │   └── github-api.sh       ← GitHub API wrappers
    │   │
    │   └── 📁 steps/               ← Étapes modulables
    │       ├── 1-check-state.sh    ← Vérifier l'état
    │       ├── 2-check-prerequisites.sh ← Valider prérequis
    │       ├── 3-init-labels.sh    ← Créer labels
    │       ├── 4-create-project.sh ← Créer Project v2
    │       ├── 5-link-workflows.sh ← Créer symlinks
    │       └── 6-finalize.sh       ← Résumé final
    │
    ├── 📁 .github/                 ← GitHub automation
    │   ├── 📄 PULL_REQUEST_TEMPLATE.md
    │   ├── 📁 workflows/           ← GitHub Actions
    │   │   ├── create-branch.yml
    │   │   ├── code-review-agent.yml
    │   │   ├── ci-tests.yml
    │   │   └── deploy-docs.yml
    │   └── 📁 ISSUE_TEMPLATE/      ← Issue templates
    │       ├── bug.md
    │       ├── feature.md
    │       └── task.md
    │
    ├── 📁 config/                  ← Configuration
    │   ├── labels.json             ← 17 labels standards
    │   └── project-fields.json     ← Champs du Project
    │
    ├── 📁 scripts/                 ← Utilitaires (optionnels)
    │   ├── setup_project_fields.py
    │   ├── project_sync.py
    │   ├── generate_dashboard.py
    │   └── velocity_calculator.py
    │
    └── 📁 docs/                    ← Documentation template
        ├── WORKFLOWS.md
        ├── TROUBLESHOOTING.md
        └── ADVANCED.md
```

---

## 🔍 Comment Trouver Quelque Chose

### "Je veux comprendre comment setup fonctionne"
→ `template/.setup/setup.sh` (orchestrator)
→ `template/.setup/steps/` (chaque étape)
→ `template/README.md` (documentation)

### "Je veux ajouter une nouvelle étape du setup"
→ Créer `template/.setup/steps/7-your-step.sh`
→ Sourcer `template/.setup/lib/colors.sh`
→ Ajouter au loop dans `template/.setup/setup.sh`

### "Je veux modifier les labels GitHub"
→ Éditer `template/config/labels.json`
→ Relancer `bash template-setup.sh --skip-completed`

### "Je veux modifier les workflows"
→ Éditer `template/.github/workflows/*.yml`
→ Changes appliquées auto (via symlinks)

### "Je veux des instructions pour un LLM"
→ Lire `CLAUDE.md` (ou `CLAUDE-USER-TEMPLATE.md`)
→ Adapté pour chaque projet

### "Je veux comprendre l'idempotence"
→ Lire `template/.setup/lib/state.sh`
→ État sauvé dans `.setup-state.json`
→ Chaque step checkable individuellement

---

## 🚀 Commandes Rapides

```bash
# First time setup
bash template-setup.sh

# Verify/update existing setup
bash template-setup.sh --skip-completed

# Dry run (preview)
bash template-setup.sh --dry-run

# Start fresh
bash template-setup.sh --reset-state

# Help
bash template-setup.sh --help

# Check setup state
cat .setup/.setup-state.json | jq .

# Run single step
bash template/.setup/steps/3-init-labels.sh
```

---

## 📊 Fichiers par Audience

### Users (Root)
```
README.md              ← Quick start
CLAUDE.md              ← Project management
.env.example           ← Secrets template
template-setup.sh      ← Setup entry point
```

### LLMs
```
CLAUDE.md              ← Instructions
.setup/.setup-state.json ← State (queryable)
template/config/labels.json ← Labels
template/config/project-fields.json ← Fields
```

### Developers
```
template/.setup/       ← Setup logic
template/.github/      ← Workflows
template/config/       ← Configuration
template/README.md     ← Architecture
REFACTOR_SUMMARY.md    ← Changes
```

### Contributors
```
template/              ← All template files
CONTRIBUTING.md        ← How to contribute
REFACTOR_SUMMARY.md    ← Design decisions
```

---

## 🔐 Gitignored Files

- `.setup-state.json` ← Project-specific state (never committed)
- `.env` ← Secrets (never committed)

---

## 💡 Key Concepts

### Idempotence
- Setup peut rouler 2x+ sans erreur
- État sauvé dans `.setup-state.json`
- Étapes skippables si déjà faites

### Modularity
- 6 étapes indépendantes
- Chaque step peut rouler seul
- Facile à tester et maintenir

### Symlinks
- Workflows dans `template/.github/`
- Symlinkés dans `.github/workflows/`
- Update template = auto-update repos

### LLM-Ready
- CLAUDE.md dans chaque repo
- `.setup-state.json` queryable
- Conventions claires
- Multi-session support

---

## 🎯 Next Steps

1. **Utilisateur** → Lire `README.md`, run `bash template-setup.sh`
2. **LLM** → Lire `CLAUDE.md`, query `.setup-state.json`
3. **Dev** → Lire `REFACTOR_SUMMARY.md`, explore `template/`
4. **Maintainer** → Lire `template/README.md`, modify `template/`

---

**Confused?** Check out the specific file for your role! 🚀
