# GitHub Project LLM Management

Template for automated GitHub project management with AI (Gemini) integration.

## Project Identity

- **Repo**: dyvan/github-project-llm-management
- **Test repo**: dyvan/projectbot-test01 (public, for E2E tests, project board #22)
- **Target repo using template**: dyvan/longtermhelp (project board #21)
- **Tech stack**: Bash (setup), Python (scripts), GitHub Actions (workflows), MkDocs Material (docs)
- **Language**: English only

## GitHub Accounts

- **dyvan**: personal account (owner). Use `GITHUB_TOKEN= gh ...` to target this account.
- **yvandtrusk**: pro account, active by default in `gh` CLI via GITHUB_TOKEN env var.

## Project Board (GraphQL IDs)

Project ID: `PVT_kwHOAX_dWc4BGnys`

| Field    | Field ID                               | Options                                                                                              |
|----------|----------------------------------------|------------------------------------------------------------------------------------------------------|
| Status   | PVTSSF_lAHOAX_dWc4BGnyszg3nS_U        | Backlog=f75ad846, Ready=61e4505c, In progress=47fc9ee4, In review=df73e18b, Done=98236657            |
| Priority | PVTSSF_lAHOAX_dWc4BGnyszg3nTXs        | P0=79628723, P1=0a877460, P2=da944a9c                                                               |
| Effort   | PVTSSF_lAHOAX_dWc4BGnyszg4oAuc        | 1=08e40e54, 2=8296128d, 3=94ddd87f, 5=61b3d099, 8=02981c20                                          |
| Type     | PVTSSF_lAHOAX_dWc4BGnyszg4oAu8        | Feature=2e5257f4, Bug=e2cd4958, Task=c7a5b589, Docs=ec266157, Infrastructure=78903647                |

## Branch and Commit Conventions

### Branches

- Features: `feat/{issue-number}-{short-description}`
- Bugs: `fix/{issue-number}-{short-description}`
- Docs: `docs/{issue-number}-{short-description}`
- Refactoring: `refactor/{issue-number}-{short-description}`

### Commits (Conventional Commits)

Format: `type(scope): description (#issue-number)`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

Rules:
- Always reference the issue number: `(#123)`
- Keep the title under 72 characters
- One commit = one logical change

## Slash Commands

Commands live in `.claude/commands/` and are invoked with `/`. Available commands:

| Command          | Description                                              |
|------------------|----------------------------------------------------------|
| /start-task      | Start working on an issue (create branch, update board)  |
| /finish-task     | Open a PR and move issue to In Review                    |
| /task-status     | Show current task status and board state                 |
| /save-session    | Save session context to issue comment                    |
| /load-session    | Restore context from a previous session                  |
| /sprint-report   | Generate a sprint progress report                        |
| /plan-task       | Break down a feature into sub-tasks                      |
| /next-task       | Pick the next task from Ready queue (P1 + milestone)     |

## GitHub Actions Workflows

| Workflow                     | Trigger                          | Purpose                              |
|------------------------------|----------------------------------|--------------------------------------|
| create-branch.yml            | Label `auto-branch`              | Auto-create branch from issue        |
| code-review-agent.yml        | PR opened/synced                 | Gemini AI code review                |
| ci-tests.yml                 | Push to main or PR               | Lint, tests, build                   |
| deploy-docs.yml              | Push to main with docs/ changes  | Deploy MkDocs to GitHub Pages        |
| update-project.yml           | Push, PR, issue events           | Sync project board                   |
| plan-with-gemini.yml         | Label `plan-with-gemini`         | Gemini generates spec questionnaire  |
| generate-specification.yml   | Label `generate-specification`   | Gemini generates detailed spec       |
| auto-close-feature.yml       | PR merged with `Closes #X`       | Auto-close parent when subs done     |
| auto-add-to-project.yml      | Issue/PR created                 | Auto-add items to project board      |

## Setup and Architecture

Install flow: `install.sh` (curl) -> `bootstrap.sh` -> `template-setup.sh` -> `template/.setup/setup.sh` (6 steps)

Setup is idempotent via `.setup-state.json`.

Key directories:
- `template/.setup/` -- setup scripts and steps (1 through 6)
- `template/.setup/lib/` -- shared bash helpers (colors, state)
- `scripts/` -- Python scripts (project_sync, dashboard, velocity, etc.)
- `.github/workflows/` -- all CI/CD and automation workflows
- `docs/` -- MkDocs Material documentation site

## Labels

**Type** (required): `type:feature`, `type:bug`, `type:task`, `type:docs`, `type:infrastructure`
**Status**: `status:backlog`, `status:ready`, `status:in-progress`, `status:in-review`, `status:blocked`, `status:done`
**Priority**: `priority:high`, `priority:medium`, `priority:low`
**Special**: `auto-branch`, `plan-with-gemini`, `generate-specification`

## Key Decisions

- All AI workflows use Gemini (opt-in, not required)
- Per-workflow API keys with fallback: GEMINI_PLAN_API_KEY, GEMINI_SPEC_API_KEY, GEMINI_REVIEW_API_KEY -> fallback GEMINI_API_KEY
- Template evolving toward Claude Code plugin packaging (#107)
- Slash commands replace inline workflow tutorials (#106)
- `setup-project-fields.py` is dead code (GitHub API cannot create custom fields) -- to remove (#103)

## Secrets

Required in Settings -> Secrets and variables -> Actions:
- `GH_TOKEN`: GitHub PAT (scopes: repo, workflow, read:org, project)
- `GEMINI_API_KEY`: Google Gemini API key (optional, for AI workflows)
- `TEST_BOT_TOKEN`: For E2E tests (uses dyvan-bot account)
