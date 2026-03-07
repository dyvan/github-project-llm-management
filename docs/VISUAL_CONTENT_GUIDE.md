# 📸 Guide de Création de Contenu Visuel

Ce guide vous aide à créer des screenshots et vidéos pour améliorer la documentation du template.

---

## 📁 Structure des Fichiers

Créez le dossier pour stocker les images :

```bash
mkdir -p docs/images
mkdir -p docs/images/screenshots
mkdir -p docs/images/demo
```

---

## 🖼️ Screenshots à Créer

### 1. Screenshot : GitHub Template Button
**Fichier** : `docs/images/screenshots/01-use-template.png`

**À capturer** :
- Page GitHub du repository template
- Bouton vert "Use this template" bien visible
- Titre du repository en haut

**Comment** :
1. Allez sur https://github.com/dyvan/github-project-llm-management
2. Capturez la partie haute de la page avec le bouton
3. Annotez le bouton avec une flèche ou un cercle

**Utilisation** : README.md, Getting-Started.md

---

### 2. Screenshot : Setup Script en Action
**Fichier** : `docs/images/screenshots/02-setup-running.png`

**À capturer** :
- Terminal avec `./setup-project.sh` en cours d'exécution
- Messages colorés (✅, ❌, emojis)
- Au moins 2-3 étapes visibles

**Comment** :
1. Lancez `./setup-project.sh` dans un terminal
2. Capturez quand les étapes sont affichées
3. Assurez-vous que les couleurs sont visibles

**Utilisation** : Getting-Started.md, Scripts-Reference.md

---

### 3. Screenshot : GitHub Project Board Créé
**Fichier** : `docs/images/screenshots/03-project-board.png`

**À capturer** :
- Vue d'ensemble du Project Board
- Colonnes : Backlog, Ready, In Progress, In Review, Done
- Au moins 2-3 issues visibles
- Champs personnalisés (Priority, Effort, Type) visibles

