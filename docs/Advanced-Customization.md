# 🎨 Personnalisation avancée

Pour adapter le template à vos besoins spécifiques.

## Changer le naming des branches

Éditer `.github/workflows/create-branch.yml` :

```bash
# De : feat/{number}-{title}
BRANCH_NAME="feat/${ISSUE_NUMBER}-${SLUGIFIED}"

# À : feature/{number}-{title}
BRANCH_NAME="feature/${ISSUE_NUMBER}-${SLUGIFIED}"

# Ou : naming basé sur le type
if [[ "$LABELS" == *"type:bug"* ]]; then
  BRANCH_NAME="fix/${ISSUE_NUMBER}-${SLUGIFIED}"
else
  BRANCH_NAME="feat/${ISSUE_NUMBER}-${SLUGIFIED}"
fi
```

## Ajouter des champs custom au Project Board

1. Créer le champ manuellement sur GitHub ou modifier `scripts/setup_project_fields.py` :

```python
fields_to_create = {
    "Status": [...],
    "Sprint": ["Sprint 1", "Sprint 2", "Sprint 3"],  # Nouveau champ
}
```

2. Mapper dans `update-project.yml` :

```yaml
- name: Update sprint field
  run: |
    if [[ "$LABEL" == "sprint:1" ]]; then
      python scripts/project_sync.py --issue $NUM --sprint "Sprint 1"
    fi
```

## Notifications Slack/Discord

Ajouter à n'importe quel workflow :

```yaml
- name: Notify Slack
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK_URL }} \
      -H 'Content-Type: application/json' \
      -d '{"text":"✅ PR #${{ github.event.pull_request.number }} merged!"}'
```

## Multi-repositories avec un seul Project

Configurez le même `GH_PROJECT_NUMBER` dans chaque repo.

## Changer le modèle LLM

Dans `code-review-agent.yml` :

```python
# Utiliser GPT-4
from openai import OpenAI
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
response = client.chat.completions.create(
    model="gpt-4-turbo",
    messages=[{"role": "user", "content": prompt}]
)
```

## Ajouter des validations custom

Dans `ci-tests.yml`, ajoutez vos étapes :

```yaml
- name: Custom validation
  run: |
    ./scripts/my_custom_check.sh
```

## Templates d'issues personnalisés

Éditez `.github/ISSUE_TEMPLATE/*.yml` selon vos besoins.

[⬅️ FAQ](FAQ) | [➡️ Contributing](Contributing)
