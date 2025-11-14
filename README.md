# 🚀 GitHub Project Management - Template Automatisé

[![Template Validation](https://github.com/dyvan/github-project-llm-management/actions/workflows/template-validation.yml/badge.svg)](https://github.com/dyvan/github-project-llm-management/actions/workflows/template-validation.yml)
[![CI Tests](https://github.com/dyvan/github-project-llm-management/actions/workflows/ci-tests.yml/badge.svg)](https://github.com/dyvan/github-project-llm-management/actions/workflows/ci-tests.yml)

**Template clé-en-main pour gérer vos projets avec GitHub**
Kanban automatique • Issues intelligentes • Revue de code IA • Zéro configuration

## 💡 C'est pour qui ?

✅ **Product managers** qui veulent organiser leur backlog sans coder
✅ **Chefs de projet** qui veulent un suivi automatique
✅ **Équipes** qui veulent GitHub Projects synchronisé automatiquement
✅ **Développeurs** qui veulent un projet géré par LLM (Claude Code, etc.)

**Aucune compétence technique requise** - Tout est automatisé 🎯

---

## ⚡ Démarrage rapide (Une seule commande!)

### Option 1️⃣: Curl + Bash (Recommandé)

```bash
curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash
```

C'est tout! Le script va:
1. 📁 Demander le nom de votre projet
2. 🔄 Cloner le template
3. 🚀 Lancer le bootstrap automatiquement
4. ✅ Configurer tout

### Option 2️⃣: Clone + Bootstrap Manuel

Si vous préférez plus de contrôle:

```bash
git clone https://github.com/dyvan/github-project-llm-management.git mon-projet
cd mon-projet
bash scripts/bootstrap.sh
```

### Que fait le bootstrap?

Le script vous demande:
- **GitHub Token** - Pour créer issues, labels, et project board
- **Gemini API Key** - Pour génération QCM (optionnel)

**Puis deux chemins possibles:**

#### ✅ Avec un GitHub Token?
Bootstrap lance automatiquement `template-setup.sh`:
- 🏷️ Labels GitHub créés
- 📊 Project Board initialisé
- 🔄 Workflows configurés
- **C'est prêt!** Créez votre première issue

#### ⏸️ Sans token?
Bootstrap affiche les instructions pour:
1. Générer un token GitHub (avec les scopes exacts)
2. L'ajouter à `.env`
3. Relancer `bash template-setup.sh` manuellement

**Zéro configuration requise!** 🎉

➡️ **[Configuration avancée](../../wiki)** • **[Guide complet](#-documentation)**

---

## 🎯 Qu'est-ce que ça fait ?

| Fonctionnalité | Description |
|----------------|-------------|
| 📋 **Project Board auto** | Issues ajoutées automatiquement au Kanban |
| 🌿 **Branches automatiques** | Ajoutez le label `auto-branch`, la branche est créée |
| 📝 **QCM de spécification** | Gemini génère un questionnaire pour clarifier les specs |
| 🤖 **Revue de code IA** | Claude analyse vos PRs et suggère des améliorations |
| ✅ **Tests automatiques** | Chaque PR est validée automatiquement |
| 🔄 **Synchronisation** | Status mis à jour automatiquement (Backlog → Done) |

**Voir en vidéo** : [Comment ça fonctionne en 2 minutes](../../wiki/Understanding-Workflows)

---

## 📚 Documentation

**Pour commencer :**
- 🚀 [Guide de démarrage](../../wiki/Getting-Started) - Setup en 5 minutes
- ⚙️ [Configuration](../../wiki/Configuration) - Personnaliser le template
- 🎓 [Utiliser le template](../../wiki/Using-The-Template) - Guide complet

**Pour approfondir :**
- 🔧 [Scripts & Automation](../../wiki/Scripts-Reference) - Comprendre les scripts
- 🔀 [Automations GitHub](../../wiki/Understanding-Workflows) - Comment ça marche
- ❓ [FAQ](../../wiki/FAQ) - Questions fréquentes
- 🐛 [Dépannage](../../wiki/Troubleshooting) - Résoudre les problèmes

**Pour contribuer :**
- 🤝 [Guide de contribution](../../wiki/Contributing) - Comment participer
- 🎨 [Personnalisation avancée](../../wiki/Advanced-Customization) - Adapter à vos besoins

➡️ **[📖 Voir toute la documentation](../../wiki)**

---

## 💬 Besoin d'aide ?

- ❓ **Question ?** → [Discussions](../../discussions)
- 🐛 **Bug ?** → [Ouvrir une issue](../../issues)
- 📖 **Documentation** → [Wiki complet](../../wiki)

---

## ⭐ Fonctionnalités principales

### Automatisation Project Board
- ✅ Issues ajoutées automatiquement au backlog
- ✅ Statuts mis à jour selon les labels
- ✅ Champs personnalisés (Priority, Effort, Type)

### Création de branches automatique
- ✅ Label `auto-branch` → branche créée instantanément
- ✅ Naming automatique (`feat/123-titre-issue`)
- ✅ Commentaire posté avec commandes git

### QCM de spécification avec Gemini
- ✅ Label `plan-with-gemini` → questionnaire généré automatiquement
- ✅ Questions adaptées au type d'issue (Feature, Bug, Task)
- ✅ Clarification des specs avant implémentation
- ✅ QCM posté en commentaire sur l'issue

### Revue de code par IA
- ✅ Analyse automatique des PRs par Claude AI
- ✅ Suggestions d'amélioration
- ✅ Détection de bugs potentiels

### Tests intégrés
- ✅ Vérification automatique sur chaque PR
- ✅ Validation de tous les fichiers
- ✅ Rapport de qualité du code

---

## 📄 Licence

MIT License - Libre d'utilisation pour tout projet

---

**Créé avec ❤️ pour simplifier la gestion de projet sur GitHub**

[Documentation](../../wiki) • [Support](../../discussions) • [Contribuer](../../wiki/Contributing)
