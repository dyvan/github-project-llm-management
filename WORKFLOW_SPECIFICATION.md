# 🎯 Spécification du Workflow Final

**Date** : 2025-11-14
**Statut** : 🟢 Définition validée
**Version** : 1.0

---

## 📋 Résumé des Décisions

### 1️⃣ Génération des User Stories
- **Approche** : IA Automatique
- **Déclencheur** : Commande Claude Code : `Generate user stories for feature #X`
- **Output** : N sub-issues créées avec format `US-<number> – <description>`
- **Localisation** : Backlog du board automatiquement

### 2️⃣ Création Automatique de la Branche
- **Approche** : Les deux (label + déplacement colonne)
  - Via label `auto-branch` (existant, garder)
  - Via déplacement en colonne `In Progress` (nouveau, ajouter)
- **Format** : `feat/<issue-number>-<slug>` (existant)
- **Moment** : Au moment de l'activation (label OU colonne)

### 3️⃣ Création Automatique de la PR
- **Approche** : Automatique après premier push
- **Déclencheur** : GitHub Actions détecte premier push sur branche
- **Format PR** :
  ```
  Title: feat(us-<number>): <description>
  Body:
    - Closes #<issue-number>
    - Specs: [reference to .specification.md]
    - Checklist
  ```
- **Placement** : Automatiquement en colonne `In Review`

### 4️⃣ Stockage des Spécifications (QCM)
- **Flux** :
  1. User story → Colonne `Ready/Plan`
  2. GitHub Actions ajoute **commentaire avec QCM**
  3. User répond aux questions
  4. Réponses enregistrées dans **commentaire épinglé**
  5. Claude Code génère **`.specification.md`** dans la branche
  6. **Historique centralisé** : fichier de log/audit des QCM répondus

- **Stockage Hiérarchique** :
  ```
  Issue #X
    ├── Commentaire épinglé (QCM original + réponses)
    ├── Custom field "Spec Status" (None/Pending/Completed)
    └── Branche feat/X-Y
        └── .specification.md (prêt pour Claude Code)

  Audit central :
    └── docs/project-specs-history/ (historique de tous les QCM)
  ```

### 5️⃣ Fermeture Automatique de la Feature
- **Approche** : Oui, automatique
- **Condition** : Tous les user stories (sub-issues) = Done
- **Action** :
  - Feature passe à `Done`
  - Peut être archivée du board
- **Workflow** : GitHub Actions vérification hebdomadaire (ou sur chaque modification)

### 6️⃣ Implémentation du QCM
- **Tech** : GitHub Actions (native)
- **Interaction** : Commentaire avec questions numérotées + réactions (✅ pour valider)
- **Stockage** : Commentaire épinglé + `.spec.md` dans branche
- **Historique** : Centralisé dans `docs/project-specs-history/spec-<issue-id>.md`
- **Issue Dédiée** : #37 (TODO, non implémentée maintenant)

### 7️⃣ Naming Convention
- **Issues mères (Features)** : Titre descriptif libre
- **Sub-issues (User Stories)** : `US-<number> – <description>`
  - Exemple : `US-42 – Login Form Integration`
- **Branches** : `feat/<issue-number>-<slug>` (existant)
- **PRs** : `feat(us-<number>): <description>`

### 8️⃣ Gestion des Blockers
- **Colonne** : ✅ Ajouter colonne `Blocked`
- **Déclencheur** :
  - Manuel : Déplacement issue vers `Blocked`
  - Optionnel : Label `blocked` pour détection automatique
- **Custom field** : Ajouter "Blocker Reason" (texte) pour documenter

---

## 🎯 Colonnes du Board (Finales)

```
1. Backlog
   ├── Issues mères (Features)
   └── User Stories non sélectionnées

2. Ready / Planning
   ├── User Stories à spécifier
   └── QCM en cours

3. In Progress
   ├── Branche créée et en développement
   └── User Story active

4. Blocked
   └── Dépendances externes ou problèmes

5. In Review
   ├── PR ouverte
   └── En attente de validation

6. Done
   ├── PR mergée
   ├── User Story complétée
   └── Feature complétée (si 100% US Done)
```

---

## 🛠️ Custom Fields à Créer/Modifier

