# 🎯 GitHub Projects v2 Setup Guide for Template Repository

This guide walks you through setting up the GitHub Project Board specifically for tracking this `github-project-llm-management` template repository itself.

## 📊 Create the Project

1. Go to: https://github.com/dyvan/github-project-llm-management/projects
2. Click **New project**
3. Set **Name**: `Template Backlog`
4. Choose template: **Table** (or Board if you prefer Kanban)
5. Click **Create project**

## 🔧 Configure Custom Fields

In your new project, click **Settings** (gear icon) and add these fields:

| Field Name | Type | Options |
|-----------|------|---------|
| **Priority** | Single select | High, Medium, Low |
| **Effort** | Single select | 1, 2, 3, 5, 8 |
| **Status** | Single select | Backlog, Ready, In Progress, In Review, Done |
| **Type** | Single select | Feature, Bug, Task, Docs, Infrastructure |
| **Owner** | People | (auto-populate from assignee) |
| **Target Version** | Text | (e.g., v1.0, v1.1, etc.) |

## 📋 Create Views

### View 1: Backlog (Table)
**Purpose**: See all work items with full details

1. Click **New view** → **Table**
2. Name: `Backlog`
3. Configure columns:
   - Title
   - Type
   - Priority
   - Effort
   - Status
   - Owner
   - Target Version
4. Filter: `Status is not Done`
5. Sort: `Created date` (oldest first)

### View 2: Priority Board (Kanban)
**Purpose**: See work in progress by status

1. Click **New view** → **Board**
2. Name: `Priority Board`
3. Group by: **Status**
4. Filter: `Priority = High OR Priority = Medium`
5. Sort: `Priority` (highest first)

**Columns will appear as**:
- Backlog
- Ready
- In Progress
- In Review
- Done

### View 3: Team Items (Table)
**Purpose**: Personal view of assigned work

1. Click **New view** → **Table**
2. Name: `Team Items`
3. Configure columns:
   - Title
   - Type
   - Status
   - Due date (if available)
   - Target Version
4. Filter: `Owner = @me`
5. Sort: `Status`, then `Priority`

## 📌 Add Issues to Project

Once the project is created, issues auto-appear if they're:
- Labeled with your project's labels
- Or manually added via right-side panel

**To manually add an issue to the project**:
1. Open any issue
2. Click **Projects** on the right sidebar
3. Select `Template Backlog`
4. Issue appears in the board

## 🔄 Workflow Integration

As you work on template improvements:

| Event | Action |
|-------|--------|
| Create issue | Manually drag to **Backlog** |
| Start work | Move to **In Progress** |
| Submit PR | Move to **In Review** |
| Merge PR | Move to **Done** |

## 📊 Current Issues to Track

These issues have been pre-created and are ready to be added to your project:

1. **Enable GitHub Pages deployment** (Effort: 1, Priority: High)
   - Configure GitHub Pages for auto-deployment

2. **Setup GitHub Projects v2 for template tracking** (Effort: 2, Priority: High)
   - Create this very project board!

3. **Add support for multiple programming languages** (Effort: 8, Priority: Medium)
   - Support JavaScript, Go, Java, etc.

4. **Add Slack/Discord notification integration** (Effort: 5, Priority: Medium)
   - Notify teams of workflow events

5. **Add automated security scanning** (Effort: 5, Priority: High)
   - SAST, dependency scanning, secret detection

6. **Setup and populate GitHub Wiki** (Effort: 3, Priority: Low)
   - Create wiki pages with FAQs and guides

## 🎯 Suggested Workflow

### Phase 1: Infrastructure (High Priority)
1. ✅ Enable GitHub Pages
2. ✅ Setup this Project Board
3. Add security scanning

### Phase 2: Multi-Language Support (Medium Priority)
1. Add JavaScript/TypeScript support
2. Add Go support
3. Add Java support

### Phase 3: Integrations (Medium Priority)
1. Add Slack/Discord notifications
2. Add monitoring/metrics

### Phase 4: Community (Low Priority)
1. Setup Wiki
2. Add contribution guides

## 💡 Tips for Using the Project Board

### Velocity Tracking
Count total effort (story points) per week to calculate velocity:
```
Week 1: 13 points completed
Week 2: 18 points completed
Average velocity: ~15 points/week
```

### Sprint Planning
Group items by target version:
- v1.0: Initial release
- v1.1: Language support
- v1.2: Integrations

### Priority Matrix
Use Status + Priority to prioritize:
```
High Priority + Ready    = Start immediately
High Priority + Backlog  = Prioritize next
Medium Priority + Ready  = Start when possible
Low Priority + Backlog   = Consider for future
```

## 🔗 Related Resources

- **Issues**: https://github.com/dyvan/github-project-llm-management/issues
- **Labels**: https://github.com/dyvan/github-project-llm-management/labels
- **Actions**: https://github.com/dyvan/github-project-llm-management/actions
- **Projects**: https://github.com/dyvan/github-project-llm-management/projects

## 📞 Questions?

See the main [README.md](./README.md) for more information about the template system.

---

**Ready? Create the project board and start tracking! 🚀**
