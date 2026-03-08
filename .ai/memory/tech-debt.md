# Tech Debt

> Known issues, shortcuts, and things to fix.
> Add items with a date and link to the tracking issue when one exists.

## Active Tech Debt

### update-project.yml is oversized (2025-11)
- **Issue**: #105
- **Problem**: 302 lines, too many triggers, fails silently without project scope token.
- **Impact**: Hard to maintain, difficult to debug failures.
- **Fix**: Simplify triggers and split into focused workflows.

### Longtermhelp has token in git remote URL (2026-03)
- **Problem**: Security risk -- token visible in `.git/config`.
- **Impact**: Token could be leaked if config is shared.
- **Fix**: Use credential helper or SSH instead.

## Bash Pitfalls

### `((VAR++))` fails under `set -e` when VAR=0
- **Workaround**: Use `VAR=$((VAR+1))` instead.
- **Affected files**: Any bash script using arithmetic increment.

### zsh incompatibility with `declare -A`
- **Workaround**: Use explicit variables instead of associative arrays.
- **Affected**: Setup scripts that might run under zsh.

## Resolved

- **setup_project_fields.py** -- removed (dead code, #103)
