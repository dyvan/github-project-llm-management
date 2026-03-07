# Créer votre première issue

Ce guide vous montre comment créer une première issue et déclencher les workflows automatiques.

## 🎯 Étape 1 : Créer une issue

### Via l'interface GitHub

1. Allez sur : https://github.com/dyvan/github-project-llm-management/issues
2. Cliquez sur **New issue**
3. Sélectionnez le template **Feature Request**

### Via la CLI

```bash
gh issue create \
  --title "Implement user authentication" \
  --body "Add OAuth2 authentication system

**Motivation**: Users need secure login

**Acceptance Criteria**:
- [ ] OAuth2 provider integration
- [ ] Token refresh mechanism
- [ ] Tests covering auth flow" \
  --label "type:feature"
```

## 📝 Remplissez le formulaire

**Exemple de Feature Request** :

```
Title: Add dark mode toggle

Description:
Users want a dark mode option for accessibility and reduced eye strain.

Motivation:
- Improve accessibility for users with light sensitivity
- Reduce eye strain during night usage
- Follow modern app standards

Acceptance Criteria:
- [ ] Toggle switch in settings
- [ ] Theme persists in localStorage
- [ ] Works across all pages
- [ ] Tests cover both themes
- [ ] Documentation updated
```

## 🏷️ Ajouter le label `auto-branch`

### Via l'interface

1. Dans l'issue, cliquez sur **Labels**
2. Cherchez `auto-branch`
3. Cliquez dessus pour l'ajouter

### Résultat attendu

**Immédiatement** après avoir ajouté le label :

✅ Le **Branch Creator** se déclenche

```
✅ Branch auto-created: `feat/1-add-dark-mode-toggle`

**Next steps:**
1. Clone the repository and checkout the branch:
   git checkout feat/1-add-dark-mode-toggle
2. Make your changes
3. Push and create a Pull Request
4. The Code Review Agent will automatically review your PR

---
Created by GitHub Actions
```

## 📊 Vérifier dans le Project Board

1. Allez à l'onglet **Projects**
2. Sélectionnez votre **Project Board**
3. Votre issue apparaît dans **Backlog**

**Colonnes visibles** :
- Title: "Add dark mode toggle"
- Priority: Medium
- Effort: 5
- Status: Backlog
- Owner: (vous)

## 💻 Développer localement

Une fois la branche créée, vous pouvez commencer :

```bash
# Cloner le repo (si pas encore fait)
git clone https://github.com/dyvan/github-project-llm-management.git
cd github-project-llm-management

# Checker la branche
git checkout feat/1-add-dark-mode-toggle

# Développer
echo "export const darkMode = true;" > src/theme.js

# Commit
git add .
git commit -m "feat: Add dark mode toggle

- Implement toggle component
- Add theme CSS variables
- Save preference in localStorage"

# Push
git push origin feat/1-add-dark-mode-toggle
```

## 🔄 Ouvrir une Pull Request

### Via l'interface

1. Vous verrez un banner "Compare & pull request"
2. Cliquez dessus
3. Remplissez le template :

```markdown
## Description
Added dark mode toggle to settings page.

## Issue
Closes #1

## Type of change
- [x] Feature

## Checklist
- [x] Tests added
- [x] Documentation updated
- [x] Lint passed
```

4. Cliquez **Create pull request**

### Workflows automatiques se déclenchent

#### 1️⃣ Code Review Agent
Dans ~30 secondes :

```
## 🤖 Automated Code Review by Gemini AI

### ✅ Strengths
- Clean component structure
- Good use of React hooks

### ⚠️ Suggestions
- Add error boundary wrapper
- Consider memoization for performance

### 🔴 Critical Issues
None found!
```

#### 2️⃣ CI Tests
Dans ~1 minute :

```
## ✅ Tests Passed

- Tests: 45/45 ✅
- Coverage: 87%
- Lint: OK
- Build: ✅
```

#### 3️⃣ Project Board Update
Status change : **Backlog → In QA**

## ✅ Merger la PR

### Conditions de merge

- ✅ Code Review completée
- ✅ Tous les tests passent
- ✅ Approuvée par un mainteneur

### Merger via interface

1. Allez à votre PR
2. Cliquez **Merge pull request**
3. Choisissez la stratégie :
   - **Create a merge commit** (recommended)
   - **Squash and merge**
   - **Rebase and merge**
4. Cliquez **Confirm merge**

### Résultat final

- ✅ Branche mergée en `main`
- ✅ Project status : **Done**
- ✅ Issue fermée automatiquement (Closes #1)
- 🎉 Feature déployée !

## 📋 Checklist récapitulatif

Vous venez de :

- [ ] Créer une issue avec un template
- [ ] Ajouter le label `auto-branch`
- [ ] Branch auto-créée
- [ ] Développé localement
- [ ] Pushez les changements
- [ ] Ouvert une PR
- [ ] Code Review Agent commenté
- [ ] CI Tests passés
- [ ] PR approuvée
- [ ] Mergée en main
- [ ] Issue fermée
- [ ] Project Board mis à jour

**Bravo ! Vous maîtrisez le workflow complet ! 🚀**

## 🎓 Prochaines étapes

- Explorez les [agents LLM](../guides/using-agents.md)
- Configurez des [webhooks Slack](../guides/setup-github-projects.md)
- Customisez les [workflows](../architecture/workflows.md)
