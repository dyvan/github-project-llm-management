# GitHub Project LLM Management

[![Template Validation](https://github.com/dyvan/github-project-llm-management/actions/workflows/template-validation.yml/badge.svg)](https://github.com/dyvan/github-project-llm-management/actions/workflows/template-validation.yml)
[![CI Tests](https://github.com/dyvan/github-project-llm-management/actions/workflows/ci-tests.yml/badge.svg)](https://github.com/dyvan/github-project-llm-management/actions/workflows/ci-tests.yml)

**Automated GitHub project management for AI-powered development teams.**
Slash commands + PM agent + Kanban automation + AI code review + Plugin packaging

---

## Quick Start

### New project (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash
```

### Existing clone

```bash
git clone https://github.com/dyvan/github-project-llm-management.git my-project
cd my-project
bash template-setup.sh
```

`template-setup.sh` is the single entry point. It creates `.env` interactively if missing, validates prerequisites (gh CLI, Python, git), sets up labels, project board, workflows, and issue templates. Idempotent -- safe to run multiple times.

---

## Features

| Feature | Description |
|---------|-------------|
| **8 Slash Commands** | `/start-task`, `/finish-task`, `/next-task`, `/plan-task`, `/task-status`, `/sprint-report`, `/save-session`, `/load-session` |
| **PM Agent** | Sprint planning, backlog grooming, retrospectives, health checks |
| **Auto Project Board** | Issues flow through Kanban (Backlog -> Ready -> In Progress -> In Review -> Done) automatically |
| **AI Code Review** | Gemini analyzes PRs (opt-in, needs API key) |
| **Project Memory** | `.ai/memory/` persists context across AI sessions |
| **Hooks** | Pre-commit checks, session save/load, board updates |
| **Plugin** | Install as Claude Code plugin with all commands bundled |
| **Wiki Templates** | Shared knowledge base for team context |

---

## GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `create-branch.yml` | Label `auto-branch` | Auto-create branch from issue |
| `code-review-agent.yml` | PR opened/synced | Gemini AI code review |
| `ci-tests.yml` | Push to main or PR | Lint, tests, build |
| `deploy-docs.yml` | Push with `docs/` changes | Deploy MkDocs to GitHub Pages |
| `update-project.yml` | Push, PR, issue events | Sync project board |
| `plan-with-gemini.yml` | Label `plan-with-gemini` | Generate spec questionnaire |
| `generate-specification.yml` | Label `generate-specification` | Generate detailed spec |
| `auto-close-feature.yml` | PR merged with `Closes #X` | Auto-close parent when subs done |

---

## Project Structure

```
.claude/commands/    -- Slash commands for Claude Code
.github/workflows/   -- CI/CD and automation workflows
template/.setup/     -- Setup scripts (6 idempotent steps)
scripts/             -- Python scripts (project sync, dashboard, velocity)
docs/                -- MkDocs Material documentation site
```

---

## Configuration

### Required secrets (Settings -> Secrets -> Actions)

- `GH_TOKEN` -- GitHub PAT (scopes: `repo`, `workflow`, `read:org`, `project`)

### Optional secrets (for AI features)

- `GEMINI_API_KEY` -- Google Gemini API key (enables code review, planning, spec generation)
- `GEMINI_PLAN_API_KEY`, `GEMINI_SPEC_API_KEY`, `GEMINI_REVIEW_API_KEY` -- Per-workflow keys (fall back to `GEMINI_API_KEY`)

---

## Testing

```bash
python3 -m pytest tests/ -v
```

---

## Documentation

Full documentation: **[dyvan.github.io/github-project-llm-management](https://dyvan.github.io/github-project-llm-management/)**

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines. Issues labeled `good-first-issue` are a great starting point.

---

## License

MIT License -- see [LICENSE](./LICENSE) for details.
