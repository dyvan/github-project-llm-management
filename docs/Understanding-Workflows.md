# 🔀 Comprendre les Workflows

Comment fonctionnent les automations GitHub Actions.

## Vue d'ensemble

```
Issue créée → update-project.yml → Ajout au Project Board (Backlog)
     ↓
Label "auto-branch" → create-branch.yml → Branche créée
     ↓
Développeur code
     ↓
PR ouverte → code-review-agent.yml → Gemini analyse
           → ci-tests.yml → Tests exécutés
           → update-project.yml → Status "In Review"
     ↓
PR mergée → update-project.yml → Status "Done"
```

## Workflows détaillés

### 1. update-project.yml

**Quand** : Issue/PR créée, labellée, mergée

**Actions** :
- Issue créée → Ajoute au Backlog
- Label ajouté → Met à jour Status/Priority/Type
- PR ouverte → Status "In Review"
- PR mergée → Status "Done"

**Variables** :
```yaml
env:
  GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  GH_OWNER: ${{ github.repository_owner }}
  GH_REPO: ${{ github.event.repository.name }}
```

### 2. create-branch.yml

**Quand** : Label `auto-branch` ajouté

**Actions** :
1. Récupère titre issue
2. Crée slug (ex: "Fix API Bug" → "fix-api-bug")
3. Crée branche `feat/{number}-{slug}`
4. Poste commentaire avec instructions

### 3. code-review-agent.yml

**Quand** : PR ouverte/mise à jour

**Actions** :
1. Récupère le diff
2. Envoie à Gemini AI
3. Génère revue (Points forts, Suggestions, Problèmes)
4. Poste commentaire

**Mode fallback** : Sans GEMINI_API_KEY, checklist basique

### 4. ci-tests.yml

**Quand** : Push sur main/develop, PR ouverte

**Actions** :
1. Vérifie permissions scripts
2. Valide YAML workflows
3. Lance tests unitaires
4. Rapport de couverture

## Personnaliser les workflows

### Ajouter un nouveau mapping label

Dans `update-project.yml` :
```yaml
- name: Update on custom label
  run: |
    if [[ "$LABEL" == "needs-review" ]]; then
      python scripts/project_sync.py --issue $NUM --status "In Review"
    fi
```

### Changer le prefix de branche

Dans `create-branch.yml` :
```bash
# Changer "feat/" en "feature/"
BRANCH_NAME="feature/${ISSUE_NUMBER}-${SLUGIFIED}"
```

### Ajouter des notifications

```yaml
- name: Notify Slack
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
      -d '{"text":"PR merged!"}'
```

## Déboguer un workflow

```bash
# Voir les logs
gh run list
gh run view RUN_ID --log

# Re-lancer un workflow
gh run rerun RUN_ID
```

[⬅️ Using Template](Using-The-Template) | [➡️ FAQ](FAQ)
