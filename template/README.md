# 📦 GitHub Project Management Template

This directory contains **everything needed** to manage a project with GitHub Projects v2, automations, and LLM integration.

> **⚠️ Users should NEVER need to touch these files directly.**
> Everything is configured via `bash template-setup.sh` at the project root.

---

## 📂 Structure

```
template/
├── .setup/                 # Setup and state management
│   ├── setup.sh           # Main orchestration script (idempotent)
│   ├── .setup-state.json  # Setup state (gitignored)
│   ├── lib/               # Shared utilities
│   │   ├── colors.sh
│   │   ├── state.sh
│   │   ├── validators.sh
│   │   └── github-api.sh
│   └── steps/             # Modular setup steps
│       ├── 1-check-state.sh
│       ├── 2-check-prerequisites.sh
│       ├── 3-init-labels.sh
│       ├── 4-create-project.sh
│       ├── 5-link-workflows.sh
│       └── 6-finalize.sh
│
├── .github/               # GitHub Workflows & Templates
│   ├── workflows/         # GitHub Actions workflows
│   │   ├── create-branch.yml
│   │   ├── code-review-agent.yml
│   │   ├── ci-tests.yml
│   │   └── ...
│   ├── ISSUE_TEMPLATE/    # Issue templates
│   │   ├── bug.md
│   │   ├── feature.md
│   │   └── task.md
│   └── PULL_REQUEST_TEMPLATE.md
│
├── config/                # Configuration files
│   ├── labels.json        # Label definitions
│   └── project-fields.json # Custom Project fields
│
├── scripts/               # Optional utilities
│   ├── setup_project_fields.py
│   ├── project_sync.py
│   ├── generate_dashboard.py
│   └── velocity_calculator.py
│
├── docs/                  # Template documentation
│   ├── WORKFLOWS.md
│   ├── TROUBLESHOOTING.md
│   └── ADVANCED.md
│
└── README.md             # This file
```

---

## 🔧 Idempotence & State Management

### How it works

The setup script is **fully idempotent**. On each run:

1. ✅ Checks state saved in `.setup-state.json`
2. ✅ Skips already-completed steps
3. ✅ Only updates what is missing
4. ✅ Can be safely re-run, even after a successful setup

### State file

```json
{
  "version": "1.0",
  "setup_started_at": "2025-11-13T10:30:00Z",
  "setup_completed_at": "2025-11-13T10:35:00Z",
  "steps": {
    "check_prerequisites": true,
    "init_labels": true,
    "create_project": true,
    "setup_fields": true,
    "link_workflows": true,
    "create_symlinks": true,
    "setup_complete": true
  },
  "configuration": {
    "repo_owner": "dyvan",
    "repo_name": "my-project",
    "project_number": 1
  },
  "errors": []
}
```

This file is **gitignored** and is only created in the user's repository, never in the template.

---

## 🚀 Setup Flow

### 1. User Launches the Setup

```bash
cd my-project
bash template-setup.sh
```

### 2. Root Script Validates Prerequisites

- ✅ GitHub CLI (gh) installed and authenticated
- ✅ Python 3.8+
- ✅ Git repository
- ✅ GitHub remote

### 3. Orchestrates Steps (idempotent)

```bash
template/.setup/setup.sh
├── 1-check-state.sh              # Checks if setup is complete
├── 2-check-prerequisites.sh      # Validates gh, python, git
├── 3-init-labels.sh              # Creates labels (skips if they exist)
├── 4-create-project.sh           # Creates Project v2 (skips if it exists)
├── 5-link-workflows.sh           # Creates symlinks to template/.github/
└── 6-finalize.sh                 # Displays summary
```

### 4. Final Result

In the user's repo:

