# GitHub Projects v2 Configuration

## 📊 Overview

GitHub Projects v2 est votre **dashboard central** pour gérer tous les travaux du projet avec visibilité complète et mises à jour automatiques.

## 🎯 Setup Initial

### 1. Créer le Project

1. Allez à votre repository
2. Cliquez l'onglet **Projects**
3. Cliquez **New project**
4. Choisissez :
   - Nom : `Project Board`
   - Template : **Table** (or Kanban)
   - Visibility : Public

### 2. Configurer les Champs Personnalisés

Dans **Settings → Custom fields** :

| Champ | Type | Options | Requis |
|-------|------|---------|--------|
| **Priority** | Single select | Low, Medium, High | Non |
| **Effort** | Single select | 1, 2, 3, 5, 8 | Non |
| **Status** | Single select | Backlog, In Progress, In QA, Done | Oui |
| **Owner** | People | (auto) | Non |
| **Sprint** | Text | (custom) | Non |
| **Environment** | Single select | dev, preprod, prod | Non |

### 3. Créer les Vues

#### Vue 1: Backlog (Table)
**Colonnes** :
- Title
- Priority
- Effort
- Owner
- Status
- Sprint

**Filtres** :
- Status is not Done

**Tri** :
- Created date (oldest first)

**Utilisation** : Planification, estimation, priorisation

#### Vue 2: Priority Board (Kanban)
**Groupage** : Status
- **Backlog** : Non commencé
- **In Progress** : En développement
- **In QA** : Testing/Review
- **Done** : Complété

**Filtres** :
- Priority = High OR Medium

**Tri** : Priority (highest first)

**Utilisation** : Vue d'exécution, tracking en temps réel

#### Vue 3: Team Items (Table)
**Colonnes** :
- Title
- Owner
- Sprint
- Status
- Due Date

**Filtres** :
- Owner = @me (for personal view)

**Tri** :
- Sprint, then Status

**Utilisation** : Suivi personnel, planning de sprint

## 🔄 Workflow Integration

### Auto-Updates

Les workflows mettent à jour le project automatiquement :

```yaml
# Dans .github/workflows/update-project.yml
# Déclenché après chaque action
```

**Actions** :
- Issue créée → Ajoutée au Backlog
- Label `auto-branch` ajouté → Status reste Backlog
- PR ouverte → Status → In QA
- Tests passent → Status → Ready for Merge
- PR mergée → Status → Done

### Manual Updates

Vous pouvez aussi manuellement :
1. Drag & drop items entre statuts
2. Éditer les champs
3. Ajouter des notes

## 📋 Field Details

### Priority
```
Low     = Nice to have, no urgency
Medium  = Important, should do
High    = Critical, must do
```

### Effort (Story Points)
```
1 = Trivial (30 mins)
2 = Small (2-4 hours)
3 = Medium (1 day)
5 = Large (2-3 days)
8 = XL (1+ week)
```

### Status
```
Backlog      = Not started, awaiting prioritization
In Progress  = Being actively worked on
In QA        = Testing, code review, validation
Done         = Completed, merged, ready for use
```

### Owner
Auto-populated from issue assignee. Can be manually set.

### Sprint
Free-text field for sprint identification:
```
v1.0 (initial release)
v1.1 (patch release)
Sprint 1, Sprint 2, etc.
```

### Environment
For tracking which environment feature is deployed:
```
dev    = In development/testing
preprod = Validated, ready for production
prod   = Live in production
```

## 📊 Sample Views

### Backlog View
```
┌─────────────────────────────────────────────┐
│ Title              │ Priority │ Effort │ Status │
├─────────────────────────────────────────────┤
│ Add authentication │ High     │ 5      │ Backlog│
│ User profiles      │ Medium   │ 3      │ Backlog│
│ Dark mode          │ Low      │ 2      │ Backlog│
└─────────────────────────────────────────────┘
```

### Priority Board (Kanban)
```
Backlog          In Progress       In QA         Done
┌─────────┐     ┌─────────┐      ┌─────────┐    ┌─────────┐
│ Add auth│     │Dark mode│      │ Profiles│    │ Setup   │
│ (P:High)│     │ (P:Low) │      │(P:Medium)    │ (P:High)│
└─────────┘     └─────────┘      └─────────┘    └─────────┘

                                  Auth
                                 (P:High)
```

## 🔍 Filtering & Sorting

### Quick Filters
```
# Show only high priority
filter: priority = "High"

# Show only my items
filter: owner = @me

# Show items for sprint 1
filter: sprint = "Sprint 1"

# Show in-progress items
filter: status = "In Progress"
```

### Sorting
- By Title (alphabetical)
- By Priority (High → Medium → Low)
- By Status (custom order)
- By Date created/updated
- By Owner

## 📈 Metrics & Reports

### Sprint Reports
1. View sprint items
2. Count completed vs in-progress
3. Calculate velocity (points/sprint)

Example:
```
Sprint 1 (Jan 1-15)
- Total points: 21
- Completed: 13 points
- Velocity: 13 points/2 weeks
```

### Release Planning
```
v1.0 Release
├─ Setup & CI/CD (5 points) - Done
├─ Authentication (8 points) - In Progress
├─ User Profiles (5 points) - Backlog
└─ Dark Mode (2 points) - Backlog

Total: 20 points
Completed: 5 points (25%)
```

## 🔗 Linking Issues & PRs

### Auto-Linking
In PR description, use:
```
Closes #123
Fixes #456
Resolves #789
```

This automatically:
- Links the PR to the issue
- Closes the issue when PR merges
- Updates project status

### Manual Linking
1. Open issue/PR
2. Click **Projects** on right sidebar
3. Select the project
4. Item is added

## ⚙️ Advanced Configuration

### Automation Rules (Future)
GitHub is adding automation for:
- Auto-move items based on triggers
- Auto-assign based on labels
- Auto-close based on time

### Custom Views via API
Using GraphQL, you can:
- Fetch project data programmatically
- Create custom dashboards
- Export reports

Example:
```graphql
query {
  projectNext(first: 1) {
    projectItems(first: 10) {
      nodes {
        title
        fieldValues(first: 5) {
          nodes {
            field { name }
            value
          }
        }
      }
    }
  }
}
```

## 🎓 Best Practices

### Planning
- ✅ Estimate all items before sprint
- ✅ Set clear acceptance criteria
- ✅ Link related issues
- ❌ Don't over-commit velocity

### Execution
- ✅ Move items to "In Progress" when starting
- ✅ Update status as work progresses
- ✅ Comment on blockers immediately
- ❌ Don't let items stuck in "In Progress"

### Review & Close
- ✅ Move to "In QA" for testing
- ✅ Review before merging
- ✅ Mark "Done" only after merge
- ✅ Update metrics weekly

## 🔐 Permissions

| Role | Can Edit | Can View |
|------|----------|----------|
| Owner | ✅ All | ✅ All |
| Maintainer | ✅ Assigned items | ✅ All |
| Developer | ✅ Assigned items | ✅ All |
| Public | ❌ No | ✅ If public |

## 🆘 Troubleshooting

### Issue not appearing in project
- Check if project is linked to repo
- Refresh the page
- Try adding manually via right sidebar

### Status not updating automatically
- Check workflow logs in Actions tab
- Verify custom field names match workflows
- Test workflow manually

### Can't drag items in Kanban
- Check if you have edit permissions
- Try full refresh (Cmd+Shift+R)
- Check browser console for errors

---

Next: [Workflows Documentation](./workflows.md)
