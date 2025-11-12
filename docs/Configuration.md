# ⚙️ Configuration

Comment personnaliser le template selon vos besoins.

## Fichier de configuration principal

### `.github/project.yml`

```yaml
project:
  number: 1  # 👈 Changez selon votre projet
  name: "Project Backlog"
  auto_link: true

fields:
  status:
    options: ["Backlog", "Ready", "In Progress", "In Review", "Blocked", "Done"]
    default: "Backlog"
  priority:
    options: ["Low", "Medium", "High"]
    default: "Medium"
```

**À modifier** :
- `project.number` : Mettez le numéro de votre projet GitHub

## Labels GitHub

Les labels sont créés par `setup-project.sh`. Pour les personnaliser :

```bash
# Modifier setup-project.sh ligne 86+
declare -a LABELS=(
    "type:feature:0e8a16:New feature"
    "priority:urgent:ff0000:Urgent"  # Ajoutez vos labels
)
```

## Secrets GitHub

### Requis
- `GH_TOKEN` : Token avec scopes `repo`, `project`, `workflow`

### Optionnels
- `CLAUDE_API_KEY` : Pour revue de code IA

```bash
gh secret set GH_TOKEN
gh secret set CLAUDE_API_KEY
```

## Workflows

Modifiez les workflows dans `.github/workflows/` selon vos besoins :

### Changer le modèle Claude
Dans `code-review-agent.yml` ligne 69 :
```python
model="claude-3-5-sonnet-20241022"  # Changez ici
```

### Modifier le naming des branches
Dans `create-branch.yml` ligne 32 :
```bash
BRANCH_NAME="feat/${ISSUE_NUMBER}-${SLUGIFIED}"  # Personnalisez
```

### Ajouter des champs au Project Board
Dans `update-project.yml`, ajoutez vos mappings :
```bash
if [[ "$LABEL" == "mon-label" ]]; then
  python scripts/project_sync.py --issue $ISSUE_NUM --status "Mon Status"
fi
```

[⬅️ Getting Started](Getting-Started) | [➡️ Using The Template](Using-The-Template)
