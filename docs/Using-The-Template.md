# 🎓 Utiliser le template

Guide complet pour utiliser toutes les fonctionnalités du template.

## Créer une issue

```bash
gh issue create \
  --title "Ajouter dark mode" \
  --label "type:feature,priority:high" \
  --body "Description de la feature"
```

**Résultat** : Issue ajoutée automatiquement au Project Board avec Priority=High, Type=Feature

## Auto-créer une branche

Ajoutez le label `auto-branch` à une issue :

```bash
gh issue edit 123 --add-label "auto-branch"
```

**Résultat** :
- ✅ Branche créée : `feat/123-titre-issue`
- ✅ Commentaire posté avec instructions git
- ✅ Status mis à jour : "Ready"

## Travailler sur une branche

```bash
# Récupérer la branche
git fetch origin
git checkout feat/123-ajouter-dark-mode

# Faire vos modifications
# ...

# Committer avec référence à l'issue
git add .
git commit -m "feat: add dark mode toggle (#123)"
git push origin feat/123-ajouter-dark-mode
```

## Créer une Pull Request

```bash
gh pr create \
  --title "Add dark mode (#123)" \
  --body "Closes #123"
```

**Résultat** :
- ✅ CI/CD se lance
- ✅ Claude AI analyse le code (si configuré)
- ✅ Status de l'issue → "In Review"

## Merger une PR

Quand la PR est approuvée :

```bash
gh pr merge 456 --squash
```

**Résultat** :
- ✅ PR et issue → Status "Done"
- ✅ Branche supprimée automatiquement

## Utiliser les labels pour automatiser

| Label | Action automatique |
|-------|-------------------|
| `auto-branch` | Crée une branche |
| `priority:high` | Priority → High |
| `type:bug` | Type → Bug |
| `status:in-progress` | Status → In Progress |

## Voir le Project Board

```bash
# Lister les items
gh project item-list 1 --owner YOUR_USERNAME

# Voir dans le navigateur
gh project view 1 --owner YOUR_USERNAME --web
```

## Templates d'issues

Utilisez les templates dans `.github/ISSUE_TEMPLATE/` :

- `feature_request.yml` : Nouvelle fonctionnalité
- `bug_report.yml` : Signaler un bug
- `task.yml` : Tâche technique

## Workflow complet

### Exemple : Développer une nouvelle feature

1. **Créer l'issue**
   ```bash
   gh issue create --title "Add user profile" --label "type:feature,priority:medium,auto-branch"
   ```

2. **Branche auto-créée** → `feat/1-add-user-profile`

3. **Développer**
   ```bash
   git checkout feat/1-add-user-profile
   # Code...
   git commit -m "feat: add user profile page (#1)"
   git push
   ```

4. **Créer PR**
   ```bash
   gh pr create --title "Add user profile (#1)" --body "Closes #1"
   ```

5. **Revue auto** → Claude analyse le code

6. **Merger** → Status "Done" automatique

[⬅️ Configuration](Configuration) | [➡️ Workflows](Understanding-Workflows)
