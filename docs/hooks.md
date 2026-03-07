# Claude Code Hooks

Pre-configured hooks that automate context loading and project management updates.

## Available Hooks

| Hook | File | Trigger | Purpose |
|------|------|---------|---------|
| Pre-commit check | `pre-commit-check.sh` | Before `git commit` | Validates commit message references an issue (#NNN) |
| Post-commit update | `post-commit-update.sh` | After `git commit` | Logs referenced issue numbers |
| Session start | `session-start.sh` | Session notification | Loads saved state from `.ai/session-state.md` |
| Session end | `session-end.sh` | Session stop | Saves branch, commit, and timestamp to `.ai/session-state.md` |

## How to Enable

1. Copy the template settings file to your project:
   ```bash
   cp template/config/claude-settings.json .claude/settings.json
   ```

2. Make hook scripts executable:
   ```bash
   chmod +x .claude/hooks/*.sh
   ```

3. Restart Claude Code to pick up the new settings.

## How to Customize

- Edit `.claude/settings.json` to add, remove, or change hook bindings.
- Edit scripts in `.claude/hooks/` to modify behavior.
- The `matcher` field in settings controls which tool invocations trigger the hook.
  Use `""` to match all invocations, or a pattern like `Bash(git commit:*)` for specific ones.

## Hook Types

- **PreToolUse**: Runs before a tool call. Exit non-zero to block the call.
- **PostToolUse**: Runs after a tool call completes.
- **Notification**: Runs on session notifications.
- **Stop**: Runs when the session ends.

## Notes

- Hooks receive JSON on stdin with tool name, input, and output.
- Keep hooks fast (under 1 second) to avoid slowing down the workflow.
- The `.ai/` directory is used for session state and should be added to `.gitignore`.
