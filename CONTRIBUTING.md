# Contribuer au projet

Merci de votre intérêt pour contribuer à ce projet ! Ce document décrit les règles et processus pour contribuer.

## 🎯 Code de conduite

Voir [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md). En participant, vous acceptez de respecter ce code.

## 📝 Comment contribuer

### Signaler un bug

1. Vérifiez que le bug n'a pas déjà été signalé dans [Issues](../../issues)
2. Créez une nouvelle issue en utilisant le template **Bug Report**
3. Décrivez les étapes pour reproduire le bug
4. Incluez des screenshots ou logs si pertinent
5. Mentionnez votre OS, version Python, etc.

### Suggérer une fonctionnalité

1. Vérifiez que la fonctionnalité n'a pas déjà été suggérée
2. Créez une nouvelle issue en utilisant le template **Feature Request**
3. Décrivez clairement la motivation et les cas d'usage
4. Listez les critères d'acceptation

### Soumettre du code

#### 1. Fork et clone

```bash
git clone https://github.com/YOUR_USERNAME/project-name.git
cd project-name
```

#### 2. Créer une branche

```bash
# Via GitHub (recommandé) : Ajouter label "auto-branch" à l'issue
# → L'action crée automatiquement feat/{issue-number}-{title}

# Ou manuellement :
git checkout -b feat/123-my-feature
```

#### 3. Développer

- Suivez le style de code du projet
- Ajoutez des tests pour vos changements
- Documentez les changements significatifs
- Commitez avec des messages clairs

```bash
git add .
git commit -m "feat: Add dark mode toggle

- Implement toggle component
- Add CSS variables for theming
- Update documentation"
```

#### 4. Lancer les tests localement

```bash
# Python
pip install -r requirements-dev.txt
pytest
black --check .
pylint src/
mypy src/

# JavaScript (si applicable)
npm run lint
npm run test
```

#### 5. Push et créer une Pull Request

```bash
git push origin feat/123-my-feature
```

Puis sur GitHub :
1. Accédez à votre fork
2. Cliquez **Compare & pull request**
3. Remplissez le template de PR
4. Liez l'issue : `Closes #123`
5. Soumettez

#### 6. Révision de code

- Le **Code Review Agent** (Gemini) commentera automatiquement
- L'équipe reverra la PR
- Les tests (lint, pytest, build) doivent passer
- Répondez aux retours et committez les corrections

#### 7. Merge

Une fois approuvée :
1. PR mergée en `develop` (branche preprod)
2. Status du Project Board → "Done"
3. Branche supprimée (optionnel)

---

## 🏗️ Structure du projet

```
project-name/
├── .github/
│   ├── workflows/           # GitHub Actions
│   ├── ISSUE_TEMPLATE/      # Templates d'issues
│   └── PULL_REQUEST_TEMPLATE/
├── agents/                  # Documentation des agents LLM
├── docs/                    # Documentation MkDocs
├── src/                     # Code source
├── tests/                   # Tests unitaires
├── requirements.txt         # Dépendances Python
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

---

## 💻 Stack technique

### Langages
- **Python 3.11+** (langage principal)
- **YAML** pour les workflows GitHub Actions
- **Markdown** pour la documentation

### Outils de développement
- **pytest** : Tests unitaires
- **pylint** / **black** : Lint et formatting
- **mypy** : Type checking
- **mkdocs** : Documentation
- **GitHub Actions** : CI/CD

### APIs LLM
- **Gemini (Google)** : Code review, planification, spécification

---

## 🔍 Vérifications avant de soumettre

Avant d'ouvrir une PR, assurez-vous que :

- [ ] Votre code passe les tests : `pytest`
- [ ] Formatage OK : `black src/ tests/`
- [ ] Pas de warnings : `pylint src/`
- [ ] Types vérifiés : `mypy src/`
- [ ] Documentation à jour (docstrings, README, docs/)
- [ ] Pas de secrets committy (clés API, tokens, etc.)
- [ ] Commits ont des messages clairs
- [ ] Issue liée dans la description de PR

---

## 📊 Utilisation du Project Board

Le **GitHub Projects v2** est le cœur de la gestion :

1. **Issues créées** → Ajoutées automatiquement au Backlog
2. **Label `auto-branch`** → Branche créée automatiquement
3. **PR ouverte** → Status → "In QA"
4. **Tests passent** → Status → "Ready for Merge"
5. **PR mergée** → Status → "Done"

**Vues** :
- **Backlog** : Toutes les issues, triées par priorité
- **Priority Board** : Kanban par statut
- **Team Items** : Filtrée par Owner et Sprint

---

## 🚀 Déploiement

### Environment de développement

Chaque PR mergée en `develop` déclenche :
- Tests complets
- Build
- Optionnel : déploiement en preprod

### Environment de production

À définir selon vos besoins :
- Release tags (v1.0, v1.1, etc.)
- Ou branche `main` déployée en prod

---

## ❓ Questions ou aide ?

- 📖 Consultez la [documentation](./docs/)
- 💬 Utilisez les [Discussions](../../discussions)
- 📋 Créez une [Issue](../../issues) (template "Task")

---

## ✅ Checklist pour mainteneurs

Avant de merger une PR :

- [ ] Code review passée
- [ ] Tests verts
- [ ] Linting OK
- [ ] Documentation à jour
- [ ] Issue liée correctement
- [ ] Pas de breaking changes majeurs (ou documentés)
- [ ] Commits ont des messages clairs

---

Merci de contribuer ! 🎉
