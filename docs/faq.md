# ❓ Questions Fréquentes (FAQ)

## Installation

### Dois-je connaître la programmation ?
Non ! Le template est conçu pour les non-développeurs. Suivez simplement le [Guide de démarrage](Getting-Started).

### Quels sont les prérequis ?
- Git
- GitHub CLI
- Python 3.11+

Tous s'installent facilement, voir [Getting Started](Getting-Started).

### Combien de temps prend l'installation ?
Environ 5 minutes en suivant le guide.

## Utilisation

### Comment créer une issue qui déclenche l'automation ?
```bash
gh issue create --title "Ma tâche" --label "type:feature,auto-branch"
```

### Puis-je désactiver l'IA Gemini ?
Oui, ne configurez simplement pas `GEMINI_API_KEY`. La revue fonctionnera en mode basique.

### Comment personnaliser les labels ?
Éditez `setup-project.sh` lignes 86+ et relancez le script.

### Est-ce que ça fonctionne avec des repos privés ?
Oui, complètement.

## Techniques

### Quel modèle est utilisé ?
`gemini-2.0-flash` par défaut. Modifiable dans les variables des workflows.

### Puis-je utiliser un autre LLM ?
Actuellement, tous les workflows utilisent Gemini. Pour utiliser un autre provider, il faut modifier les workflows manuellement.

### Les workflows consomment-ils beaucoup de minutes GitHub Actions ?
Non, très peu. Environ 1-2 minutes par workflow.

### Puis-je utiliser plusieurs projets ?
Oui, spécifiez `--project NUMBER` dans les scripts.

## Dépannage

### "Project not found"
Vérifiez `.github/project.yml` et `gh project list --owner YOUR_USERNAME`.

### Les workflows ne se déclenchent pas
Vérifiez Settings → Actions → "Allow all actions".

### Plus de questions ?
- [Troubleshooting](Troubleshooting)
- [Discussions](https://github.com/dyvan/github-project-llm-management/discussions)

[⬅️ Troubleshooting](Troubleshooting) | [➡️ Advanced](Advanced-Customization)
