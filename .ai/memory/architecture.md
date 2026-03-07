# Architecture

> System design, components, and data flow for the project.
> Update this file as the architecture evolves.

## Overview

Template for automated GitHub project management with AI (Gemini) integration.

## Setup Flow

```
install.sh (curl) -> bootstrap.sh -> template-setup.sh -> template/.setup/setup.sh
```

Setup runs 6 idempotent steps tracked via `.setup-state.json`:
1. Check state
2. Check prerequisites (gh CLI, git, Python)
3. Initialize labels
4. Create project board
5. Copy files (workflows, templates, scripts, commands)
6. Finalize

## Key Components

### GitHub Actions Workflows (`.github/workflows/`)
- `create-branch.yml` -- auto-create branch from issue (trigger: label `auto-branch`)
- `code-review-agent.yml` -- Gemini AI code review on PRs
- `ci-tests.yml` -- lint, tests, build on push/PR
- `deploy-docs.yml` -- deploy MkDocs to GitHub Pages
- `update-project.yml` -- sync project board on events
- `plan-with-gemini.yml` -- Gemini generates spec questionnaire
- `generate-specification.yml` -- Gemini generates detailed spec
- `auto-close-feature.yml` -- auto-close parent when sub-issues done

### Scripts (`scripts/`)
- `project_sync.py` -- sync project board via GraphQL
- `auto_close_parent_feature.py` -- check and close parent issues
- `generate_specification.py` -- generate specs from questionnaire
- `generate_qcm.py` -- generate planning questionnaire

### Setup (`template/.setup/`)
- `setup.sh` -- orchestrator for 6 setup steps
- `steps/` -- individual step scripts (1 through 6)
- `lib/` -- shared bash helpers (colors, state management)

### Documentation (`docs/`)
- MkDocs Material site deployed via GitHub Pages

## Data Flow

```
Issue created -> auto-add to project board -> label triggers branch creation
-> development -> PR -> Gemini review -> CI checks -> merge -> auto-close
```