**Comment** :
1. Allez sur votre GitHub Project (https://github.com/users/VOTRE_NOM/projects/X)
2. Vue "Table" pour voir les champs
3. Capturez toute la largeur du tableau

**Utilisation** : README.md, Using-The-Template.md, Configuration.md

---

### 4. Screenshot : Auto-Branch en Action
**Fichier** : `docs/images/screenshots/04-auto-branch-comment.png`

**À capturer** :
- Issue avec label `auto-branch`
- Commentaire automatique du bot avec commandes git
- Nouvelle branche créée visible

**Comment** :
1. Créez une issue
2. Ajoutez le label `auto-branch`
3. Attendez 30 secondes
4. Capturez le commentaire automatique

**Utilisation** : README.md, Understanding-Workflows.md

---

### 5. Screenshot : Code Review par Gemini AI
**Fichier** : `docs/images/screenshots/05-gemini-review.png`

**À capturer** :
- Pull Request avec commentaire de Gemini
- Suggestions d'amélioration
- Emojis et formatage markdown

**Comment** :
1. Créez une PR avec du code
2. Attendez la revue automatique de Gemini
3. Capturez le commentaire complet

**Utilisation** : README.md, Understanding-Workflows.md

---

### 6. Screenshot : GitHub Actions Workflows
**Fichier** : `docs/images/screenshots/06-github-actions.png`

**À capturer** :
- Onglet "Actions" du repository
- Liste des workflows (validation, tests, etc.)
- Statuts verts (✓) pour montrer que ça fonctionne

**Comment** :
1. Allez sur l'onglet "Actions" du repository
2. Capturez la liste des derniers runs
3. Assurez-vous que des checkmarks verts sont visibles

**Utilisation** : Understanding-Workflows.md, Template-Validation.md

---

### 7. Screenshot : Labels Configurés
**Fichier** : `docs/images/screenshots/07-labels.png`

**À capturer** :
- Page des labels du repository
- Labels organisés par catégorie (type:, status:, priority:)
- Couleurs distinctes

**Comment** :
1. Allez sur Issues → Labels
2. Capturez la liste complète
3. Montrez au moins 10-15 labels

**Utilisation** : Getting-Started.md, Configuration.md

---

### 8. Screenshot : Validation Script Output
**Fichier** : `docs/images/screenshots/08-validation.png`

**À capturer** :
- Terminal avec `./scripts/validate_setup.sh`
- Tous les checks passés (✅)
- Score final

**Comment** :
1. Lancez `./scripts/validate_setup.sh`
2. Capturez tout l'output
3. Assurez-vous que le score est visible

**Utilisation** : Getting-Started.md, Troubleshooting.md

---

## 🎬 Vidéo Démo à Créer

### Vidéo : Workflow Complet (2-3 minutes)
**Fichier** : Hébergé sur YouTube/Vimeo, lien dans README

**Script Détaillé** :

#### 0:00-0:15 - Introduction
- Montrer le README du template
- Texte à l'écran : "GitHub Project Management - Setup en 2 minutes"
- Expliquer brièvement : "Template clé-en-main pour gérer vos projets"

#### 0:15-0:45 - Étape 1 : Utiliser le Template
- Cliquer sur "Use this template"
- Remplir le nom du nouveau repository
- Cliquer sur "Create repository"
- Texte : "1️⃣ Créez votre repository depuis le template"

#### 0:45-1:15 - Étape 2 : Setup Script
- Cloner le repository localement
- Ouvrir un terminal
- Lancer `./setup-project.sh`
- Montrer les étapes qui s'exécutent (accéléré si besoin)
- Texte : "2️⃣ Lancez le script de setup automatique"

#### 1:15-1:45 - Étape 3 : Project Board
- Ouvrir le Project Board créé
- Montrer les colonnes
- Montrer les champs personnalisés
- Créer une issue rapidement
- Montrer qu'elle apparaît automatiquement dans le board
- Texte : "3️⃣ Votre Project Board est prêt !"

#### 1:45-2:15 - Étape 4 : Automations
- Ajouter le label `auto-branch` à une issue
- Montrer le commentaire automatique qui apparaît
- Créer une branche depuis les commandes
- Faire un commit et ouvrir une PR
- Texte : "4️⃣ Les automations fonctionnent : branches, reviews, sync"

#### 2:15-2:30 - Étape 5 : Code Review
- Montrer Gemini AI qui review la PR automatiquement
- Zoomer sur un commentaire de suggestion
- Texte : "5️⃣ Gemini AI review votre code automatiquement"

#### 2:30-2:45 - Conclusion
- Récapitulatif des bénéfices :
  - ✅ Project Board automatique
  - ✅ Branches auto-créées
  - ✅ Revue de code par IA
  - ✅ Tests automatiques
- Texte : "Prêt en 2 minutes. Aucune compétence technique requise."
- Afficher le lien du repository

#### 2:45-3:00 - Call to Action
- Texte : "Essayez maintenant !"
- Afficher : github.com/dyvan/github-project-llm-management
- Afficher : "⭐ Star le projet si ça vous aide !"

---

## 📝 Où Utiliser les Screenshots

### README.md
```markdown
## ⚡ Démarrage rapide

1. **Cliquez sur "Use this template"**
   ![Use Template](docs/images/screenshots/01-use-template.png)

2. **Lancez le setup**
   ```bash
   ./setup-project.sh
   ```
   ![Setup Running](docs/images/screenshots/02-setup-running.png)

3. **Votre Project Board est prêt !**
   ![Project Board](docs/images/screenshots/03-project-board.png)

**[Voir la vidéo démo complète (2 min) →](https://youtube.com/...)**
```

### docs/Getting-Started.md
Ajouter des screenshots pour chaque étape :
- Étape 1 : `01-use-template.png`
- Étape 2 : `02-setup-running.png`
- Étape 3 : `03-project-board.png`
- Étape 4 : `07-labels.png`
- Étape 5 : `08-validation.png`

### docs/Understanding-Workflows.md
Ajouter des screenshots pour expliquer :
- Auto-branch : `04-auto-branch-comment.png`
- Code review : `05-gemini-review.png`
- GitHub Actions : `06-github-actions.png`

### docs/Home.md (Wiki Homepage)
Ajouter la vidéo démo en haut :
```markdown
# 🚀 GitHub Project Management

**Vidéo de présentation (2 min)** : [Voir le workflow complet →](https://youtube.com/...)

![Project Board Example](docs/images/screenshots/03-project-board.png)
```

---

## 🛠️ Outils Recommandés

### Pour les Screenshots
- **macOS** : Cmd+Shift+4 (sélection), Cmd+Shift+3 (plein écran)
- **Windows** : Windows+Shift+S (Snipping Tool)
- **Linux** : `gnome-screenshot` ou `flameshot`
- **Annotation** : [Skitch](https://evernote.com/products/skitch) (gratuit)

### Pour la Vidéo
- **Screencast** :
  - [OBS Studio](https://obsproject.com/) (gratuit, multi-plateforme)
  - [Loom](https://www.loom.com/) (gratuit pour vidéos courtes)
  - macOS QuickTime (Cmd+Shift+5)
- **Montage** :
  - [DaVinci Resolve](https://www.blackmagicdesign.com/products/davinciresolve) (gratuit)
  - iMovie (macOS)
  - Windows Video Editor

### Pour l'Hébergement
- **YouTube** : Illimité, bon référencement
- **Vimeo** : Plus professionnel
- **Asciinema** : Pour les démos terminal (https://asciinema.org/)

---

## ✅ Checklist de Publication

Avant de mettre à jour la documentation :

- [ ] Tous les screenshots sont créés (8 fichiers)
- [ ] Screenshots sont en format PNG ou JPG
- [ ] Résolution minimum : 1920x1080 pour les screenshots larges
- [ ] Annotations claires (flèches, cercles) si nécessaire
- [ ] Vidéo démo enregistrée (2-3 minutes)
- [ ] Vidéo uploadée sur YouTube/Vimeo
- [ ] Vidéo a des sous-titres/captions (accessibilité)
- [ ] Lien vidéo testé (pas en privé)
- [ ] Tous les fichiers sont dans `docs/images/`
- [ ] README.md mis à jour avec les screenshots
- [ ] Wiki pages mises à jour avec les visuels
- [ ] Commit et push vers le repository

---

## 🎯 Résultat Attendu

Après avoir ajouté le contenu visuel :

1. **README.md** devient beaucoup plus engageant visuellement
2. **Wiki** a des guides illustrés faciles à suivre
3. **Vidéo démo** permet de comprendre en 2 minutes
4. **Taux d'adoption** augmenté (users comprennent plus vite)
5. **Questions réduites** (tout est montré visuellement)

---

## 📚 Ressources Supplémentaires

- [GitHub Docs - Images in Markdown](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#images)
- [GitHub Wiki Best Practices](https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis)
- [YouTube Video Optimization](https://creatoracademy.youtube.com/)

---

**Note** : Ce guide est un template. Adaptez-le selon vos besoins et votre style visuel !
