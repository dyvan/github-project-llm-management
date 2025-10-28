# Branch Creator Agent

## 📋 Rôle

Le **Branch Creator** est un agent autonome qui crée automatiquement une branche de travail quand une issue reçoit le label `auto-branch`. Il simplifie le workflow en éliminant les étapes manuelles de création de branche.

## 🎯 Objectif

- Créer une branche de feature nommée selon le format : `feat/{issue-number}-{slugified-title}`
- Commenter l'issue avec les instructions de checkout
- Standardiser la nomenclature des branches dans le projet

## 🔄 Flux d'exécution

### 1. **Déclenchement**

```yaml
on:
  issues:
    types: [labeled]
```

**Condition** : Label `auto-branch` est ajouté à une issue

### 2. **Actions**

#### Étape 1 : Extracture des informations
- Récupère le numéro de l'issue : `${{ github.event.issue.number }}`
- Récupère le titre : `${{ github.event.issue.title }}`

#### Étape 2 : Slugification du titre
Le titre est transformé en "slug" :
- Minuscules
- Espaces et caractères spéciaux remplacés par `-`
- Espaces multiples réduits à un seul `-`

**Exemple** :
```
Titre d'issue : "Add dark mode toggle to settings"
Slug généré  : "add-dark-mode-toggle-to-settings"
```

#### Étape 3 : Création du nom de branche
```
Format : feat/{issue-number}-{slug}
Exemple: feat/123-add-dark-mode-toggle-to-settings
```

#### Étape 4 : Création de la branche
```bash
git checkout -b feat/123-add-dark-mode-toggle-to-settings
git push origin feat/123-add-dark-mode-toggle-to-settings
```

#### Étape 5 : Commentaire sur l'issue
Poste un commentaire avec :
- ✅ Confirmation de création
- 📝 Commande git pour checker la branche
- 📋 Instructions suivantes

### 3. **Résultat attendu**

**Commentaire exemple** :

```markdown
✅ Branch auto-created: `feat/123-add-dark-mode-toggle-to-settings`

**Next steps:**
1. Clone the repository and checkout the branch:
   ```bash
   git checkout feat/123-add-dark-mode-toggle-to-settings
   ```
2. Make your changes
3. Push and create a Pull Request
4. The Code Review Agent will automatically review your PR

---
*Created by GitHub Actions*
```

## 🔐 Permissions requises

| Permission | Raison |
|-----------|--------|
| `contents: write` | Créer et pousser des branches |
| `issues: write` | Commenter sur les issues |

## ⚙️ Configuration

### Fichier de workflow
`.github/workflows/create-branch.yml`

### Variables d'environnement
Aucune clé API requise (utilise `secrets.GITHUB_TOKEN`)

## 📝 Exemple d'utilisation complet

### 1. Créer une issue
- Type : Feature Request
- Titre : "Add authentication system"
- Description : "Implement OAuth2 authentication"

### 2. Ajouter le label
Sur GitHub, dans l'issue :
- Cliquez sur "Labels"
- Sélectionnez `auto-branch`

### 3. Agent crée automatiquement
- Branche : `feat/456-add-authentication-system`
- Commentaire posté : Instructions de checkout

### 4. Développeur commence
```bash
git checkout feat/456-add-authentication-system
# Développer...
git push
```

### 5. PR créée
- Titre : "Add authentication system (#456)"
- Description : Remplit le template
- → Autres agents se déclenchent

## 🚨 Gestion des erreurs

| Erreur | Cause | Solution |
|--------|-------|----------|
| Branche existe déjà | Issue déjà traitée | Pas d'action (idempotent) |
| Pas de permissions | Token GitHub insuffisant | Vérifier les secrets GitHub |
| Slug vide | Titre avec seulement caractères spéciaux | Renommer l'issue |

## 🔄 Intégration avec autres agents

```
Branch Creator (crée branche)
    ↓
Développeur code localement
    ↓
PR ouverte
    ↓
Code Reviewer (revue auto)
    ↓
Test Feedback (CI/CD)
    ↓
Project Board (mise à jour)
```

## 💡 Cas d'usage

- ✅ Issues simples/petites (PR directe)
- ✅ Features de sprint
- ✅ Bugs à corriger rapidement
- ✅ Refactoring et tech debt

## ❌ Quand ne pas utiliser

- **Issues avec sous-tâches** : Créez plutôt des branches manuelles pour chaque sous-tâche
- **Hotfix critique** : Utilisez une branche `hotfix/` manuellement
- **Issues sans code** : Documentation ou discussions (pas besoin de branche)

## 📊 Statistiques et monitoring

Actuellement, il n'y a pas de dashboard, mais vous pouvez vérifier :

```bash
# Voir toutes les branches créées par cet agent
git branch -r | grep "feat/"

# Voir les issues avec le label auto-branch
gh issue list --label auto-branch
```

## 🔮 Améliorations futures

- [ ] Support de préfixes custom (`feat/`, `bugfix/`, `docs/`)
- [ ] Assignation automatique au créateur de l'issue
- [ ] Validation du titre d'issue (minimum de caractères)
- [ ] Intégration avec protection de branches (pr-required)
- [ ] Webhook pour notifier Slack/Discord
