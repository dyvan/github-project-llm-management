# 🧪 Plan de Test - Phases 1 & 2

**Date**: 2025-11-14
**Statut**: À Exécuter
**Phases Couvertes**: Phase 1 (Board-first workflow) + Phase 2 (Infrastructure)

---

## 📋 Checklist Pre-Test

- [ ] Main branch est à jour avec PR #38 et PR #39 mergées
- [ ] `.env` contient `GH_PROJECT_NUMBER=3` (ou valeur correcte)
- [ ] `GH_TOKEN` secret est configuré avec permissions `project`
- [ ] Repository est sur GitHub
- [ ] Accès au board project v2 (https://github.com/users/dyvan/projects/3)

---

## 🎯 Test 1: Labels Creation

**Objectif**: Vérifier que les 3 nouveaux labels sont bien créés

### Étapes

1. Exécutez l'étape 3 du setup manuellement:
```bash
bash template/.setup/steps/3-init-labels.sh
```

2. Vérifiez les labels dans GitHub:
```bash
gh label list
```

### Résultats Attendus

- ✅ Labels existants intacts:
  - `type:feature`, `type:bug`, `type:task`, `type:docs`, `type:infrastructure`
  - `priority:high`, `priority:medium`, `priority:low`
  - `status:backlog`, `status:ready`, `status:in-progress`, `status:in-review`, `status:blocked`, `status:done`
  - `auto-branch`, `good-first-issue`, `help-wanted`

- ✅ Nouveaux labels créés:
  - `us` (purple)
  - `needs-spec` (red)
  - `blocked` (dark red)

### Command de Vérification
```bash
gh label list | grep -E "us|needs-spec|blocked"
# Expected: 3 lignes
```

---

## 🎯 Test 2: Custom Fields Creation

**Objectif**: Vérifier que les nouveaux custom fields sont créés sur le board

### Étapes

1. Exécutez le script de setup des champs:
```bash
python3 scripts/setup_project_fields.py --project-number 3 --owner dyvan
```

2. Allez sur le board: https://github.com/users/dyvan/projects/3

3. Vérifiez la vue "Settings" du projet

### Résultats Attendus

**Champs Single Select à vérifier**:
- ✅ **Status**: Backlog, Ready, In progress, In review, Blocked, Done
- ✅ **Type**: Feature, User Story, Bug, Task, Docs, Infrastructure (avec "User Story" nouveau)
- ✅ **Priority**: Low, Medium, High
- ✅ **Effort**: 1, 2, 3, 5, 8
- ✅ **Spec Status** (NOUVEAU): None, Pending, Completed

**Champs Text à vérifier**:
- ✅ **Target Version**
- ✅ **Parent Issue** (NOUVEAU)
- ✅ **Branch Name** (NOUVEAU)
- ✅ **Blocker Reason** (NOUVEAU)

### Vérification Visuelle
1. Ouvrez board settings
2. Allez dans "Custom fields"
3. Comptez les champs: doit y avoir 9 au total
4. Vérifiez que "Blocked" apparaît dans Status dropdown

---

## 🎯 Test 3: Helper Script `start-work.sh`

**Objectif**: Vérifier que le script simplifie le démarrage du travail

### Prérequis
- Une issue de test (ex: issue #42 ou créer temporaire)

### Étapes

1. Exécutez le script helper:
```bash
./tools/start-work.sh 20
```

2. Vérifiez que le label `auto-branch` a été ajouté:
```bash
gh issue view 20 --json labels
```

3. Attendez quelques secondes et vérifiez que la branche a été créée:
```bash
git fetch origin
git branch -r | grep feat/20
```

### Résultats Attendus

- ✅ Label `auto-branch` visible sur issue #20
- ✅ Branche `feat/20-generate-and-copy-claude-md-during-setup` créée automatiquement
- ✅ Issue #20 passe en "In progress" sur le board (vérifiez manuellement)

---

## 🎯 Test 4: Auto-PR Creation on First Push

**Objectif**: Vérifier que les PRs sont créées automatiquement sur first push

### Prérequis
- Une branche de test (ex: feat/999-test-feature)
- Ou créer temporairement

### Étapes

1. Créez une branche de test:
```bash
git checkout -b feat/999-test-auto-pr
git push -u origin feat/999-test-auto-pr
```

2. Vérifiez que la PR a été créée automatiquement:
```bash
gh pr list --head feat/999-test-auto-pr
```

3. Vérifiez le contenu de la PR créée:
```bash
gh pr view <pr-number> --json title,body
```

### Résultats Attendus

- ✅ PR créée automatiquement
- ✅ Titre: `feat(us-999): test auto pr` (ou similaire)
- ✅ Body contient: `Closes #999`
- ✅ Body contient checklist
- ✅ PR visible dans board colonne "In review"

### Cleanup
```bash
git branch -D feat/999-test-auto-pr
gh pr close <pr-number>
gh branch delete origin feat/999-test-auto-pr
```

---

## 🎯 Test 5: Status Consistency (Lowercase)

**Objectif**: Vérifier que les statuts sont en minuscule

### Étapes

1. Vérifiez le workflow `update-project.yml`:
```bash
grep -n "In progress\|In review" .github/workflows/update-project.yml
```

2. Vérifiez le script de sync:
```bash
grep -n "In progress\|In review" scripts/project_sync.py
```

3. Vérifiez le custom field Status:
```bash
python3 scripts/setup_project_fields.py --project-number 3 --owner dyvan | grep Status
```

### Résultats Attendus

- ✅ Workflow: `"In progress"` (minuscule)
- ✅ Workflow: `"In review"` (minuscule)
- ✅ Custom field: `"In progress"`, `"In review"` (minuscule)
- ✅ Pas de majuscules incohérentes

---

## 🎯 Test 6: Full Workflow Integration

**Objectif**: Tester le flux complet end-to-end

### Prérequis
- Issue de test (ex: #20)
- Board vide ou cloisonné pour test

### Étapes Complètes

**Étape 1: Créer une issue (reste en Backlog GitHub)**
```bash
# Issue #20 existe déjà
# Status: Backlog (pas encore sur board)
```

**Étape 2: Lancer le travail (déplace en In progress)**
```bash
./tools/start-work.sh 20
# ↓
# Auto: Label auto-branch ajouté
# Auto: Branche feat/20-... créée
# Auto: Issue #20 va en "In progress" sur board
```

**Étape 3: Développer et pusher**
```bash
git fetch origin
git checkout feat/20-...
echo "test" >> README.md
git add README.md
git commit -m "feat: test for phase 1-2 workflow (#20)"
git push
# ↓
# Auto: GitHub Actions détecte first push
# Auto: PR créée avec "Closes #20"
# Auto: PR ajoutée à board en "In review"
```

**Étape 4: Valider et merger**
```bash
gh pr merge <pr-number> --squash --delete-branch
# ↓
# Auto: PR va en "Done"
# Auto: Issue #20 va en "Done"
# Auto: Les deux disparaissent (ou restent archivés)
```

### Résultats Attendus à Chaque Étape

| Étape | GitHub Status | Board Status | Notes |
|-------|---------------|--------------|-------|
| **Créée** | Open (Backlog) | ❌ Pas visible | Dans GitHub backlog seulement |
| **start-work** | Open + auto-branch label | In progress ✅ | Issue ajoutée au board |
| **First push** | Open + PR | PR en In review ✅ | Deux entrées: Issue + PR |
| **Mergée** | Closed | Done ✅ | Les deux fermées/complétées |

### Vérification Visuelle Board
1. Ouvrez https://github.com/users/dyvan/projects/3
2. Vérifiez chaque colonne avant/après chaque action

---

## 🚨 Issues Connues à Monitorer

### Issue 1: Doublon Issue + PR en "In Review"
**Symptôme**: Quand on crée une PR, on voit l'issue ET la PR sur le board
**Attendu**: C'est normal! (Issue #20 identifiée au début)
**Status**: À résoudre en Phase 3 (logique métier: masquer issue si PR existe)

### Issue 2: Auto-PR si branche existe déjà
**Symptôme**: PR non créée si branche est pushée en second
**Attendu**: Workflow vérifie d'abord si PR existe
**Test**: Repousher sur même branche - pas de nouvelle PR

### Issue 3: Permissions GITHUB_TOKEN
**Symptôme**: Auto-PR échoue avec erreur de permissions
**Solution**: Vérifier `GH_TOKEN` secret dans Settings → Secrets

---

## ✅ Checklist Finale

Après tous les tests, vérifiez:

- [ ] Test 1: Labels créés (3 nouveaux + existants)
- [ ] Test 2: Custom fields sur board (9 totals)
- [ ] Test 3: Helper script fonctionne
- [ ] Test 4: Auto-PR création fonctionne
- [ ] Test 5: Statuts en minuscule (cohérent)
- [ ] Test 6: Workflow complet marche end-to-end
- [ ] Board: Colonnes visibles et utilisables
- [ ] Board: Custom fields fonctionnels
- [ ] Documentation: WORKFLOW_SPECIFICATION.md exact
- [ ] Scripts: tools/start-work.sh exécutable et compréhensible

---

## 📝 Résultats du Test

**Quand vous terminez les tests, documentez ici**:

### Résultats par Test
- Test 1: ✅ / ⚠️ / ❌
- Test 2: ✅ / ⚠️ / ❌
- Test 3: ✅ / ⚠️ / ❌
- Test 4: ✅ / ⚠️ / ❌
- Test 5: ✅ / ⚠️ / ❌
- Test 6: ✅ / ⚠️ / ❌

### Issues Rencontrées
(Documenter toute issue et sa résolution)

### Prêt pour Phase 3?
- [ ] Oui, tout fonctionne
- [ ] Non, problèmes identifiés (lister)

---

**Plan suivant**: Selon résultats, continuer Phase 3 ou corriger Phases 1-2.
