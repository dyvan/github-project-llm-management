# ✅ Validation du Template

Comment le template est validé automatiquement.

## Workflow de validation

Le workflow `.github/workflows/template-validation.yml` valide automatiquement que toutes les fonctionnalités du template fonctionnent.

### Quand s'exécute-t-il ?

- ✅ Sur chaque **Pull Request**
- ✅ Sur chaque **push** vers main/develop
- ✅ **Manuellement** via Actions tab
- ✅ **Hebdomadairement** (lundi 9h UTC)

### Ce qui est testé

#### 1. Scripts (Syntaxe & Exécution)

**Scripts Python** :
- `scripts/project_sync.py`
- `scripts/setup_project_fields.py`

**Scripts Bash** :
- `setup-project.sh`
- `scripts/validate_setup.sh`

**Vérifications** :
- ✅ Syntaxe valide
- ✅ Scripts exécutables
- ✅ CLI fonctionne (--help)

#### 2. Workflows GitHub Actions

**Workflows testés** :
- `ci-tests.yml`
- `update-project.yml`
- `create-branch.yml`
- `code-review-agent.yml`
- `template-validation.yml`

**Vérifications** :
- ✅ YAML valide
- ✅ Tous les workflows requis présents
- ✅ Syntaxe correcte

#### 3. Tests unitaires

**Tests exécutés** :
- 32 tests unitaires (pytest)
- Tests de workflows
- Tests de project_sync.py

**Couverture** :
- GraphQL queries
- Field updates
- Error handling

#### 4. Configuration

**Fichiers validés** :
- `.github/project.yml`
- `.env.example`
- `requirements.txt`
- `requirements-dev.txt`

**Vérifications** :
- ✅ YAML valide
- ✅ Variables requises présentes
- ✅ Dépendances installables

#### 5. Documentation

**Fichiers vérifiés** :
- `README.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `docs/Home.md`
- `docs/Getting-Started.md`
- `docs/Scripts-Reference.md`
- Tous les autres docs/

**Vérifications** :
- ✅ Tous les fichiers présents
- ✅ Structure complète
- ✅ Liens internes valides

#### 6. Templates

**Templates validés** :
- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `.github/ISSUE_TEMPLATE/task.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`

**Vérifications** :
- ✅ YAML valide (issue templates)
- ✅ Markdown valide (PR template)
- ✅ Tous les templates présents

#### 7. Dépendances

**Packages testés** :
- requests
- pyyaml
- google-generativeai
- pytest
- pytest-cov
- pytest-mock

**Vérifications** :
- ✅ Installation réussie
- ✅ Imports fonctionnels
- ✅ Versions compatibles

#### 8. Sécurité

**Vérifications** :
- ✅ Pas de secrets exposés (API keys)
- ✅ Pas de tokens dans le code
- ✅ Secrets utilisés correctement (via secrets.*)

#### 9. Simulation de fonctionnalités

**Fonctionnalités simulées** :
- CLI project_sync.py
- CLI setup_project_fields.py
- Validation setup

#### 10. Test d'intégration (sur main)

**Workflow utilisateur simulé** :
- Clone du repo
- Installation dépendances
- Exécution setup
- Validation

---

## Lancer la validation manuellement

### Via GitHub Actions

1. Allez dans **Actions** tab
2. Sélectionnez **Template Validation - E2E Tests**
3. Cliquez **Run workflow**
4. Choisissez la branche
5. Cliquez **Run workflow**

### En local

```bash
# Installer les dépendances
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Lancer les tests
pytest tests/ -v

# Valider les workflows
python -c "import yaml; [yaml.safe_load(open(f)) for f in ['.github/workflows/ci-tests.yml', '.github/workflows/update-project.yml']]"

# Valider le setup
./scripts/validate_setup.sh
```

---

## Rapport de validation

Après exécution, le workflow génère un **rapport détaillé** :

```
📊 TEMPLATE VALIDATION REPORT
================================

✅ Scripts syntax: PASSED
✅ Workflows YAML: PASSED
✅ Unit tests: PASSED
✅ Configuration files: PASSED
✅ Documentation: PASSED
✅ Issue templates: PASSED
✅ Dependencies: PASSED
✅ Security checks: PASSED

================================
🎉 TEMPLATE VALIDATION: SUCCESS

The template is ready for use!
```

Le rapport est aussi disponible dans l'onglet **Summary** de chaque exécution.

---

## En cas d'échec

Si un test échoue :

### 1. Consulter les logs

- Aller dans Actions → Template Validation
- Cliquer sur l'exécution échouée
- Voir les logs détaillés

### 2. Reproduire en local

```bash
# Reproduire la partie qui échoue
pytest tests/test_workflows.py -v

# Ou lancer un script spécifique
python scripts/project_sync.py --help
```

### 3. Corriger

- Corriger le problème identifié
- Commiter
- Push → Le workflow se relance

### 4. Demander de l'aide

Si vous ne comprenez pas l'erreur :
- [Ouvrir une issue](https://github.com/dyvan/github-project-llm-management/issues)
- [Poser une question](https://github.com/dyvan/github-project-llm-management/discussions)

---

## Badge de validation

Ajoutez le badge dans votre README :

```markdown
[![Template Validation](https://github.com/OWNER/REPO/actions/workflows/template-validation.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/template-validation.yml)
```

---

## Fréquence de validation

| Déclencheur | Fréquence |
|-------------|-----------|
| Pull Request | À chaque PR |
| Push main/develop | À chaque push |
| Manuel | Sur demande |
| Automatique | Lundi 9h UTC |

---

## Avantages

✅ **Confiance** : Le template est testé automatiquement
✅ **Qualité** : Détection précoce des régressions
✅ **Documentation** : Rapport détaillé à chaque exécution
✅ **Transparence** : Validation visible publiquement

---

[⬅️ Understanding Workflows](Understanding-Workflows) | [🏠 Home](Home)
