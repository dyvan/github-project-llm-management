# 🤝 Contribuer au projet

Merci de votre intérêt ! Voici comment participer.

## Signaler un bug

1. Vérifiez qu'il n'existe pas déjà dans [Issues](../../issues)
2. Créez une issue avec template "Bug Report"
3. Décrivez étapes pour reproduire
4. Incluez screenshots si pertinent

## Suggérer une fonctionnalité

1. Créez une issue avec template "Feature Request"
2. Décrivez la motivation et cas d'usage
3. Listez critères d'acceptation

## Soumettre du code

### 1. Fork et clone

```bash
git clone https://github.com/YOUR_USERNAME/github-project-llm-management.git
cd github-project-llm-management
```

### 2. Créer une branche

```bash
# Méthode recommandée : créer une issue avec label "auto-branch"
# Ou manuellement :
git checkout -b feat/123-ma-feature
```

### 3. Développer

- Suivez le style de code
- Ajoutez des tests
- Documentez les changements

```bash
git commit -m "feat: add new feature

- Description du changement
- Impact
- Tests ajoutés"
```

### 4. Tester

```bash
pip install -r requirements-dev.txt
pytest tests/ -v
./scripts/validate_setup.sh
```

### 5. Créer la PR

```bash
git push origin feat/123-ma-feature
gh pr create --title "Ma feature (#123)" --body "Closes #123"
```

## Checklist avant de soumettre

- [ ] Tests passent
- [ ] Documentation mise à jour
- [ ] Pas de secrets committés
- [ ] Messages de commit clairs
- [ ] Issue liée dans la PR

## Code de conduite

Voir [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md). En participant, vous acceptez ce code.

## Questions ?

- [Discussions](../../discussions)
- [Issues](../../issues)

[⬅️ Advanced Customization](Advanced-Customization) | [🏠 Home](Home)
