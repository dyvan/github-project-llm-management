# 🚀 Guide de démarrage

Installez et configurez le template en **5 minutes chrono**.

## Prérequis (2 minutes)

Avant de commencer, assurez-vous d'avoir :

### 1. Git
```bash
# Vérifier si Git est installé
git --version

# Installer Git si nécessaire:
# macOS: brew install git
# Linux: sudo apt install git
# Windows: https://git-scm.com/download/win
```

### 2. GitHub CLI
```bash
# Installer GitHub CLI
# macOS
brew install gh

# Linux (Ubuntu/Debian)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo apt install gh

# Windows
winget install GitHub.cli

# Vérifier l'installation
gh --version
```

### 3. Python 3.11+
```bash
# Vérifier si Python est installé
python3 --version

# Installer Python si nécessaire:
# macOS: brew install python@3.11
# Linux: sudo apt install python3.11
# Windows: https://www.python.org/downloads/
```

---

## Étape 1 : Créer votre projet (1 minute)

### Option A : Utiliser comme template (recommandé)

1. Sur GitHub, cliquez sur le bouton **"Use this template"** en haut de la page
2. Donnez un nom à votre projet (ex: `mon-projet`)
3. Choisissez visibilité (Public ou Private)
4. Cliquez **"Create repository from template"**

```bash
# Clonez votre nouveau repository
git clone https://github.com/VOTRE_NOM/mon-projet.git
cd mon-projet
```

### Option B : Ajouter à un projet existant

```bash
cd votre-projet-existant
git remote add template https://github.com/dyvan/github-project-llm-management.git
git fetch template
git merge template/main --allow-unrelated-histories
```

---

## Étape 2 : Authentification GitHub (30 secondes)

```bash
# Connectez-vous à GitHub
gh auth login

# Suivez les instructions :
# 1. Choisissez "GitHub.com"
# 2. Choisissez "HTTPS"
# 3. Dites "Yes" pour authentifier
# 4. Choisissez "Login with a web browser"
# 5. Copiez le code et ouvrez le navigateur
```

---

## Étape 3 : Configuration des secrets (1 minute)

### Créer un GitHub Personal Access Token (PAT)

1. Allez sur : https://github.com/settings/tokens/new
2. Donnez un nom : `Mon template automation`
3. **Cochez ces scopes** :
   - ✅ `repo` (Full control of private repositories)
   - ✅ `project` (Full control of projects)
   - ✅ `workflow` (Update GitHub Action workflows)
4. Cliquez **"Generate token"**
5. **Copiez le token** (vous ne le reverrez plus !)

### Configurer le token

```bash
# Configurez le token GitHub
gh secret set GH_TOKEN
# Collez votre token quand demandé

# (Optionnel) Configurez la clé API Gemini pour la revue de code IA
gh secret set GEMINI_API_KEY
# Obtenez votre clé sur : https://aistudio.google.com/app/apikey
```

> **💡 Note** : Sans `GEMINI_API_KEY`, la revue de code fonctionnera en mode basique (sans IA).

---

## Étape 4 : Installation (2 minutes)

```bash
# Installez les dépendances Python
pip install -r requirements.txt

# Lancez le script de setup
./setup-project.sh
```

**Le script va** :
1. ✅ Vérifier que tout est installé
2. ✅ Créer les labels GitHub (type:feature, priority:high, etc.)
3. ✅ Créer un GitHub Project v2
4. ✅ Vous demander de noter le numéro du projet

> **🔔 Important** : Notez le **numéro du projet** affiché (ex: Project #1)

---

## Étape 5 : Configuration du projet (1 minute)

### 5a. Mettre à jour le numéro de projet

Éditez le fichier `.github/project.yml` :

```yaml
project:
  number: 1  # 👈 Remplacez par le numéro de votre projet
  name: "Project Backlog"
```

### 5b. Auto-créer les champs custom

```bash
# Créez automatiquement les champs du Project Board
python3 scripts/setup_project_fields.py --project-number 1 --owner VOTRE_NOM
```

Cela crée automatiquement :
- **Status** : Backlog, Ready, In Progress, In Review, Blocked, Done
- **Priority** : Low, Medium, High
- **Effort** : 1, 2, 3, 5, 8 (story points)
- **Type** : Feature, Bug, Task, Docs, Infrastructure
- **Target Version** : (champ texte libre)

---

## Étape 6 : Validation (30 secondes)

```bash
# Validez que tout fonctionne
./scripts/validate_setup.sh
```

Si vous voyez `✅ All checks passed!`, **c'est prêt** ! 🎉

---

## Test rapide

Testons que l'automation fonctionne :

### 1. Créer une issue

```bash
gh issue create \
  --title "Test automation" \
  --label "type:feature,priority:medium,auto-branch" \
  --body "Tester que l'automation fonctionne"
```

### 2. Observer la magie ✨

Quelques secondes après, vous devriez voir :
- ✅ Issue ajoutée au Project Board avec Priority=Medium
- ✅ Branche créée automatiquement : `feat/1-test-automation`
- ✅ Commentaire posté sur l'issue avec les instructions git

### 3. Créer une Pull Request

```bash
# Récupérez la branche
git fetch origin
git checkout feat/1-test-automation

# Faites un changement (exemple)
echo "# Test" > test.md
git add test.md
git commit -m "feat: test automation (#1)"
git push origin feat/1-test-automation

# Créez une PR
gh pr create \
  --title "Test PR" \
  --body "Closes #1"
```

### 4. Observer encore la magie ✨

Vous devriez voir :
- ✅ CI/CD qui se lance automatiquement
- ✅ Claude AI qui analyse votre code (si API key configurée)
- ✅ Project Board mis à jour : Status → "In Review"

---

## Prochaines étapes

Maintenant que tout fonctionne :

1. **[📖 Lire la documentation complète](Using-The-Template)** - Comprendre toutes les fonctionnalités
2. **[⚙️ Personnaliser le template](Configuration)** - Adapter à vos besoins
3. **[🔀 Comprendre les workflows](Understanding-Workflows)** - Savoir comment ça marche

---

## Besoin d'aide ?

- **Problème ?** → Consultez le [Dépannage](Troubleshooting)
- **Question ?** → Postez dans les [Discussions](https://github.com/dyvan/github-project-llm-management/discussions)
- **Bug ?** → Ouvrez une [Issue](https://github.com/dyvan/github-project-llm-management/issues)

---

[⬅️ Retour à l'accueil](Home) | [Suivant : Configuration ➡️](Configuration)
