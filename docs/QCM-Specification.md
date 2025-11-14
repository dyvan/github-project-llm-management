# QCM Specification avec Gemini

## 📋 Vue d'ensemble

La fonctionnalité **QCM Specification** utilise l'intelligence artificielle Gemini pour générer automatiquement un questionnaire de spécification personnalisé lorsqu'une issue est prête à être planifiée. Ce questionnaire aide à clarifier les détails techniques et fonctionnels avant de démarrer l'implémentation.

## 🎯 Objectif

Cette fonctionnalité permet de :

- **Clarifier les exigences** avant le démarrage du développement
- **Identifier les ambiguïtés** dans les descriptions d'issues
- **Standardiser** le processus de collecte des spécifications
- **Améliorer la qualité** des implémentations grâce à une meilleure préparation
- **Réduire les allers-retours** entre développeurs et product owners

## 🚀 Comment l'utiliser

### Méthode 1 : Automatique via Label

1. **Créer ou sélectionner une issue** dans votre projet GitHub
2. **Déplacer l'issue dans la colonne "Ready"** de votre Project Board
3. **Ajouter le label `plan-with-gemini`** à l'issue
4. **Attendre quelques secondes** - Un workflow GitHub Actions va se déclencher
5. **Consulter le commentaire** - Le QCM sera posté automatiquement en commentaire

### Méthode 2 : Manuelle via Workflow Dispatch

1. Aller dans l'onglet **Actions** de votre repository
2. Sélectionner le workflow **"Plan with Gemini QCM"**
3. Cliquer sur **"Run workflow"**
4. Entrer le numéro de l'issue
5. Cliquer sur **"Run workflow"** pour démarrer

## 📝 Types de Questions Générées

Le QCM s'adapte automatiquement au type d'issue :

### Pour les Features (`type:feature`)

- **Périmètre de la fonctionnalité** (MVP vs feature complète)
- **Interface utilisateur** (UI/UX attendue)
- **Intégration et dépendances** (systèmes affectés)
- **Performance et scalabilité** (contraintes de performance)
- **Question ouverte** pour détails supplémentaires

### Pour les Bugs (`type:bug`)

- **Sévérité et impact** (criticité du bug)
- **Reproductibilité** (fréquence et conditions)
- **Environnement affecté** (dev, staging, prod)
- **Approche de correction** (hotfix vs correction complète)
- **Question ouverte** pour logs et debugging

### Pour les Tasks (`type:task`)

- **Objectif principal** (refactoring, setup, documentation)
- **Approche technique** (plan technique vs investigation)
- **Dépendances et blocages** (prérequis)
- **Critères de succès** (livrables attendus)
- **Question ouverte** pour contraintes spécifiques

## ⚙️ Configuration

### Prérequis

