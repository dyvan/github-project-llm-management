# Architecture Overview

## 🏗️ System Design

Le système est composé de trois couches interconnectées :

```
┌─────────────────────────────────────────────────────────────┐
│                    HUMAN OVERSIGHT LAYER                     │
│              GitHub Projects v2 - Central Dashboard           │
│         (Backlog, Priority Board, Team Items Views)           │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────┼─────────────────────────────┐
│           AUTOMATION LAYER (GitHub Actions)                │
├─────────────────────────────┼─────────────────────────────┤
│  Branch Creator  │ Code Reviewer │ Test Feedback │ Update  │
│  (on: labeled)   │ (on: pr open) │ (on: push)    │ Project │
└─────────────────────────────┼─────────────────────────────┘
                              │
┌─────────────────────────────┼─────────────────────────────┐
│              DEVELOPMENT LAYER                              │
├─────────────────────────────┼─────────────────────────────┤
│  Git Repository │ Issues & PRs │ Branches │ Commits         │
└─────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow

### 1️⃣ Issue Creation
```
Developer creates issue
       ↓
Issue gets auto-labeled
       ↓
Issue appears in Project Backlog
       ↓
Developer can set Priority/Effort
```

### 2️⃣ Branch Auto-Creation
```
"auto-branch" label added
       ↓
GitHub Actions triggered
       ↓
Branch Creator Agent runs
       ↓
Branch created: feat/{number}-{title}
       ↓
Comment posted on issue
       ↓
Developer can checkout branch
```

### 3️⃣ Development & PR
```
Developer codes locally
       ↓
Push to branch
       ↓
Create Pull Request
       ↓
GitHub Actions triggered (multiple parallel)
```

### 4️⃣ PR Automation
```
CI Tests Workflow              Code Review Workflow
    ↓                                ↓
1. Install deps               1. Get PR diff
2. Lint (black, pylint)       2. Call Claude API
3. Type check (mypy)          3. Generate review
4. Run tests (pytest)         4. Post comment
5. Build                      5. Update status
6. Comment result
    ↓                                ↓
        ← Merge decision ←
```

### 5️⃣ Post-Merge
```
PR merged
     ↓
Update Project status → "Done"
     ↓
Issue linked to PR auto-closes
     ↓
Project Board reflects completion
```

## 🔄 Agent Responsibilities

### Branch Creator
- **Input** : Issue + `auto-branch` label
- **Process** : Validate → Format → Create → Comment
- **Output** : Branch created, comment posted
- **Permissions** : `contents: write`, `issues: write`

### Code Reviewer
- **Input** : PR opened/updated
- **Process** : Extract diff → Call Claude → Format → Post
- **Output** : Comment with feedback
- **Permissions** : `pull-requests: write`, `contents: read`
- **Note** : Non-blocking, informational only

### Test Feedback
- **Input** : Push to branch or PR
- **Process** : Run tests → Collect results → Report → Update project
- **Output** : Comment + status update
- **Permissions** : `contents: read`, `pull-requests: write`

## 🎯 Project Board Integration

### Fields & Views

**Custom Fields** :
- Priority: Low/Medium/High
- Effort: 1/2/3/5/8 (story points)
- Status: Backlog/In Progress/In QA/Done
- Owner: (auto from assignee)
- Sprint: (text field)
- Environment: dev/preprod/prod

**Views** :
1. **Backlog** (Table) : All issues, sortable
2. **Priority Board** (Kanban) : Grouped by status
3. **Team Items** (Table) : Filtered by owner

## 🔐 Permission Model

| Agent | Scope | Permissions | Why |
|-------|-------|-------------|-----|
| Branch Creator | Repository | write | Create branches |
| Code Reviewer | PR | read/write | Analyze code, comment |
| Test Feedback | Repository | read/write | Run tests, update status |
| Human Maintainers | All | admin | Final approval, merge |

## 🚀 Deployment Strategy

### Current (Development)
```
main/develop branch
       ↓
GitHub Pages (docs)
       ↓
Manual preprod deployment
```

### Recommended (Future)
```
develop branch (preprod)
       ↓
Test automatically
       ↓
main branch (prod)
       ↓
Tag release (v1.0.0)
       ↓
Deploy to production
```

## 📈 Scalability

### Current Capacity
- ✅ Single repo with unlimited issues
- ✅ Parallel workflow execution (GitHub Actions standard)
- ✅ Claude API calls limited by rate limits

### Growth Path
1. Add more agents (Security Scanner, Performance Profiler)
2. Multi-repo support via GitHub Organization
3. Custom webhooks for external integrations
4. GitHub App for advanced permissions

## 🔌 Integration Points

### External Services
- **Claude API** (Anthropic) : Code review
- **GitHub API** : Repository operations
- **GitHub GraphQL** : Project updates (future)

### Future Integrations
- Slack/Discord webhooks
- Jira synchronization
- Cloud deployment (AWS, GCP, Azure)
- Container registry (Docker Hub, ECR)

## 🛡️ Security Model

### Secrets Management
- All API keys in GitHub Secrets (encrypted)
- Never in git history
- Rotatable per environment

### Code Review
- Non-blocking (informational)
- No auto-merge capability
- Human approval required

### Access Control
- Branch protection rules (recommended)
- Required status checks (tests)
- Required reviews (humans)
- Dismiss stale PR reviews

## 📊 Metrics & Monitoring

### Available Metrics
- Test pass/fail rate
- Code coverage %
- Average review time
- PR merge rate
- Issue velocity (points/sprint)

### Monitoring (Future)
- Workflow execution time trends
- API cost tracking
- Performance regressions
- Security vulnerability scanning

---

See [Workflows](./workflows.md) for technical details on each workflow.
