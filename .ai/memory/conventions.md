# Conventions

> Code style, naming patterns, and workflow conventions.
> Follow these consistently across the project.

## Branch Naming

| Type        | Pattern                                  | Example                          |
|-------------|------------------------------------------|----------------------------------|
| Feature     | `feat/{issue}-{short-description}`       | `feat/98-project-memory`         |
| Bug fix     | `fix/{issue}-{short-description}`        | `fix/124-auth-bug`               |
| Docs        | `docs/{issue}-{short-description}`       | `docs/125-api-docs`              |
| Refactor    | `refactor/{issue}-{short-description}`   | `refactor/126-simplify-queries`  |

## Commit Messages (Conventional Commits)

Format: `type(scope): description (#issue-number)`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

Rules:
- Always reference the issue: `(#123)`
- Title under 72 characters
- One commit = one logical change
- No marketing-speak in messages

## GitHub Accounts

- **dyvan**: personal account (repo owner). Use `GITHUB_TOKEN= gh ...` to target.
- **yvandtrusk**: pro account, active by default in gh CLI via GITHUB_TOKEN env var.

## Labels

Required on every issue:
- **Type**: `type:feature`, `type:bug`, `type:task`, `type:docs`, `type:infrastructure`
- **Priority**: `priority:high`, `priority:medium`, `priority:low`

Automatic via workflows:
- **Status**: `status:backlog`, `status:ready`, `status:in-progress`, `status:in-review`, `status:done`

## Story Points Scale

| Points | Meaning                    |
|--------|----------------------------|
| 1      | < 1 hour, trivial change   |
| 2      | 2-4 hours, simple change   |
| 3      | 1 day, medium change       |
| 5      | 2-3 days, complex change   |
| 8      | 1 week, very complex       |

If > 8 points, break down into multiple issues.

## Bash Scripting

- Use `VAR=$((VAR+1))` not `((VAR++))` (fails under `set -e` when VAR=0)
- Avoid `declare -A` (not portable to zsh)
- Scripts must be executable (`chmod +x`)

## File Organization

- Workflows: `.github/workflows/`
- Scripts: `scripts/`
- Setup: `template/.setup/`
- Docs: `docs/`
- AI memory: `.ai/memory/`
- Claude commands: `.claude/commands/`