1. **Clé API Gemini** : Obtenir une clé sur [Google AI Studio](https://ai.google.dev/gemini-api/docs/api-key)
2. **Secret GitHub** : Configurer `GEMINI_API_KEY` dans les secrets du repository

### Configuration du Secret

```bash
# Dans les paramètres GitHub de votre repository
Settings → Secrets and variables → Actions → New repository secret

Name: GEMINI_API_KEY
Value: <votre-clé-api-gemini>
```

### Variables d'environnement (optionnel)

Vous pouvez également configurer dans `.env` pour les tests locaux :

```bash
GEMINI_API_KEY=your_gemini_api_key_here
GH_TOKEN=your_github_token_here
GH_OWNER=your_github_username
GH_REPO=project-name
```

## 🔧 Utilisation en ligne de commande

Le script peut aussi être exécuté manuellement :

```bash
# Générer un QCM pour l'issue #42
python scripts/generate_qcm.py --issue 42

# Générer et poster automatiquement en commentaire
python scripts/generate_qcm.py --issue 42 --post-comment

# Sauvegarder dans un fichier
python scripts/generate_qcm.py --issue 42 --output qcm-issue-42.md
```

### Options disponibles

| Option | Description |
|--------|-------------|
| `--issue` | Numéro de l'issue (requis) |
| `--owner` | Propriétaire du repository (optionnel, par défaut depuis env) |
| `--repo` | Nom du repository (optionnel, par défaut depuis env) |
| `--post-comment` | Poster le QCM en commentaire sur l'issue |
| `--output` | Fichier de sortie pour sauvegarder le QCM |

## 📊 Workflow GitHub Actions

Le workflow `.github/workflows/plan-with-gemini.yml` :

- **Se déclenche sur** : Label `plan-with-gemini` ajouté à une issue
- **Peut aussi être déclenché** : Manuellement via workflow_dispatch
- **Génère** : Un QCM personnalisé avec Gemini
- **Poste** : Le QCM en commentaire sur l'issue
- **Ajoute** : Le label `qcm-generated` une fois terminé

### Diagramme du processus

```
Issue créée → Déplacée vers "Ready" → Label "plan-with-gemini" ajouté
                                              ↓
                                    Workflow GitHub Actions déclenché
                                              ↓
                                    Script Python exécuté
                                              ↓
                                    Gemini génère le QCM
                                              ↓
                                    QCM posté en commentaire
                                              ↓
                                    Label "qcm-generated" ajouté
```

## 🎨 Format du QCM

Le QCM généré suit ce format Markdown :

```markdown
## 🎯 Questionnaire de Spécification

> Ce questionnaire vous aide à préciser les détails...

### Question 1: [Titre de la question]

**Contexte:** [Pourquoi cette question est importante]

- [ ] Option A: [Description]
- [ ] Option B: [Description]
- [ ] Option C: [Description]

### Question Ouverte: Informations Supplémentaires

**Y a-t-il des détails importants à considérer ?**

[Espace pour réponse libre]

---

**Instructions:** Veuillez cocher les options pertinentes...
```

## 🔍 Exemple de Résultat

Pour une issue de feature demandant "Ajouter un mode sombre", le QCM pourrait inclure :

1. **Périmètre** : Toggle simple vs thème complet personnalisable
2. **Persistance** : localStorage vs préférences utilisateur en DB
3. **Détection auto** : Respecter la préférence système ou non
4. **Composants** : Quels éléments de l'UI doivent supporter le mode sombre
5. **Question ouverte** : Couleurs spécifiques, accessibilité, etc.

## ❓ FAQ

### Comment personnaliser les questions ?

Les questions sont générées par Gemini en fonction du contenu de l'issue. Pour obtenir des questions plus pertinentes :

- Fournissez une description détaillée dans l'issue
- Utilisez les templates d'issue appropriés
- Ajoutez du contexte dans la section "Motivation"

### Que faire si le QCM n'est pas généré ?

1. Vérifier que `GEMINI_API_KEY` est configuré dans les secrets
2. Consulter les logs du workflow dans l'onglet Actions
3. Vérifier que le quota API Gemini n'est pas dépassé
4. Réessayer en retirant puis rajoutant le label

### Puis-je modifier le template du QCM ?

Oui ! Modifiez la méthode `_generate_template_qcm()` dans `scripts/generate_qcm.py` pour personnaliser les templates de fallback.

### Le QCM peut-il être régénéré ?

Oui, retirez le label `plan-with-gemini` puis rajoutez-le pour déclencher une nouvelle génération.

## 🛠️ Dépannage

### Erreur : "GEMINI_API_KEY not set"

**Solution** : Configurez le secret `GEMINI_API_KEY` dans les paramètres du repository.

### Erreur : "API rate limit exceeded"

**Solution** : Attendez quelques minutes ou utilisez une clé API avec un quota plus élevé.

### Le workflow ne se déclenche pas

**Vérifications** :
- Le label exact est `plan-with-gemini` (sensible à la casse)
- Le workflow file existe dans `.github/workflows/`
- Les permissions du GITHUB_TOKEN sont correctes

### Le commentaire n'est pas posté

**Vérifications** :
- Le token GitHub a les permissions `issues: write`
- L'issue n'est pas verrouillée
- Consulter les logs du workflow pour plus de détails

## 📚 Ressources

- [Documentation Gemini API](https://ai.google.dev/gemini-api/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Script generate_qcm.py](../scripts/generate_qcm.py)
- [Workflow plan-with-gemini.yml](../.github/workflows/plan-with-gemini.yml)

## 🔄 Intégration avec le workflow existant

Cette fonctionnalité s'intègre avec le workflow de gestion de projet existant :

1. **Backlog** → Issue créée
2. **Ready** → Label `plan-with-gemini` ajouté → QCM généré
3. **Répondre au QCM** → Équipe répond aux questions
4. **In Progress** → Label `auto-branch` ajouté → Branche créée
5. **In Review** → PR ouverte
6. **Done** → PR mergée

## 🎯 Bonnes Pratiques

1. **Ajoutez le label `plan-with-gemini`** systématiquement pour les features complexes
2. **Répondez au QCM** avant d'ajouter le label `auto-branch`
3. **Conservez les réponses** dans l'issue pour référence future
4. **Itérez si nécessaire** en régénérant le QCM si des questions restent
5. **Documentez les décisions** prises suite au QCM dans l'issue

## 📈 Métriques et Suivi

Le label `qcm-generated` permet de suivre :
- Nombre d'issues ayant reçu un QCM
- Taux de complétion des questionnaires
- Impact sur la qualité des implémentations
