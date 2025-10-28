# Code Reviewer Agent

## 📋 Rôle

Le **Code Reviewer** est un agent LLM autonome qui analyse automatiquement le code des Pull Requests. Il examine la logique, la sécurité, la performance, et la documentation pour fournir des retours constructifs et non-bloquants.

## 🎯 Objectif

- Fournir une revue de code rapide et intelligente
- Identifier les problèmes potentiels (sécurité, perf, logique)
- Commenter directement sur la PR avec des suggestions
- Accélérer le processus de review humain en soulevant les problèmes évidents

## 🔄 Flux d'exécution

### 1. **Déclenchement**

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
```

**Conditions** :
- PR ouverte
- PR synchronisée (nouveau commit)
- PR réouverte

### 2. **Actions**

#### Étape 1 : Extraction du diff
```bash
gh pr diff {PR_NUMBER}
```

Récupère les changements complets de la PR (limité à 10000 lignes)

#### Étape 2 : Préparation du contexte
```
- Titre de la PR : ${{ github.event.pull_request.title }}
- Description : ${{ github.event.pull_request.body }}
- Diff : (voir fichier temporaire)
```

#### Étape 3 : Appel à l'API Claude
Envoie au modèle `claude-3-5-sonnet-20241022` :

```
Prompt:
Review this GitHub Pull Request code changes. Provide constructive feedback in a GitHub-friendly format.

**PR Title**: {title}
**PR Description**: {description}

**Code Changes**:
```diff
{diff}
```

Provide a code review with:
1. ✅ Strengths
2. ⚠️ Suggestions
3. 🔴 Critical Issues
```

#### Étape 4 : Génération de la revue
Claude retourne une réponse structurée en Markdown

#### Étape 5 : Publication en tant que commentaire PR
```bash
gh pr comment {PR_NUMBER} --body "{review_comment}"
```

### 3. **Format de la réponse**

```markdown
## 🤖 Automated Code Review by Claude AI

### ✅ Strengths
- Good error handling in the database query
- Proper input validation on user inputs
- Well-structured async/await pattern

### ⚠️ Suggestions
- Consider using a context manager for database connections
- Extract magic number `100` into a named constant
- Add type hints to function parameters for clarity
- Consider logging at DEBUG level instead of print()

### 🔴 Critical Issues
- **Security**: SQL injection risk in line 45 (use parameterized queries)
- **Performance**: N+1 query problem in loop (lines 30-35)

---
*This is an informational review - approval is not required for merge*
```

## 🔐 Permissions requises

| Permission | Raison |
|-----------|--------|
| `pull-requests: write` | Commenter sur les PRs |
| `contents: read` | Lire le code et les diffs |

## 🔑 Configuration

### Secrets requis
- `CLAUDE_API_KEY` : Clé API Anthropic

### Fichier de workflow
`.github/workflows/code-review-agent.yml`

## 🤖 Modèle LLM

| Propriété | Valeur |
|-----------|--------|
| **Provider** | Anthropic |
| **Model** | `claude-3-5-sonnet-20241022` |
| **Max Tokens** | 1024 |
| **Temperature** | 1.0 (défaut) |

### Alternative : Fallback sans API key
Si `CLAUDE_API_KEY` n'est pas défini, l'agent fourni une revue de base :
- Check de taille de fichiers
- Vérification de commits
- Rappel de configuration de clé API

## 📝 Aspects analysés

Le Code Reviewer évalue :

### 🔒 Sécurité
- Injections SQL / NoSQL
- Validation des inputs
- Gestion des secrets
- Autorisation / authentification
- Dépendances vulnérables

### 🚀 Performance
- N+1 queries
- Algorithmes inefficaces
- Utilisation mémoire
- Cache non utilisé

### 🏗️ Architecture
- Design patterns
- Responsabilité unique (SRP)
- Couplage / Cohésion
- Testabilité

### 📚 Documentation
- Docstrings / commentaires
- Type hints
- README / changelog

### 🎨 Style
- Conventions de code
- Readabilité
- Maintenabilité

## 💡 Points positifs & suggestions

### Strengths (✅)
Le reviewer met en avant :
- Code bien structuré
- Bonnes pratiques appliquées
- Tests complets
- Documentation claire
- Performance optimisée

### Suggestions (⚠️)
Le reviewer propose :
- Refactoring mineur
- Optimisations possibles
- Améliorations de documentation
- Style code inconsistant
- Pattern ou convention à suivre

**Non-bloquant** : Peut être implémenté plus tard

### Critical Issues (🔴)
Le reviewer signale :
- Bugs logiques
- Failles de sécurité
- Race conditions
- Memory leaks
- **Ces points devraient être corrigés avant merge**

## 🔄 Intégration avec autres agents

```
PR ouverte
    ↓
Code Review Agent (commentaire)
    ↓
CI Tests Agent (tests & build)
    ↓
Développeur corrige (si suggestions)
    ↓
Tests re-exécutés
    ↓
Team review & approve
    ↓
Merge + Project Board update
```

## 📊 Cas d'usage

### Quand c'est utile
- ✅ Junior developers → apprentissage rapide
- ✅ Large codebases → couverture sans bottleneck
- ✅ 24/7 review → asynchrone, pas limité par fuseaux horaires
- ✅ Quick feedback → identifier issues avant revue humaine

### Quand ce n'est pas suffisant
- ❌ Architecture majeure → nécessite expertise humaine
- ❌ Décisions de design → discussion d'équipe
- ❌ Breaking changes → revue manuelle requise

## 🚨 Limitations

| Limitation | Raison | Workaround |
|-----------|--------|-----------|
| Pas de contexte projet | Analyse locale du diff | Reviewer humain pour context métier |
| Pas de type checking | Pas d'AST full | CI-tests avec mypy/pylint |
| Pas d'exécution de code | Safety et performance | Tests unitaires requis |
| Pas de revue de sécurité complète | Surface analysis | Audit sécurité pour secrets/auth |

## 🔮 Améliorations futures

- [ ] Multi-langage support (Go, Java, Rust, TypeScript)
- [ ] Configuration de règles custom par projet
- [ ] Integration avec Sonarqube / CodeClimate
- [ ] Score de review (A/B/C/D)
- [ ] Suggestion de tests automatiques
- [ ] Détection de patterns (Copier/coller, code dupliqué)
- [ ] Analyse de complexité cyclomatique
- [ ] Documentation auto-générée

## 📋 Checklist pour les mainteneurs

Avant d'activer le Code Reviewer :

- [ ] Ajouter `CLAUDE_API_KEY` à GitHub Secrets
- [ ] Tester sur une PR pilote
- [ ] Vérifier le coût API (Anthropic billing)
- [ ] Définir les rules de code review team
- [ ] Former les developers à utiliser le feedback
- [ ] Itérer sur les prompts pour améliorer qualité