```
.github/
├── workflows/              → symlink to template/.github/workflows
├── ISSUE_TEMPLATE/         → symlink to template/.github/ISSUE_TEMPLATE
└── PULL_REQUEST_TEMPLATE.md → symlink to template/.github/...

.setup/
└── .setup-state.json       # Setup state (gitignored)

CLAUDE.md                    # Instructions for LLM
.env                         # Secrets & config (gitignored)
```

---

## 🤖 LLM Integration (CLAUDE.md)

The `CLAUDE.md` file at the root of the user's project contains:

1. **Project state**: read from `.setup-state.json`
2. **Conventions**: branches, commits, issues
3. **Standard labels**: with descriptions
4. **Available workflows**: with triggers
5. **LLM capabilities**: what to do to manage the project
6. **Examples**: typical use cases

The LLM can then:
- ✅ Read the project state
- ✅ Create/update issues
- ✅ Make conventional commits
- ✅ Open PRs with proper templates
- ✅ Manage the board across sessions

---

## 📝 Configuration

### labels.json

Defines the 17 standard labels:

- **Type**: `feature`, `bug`, `task`, `docs`, `infrastructure`
- **Priority**: `high`, `medium`, `low`
- **Status**: `backlog`, `ready`, `in-progress`, `in-review`, `blocked`, `done`
- **Utility**: `good-first-issue`, `help-wanted`, `auto-branch`

### project-fields.json

Custom Project fields:

- **Status**: Backlog, Ready, In Progress, In Review, Done, Blocked
- **Priority**: High, Medium, Low
- **Effort**: 1, 2, 3, 5, 8 (story points)
- **Sprint**: free text (optional)

---

## 🔗 Symlinks: Always Up to Date

Workflows and templates are symlinked to `template/.github/`:

```bash
.github/workflows/          → template/.github/workflows
.github/ISSUE_TEMPLATE/     → template/.github/ISSUE_TEMPLATE
```

**Benefits**:
- ✅ Updating the template = automatic update
- ✅ Zero duplication
- ✅ Single place to maintain
- ✅ Easy to override (remove symlink, create local version)

---

## 🛠️ Utility Scripts

### setup_project_fields.py

Configures custom Project v2 fields (via GraphQL):

```bash
python3 scripts/setup_project_fields.py --project-number 1 --owner dyvan
```

### project_sync.py

Synchronizes the Project Board with issues/PRs:

```bash
python3 scripts/project_sync.py --sync-all
```

### generate_dashboard.py

Generates a progress dashboard:

```bash
python3 scripts/generate_dashboard.py --format json --output report.json
```

### velocity_calculator.py

Calculates team velocity:

```bash
python3 scripts/velocity_calculator.py --weeks 4
```

---

## 📖 Additional Documentation

- **[WORKFLOWS.md](./docs/WORKFLOWS.md)** - Automation details
- **[TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)** - Troubleshooting
- **[ADVANCED.md](./docs/ADVANCED.md)** - Customization

---

## ❓ Template Maintenance

### For template contributors

If you are improving the template:

1. ✅ Edit files in `template/`
2. ✅ Test with `bash template-setup.sh --dry-run`
3. ✅ Re-run 2-3 times to test idempotence
4. ✅ Commit your changes
5. ✅ Create a PR

### Entry points

- **Root script**: `../template-setup.sh` (copy this logic if needed)
- **Main setup**: `.setup/setup.sh`
- **Steps**: `.setup/steps/*.sh` (add steps here)
- **Libraries**: `.setup/lib/*.sh` (shared utilities)

---

## 🎯 Design Principles

### Simplicity for the User

```bash
# This is ALL the user needs to do
bash template-setup.sh

# That's it.
```

### Complexity Hidden in the Template

- Modular and testable setup
- Guaranteed idempotence
- Detailed logging
- Persistent state

### LLM-First

- Queryable state via `.setup-state.json`
- Clear conventions in `CLAUDE.md`
- Explicitly listed capabilities
- Examples provided

---

**This structure enables a professional-grade template while remaining simple for users.**