| Field | Type | Values |
|-------|------|--------|
| **Type** | Single Select | Feature / User Story / Bug / Technical Task |
| **Priority** | Single Select | High / Medium / Low |
| **Effort** | Single Select | 1 / 2 / 3 / 5 / 8 |
| **Spec Status** | Single Select | None / Pending / Completed |
| **Parent Issue** | Text | #X (Feature id) |
| **Branch Name** | Text | feat/X-slug |
| **Blocker Reason** | Text | (libre, si Blocked) |

---

## 🏗️ Entités Finales

```
Feature (Issue)
  ├── Type: Feature
  ├── Custom field "Spec Status": None
  └── Sub-issues (1..N)
        ├── Type: User Story
        ├── Title: US-X – description
        ├── Parent Issue: #Feature
        ├── Spec Status: Pending (after QCM)
        ├── Branch: feat/X-Y (created in In Progress)
        └── PR: #Y (created after first push)
              ├── Description: Closes #US-X
              ├── Spec: .specification.md
              └── Status: In Review → Done
```

---

## 📊 Workflow Complet (Chronologique)

```
1. Créer Feature
   Issue #X créée → Board Backlog → Status: None

2. Générer User Stories (Manuel OU IA)
   Claude Code: "Generate user stories for #X"
   → Crée US-1, US-2, US-3... → Backlog

3. Sélectionner US pour Planifier
   Vous: Déplacer US-1 → Ready/Plan
   → GitHub Actions ajoute QCM commentaire
   → Spec Status: Pending

4. Répondre au QCM
   Vous: Réagissez ou commentez avec réponses
   → Commentaire épinglé mis à jour
   → Spec Status: Completed

5. Commencer le Développement
   Vous: Déplacer US-1 → In Progress
   → Branche créée automatiquement (feat/X-1-slug)
   → Cloner branche localement

6. Claude Code Développe
   Claude Code:
   ├── Lit .specification.md (créé après QCM)
   ├── Implémente la feature
   ├── Commit et push
   → GitHub Actions détecte premier push

7. PR Créée Automatiquement
   GitHub Actions:
   ├── Crée PR avec "Closes #US-1"
   ├── Ajoute .specification.md en description
   ├── Ajoute checklist
   → PR au board en In Review automatiquement

8. Validation
   Vous: Vérifiez et mergez
   → GitHub Actions:
      ├── Marque PR → Done
      ├── Marque US-1 → Done
      ├── Ferme issue #US-1
      ├── Vérifie si Feature 100% US Done
      └── Si oui → Feature → Done

9. Historique QCM
   GitHub Actions sauvegarde réponses dans:
   docs/project-specs-history/spec-US-1.md
```

---

## 🚀 Phases d'Implémentation

### Phase 1 : Correction du Workflow Actuel ⚡
- [ ] Corriger `update-project.yml` (n'ajouter que PRs)
- [ ] Ajouter déclencheur "issue → In Progress" = crée branche
- [ ] Ajouter déclencheur "first push" = crée PR

### Phase 2 : Custom Fields & Labels 🏗️
- [ ] Ajouter custom fields (Spec Status, Parent Issue, Branch Name, Blocker Reason)
- [ ] Ajouter colonne "Blocked"
- [ ] Ajouter labels (us, needs-spec, blocked)

### Phase 3 : Automatisations 🤖
- [ ] Auto-branch on In Progress (+ garder label)
- [ ] Auto-PR creation on first push
- [ ] Auto-close parent Feature (100% US Done)

### Phase 4 : Historique & QCM 📝
- [ ] Créer structure `docs/project-specs-history/`
- [ ] Implémenter GitHub Actions pour QCM (#37)
- [ ] Implémenter sauvegarde historique QCM

### Phase 5 : IA & Génération 🧠
- [ ] Claude Code command: "Generate user stories for #X"
- [ ] Intégration avec CLAUDE.md

### Phase 6 : Documentation 📚
- [ ] Mettre à jour CLAUDE.md avec nouveau workflow
- [ ] Créer WORKFLOW_DIAGRAM.md (visual)

---

## 📝 Notes Importantes

1. **Historique QCM** : Nouveau besoin identifié
   - Centraliser tous les QCM répondus
   - Traçabilité des décisions techniques
   - Référence pour futures features similaires

2. **Spec Status Field** : Critique
   - Track si spécifications sont complètes avant dev
   - Évite les PRs sans contexte

3. **Parent Issue Field** : Essentiel
   - Lie les US aux Features
   - Permet auto-close Feature à 100% US Done

4. **Blockers Management** : Flexible
   - Colonne visuelle pour les blockers
   - Permet identification rapide des dépendances

---

**Prêt pour implémentation ? 🚀**
